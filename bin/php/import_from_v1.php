<?php

require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;

$script = eZScript::instance(array(
    'description' => ("Importa eventi da un'istanza openpa dato un host e eventualmente una query ocsql"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
));

$script->startup();

class LoggedHttpClient extends HttpClient
{
    public function request($method, $url, $data = null)
    {
        eZCLI::instance()->output($url);
        return parent::request($method, $url, $data);
    }

    public function findAll($query, \Closure $paginationCallback = null)
    {
        $collectData = array();
        $nextPageQuery = $this->buildUrl('/search/' . urlencode($query));
        while($nextPageQuery){
            if ($nextPageQuery == $this->buildUrl('/search/')){
                break;
            }
            $data = $this->request('GET', $nextPageQuery);
            $collectData = array_merge($collectData, $data['searchHits']);
            $nextPageQuery = !empty($nextPageQuery) ? $this->buildUrl('/search/' . urlencode($data['nextPageQuery'])) : false;
            if ($paginationCallback instanceof \Closure){
                $paginationCallback($data);
            }
        }
        return $collectData;
    }
}

$query = 'classes [event] and calendar[] = [now,next month]';

$options = $script->getOptions(
    '[host:][creator_id:][status:][update][query:][password:]',
    '',
    array(
        'host' => 'Esempio: "http://www.valledeltesino.com/"',
        'password' => 'password',
        'creator_id' => "Id dell'autore (default admin)",
        'update' => 'Aggiorna i contenuti se già imporatti altrimenti non li considera',
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


try {

    $host = $options['host'];
    $doUpdate = $options['update'];
    if (empty($host) || !eZHTTPTool::getDataByURL($host, true)) {
        throw new Exception("Host $host non raggiungibile");
    }

    $client = new LoggedHttpClient($host, 'admin', $options['password'], 'full', '/opendata/api');

/*
    eZCLI::instance()->output("Associazioni");
    $index = 0;
    $client->findAll('classes [associazione]', function ($response) use ($host, &$index, $doUpdate) {
        $mapper = new OpenAgenda_BC_Mapper_Associazione();
        foreach ($response['searchHits'] as $searchHit) {
            $index++;
            $remoteId = $searchHit['metadata']['remoteId'];
            $exists = eZContentObject::fetchByRemoteID($remoteId);

            if ($exists) {
                eZCLI::instance()->output(" - $index/" . $response['totalCount'] . ' ' . $searchHit['metadata']['name']['ita-IT']);
                $doImport = $doUpdate;
            } else {
                eZCLI::instance()->warning(" - $index/" . $response['totalCount'] . ' ' . $searchHit['metadata']['name']['ita-IT']);
                $doImport = true;
            }

            if ($doImport) {
                try {
                    $map = $mapper->map($searchHit);

                    foreach (['has_spatial_coverage', 'has_online_contact_point'] as $identifier) {
                        $relations = [];
                        foreach ($map['data']['ita-IT'][$identifier] as $relation) {
                            $relations[] = $mapper->import($relation);
                        }
                        $map['data']['ita-IT'][$identifier] = $relations;
                    }

                    $mapper->import($map);
                } catch (Exception $e) {
                    eZCLI::instance()->error($e->getMessage());
                }
            }
        }
    });
*/

    eZCLI::instance()->output("Eventi");
    $index = 0;
    $register = new ArrayObject([
        'tipo_evento' => [],
        'target' => [],
        'luogo_svolgimento' => [],
    ]);
    $doForMapper = false;
    $client->findAll('classes [event] limit 100', function ($response) use ($host, &$index, $doUpdate, $register, $doForMapper) {
        $mapper = new OpenAgenda_BC_Mapper_Event($host);
        foreach ($response['searchHits'] as $searchHit) {

            $index++;
            $remoteId = $searchHit['metadata']['remoteId'];
            $exists = $doForMapper ? false : eZContentObject::fetchByRemoteID($remoteId);

            if ($exists) {
                eZCLI::instance()->output(" - $index/" . $response['totalCount'] . ' ' . $searchHit['metadata']['name']['ita-IT']);
                $doImport = $doUpdate;
            } else {
                eZCLI::instance()->warning(" - $index/" . $response['totalCount'] . ' ' . $searchHit['metadata']['name']['ita-IT']);
                $doImport = true;
            }

            if ($doForMapper) {
                $register['tipo_evento'] = array_unique(array_merge($register['tipo_evento'], $searchHit['data']['ita-IT']['tipo_evento']['content']));
                $register['target'] = array_unique(array_merge($register['tipo_evento'], $searchHit['data']['ita-IT']['tipo_evento']['content']));
                $register['luogo_svolgimento'][] = $searchHit['data']['ita-IT']['luogo_svolgimento']['content'];
                $register['luogo_svolgimento'] = array_unique($register['luogo_svolgimento']);
                $doImport = false;
            }

            if ($doImport) {
                try {
                    $map = $mapper->map($searchHit);

                    foreach (['image', 'takes_place_in', 'has_online_contact_point', 'has_offer', 'organizer', 'sponsor'] as $identifier) {
                        $relations = [];
                        foreach ($map['data']['ita-IT'][$identifier] as $relation) {
                            if (is_array($relation)){
                                $relations[] = $mapper->import($relation);
                            }else{
                                $relations[] = $relation;
                            }
                        }
                        $map['data']['ita-IT'][$identifier] = $relations;
                    }

                    $mapper->import($map);
                } catch (Exception $e) {
                    eZCLI::instance()->error($e->getMessage());
                    //eZCLI::instance()->error($e->getMessage() . ' on line ' . $e->getFile() . '#' . $e->getLine() . PHP_EOL . $e->getTraceAsString());
                }
            }
        }
    });

    print_r($register);

} catch (Throwable $e) {
    $cli->error($e->getMessage());
    //eZCLI::instance()->error($e->getMessage() . ' on line ' . $e->getFile() . '#' . $e->getLine() . PHP_EOL . $e->getTraceAsString());
}

$script->shutdown();
