<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "OpenPA Agenda Locate Organizations \n\n" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();

$script->startup();
$options = $script->getOptions();

$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

OpenPALog::setOutputLevel( OpenPALog::ALL );

try
{
    /** @var eZUser $user */
    $user = eZUser::fetchByName( 'admin' );
    eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

    /** @var eZContentObjectTreeNode[] $associazioni */
    $associazioni = eZContentObjectTreeNode::subTreeByNodeID(array(
        'ClassFilterType' => 'include',
        'ClassFilterArray' => array('associazione')
    ),1);

    foreach($associazioni as $associazione){
        $cli->warning("Add assignment to " . $associazione->attribute('name'));
        $mainNodeID = $associazione->attribute('main_node_id');
        $objectId = $associazione->attribute('contentobject_id');
        $targetNodeId = OpenPAAgenda::associationsNodeId();
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
