<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Set event link webhooks"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);
$script->startup();
$options = $script->getOptions(
    '[target:][agenda:]',
    '',
    [
        'target' => 'Target identifier (example: opencitybuglianoqa)',
        'agenda' => 'Override agenda host (example: agenda.localtest.me/)'
    ]
);
$script->initialize();
$script->setUseDebugAccumulators(true);

function setAccess($identifier, $env = 'backend')
{
    $accessName = $identifier . '_' . $env;
    if (!file_exists('settings/siteaccess/' . $accessName)) {
        throw new InvalidArgumentException("Siteaccess $accessName not found");
    }
    $access = eZSiteAccess::change([
        'name' => $accessName,
        'type' => eZSiteAccess::TYPE_STATIC,
    ]);
    eZINI::resetAllInstances(false);
    unset($GLOBALS['eZDBGlobalInstance']);
    return $identifier;
}

function ask($question)
{
    $output = new ezcConsoleOutput();
    $opts = new ezcConsoleQuestionDialogOptions();
    $opts->text = $question;
    $opts->showResults = true;
    $opts->validator = new ezcConsoleQuestionDialogTypeValidator(ezcConsoleQuestionDialogTypeValidator::TYPE_STRING);
    $question = new ezcConsoleQuestionDialog($output, $opts);
    return ezcConsoleDialogViewer::displayDialog($question);
}

function issueInternalJWTToken(eZUser $user): string
{
    $issuer = OpenPABase::getCurrentSiteaccessIdentifier();
    $tokenTTL = 60*60*24*365;
    $now = time();
    /** @var eZContentObject[] $groups */
    $groups = $user->groups(true);
    $allowedRoles = [];
    foreach ($groups as $group) {
        $allowedRoles[] = eZCharTransform::instance()
            ->transformByGroup($group->attribute('name'), 'identifier');
    }

    $payload = [
        "iss" => 'opencity',
        "aud" => 'opencity',
        "iat" => $now,
        "nbf" => $now,
        "exp" => $now + $tokenTTL,
        "uid" => $user->id(),
        "name" => $user->attribute('contentobject')->attribute('name'),
        "username" => $user->attribute('login'),
        "email" => $user->attribute('email'),
        "email_verified" => true,
        "opencity-claims" => [
            "allowed-roles" => $allowedRoles,
            "default-role" => $user->attribute('contentobject')->attribute('class_identifier'),
            "user-id" => $user->id(),
            "tenant" => $issuer,
        ],
    ];

    $privateKey = file_get_contents(eZSys::rootDir() . '/../jwt/private.key.pem');
    $jwt = \Firebase\JWT\JWT::encode($payload, $privateKey, 'RS256');

    return $jwt;
}

function fetchWebhooksByTrigger($triggerIdentifier)
{
    $db = eZDB::instance();
    $triggerIdentifier = $db->escapeString($triggerIdentifier);
    $res = $db->arrayQuery(
        "SELECT webhook_id FROM ocwebhook_trigger_link WHERE trigger_identifier = '$triggerIdentifier' ORDER BY webhook_id ASC"
    );
    $idList = array_column($res, 'webhook_id');
    if (!empty($idList)) {
        $webhookList = OCWebHook::fetchObjectList(OCWebHook::definition(), null, [
            'id' => [$idList],
        ]);
    } else {
        $webhookList = [];
    }

    return $webhookList;
}

$cli = eZCLI::instance();
$currentIdentifier = OpenPABase::getCurrentSiteaccessIdentifier();
$agendaUrl = $options['agenda'] ??
    eZSiteAccess::getIni($currentIdentifier . '_agenda')->variable('SiteSettings', 'SiteURL');
$agendaUrl = 'https://' . $agendaUrl;

$targetIdentifier = setAccess($options['target'] ?? ask('Insert target site identifier'), 'frontend');

$cli->output('Check target class: ', false);
if (!eZContentClass::fetchByIdentifier('event_link') instanceof eZContentClass) {
    $cli->error('FAIL');
    $script->shutdown(1);
} else {
    $cli->output('OK');
}
$cli->output('Check target user: ', false);
$user = eZContentObject::fetchByRemoteID('openagendabot');
try {
    if ($user instanceof eZContentObject) {
        $token = issueInternalJWTToken(eZUser::fetch((int)$user->attribute('id')));
        $cli->output('OK');
    } else {
        throw new Exception('User not found');
    }
} catch (Throwable $e) {
    $cli->error('FAIL ' . $e->getMessage());
    $script->shutdown(1);
}
$targetNode = eZContentObject::fetchByRemoteID('all-events')->mainNodeID();
$siteUrl = eZINI::instance()->variable('SiteSettings', 'SiteURL');
$cli->output('Check openagenda url: ', false);
$currentAgendaUrl = OpenAgendaBridge::factory()->getOpenAgendaUrl();
if ($currentAgendaUrl !== $agendaUrl) {
    OpenAgendaBridge::factory()->setOpenAgendaUrl($agendaUrl);
    $cli->warning("REPLACE $currentAgendaUrl WITH $agendaUrl");
} else {
    $cli->output('OK');
}


setAccess($currentIdentifier);
$currentHostsByTrigger = [];
$publishList = fetchWebhooksByTrigger(OpenAgendaPublishEventLinkWebHookTrigger::IDENTIFIER);
$deleteList = fetchWebhooksByTrigger(OpenAgendaDeleteEventLinkWebHookTrigger::IDENTIFIER);
$cli->output('Current webhooks:');
foreach (array_merge($publishList, $deleteList) as $webhook) {
    $targetHost = parse_url($webhook->attribute('url'), PHP_URL_HOST);
    $headers = (array)json_decode($webhook->attribute('headers'), true);
    if (isset($headers['Host'])) {
        $targetHost = $headers['Host'];
    }
    $triggers = [];
    /** @var OCWebHookTriggerInterface $trigger */
    foreach ($webhook->getTriggers() as $trigger) {
        $triggers[] = $trigger['identifier'];
        $currentHostsByTrigger[$trigger['identifier']][$targetHost] = $webhook->attribute('id');
    }
    $triggers = implode(', ', $triggers);
    $cli->output(' - ' . $webhook->attribute('name') . ' ' . $triggers . ' -> ' . $targetHost);
}


foreach ($currentHostsByTrigger as $trigger => $hostAndId) {
    $headers = json_encode([
        'Host' => $siteUrl,
        'X-Target-Node' => $targetNode,
        'Authorization' => "Bearer $token",
    ]);
    if (!isset($hostAndId[$siteUrl])) {
        $cli->warning("Add $trigger webhook to $siteUrl");
        $webHook = new OCWebHook([]);
        $webHook->setAttribute(
            'name',
            $trigger === OpenAgendaPublishEventLinkWebHookTrigger::IDENTIFIER ? 'Publish event link' : 'Delete event link'
        );
        $webHook->setAttribute('url', 'http://localhost/api/opendata/v2/content/upsert');
        $webHook->setAttribute('method', 'POST');
        $webHook->setAttribute('enabled', 1);
        $webHook->setAttribute('retry_enabled', 1);
        $webHook->setAttribute('headers', $headers);
        $webHook->store();
        $webHook->setTriggers([
            'identifier' => $trigger,
        ]);
    } else {
        $cli->warning("Refresh $trigger webhook to $siteUrl #" . $hostAndId[$siteUrl]);
        $webHook = OCWebHook::fetch((int)$hostAndId[$siteUrl]);
        $webHook->setAttribute('headers', $headers);
        $webHook->store();
    }
}

$script->shutdown();
