<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\Exception\EnvironmentForbiddenException;
use Opencontent\Opendata\Api\Exception\EnvironmentMisconfigurationException;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAAgendaEventEmitter
{
    public static function triggerPublishEvent(OCEditorialStuffPostInterface $post)
    {
        self::trigger(OpenAgendaPublishEventWebHookTrigger::IDENTIFIER, $post, 'extraindex');
        self::trigger(OpenAgendaPublishUpdateEventWebHookTrigger::IDENTIFIER, $post, 'ocopendata');
        self::trigger(OpenAgendaPublishEventLinkWebHookTrigger::IDENTIFIER, $post, 'event_placeholder');
    }

    public static function triggerDeleteEvent(OCEditorialStuffPostInterface $post)
    {
        self::trigger(OpenAgendaDeleteEventWebHookTrigger::IDENTIFIER, $post, 'extraindex');
        self::trigger(OpenAgendaPublishUpdateEventWebHookTrigger::IDENTIFIER, $post, 'ocopendata');
        self::trigger(OpenAgendaDeleteEventLinkWebHookTrigger::IDENTIFIER, $post, 'event_placeholder');
    }

    private static function trigger($event, $post, $payloadFormat)
    {
        $webHooks = OCWebHook::fetchEnabledListByTrigger($event);
        if (count($webHooks) === 0) {
            return;
        }

        $payloads = self::getPayload($post, $payloadFormat);
        if (is_array($payloads)) {
            foreach ($payloads as $payload) {
                if (!self::isPendingByTrigger($event, $payload)) {
                    self::removeReversePending($event, $payload);
                    OCWebHookEmitter::emit(
                        $event,
                        $payload,
                        OCWebHookQueue::defaultHandler()
                    );
                }
            }
        }
    }

    private static function isPendingByTrigger($triggerIdentifier, $payload): bool
    {
        return (int)OCWebHookJob::count(OCWebHookJob::definition(), [
            'execution_status' => [[
                OCWebHookJob::STATUS_PENDING,
                OCWebHookJob::STATUS_RETRYING
            ]],
            'trigger_identifier' => $triggerIdentifier,
            'payload' => OCWebHookJob::encodePayload($payload),
        ]) > 0;
    }

    private static function removeReversePending($triggerIdentifier, $payload): void
    {
        $reverseTriggerIdentifier = false;
        if ($triggerIdentifier === OpenAgendaPublishEventLinkWebHookTrigger::IDENTIFIER) {
            $reverseTriggerIdentifier = OpenAgendaDeleteEventLinkWebHookTrigger::IDENTIFIER;
        }elseif ($triggerIdentifier === OpenAgendaDeleteEventLinkWebHookTrigger::IDENTIFIER){
            $reverseTriggerIdentifier = OpenAgendaPublishEventLinkWebHookTrigger::IDENTIFIER;
        }
        if ($reverseTriggerIdentifier) {
            OCWebHookJob::removeObject(OCWebHookJob::definition(), [
                'execution_status' => [[
                    OCWebHookJob::STATUS_PENDING,
                    OCWebHookJob::STATUS_RETRYING
                ]],
                'trigger_identifier' => $reverseTriggerIdentifier,
                'payload' => OCWebHookJob::encodePayload($payload),
            ]);
        }
    }

    /**
     * @param OCEditorialStuffPost|AgendaItem $post
     * @param $format
     * @return array|false
     */
    private static function getPayload(OCEditorialStuffPostInterface $post, $format)
    {
        try {
            if ($format === 'ocopendata') {
                $content = Content::createFromEzContentObject($post->getObject());
                try {
                    $environment = EnvironmentLoader::loadPreset('content');
                    return [$environment->filterContent($content)];
                } catch (Throwable $e) {
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    return false;
                }
            } else {
                return [json_encode($post->id())];
            }
        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return false;
    }
}
