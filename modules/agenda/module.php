<?php
$Module = array('name' => 'Agenda');

$ViewList = array();
$ViewList['home'] = array(
    'script' => 'home.php',
    'functions' => array('use')
);

$ViewList['info'] = array(
    'script' => 'info.php',
    'params' => array('Page'),
    'functions' => array('use')
);

$ViewList['event'] = array(
    'script' => 'event.php',
    'params' => array('NodeId'),
    'functions' => array('use')
);

$ViewList['config'] = array(
    'script' => 'config.php',
    'functions' => array('config')
);

$FunctionList = array();
$FunctionList['use'] = array();
$FunctionList['config'] = array();