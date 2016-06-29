<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();

$currentUser = eZUser::currentUser();

$root = OpenPAAgenda::instance()->rootNode();

$tpl->setVariable( 'root', $root );
$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'persistent_variable', array() );

$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['content'] = $tpl->fetch( 'design:agenda/config.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'agenda/config' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false )
{
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array();