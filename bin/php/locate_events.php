<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "OpenPA Agenda Locate events \n\n" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();

$script->startup();
$options = $script->getOptions(
    '[subtree:]',
    '',
    array( 'subtree'  => 'subtree node id (default 1)')
);

$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

OpenPALog::setOutputLevel( OpenPALog::ALL );

try
{
    $subtree = (int)$options['subtree'];
    if ($subtree == 0){
        $subtree = 1;
    }
    /** @var eZUser $user */
    $user = eZUser::fetchByName( 'admin' );
    eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

    /** @var eZContentObjectTreeNode[] $events */
    $events = eZContentObjectTreeNode::subTreeByNodeID(array(
        'ClassFilterType' => 'include',
        'ClassFilterArray' => array('event')
    ),$subtree);

    foreach($events as $event){
        $cli->warning("Add assignment to " . $event->attribute('name'));
        $mainNodeID = $event->attribute('main_node_id');
        $objectId = $event->attribute('contentobject_id');
        $targetNodeId = OpenPAAgenda::calendarNodeId();
        eZContentOperationCollection::addAssignment( $mainNodeID, $objectId, array($targetNodeId) );
    }

    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}
