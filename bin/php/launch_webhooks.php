<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("OpenPA Agenda launch webhhoks \n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$script->startup();
$options = $script->getOptions();

$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

try {
    /** @var eZUser $user */
    $user = eZUser::fetchByName('admin');
    eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));
    $class = eZContentClass::fetchByIdentifier('event');
    if (!$class instanceof eZContentClass) {
        throw new Exception("Class event not found");
    }
    $events = eZPersistentObject::fetchObjectList(
        eZContentObject::definition(),
        ['id'],
        ['contentclass_id' => $class->attribute('id')],
        null,
        null,
        false
    );

    $errors = [];
    $count = count($events);
    if ($events > 0) {
        $output = new ezcConsoleOutput();
        $progressBarOptions = ['emptyChar' => ' ', 'barChar' => '='];
        $progressBar = new ezcConsoleProgressbar($output, $count, $progressBarOptions);
        $progressBar->start();
        foreach ($events as $event) {
            try {
                $post = OCEditorialStuffHandler::instance('agenda')->fetchByObjectId((int)$event['id']);
                if ($post instanceof AgendaItem) {
                    $post->launchWebhooks();
                }
            }catch (Throwable $e){
                $errors[] = $e->getMessage();
            }
            $progressBar->advance();
        }
        $progressBar->finish();
    }

    $cli->output();
    foreach ($errors as $error){
        $cli->output($error);
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
