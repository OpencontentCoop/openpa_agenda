<?php

use Opencontent\OpenApi\EndpointDiscover\LoggableTrait;
use Opencontent\OpenApi\EndpointDiscover\SubEndpointProviderTrait;
use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\EndpointFactoryCollection;
use Opencontent\OpenApi\EndpointFactoryProvider;
use Opencontent\OpenApi\OperationFactory;
use Opencontent\OpenApi\OperationFactoryCollection;

class OpenAgendaEndpointFactoryProvider extends EndpointFactoryProvider
{
    use LoggableTrait;
    use SubEndpointProviderTrait;

    /**
     * @var EndpointFactory[]|EndpointFactory\NodeClassesEndpointFactory[]
     */
    private $endpoints;

    public function getEndpointFactoryCollection()
    {
        if ($this->endpoints === null) {
            $this->endpoints = [];
            $this->discoverFromIni();
            $sort = [];
            $this->endpoints = array_values($this->endpoints);
            foreach ($this->endpoints as $endpoint) {
                $path = $endpoint->getPath();
                $path = str_replace('{', 'aaa', $path);
                $sortKey = \eZCharTransform::instance()->transformByGroup($path, 'identifier');
                $sort[$sortKey] = $endpoint;
            }
            ksort($sort);
            $this->endpoints = array_values($sort);
        }

        return new EndpointFactoryCollection($this->endpoints);
    }

    private function getMainNodeIdFromObjectRemoteId($remoteId)
    {
        $contentObjectIdentifier = \eZDB::instance()->escapeString($remoteId);
        $query = "SELECT node_id
              FROM ezcontentobject_tree
              WHERE main_node_id = node_id AND
                    contentobject_id in ( SELECT ezcontentobject.id
                                          FROM ezcontentobject
                                          WHERE ezcontentobject.remote_id='$contentObjectIdentifier')";
        $resArray = \eZDB::instance()->arrayQuery($query);

        if (count($resArray) == 1 && $resArray !== false) {
            return $resArray[0]['node_id'];
        }

        return 0;
    }

    private function discoverFromIni()
    {
        $instanceIdentifier = OpenPABase::getCurrentSiteaccessIdentifier();
        $paths = [
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId($instanceIdentifier . '_openpa_agenda_calendars'),
                'classes' => ['agenda_calendar'],
                'path' => '/calendari',
                'tag' => 'calendari-tematici',
            ],
            [
                'node' => 51,
                'classes' => ['image'],
                'path' => '/immagini',
                'tag' => 'immagini',
            ],
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId($instanceIdentifier . '_openpa_agenda_contacts'),
                'classes' => ['online_contact_point'],
                'path' => '/contatti',
                'tag' => 'contatti',
            ],
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId($instanceIdentifier . '_openpa_agenda_stuff'),
                'classes' => ['opening_hours_specification', 'offer'],
                'path' => '/classificazioni',
                'tag' => 'classificazioni',
            ],
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId($instanceIdentifier . '_openpa_agenda_locations'),
                'classes' => ['place'],
                'path' => '/luoghi',
                'tag' => 'luoghi',
            ],
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId($instanceIdentifier . '_openpa_agenda_associations'),
                'classes' => ['private_organization'],
                'path' => '/associazioni',
                'tag' => 'associazioni',
            ],
            [
                'node' => $this->getMainNodeIdFromObjectRemoteId(
                    $instanceIdentifier . '_openpa_agenda_agenda_container'
                ),
                'classes' => ['event'],
                'path' => '/eventi',
                'tag' => 'eventi',
                'collection' => new OperationFactoryCollection([
                    (new OperationFactory\ContentObject\CreateOperationFactory()),
                    (new OperationFactory\ContentObject\FilteredSearchOperationFactory()),
                ]),
                'item' => new OperationFactoryCollection([
                    (new OperationFactory\ContentObject\EmbedReadOperationFactory()),
                    (new OperationFactory\ContentObject\UpdateOperationFactory()),
                    (new OperationFactory\ContentObject\MergePatchOperationFactory()),
                    (new OperationFactory\ContentObject\DeleteOperationFactory()),
                ])
            ],
        ];

        foreach ($paths as $path) {
            if ($path['node'] > 0) {
                $this->build(
                    $path['path'],
                    $path['node'],
                    $path['classes'],
                    $path['tag'],
                    $path['collection'] ?? null,
                    $path['item'] ?? null
                );
            }
        }

        foreach ($this->endpoints as $endpoint) {
            if ($endpoint instanceof EndpointFactory\NodeClassesEndpointFactory
                && $endpoint->hasOperationMethod('get')
                && $endpoint->getOperationByMethod('get')
                instanceof OperationFactory\ContentObject\ReadOperationFactory) {
                $operation = $endpoint->getOperationByMethod('get');
                $this->createSubEndpoints($endpoint, $operation);
            }
        }

//        echo '<pre>';print_r([$paths,$this->endpoints]);die();
    }

    private function build(
        $path,
        $nodeId,
        $classes,
        $tag = 'default',
        $collectionOperationFactories = null,
        $itemOperationFactories = null
    ) {
        if (empty($collectionOperationFactories)){
            $collectionOperationFactories = new OperationFactoryCollection([
                (new OperationFactory\ContentObject\CreateOperationFactory()),
                (new OperationFactory\ContentObject\SearchOperationFactory()),
            ]);
        }

        if (empty($itemOperationFactories)){
            $itemOperationFactories = new OperationFactoryCollection([
                (new OperationFactory\ContentObject\ReadOperationFactory()),
                (new OperationFactory\ContentObject\UpdateOperationFactory()),
                (new OperationFactory\ContentObject\MergePatchOperationFactory()),
                (new OperationFactory\ContentObject\DeleteOperationFactory()),
            ]);
        }

        $this->endpoints[$path] = (new EndpointFactory\NodeClassesEndpointFactory(
            $nodeId, $classes
        ))
            ->setPath($path)
            ->addTag($tag)
            ->setOperationFactoryCollection($collectionOperationFactories);

        $path .= '/{id}';
        $this->endpoints[$path] = (new EndpointFactory\NodeClassesEndpointFactory(
            $nodeId, $classes
        ))
            ->setPath($path)
            ->addTag($tag)
            ->setOperationFactoryCollection($itemOperationFactories);
    }
}
