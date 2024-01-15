<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Get version\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

/** @var eZUser $user */
$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

OpenAgendaTopicMapper::migrateAgendaTopicNames($options['verbose']);

$script->shutdown();
