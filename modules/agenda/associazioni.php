<?php
/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$NodeId = $Params['NodeId'];

if ( is_numeric( $NodeId ) )
{
    $contentModule = eZModule::exists( 'content' );
    return $contentModule->run(
        'view',
        array( 'full', $NodeId )
    );
}
else
{
    $currentUser = eZUser::currentUser();

    $tpl = eZTemplate::factory();
    $tpl->setVariable('current_user', $currentUser);
    $tpl->setVariable('persistent_variable', array());

    $Result = array();
    $Result['persistent_variable'] = $tpl->variable('persistent_variable');
    $Result['content'] = $tpl->fetch('design:agenda/associazioni.tpl');
    $Result['node_id'] = 0;

    $contentInfoArray = array('url_alias' => 'agenda/associazioni');
    $contentInfoArray['persistent_variable'] = array();
    if ($tpl->variable('persistent_variable') !== false) {
        $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
    }
    $Result['content_info'] = $contentInfoArray;
    $Result['path'] = array();
}