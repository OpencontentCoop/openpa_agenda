<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "Make private all private organizations \n\n" ),
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

    /** @var eZContentObjectTreeNode[] $organizations */
    $organizations = eZContentObjectTreeNode::subTreeByNodeID(array(
        'ClassFilterType' => 'include',
        'ClassFilterArray' => array('private_organization')
    ),OpenPAAgenda::associationsNodeId());

    $stateGroup = eZContentObjectStateGroup::fetchByIdentifier('privacy');
    $state = eZContentObjectState::fetchByIdentifier('private', $stateGroup->attribute('id'));

    foreach($organizations as $organization){
        $cli->warning("Make private " . $organization->attribute('name'));
        $object = $organization->object();
        $object->assignState($state);
        eZSearch::updateObjectState($object->attribute('id'), [$state->attribute('id')]);
        eZContentCacheManager::clearContentCacheIfNeeded($object->attribute('id'));
    }

    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}
