<?php

use maxh\Nominatim\Nominatim;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class OpenAgenda_BC_Mapper_Associazione
{
    const PARENT_ASSOCIAZIONI = 63;

    const PARENT_LUOGHI = 61;

    const PARENT_CONTATTI = 64;

    private $nominatim;

    private $cli;

    private $topics = [71];

    private $types = ['Edifici residenziali'];

    private $statusCode = ['Associazione riconosciuta'];

    private $host;

    public function __construct($host)
    {
        $this->host = $host;

        $url = 'http://nominatim.openstreetmap.org/';
        $this->nominatim = new Nominatim($url, [
            'verify' => false,
        ]);
        $this->cli = eZCLI::instance();
    }

    public function map($sourceData)
    {
        $data = [];
        foreach ($sourceData['data'] as $language => $sourceDatum) {

            $data[$language]['legal_name'] = $sourceDatum['titolo']['content'];
            if ($sourceDatum['abstract']['content']) {
                $data[$language]['description'] = $sourceDatum['abstract']['content'];
                $data[$language]['business_objective'] = $sourceDatum['scheda']['content'];
            }elseif ($sourceDatum['scheda']['content']) {
                $data[$language]['description'] = $sourceDatum['scheda']['content'];
            }else{
                $data[$language]['description'] = $sourceDatum['titolo']['content'];
            }
            $data[$language]['has_spatial_coverage'] = $this->mapToPlace($sourceData['metadata']['remoteId'], $sourceDatum);
            $data[$language]['has_online_contact_point'] = $this->mapToContactPoints($sourceData['metadata']['remoteId'], $sourceDatum);
            if ($sourceDatum['contatti']['content']) {
                $data[$language]['more_information'] = $sourceDatum['contatti']['content'];
            }
            $data[$language]['identifier'] = $sourceDatum['cod_associazione']['content'];
            if ($sourceDatum['data_inizio_validita']['content']) {
                $data[$language]['start_time'] = $sourceDatum['data_inizio_validita']['content'];
            }
            if ($sourceDatum['data_archiviazione']['content']) {
                $data[$language]['end_time'] = $sourceDatum['data_archiviazione']['content'];
            }
            $data[$language]['topics'] = $this->topics;
            $data[$language]['tax_code'] = $sourceDatum['cod_associazione']['content'];
            $data[$language]['vat_code'] = $sourceDatum['cod_associazione']['content'] ? $sourceDatum['cod_associazione']['content'] : '000';
            $data[$language]['legal_status_code'] = $this->statusCode;

            $data[$language]['user_account'] = $sourceDatum['user_account']['content'];

        }

        return [
            'metadata' => [
                'remoteId' => $sourceData['metadata']['remoteId'],
                'classIdentifier' => 'private_organization',
                'parentNodes' => [self::PARENT_ASSOCIAZIONI],
                'languages' => ['ita-IT']
            ],
            'data' => $data
        ];
    }

    private function mapToContactPoints($remoteId, $sourceDatum)
    {
        $data = [];
        $contacts = [];
        if ($sourceDatum['telefono']['content']) {
            $contacts[] = [
                'type' => 'Telefono',
                'value' => $sourceDatum['telefono']['content'],
                'contact' => ''
            ];
        }
        if ($sourceDatum['numero_telefono1']['content']) {
            $contacts[] = [
                'type' => ' Telefono alternativo ',
                'value' => $sourceDatum['numero_telefono1']['content'],
                'contact' => ''
            ];
        }
        if ($sourceDatum['fax']['content']) {
            $contacts[] = [
                'type' => 'Fax',
                'value' => $sourceDatum['fax']['content'],
                'contact' => ''
            ];
        }
        if ($sourceDatum['url']['content']) {
            $contacts[] = [
                'type' => 'Sito web',
                'value' => $sourceDatum['url']['content'],
                'contact' => ''
            ];
        }
        if ($sourceDatum['email']['content']) {
            $contacts[] = [
                'type' => 'Email',
                'value' => $sourceDatum['email']['content'],
                'contact' => ''
            ];
        }
        if ($sourceDatum['referente_telefono']['content']) {
            $contacts[] = [
                'type' => 'Telefono',
                'value' => $sourceDatum['referente_telefono']['content'],
                'contact' => implode(' ', [
                    $sourceDatum['referente_nome']['content'],
                    $sourceDatum['referente_ruolo']['content'],
                ])
            ];
        }
        if ($sourceDatum['referente_fax']['content']) {
            $contacts[] = [
                'type' => 'Fax',
                'value' => $sourceDatum['referente_fax']['content'],
                'contact' => implode(' ', [
                    $sourceDatum['referente_nome']['content'],
                    $sourceDatum['referente_ruolo']['content'],
                ])
            ];
        }
        if ($sourceDatum['referente_indirizzo']['content']) {
            $contacts[] = [
                'type' => 'Indirizzo',
                'value' => $sourceDatum['referente_indirizzo']['content'],
                'contact' => implode(' ', [
                    $sourceDatum['referente_nome']['content'],
                    $sourceDatum['referente_ruolo']['content'],
                ])
            ];
        }
        $data[] = [
            'metadata' => [
                'remoteId' => 'online_contact_point_' . $remoteId,
                'classIdentifier' => 'online_contact_point',
                'parentNodes' => [self::PARENT_CONTATTI],
                'languages' => ['ita-IT']
            ],
            'data' => [
                'ita-IT' => [
                    'name' => "Punto di contatto di " . $sourceDatum['titolo']['content'],
                    'contact' => $contacts
                ]
            ]
        ];

        return $data;
    }

    private function mapToPlace($remoteId, $sourceDatum)
    {
        $data = [];
        $data[] = [
            'metadata' => [
                'remoteId' => 'sede_' . $remoteId,
                'classIdentifier' => 'place',
                'parentNodes' => [self::PARENT_LUOGHI],
                'languages' => ['ita-IT']
            ],
            'data' => [
                'ita-IT' => [
                    'name' => "Sede di " . $sourceDatum['titolo']['content'],
                    'has_address' => $this->convertToGeo($sourceDatum),
                    'topics' => $this->topics,
                    'type' => $this->types,
                ]
            ]
        ];

        return $data;
    }

    private function convertToGeo($sourceDatum)
    {
        $geo = [];
        try {
            $geo['latitude'] = 0;
            $geo['longitude'] = 0;

            $address = implode(' ', [
                $sourceDatum['indirizzo']['content'],
                $sourceDatum['presso']['content'],
                $sourceDatum['cap']['content'],
                $sourceDatum['localita']['content'],
            ]);
            $address = trim(str_ireplace('Sede:', '', $address));
            $address = trim(str_ireplace('a/A:', '', $address));

            if ($sourceDatum['gps']['content']['latitude'] == 0) {
                $street = str_ireplace('Sede:', '', $sourceDatum['indirizzo']['content']);
                $streetParts = explode(',', $street);
                $street = $streetParts[0];

                $cap = $sourceDatum['cap']['content'] ? $sourceDatum['cap']['content'] : '';

                $city = str_ireplace('(tn)', '', $sourceDatum['localita']['content']);
                $city = str_ireplace('(tn)', 'a/A', $city);
                $search = $this->nominatim->newSearch()
                    ->country('Italy')
                    ->city($city)
                    ->postalCode($cap)
                    ->street($street)
                    ->addressDetails();

                $results = $this->nominatim->find($search);
                if (!empty($results)) {
                    $result = $results[0];
                    $geo['latitude'] = $result['lat'];
                    $geo['longitude'] = $result['lon'];
                }
            } else {
                $geo['latitude'] = $sourceDatum['gps']['content']['latitude'];
                $geo['longitude'] = $sourceDatum['gps']['content']['longitude'];
            }

            $geo['address'] = $address;

        } catch (\maxh\Nominatim\Exceptions\InvalidParameterException $e) {
            // If you set invalid parameter in instance
            $this->cli->error($e->getMessage());
        } catch (\GuzzleHttp\Exception\ClientException $e) {
            // If you have any exceptions with Guzzle
            $this->cli->error($e->getMessage());
        } catch (\maxh\Nominatim\Exceptions\NominatimException $e) {
            // If you set a wrong instance of Nominatim
            $this->cli->error($e->getMessage());
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            // If you set a wrong instance of Nominatim
            $this->cli->error($e->getMessage());
        }

        return $geo;
    }

    public function import($content)
    {
        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));

        if (isset($content['metadata']['remoteId']) && \eZContentObject::fetchByRemoteID($content['metadata']['remoteId'])){
            $result = $contentRepository->update($content);
        }else {
            $result = $contentRepository->create($content);
        }

        return $result['content']['metadata']['id'];
    }
}
