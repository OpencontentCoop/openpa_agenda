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
    $redirect = '/';
    if (OpenPAAgenda::instance()->isSiteRoot()) {
        $node = eZContentObjectTreeNode::fetch(OpenPAAgenda::calendarNodeId());
        $redirect = $node->attribute('url_alias');
    }

    $module->redirectTo($redirect);
}
