<?php

require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Api\ContentRepository;

$script = eZScript::instance( array( 'description' => ( "Importa oggetti tipo_evento da cultura trentino" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();
$options = $script->getOptions(
    '[parent:]',
    '',
    array( 'parent'  => 'Parent node id')
);
$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName( 'admin' );
eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

try
{
    if (!$options['parent']){
        throw new Exception("Specifica un parent node id");
    }
    $parentNodeId = $options['parent'];

    $host = 'https://www.cultura.trentino.it/';
    $query = "classes 'tipo_evento'";

    $client = new HttpClient($host);


    $repository = new ContentRepository();
    $repository->setEnvironment(new DefaultEnvironmentSettings());

    $client = new HttpClient($host);

    // find in remotes
    $client->findAll($query, function ($response) use ($parentNodeId, $cli, $client, $repository) {
        foreach ($response['searchHits'] as $item) {
            $import = $client->import(
                $item,
                $repository,
                function(PayloadBuilder $payload) use($parentNodeId){

                    $payload->unSetLanguage('eng-GB');
                    $payload->unSetLanguage('ger-DE');
                    $payload->setParentNodes(array($parentNodeId));
                    $payload->unSetData('image');

                    return $payload;
                }
            );

            if ($import['message'] == 'success') {
                $cli->warning( "Import " . $import['content']['metadata']['name']['ita-IT'] );
            } else {
                $cli->warning( "Error importing " . $item['metadata']['name']['ita-IT'] . " " . $import['message'] );
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
