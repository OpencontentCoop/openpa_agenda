<?php

use Opencontent\Opendata\Api\Values\Content;

class OpenAgendaPublishEventWebHookTrigger implements OCWebHookTriggerInterface,
                                                      OCWebHookCustomPayloadSerializerInterface
{
    const IDENTIFIER = 'openagenda_publish_event';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Pubblicazione di un evento (opencity extraindex)';
    }

    public function getDescription()
    {
        return 'L\'evento viene scatenato alla pubblicazione e all\'aggiornamento di stato un evento. Il payload è compatibile con la funzionalità extra index di opencity';
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
        $payload = $originalPayload;
        if (is_numeric($originalPayload)) {
            $contentObject = eZContentObject::fetch((int)$originalPayload);
            if ($contentObject instanceof eZContentObject) {
                $payload = self::generatePayloads(Content::createFromEzContentObject($contentObject));
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
        return '';
    }

    private static function generatePayloads(Content $content)
    {
        $content = $content->jsonSerialize();
        $payloads = [];
        $metadata = $content['metadata'];
        foreach ($content['data'] as $language => $data) {
            $siteUrl = '/';
            eZURI::transformURI($siteUrl, true, 'full');
            $handler = new OpenPAAgendaPageDataHandler();
            $sourceName = $handler->siteTitle();
            $sourceUri = $siteUrl;
            $eventRemoteId = md5(
                eZINI::instance()->variable(
                    'DatabaseSettings',
                    'Database'
                ) . '_' . $metadata['remoteId'] . '_' . $language
            );
            $eventUri = rtrim($siteUrl, '/') . '/openpa/object/' . $metadata['id'];
            $eventTitle = $data['event_title']['content'];
            $eventShortTitle = $data['short_event_title']['content'];
            $eventAbstract = $data['event_abstract']['content'];
            $eventTimeInterval = $data['time_interval']['content'];
            $eventPublished = strtotime($metadata['published']);
            $eventModified = strtotime($metadata['modified']);
            $eventImage = false;
            foreach ($data['image']['content'] as $image) {
                if ($image['classIdentifier'] == 'image') {
                    $image = eZContentObject::fetch((int)$image['id']);
                    if ($image instanceof eZContentObject) {
                        $imageDataMap = $image->dataMap();
                        if (isset($imageDataMap['image']) && $imageDataMap['image']->hasContent()) {
                            $imageContent = $imageDataMap['image']->content();
                            if ($imageContent instanceof eZImageAliasHandler) {
                                $imageAlias = $imageContent->attribute('original');
                                $url = $imageAlias['full_path'];
                                eZURI::transformURI($url, true, 'full');
                                $eventImage = $url;
                            }
                        }
                    }
                }
            }

            $eventDate = '';
            try {
                $timeInterval = is_array($eventTimeInterval) ? $eventTimeInterval : json_decode(
                    $eventTimeInterval,
                    true
                );
                if (isset($timeInterval['default_value'])) {
                    $from = new DateTime($timeInterval['default_value']['from_time'], new DateTimeZone('Europe/Rome'));
                    $to = new DateTime($timeInterval['default_value']['to_time'], new DateTimeZone('Europe/Rome'));
                    if ($from->format('Ymd') != $to->format('Ymd') && $timeInterval['default_value']['count'] == 1) {
                        $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format(
                                'd/m/Y H:i'
                            ) . '</strong></p>';
                    } elseif ($timeInterval['default_value']['count'] == 1) {
                        $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format(
                                'H:i'
                            ) . '</strong></p>';
                    } elseif ($timeInterval['default_value']['count'] > 1) {
                        $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format(
                                'd/m/Y H:i'
                            ) . ' ' . $timeInterval['text'] . '</strong></p>';
                    }
                }
            } catch (Exception $e) {
            }

            $abstract = $eventDate;
            if (!empty($eventShortTitle)) {
                $abstract .= '<p>' . trim($eventShortTitle) . '</p>';
            }
            $abstract .= trim($eventAbstract);

            $payloads[] = [
                "guid" => $eventRemoteId,
                "language" => $language,
                "source_name" => $sourceName,
                "source_uri" => $sourceUri,
                "uri" => $eventUri,
                "name" => $eventTitle,
                "image" => $eventImage,
                "abstract" => $abstract,
                "class_identifier" => 'event',
                "published_at" => $eventPublished,
                "modified_at" => $eventModified,
            ];
        }

        return $payloads;
    }
}
