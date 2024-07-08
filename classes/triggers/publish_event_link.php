<?php

use Opencontent\Opendata\Api\Values\Content;

class OpenAgendaPublishEventLinkWebHookTrigger implements OCWebHookTriggerInterface,
                                                          OCWebHookCustomPayloadSerializerInterface
{
    const IDENTIFIER = 'openagenda_publish_event_link';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Pubblicazione di un placeholder evento';
    }

    public function getDescription()
    {
        return 'L\'evento viene scatenato alla pubblicazione e all\'aggiornamento di stato un evento.';
    }

    public function canBeEnabled()
    {
        return true;
    }

    public function useFilter()
    {
        return false;
    }

    public function isValidPayload($payload, $filters)
    {
        return true;
    }

    public function serializeCustomPayload($originalPayload, OCWebHook $webHook)
    {
        $payload = false;
        if (is_numeric($originalPayload)) {
            eZContentObject::clearCache();
            $contentObject = eZContentObject::fetch((int)$originalPayload);
            if ($contentObject instanceof eZContentObject) {
                $payload = self::generatePayload($contentObject, $webHook);
            }
        }
        return $payload;
    }

    public function getPlaceholders()
    {
        return [];
    }

    public function getHelpText()
    {
        return '<b>Attenzione: il payload viene generato automaticamente: utilizzare il <em>default payload</em></b>';
    }

    private static function generatePayload(eZContentObject $contentObject, OCWebHook $webHook)
    {
        $headers = (array)json_decode($webHook->attribute('headers'), true);
//        if (!isset($headers['Authorization'])){
//            /** @var eZUser $user */
//            $user = eZUser::fetchByName('admin');
//            $headers['Authorization'] = "Bearer " . JWTManager::issueInternalJWTToken($user);
//            $webHook->setAttribute('headers', json_encode($headers));
//            $webHook->sync(['headers']);
//        }
        $content = Content::createFromEzContentObject($contentObject);
        $contentObjectDataMap = $contentObject->dataMap();
        $payloadContent = [];
        $targetAudience = '';
        $topic = [];
        $type = [];
        $contactPoint = [];
        $place = [];
        $image = [];
        $offer = [];
        foreach ($content->data as $language => $data) {
            $organizer = null;
            if (isset($data['organizer']['content'][0]['id'])) {
                $organizer = eZContentObject::fetch((int)$data['organizer']['content'][0]['id']);
                $organizerDataMap = $organizer->dataMap();
            }

            $targetAudience .= '<ul>';
            foreach ($data['target_audience']['content'] as $target) {
                $targetAudience .= '<li>' . $target . '</li>';
            }
            $targetAudience .= '</ul>';
            $targetAudience .= $data['about_target_audience']['content'];

            foreach ($data['topics']['content'] as $item) {
                $topic[] = [
                    'id' => $item['remoteId'],
                    'language' => $language,
                    'name' => $item['name'][$language],
                ];
            }

            foreach ($data['has_public_event_typology']['content'] as $item) {
                $type[] = [
                    'id' => '',
                    'language' => $language,
                    'name' => $item,
                ];
            }

            foreach ($data['has_online_contact_point']['content'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $objectDataMap = $object->dataMap();
                    $contacts = isset($objectDataMap['contact']) ?
                        self::getMatrixAsHash($objectDataMap['contact']->content()) : [];
                    $phone = $web = $email = '';
                    foreach ($contacts as $contact) {
                        if (strpos($contact['value'], 'http') || strpos($contact['value'], 'www')) {
                            $web = $contact['value'];
                        } elseif (strpos($contact['value'], '@')) {
                            $email = $contact['value'];
                        } else {
                            $phone = $contact['value'];
                        }
                    }
                    $contactPoint[] = [
                        'id' => $object->attribute('remote_id'),
                        'language' => $language,
                        'name' => $object->attribute('name'),
                        'phone' => $phone,
                        'email' => $email,
                        'website' => $web,
                    ];
                }
            }
            if (empty($contactPoint) && $organizer instanceof eZContentObject) {
                $organizerUser = eZUser::fetch((int)$organizer->attribute('id'));
                $contactPoint[] = [
                    'id' => '',
                    'language' => $language,
                    'name' => $organizer->attribute('name'),
                    'phone' => isset($organizerDataMap['main_phone']) ?
                        $organizerDataMap['main_phone']->toString() : '',
                    'email' => $organizerUser instanceof eZUser ?
                        $organizerUser->attribute('email') : '',
                    'website' => isset($organizerDataMap['website']) ?
                        $organizerDataMap['website']->toString() : '',
                ];
            }

            foreach ($data['takes_place_in']['content'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $objectDataMap = $object->dataMap();
                    if (isset($objectDataMap['has_address']) && $objectDataMap['has_address']->hasContent()) {
                        /** @var eZGmapLocation $geo */
                        $geo = $objectDataMap['has_address']->content();
                        $place[] = [
                            'id' => $item['remoteId'],
                            'language' => $language,
                            'name' => $item['name'][$language],
                            'address' => html_entity_decode($geo->attribute('address')),
                            'latitude' => $geo->attribute('latitude'),
                            'longitude' => $geo->attribute('longitude'),
                        ];
                    }
                }
            }
            if (empty($place) && $organizer instanceof eZContentObject) {
                if (isset($organizerDataMap['main_address']) && $organizerDataMap['main_address']->hasContent()) {
                    /** @var eZGmapLocation $geo */
                    $geo = $organizerDataMap['main_address']->content();
                    $place[] = [
                        'id' => '',
                        'language' => $language,
                        'name' => $organizer->attribute('name'),
                        'address' => html_entity_decode($geo->attribute('address')),
                        'latitude' => $geo->attribute('latitude'),
                        'longitude' => $geo->attribute('longitude'),
                    ];
                }
            }

            foreach ($data['image']['content'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $objectDataMap = $object->dataMap();
                    /** @var \eZImageAliasHandler $attributeContent */
                    $attributeContent = $objectDataMap['image']->content();
                    $imageContent = $attributeContent->attribute('original');
                    $url = $imageContent['full_path'];
                    eZURI::transformURI($url, true);
                    $image[] = [
                        'url' => $url,
                        'name' => $object->attribute('name'),
                        'license' => $objectDataMap['license']->content()->keywordString(' '),
                        'author' => $objectDataMap['author']->content(),
                        'width' => $imageContent['width'],
                        'height' => $imageContent['height'],
                    ];
                }
            }

            foreach ($data['has_offer']['content'] as $item) {
                $object = eZContentObject::fetch((int)$item['id']);
                if ($object instanceof eZContentObject) {
                    $objectDataMap = $object->dataMap();
                    $offer[] = [
                        'id' => '',
                        'language' => $language,
                        'name' => $object->attribute('name'),
                        'has_eligible_user' => $objectDataMap['has_eligible_user']->content()->keywordString(' '),
                        'has_currency' => '€ ' . number_format(
                                $objectDataMap['has_price_specification']->content(),
                                2,
                                ',',
                                ''
                            ),
                        'description' => $objectDataMap['description']->content(),
                        'note' => $objectDataMap['note']->content(),
                    ];
                }
            }

            $payloadContent[$language] = [
                'event_title' => $data['event_title']['content'],
                'time_interval' => isset($contentObjectDataMap['time_interval']) ?
                    $contentObjectDataMap['time_interval']->toString() : null,
                'event_abstract' => $data['event_abstract']['content'],
                'about_target_audience' => $targetAudience,
                'virtual_topic' => $topic,
                'virtual_has_public_event_typology' => $type,
                'virtual_has_online_contact_point' => $contactPoint,
                'virtual_takes_place_in' => $place,
                'virtual_image' => $image,
                'virtual_has_offer' => $offer,
                'cost_notes' => $data['cost_notes']['content'] ?? '',
            ];
        }
        return [
            'metadata' => [
                'remoteId' => $content->metadata->remoteId,
                'languages' => array_keys($payloadContent),
                'parentNodes' => [$headers['X-Target-Node'] ?? 2],
                'classIdentifier' => 'event_link',
            ],
            'data' => $payloadContent,
        ];
    }

    private static function getMatrixAsHash($matrix): array
    {
        $data = $headers = [];
        if (!$matrix instanceof eZMatrix) {
            return $data;
        }

        $matrix = $matrix->attribute('matrix');
        foreach ($matrix['columns']['sequential'] as $column) {
            $headers[] = $column['identifier'];
        }
        foreach ($matrix['rows']['sequential'] as $row) {
            $item = [];
            $columns = $row['columns'];
            foreach ($headers as $index => $header) {
                $item[$header] = $columns[$index];
            }
            $data[] = $item;
        }

        return $data;
    }
}
