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

OpenAgendaTopicMapper::migrateAgendaTopicNames($options['verbose']);

$script->shutdown();
