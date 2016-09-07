<?php

/*
 * php extension/openpa_agenda/bin/php/collocate_objects.php --class=associazione --target=15488 -s ala_backend
 */


require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Api\ContentRepository;

$script = eZScript::instance( array( 'description' => ( "Colloca gli oggetti del tipospecificato  nel nodo target" ),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true ) );

$script->startup();
$options = $script->getOptions(
    '[action:][class:][target:][main:]',
    '',
    array(
        'action'  => 'Action to execute',
        'class'   => 'Class identifier',
        'target'  => 'Target node id',
        'main'    => 'Set new collocation as main'
    )
);
$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName( 'admin' );
eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

try
{
    $action = 'list';
    if ($options['action']){
        $action = $options['action'];
    }

    if (!$options['class']){
        throw new Exception("Specifica una classe");
    }

    $classIdentifier  = $options['class'];
    $class = eZContentClass::fetchByIdentifier( $classIdentifier );
    if ( !$class instanceof eZContentClass )
    {
        throw new Exception("Classe non presente");
    }

    if (!$options['target']){
        throw new Exception("Specifica un target node id");
    }
    $targetNodeId = $options['target'];
    $targetNode = eZContentObjectTreeNode::fetch($targetNodeId);
    if ( !$targetNode instanceof eZContentObjectTreeNode )
    {
        throw new Exception("Nodo non presente");
    }

    $setMain = false;

    $host = 'http://' . eZINI::instance( 'site.ini' )->variable( 'SiteSettings', 'SiteURL' ) .'/';
    $query = "classes '{$classIdentifier}'";

    $client = new HttpClient($host);
    $repository = new ContentRepository();
    $repository->setEnvironment(new DefaultEnvironmentSettings());

    $client = new HttpClient($host);
    // find in remotes
    $client->findAll($query, function ($response) use ($targetNodeId, $cli, $client, $repository, $action) {
        foreach ($response['searchHits'] as $item) {
            $object = eZContentObject::fetch($item['metadata']['id']);
            if ( $object instanceof eZContentObject)
            {
                switch ($action)
                {
                    case 'collocate':
                        eZContentOperationCollection::addAssignment( $object->mainNodeID(), $object->ID, array($targetNodeId) );
                        break;

                    case 'clear':
                        eZNodeAssignment::purgeByParentAndContentObjectID($targetNodeId, $object->ID);
                        break;

                    case 'list':
                    default:
                        $cli->output($object->Name);
                        break;
                }
            }
        }
    });
    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}
