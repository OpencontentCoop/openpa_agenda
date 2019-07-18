<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class OpenAgenda_BC_Mapper_Event
{
    const PARENT_EVENTI = 65;

    const PARENT_IMAGES = 51;

    const PARENT_LUOGHI = 61;

    const PARENT_CONTATTI = 64;

    private $host;

    private $topics = [71];

    private $types = ['Edifici residenziali'];

    public function __construct($host)
    {
        $this->host = str_replace('/eventi', '', $host);
    }

    public function map($sourceData)
    {
        $data = [];
        foreach ($sourceData['data'] as $language => $sourceDatum) {
            $data[$language]['event_title'] = $sourceDatum['titolo']['content'];
            $data[$language]['short_event_title'] = $sourceDatum['short_title']['content'];
            $data[$language]['image'] = $this->mapImage($sourceDatum);
            $data[$language]['has_public_event_typology'] = $this->mapType($sourceDatum);
            $data[$language]['topics'] = $this->mapTopic($sourceDatum);
            $data[$language]['event_abstract'] = $sourceDatum['titolo']['content'];
            if ($sourceDatum['titolo']['abstract']) {
                $data[$language]['event_abstract'] = $sourceDatum['abstract']['content'];
            } else {
                $data[$language]['event_abstract'] = $sourceDatum['titolo']['content'];
            }
            $data[$language]['description'] = $sourceDatum['description']['content'];
            $data[$language]['takes_place_in'] = $this->mapPlace($sourceDatum);
            $data[$language]['time_interval'] = $this->mapTimeInterval($sourceDatum);
            $data[$language]['organizer'] = $this->mapOrganizer($sourceDatum);
            $data[$language]['target_audience'] = $this->mapTarget($sourceDatum);

        }

        return [
            'metadata' => [
                'remoteId' => $sourceData['metadata']['remoteId'],
                'classIdentifier' => 'event',
                'parentNodes' => [self::PARENT_EVENTI],
                'languages' => ['ita-IT'],
                'stateIdentifiers' => ['moderation.accepted']
            ],
            'data' => $data
        ];
    }

    private function mapOrganizer($sourceDatum)
    {
        $data = [];
        if (!empty($sourceDatum['associazione']['content'])) {
            foreach ($sourceDatum['associazione']['content'] as $item) {
                $data[] = $item['remoteId'];
            }
        } else {
            $data[] = 57; //@todo
        }

        return $data;
    }

    private function mapTimeInterval($sourceDatum)
    {
        $interval = [
            'input' => [
                'startDateTime' => $sourceDatum['from_time']['content'],
                'endDateTime' => $sourceDatum['to_time']['content'],
                'freq' => 'none',
                'interval' => 1,
            ],
            'recurrences' => [
                [
                    'id' => strtotime($sourceDatum['from_time']['content']) . '-' . strtotime($sourceDatum['to_time']['content']),
                    'start' => $sourceDatum['from_time']['content'],
                    'end' => $sourceDatum['to_time']['content'],
                ]
            ],
            'events' => [
                [
                    'id' => strtotime($sourceDatum['from_time']['content']) . '-' . strtotime($sourceDatum['to_time']['content']),
                    'start' => $sourceDatum['from_time']['content'],
                    'end' => $sourceDatum['to_time']['content'],
                ]
            ]
        ];

        return json_encode($interval);
    }

    private function mapPlace($sourceDatum)
    {
        $data = [];
        if ($sourceDatum['luogo_svolgimento']['content']) {
            $remoteId = md5($sourceDatum['luogo_svolgimento']['content']);
        } elseif ($sourceDatum['geo']['content']) {
            $remoteId = md5($sourceDatum['geo']['content']['latitude'] . $sourceDatum['geo']['content']['longitude']);
        }
        if ($remoteId) {
            $data[] = [
                'metadata' => [
                    'remoteId' => $remoteId,
                    'classIdentifier' => 'place',
                    'parentNodes' => [self::PARENT_LUOGHI],
                    'languages' => ['ita-IT']
                ],
                'data' => [
                    'ita-IT' => [
                        'name' => $sourceDatum['luogo_svolgimento']['content'] ? $sourceDatum['luogo_svolgimento']['content'] : $sourceDatum['geo']['content']['address'],
                        'has_address' => $sourceDatum['geo']['content'],
                        'topics' => $this->topics,
                        'type' => $this->types,
                    ]
                ]
            ];
        }
        return $data;
    }

    private function mapTarget($sourceDatum)
    {
        return ['Famiglie']; //@todo
    }

    private function mapTopic($sourceDatum)
    {
        return ['71']; //@todo
    }

    private function mapType($sourceDatum)
    {
        return ['Evento culturale']; //@todo
    }

    private function mapImage($sourceDatum)
    {
        $url = rtrim($this->host, '/') . $sourceDatum['image']['content']['url'];
        if ( $sourceDatum['image']['content']['url']) {
            return [
                [
                    'metadata' => [
                        'remoteId' => md5($url),
                        'classIdentifier' => 'image',
                        'parentNodes' => [self::PARENT_IMAGES],
                        'languages' => ['ita-IT']
                    ],
                    'data' => [
                        'ita-IT' => [
                            'name' => OpenPABootstrapItaliaOperators::cleanFileName($sourceDatum['image']['content']['filename']),
                            'image' => [
                                'filename' => $sourceDatum['image']['content']['filename'],
                                'url' => $url
                            ],
                            'license' => ['Licenza sconosciuta'],
                            'author' => 'Autore sconosciuto'
                        ]
                    ]
                ]
            ];
        }

        return [];
    }

    public function import($content)
    {
        try {
            $contentRepository = new ContentRepository();
            $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

            if (isset($content['metadata']['remoteId']) && \eZContentObject::fetchByRemoteID($content['metadata']['remoteId'])) {
                $result = $contentRepository->update($content);
            } else {
                $result = $contentRepository->create($content);
            }

            return $result['content']['metadata']['id'];
        } catch (Exception $e) {
            var_dump($content);
            throw $e;
        }
    }
}
