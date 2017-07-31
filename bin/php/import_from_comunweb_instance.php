<?php

require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Rest\Client\PayloadBuilder;
use Opencontent\Opendata\Api\ContentRepository;

$script = eZScript::instance(array(
    'description' => ( "Importa eventi da un'istanza comunweb dato un host e eventualmente una query ocsql" ),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
));

$script->startup();

$query = 'classes [event] and calendar[] = [now,next month]';

$options = $script->getOptions(
    '[host:][creator_id:][status:][update][query:]',
    '',
    array(
        'host' => 'Esempio: "http://www.valledeltesino.com/"',
        'creator_id' => "Id dell'autore (default admin)",
        'update' => 'Aggiorna gli eventi se già imporatti altrimenti non li considera',
        'query' => "Default: '$query'",
        'status' => "Stato in cui importa (default: 'moderation.waiting')"
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

function createTag($name)
{
    $tagRepository = new \Opencontent\Opendata\Api\TagRepository();
    $locale = 'ita-IT';

    $root = $tagRepository->read('Tipologia di evento');

    $struct = new \Opencontent\Opendata\Api\Structs\TagStruct();
    $struct->parentTagId = $root->id;
    $struct->keyword = $name;
    $struct->locale = $locale;
    $struct->alwaysAvailable = true;

    $result = $tagRepository->create($struct);
    if ($result['message'] == 'success') {
        eZCLI::instance()->warning(' - Created tag ' . $name);
    }
    return $result['tag'];
}

function setTipoEventoInPayload($language, $tipoEventoResponse, PayloadBuilder $payload)
{
    $tags = array();

    foreach($tipoEventoResponse as $tipoEventoResponseItem){
        $tipoEvento = $tipoEventoResponseItem['name'][$language];
        if (eZTagsObject::fetchListCount(array( 'keyword' => $tipoEvento ))){
            if ($tipoEvento == 'Evento singolo'){
                createTag('Altro');
                $tipoEvento = 'Altro';
            }
            $tags[] = $tipoEvento;
        }
    }
    if (empty($tags)){
        createTag('Altro');
        $tags[] = 'Altro';
    }

    $payload->setData($language, 'tipo_evento', $tags);
}

function setIniziativaInPayload($language, $iniziativaResponse, PayloadBuilder $payload)
{
    $payload->unSetData('iniziativa'); //@todo
}

function notice($message)
{
    if (!eZCLI::instance()->isQuiet()){
        eZCLI::instance()->notice($message);
    }
}

function warning($message)
{
    if (!eZCLI::instance()->isQuiet()){
        eZCLI::instance()->warning($message);
    }
}

function error($message)
{
    eZCLI::instance()->error($message);
}


try {

    $host = $options['host'];
    if (empty( $host ) || !eZHTTPTool::getDataByURL($host, true)) {
        throw new Exception("Host $host non raggiungibile");
    }

    $client = new HttpClient($host);

    if ($options['query']) {
        $query = $options['query'];
    }

    notice("Search $query in $host");

    $repository = new ContentRepository();
    $repository->setEnvironment(new DefaultEnvironmentSettings());

    $agendaEventClass = eZContentClass::fetchByIdentifier('event');
    /** @var eZContentClassAttribute[] $agendaEventAttributes */
    $agendaEventAttributes = $agendaEventClass->dataMap();

    $count = 0;

    $client->findAll($query, function ($response) use ($client, $repository, $agendaEventAttributes, &$count, $host, $options) {

        $count += count($response['searchHits']);
        warning("*** Process $count of {$response['totalCount']} event");

        foreach ($response['searchHits'] as $item) {
            $exists = eZContentObject::fetchByRemoteID($item['metadata']['remoteId']);
            if (!$options['update'] && $exists instanceof eZContentObject){
                warning("Skip #" . $item['metadata']['id'] . ' ' . $import['content']['metadata']['name']['ita-IT']);
                continue;
            }
            try {
                $import = $client->import(
                    $item,
                    $repository,
                    function (PayloadBuilder $payload) use ($client, $repository, $agendaEventAttributes, $host, $options) {

                        $required = array();
                        foreach($agendaEventAttributes as $agendaEventAttribute){
                            if ($agendaEventAttribute->attribute('is_required')){
                                $required[] = $agendaEventAttribute->attribute('identifier');
                            }
                        }

                        $payload->setParentNodes(array(OpenPAAgenda::instance()->calendarNodeId()));

                        if ($options['creator_id']){
                            $payload['metadata']['creatorId'] = $options['creator_id'];
                        }

                        $payloadData = $payload->getData();
                        foreach ($payloadData as $language => $dataItems) {
                            foreach ($dataItems as $identifier => $dataItem) {

                                $agendaEventAttribute = isset( $agendaEventAttributes[$identifier] ) ? $agendaEventAttributes[$identifier] : null;

                                if (!$agendaEventAttribute) {

                                    switch ($identifier) {
                                        case 'image':
                                            $payloadImageData = $payload->getData('image', $language);
                                            $payloadImageData['url'] = rtrim($host, '/') . $payloadImageData['url'];
                                            $payload->unSetData('image');
                                            $payload->setData($language, 'images', array($payloadImageData));
                                            break;

                                        default:
                                            //warning("Unset $identifier from payload");
                                            $payload->unSetData($identifier);
                                    }

                                } else {
                                    switch ($identifier) {
                                        case 'image':
                                            $payloadImageData = $payload->getData('image', $language);
                                            $payloadImageData['url'] = rtrim($host, '/') . $payloadImageData['url'];
                                            $payload->setData($language, 'image', $payloadImageData);
                                            break;

                                        case 'tipo_evento':
                                            setTipoEventoInPayload($language, $dataItem, $payload);
                                            break;

                                        case 'iniziativa':
                                            setIniziativaInPayload($language, $dataItem, $payload);
                                            break;

                                        default:
                                            if ($agendaEventAttribute->attribute('data_type_string') == 'ezobjectrelationlist') {
                                                $payload->unSetData($identifier);
                                            }
                                    }
                                }
                            }

                            foreach($required as $identifier){
                                if (empty($payload->getData($identifier, $language))){
                                    if($identifier == 'abstract'){
                                        if (!empty($payload->getData('text', $language))) {
                                            $payload->setData($language, 'abstract', $payload->getData('text', $language));
                                            $payload->unSetData('text');
                                        }else{
                                            $payload->setData($language, 'abstract', $payload->getData('titolo', $language));
                                        }
                                    }

                                    if($identifier == 'to_time'){
                                        $fromTime = $payload->getData('from_time', $language);
                                        $toTimestamp = date("U", strtotime($fromTime)) + 3600;
                                        $payload->setData($language, 'to_time', date('c', (int)$toTimestamp));
                                    }
                                }
                            }


                        }

                        $status = 'moderation.waiting';
                        if ($options['status']){
                            $status = $options['status'];
                        }

                        $payload->setStateIdentifiers(array($status));

                        if ($options['debug']){
                            throw new Exception(var_export($payload, 1));
                        }

                        return $payload;
                    }
                );

                if ($import['message'] == 'success') {
                    notice("Import #" . $item['metadata']['id'] . ' ' . $import['content']['metadata']['name']['ita-IT'] . " in  {$import['content']['metadata']['id']}");
                } else {
                    error("Error importing #" . $item['metadata']['id'] . ' ' . $item['metadata']['name']['ita-IT'] . " " . $import['message']);
                }
            } catch (Exception $e) {
                error("Error importing #" . $item['metadata']['id'] . ' ' . $item['metadata']['name']['ita-IT'] . " " . $e->getMessage());
            }
        }
    });

} catch (Exception $e) {
    error($e->getMessage());
}

$script->shutdown();
