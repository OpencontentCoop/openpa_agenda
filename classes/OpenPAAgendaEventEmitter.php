<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\Exception\EnvironmentForbiddenException;
use Opencontent\Opendata\Api\Exception\EnvironmentMisconfigurationException;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAAgendaEventEmitter
{
    public static function triggerPublishEvent(OCEditorialStuffPostInterface $post)
    {
        self::trigger(OpenAgendaPublishEventWebHookTrigger::IDENTIFIER, $post, 'extraindex');
        self::trigger(OpenAgendaPublishUpdateEventWebHookTrigger::IDENTIFIER, $post, 'ocopendata');
    }

    public static function triggerDeleteEvent(OCEditorialStuffPostInterface $post)
    {
        self::trigger(OpenAgendaDeleteEventWebHookTrigger::IDENTIFIER, $post, 'extraindex');
        self::trigger(OpenAgendaPublishUpdateEventWebHookTrigger::IDENTIFIER, $post, 'ocopendata');
    }

    private static function trigger($event, $post, $payloadFormat)
    {
        if (class_exists('OCWebHookEmitter')) {
            $payloads = self::getPayload($post, $payloadFormat);
            if (is_array($payloads)) {
                foreach ($payloads as $payload) {
                    OCWebHookEmitter::emit(
                        $event,
                        $payload,
                        OCWebHookQueue::defaultHandler()
                    );
                }
            }
        }
    }

    /**
     * @param OCEditorialStuffPost|AgendaItem $post
     * @param $format
     * @return array|false
     */
    private static function getPayload(OCEditorialStuffPostInterface $post, $format)
    {
        try {
            $content = Content::createFromEzContentObject($post->getObject());
            if ($format === 'ocopendata') {
                try {
                    $environment = EnvironmentLoader::loadPreset('content');
                    return [$environment->filterContent($content)];

                }catch (EnvironmentForbiddenException $e){
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    return false;

                }catch (EnvironmentMisconfigurationException $e){
                    eZDebug::writeError($e->getMessage(), __METHOD__);
                    return false;
                }
            }

            $content = $content->jsonSerialize();
            $payloads = [];
            $metadata = $content['metadata'];
            foreach ($content['data'] as $language => $data) {
                $siteUrl = '/';
                eZURI::transformURI($siteUrl, true, 'full');
                $handler = new OpenPAAgendaPageDataHandler();
                $sourceName = $handler->siteTitle();
                $sourceUri = $siteUrl;
                $eventRemoteId = md5(eZINI::instance()->variable('DatabaseSettings', 'Database') . '_' . $metadata['remoteId'] . '_' . $language);
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
                    $timeInterval = is_array($eventTimeInterval) ? $eventTimeInterval : json_decode($eventTimeInterval, true);
                    if (isset($timeInterval['default_value'])) {
                        $from = new DateTime($timeInterval['default_value']['from_time'], new DateTimeZone('Europe/Rome'));
                        $to = new DateTime($timeInterval['default_value']['to_time'], new DateTimeZone('Europe/Rome'));
                        if ($from->format('Ymd') != $to->format('Ymd') && $timeInterval['default_value']['count'] == 1) {
                            $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format('d/m/Y H:i') . '</strong></p>';
                        } elseif ($timeInterval['default_value']['count'] == 1) {
                            $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format('H:i') . '</strong></p>';
                        } elseif ($timeInterval['default_value']['count'] > 1) {
                            $eventDate = '<p><strong>' . $from->format('d/m/Y H:i') . ' - ' . $to->format('d/m/Y H:i') . ' ' . $timeInterval['text'] . '</strong></p>';
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

        } catch (Exception $e) {
            eZDebug::writeError($e->getMessage(), __METHOD__);
        }

        return false;
    }
}
