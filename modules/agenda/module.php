<?php
$Module = array('name' => 'Agenda');

$ViewList = array();
$ViewList['home'] = array(
    'script' => 'home.php',
    'functions' => array('use')
);

$ViewList['view'] = array(
    'script' => 'view.php',
    'params' => array('Calendar'),
    'functions' => array('use')
);

$ViewList['add'] = array(
    'script' => 'add.php',
    'params' => array('Class'),
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

$ViewList['image'] = array(
    'script' => 'image.php',
    'params' => array('ObjectId'),
    'functions' => array('use')
);

$ViewList['config'] = array(
    'script' => 'config.php',
    'params' => array("Part"),
    'unordered_params' => array('offset' => 'Offset'),
    'functions' => array('config')
);

$ViewList['comment'] = array(
    'script' =>	'comment.php',
    'params' => array( 'ForumID', 'ForumReplyID' ),
    'functions' => array( 'use' )
);

$ViewList['associazioni'] = array(
    'script' => 'associazioni.php',
    'params' => array('NodeId'),
    'functions' => array('use')
);

$ViewList['qrcode'] = array(
    'script' => 'qrcode.php',
    'params' => array('NodeId'),
    'functions' => array('qrcode')
);

$ViewList['download'] = array(
    'script' => 'download.php',
    'params' => array('Params'),
    'functions' => array('download')
);

$ViewList['push'] = array(
    'script' => 'push.php',
    'params' => array('NodeId'),
    'functions' => array('push')
);

$ViewList['widget'] = array(
    'script' => 'widget.php',
    'params' => array('WidgetId'),
    'functions' => array('use')
);


$FunctionList = array();
$FunctionList['use'] = array();
$FunctionList['config'] = array();
$FunctionList['qrcode'] = array();
$FunctionList['download'] = array();
$FunctionList['push'] = array();
