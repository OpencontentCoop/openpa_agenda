<?php

require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Api\ContentRepository;

$script = eZScript::instance( array( 'description' => ( "Importa eventi da trentino cultura in base a una query ocsql" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();
$options = $script->getOptions(
    '[query:]',
    '',
    array( 'query'  => 'Esempio: "classes \'event\' and comune = \'Ala\' and calendar[] = [2016-01-01,2016-07-01]"')
);
$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName( 'admin' );
eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );


$host = 'https://www.cultura.trentino.it/';

try {

    $client = new HttpClient($host);

    if (!$options['query']){
        throw new Exception( "Specifica la query" );
    }
    
    $query = $options['query'];
    
    $output = new ezcConsoleOutput();
    $question = ezcConsoleQuestionDialog::YesNoQuestion( $output, "Importo oggetti cercando \"$query\" ? ", "y" );
    if ( ezcConsoleDialogViewer::displayDialog( $question ) == "y" )
    {
    
        $repository = new ContentRepository();
        $repository->setEnvironment(new DefaultEnvironmentSettings());
    
        $relationFilters = array(
            'tipo_evento' => function (PayloadBuilder $payload) {
                $payload->setParentNodes(array(505));
                $payload->unSetLanguage('eng-GB');
                $payload->unSetLanguage('ger-DE');
                $payload->unSetData('image');
                return $payload;
    
            }
        );
    
        $client->findAll($query, function ($response) use ($client, $repository, $relationFilters) {
            foreach ($response['searchHits'] as $item) {
                $import = $client->import(
                    $item,
                    $repository,
                    function (PayloadBuilder $payload) use ($client, $repository, $relationFilters) {
    
                        $payload->unSetLanguage('eng-GB');
                        $payload->unSetLanguage('ger-DE');
    
                        $payload->unSetData('telefono');
                        $payload->unSetData('fax');
                        $payload->unSetData('url');
                        $payload->unSetData('email');
                        $payload->unSetData('short_description');
                        $payload->unSetData('utenza_target');
                        $payload->unSetData('immagini');
                        $payload->unSetData('costi_text');
                        $payload->unSetData('comune');
                        $payload->unSetData('rassegna');
                        $payload->unSetData('luogo_della_cultura');
                        $payload->unSetData('indirizzo');
                        $payload->unSetData('note');
                        $payload->unSetData('preview_image');
                        $payload->unSetData('poster_image');
                        $payload->unSetData('tema');
                        $payload->unSetData('soggetto');
                        $payload->unSetData('organizzatori');
                        $payload->unSetData('stato');
                        $payload->unSetData('circoscrizione');
                        $payload->unSetData('associazione');
                        $payload->unSetData('progressivo');
                        $payload->unSetData('fonte');
                        $payload->unSetData('abbonamenti_text');
                        $payload->unSetData('prevendita');
                        $payload->unSetData('codice');
                        $payload->unSetData('abbonamenti');
                        $payload->unSetData('iniziativa');
                        $payload->unSetData('iniziativa_text');
    
                        $payload->setParentNodes(array(OpenPAAgenda::instance()->rootObject()->attribute('main_node_id')));
                        $payload->setStateIdentifiers(array('moderation.waiting'));
    
                        $orario_svolgimento = $payload->getData('orario_svolgimento');
                        foreach ($orario_svolgimento as $language => $string) {
                            $payload->setData($language, 'orario_svolgimento', strip_tags($string));
                        }
    
                        $costi = $payload->getData('costi');
                        foreach ($costi as $language => $string) {
                            $payload->setData($language, 'costi', strip_tags($string));
                        }
    
                        foreach ($relationFilters as $identifier => $relatedClosure) {
                            $relationData = array();
                            $relationList = $payload->getData($identifier);
                            foreach ($relationList as $language => $relations) {
                                foreach ($relations as $relation) {
                                    try {
                                        $newRelation = $client->import(
                                            $relation['id'],
                                            $repository,
                                            $relatedClosure
                                        );
                                        if ($newRelation['message'] == 'success') {
                                            $relationData[] = $newRelation['content']['metadata']['remoteId'];
                                        } else {
                                            eZCLI::instance()->error($newRelation['message'], __METHOD__);
                                        }
                                    } catch (Exception $e) {
                                        eZCLI::instance()->error($e->getMessage(), __METHOD__);
                                    }
                                }
                            }
    
                            if (empty( $relationData )) {
                                $payload->unSetData($identifier);
                            } else {
                                $payload->setData(null, $identifier, $relationData);
                            }
                        }
    
                        return $payload;
                    }
                );
    
                if ($import['message'] == 'success') {
                    eZCLI::instance()->notice("Import " . $import['content']['metadata']['name']['ita-IT']);
                } else {
                    eZCLI::instance()->error("Error importing " . $item['metadata']['name']['ita-IT'] . " " . $import['message']);
                }
            }
        });
    }

} catch (Exception $e) {
    eZCLI::instance()->error($e->getMessage());
}

$script->shutdown();