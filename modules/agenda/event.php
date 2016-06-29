<?php
/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$NodeId = $Params['NodeId'];

if ( is_numeric( $NodeId ) && OpenPAAgenda::instance()->checkAccess($NodeId))
{
    $contentModule = eZModule::exists( 'content' );
    return $contentModule->run(
        'view',
        array( 'full', $NodeId )
    );
}
else
{
    $module->redirectTo('/');
}