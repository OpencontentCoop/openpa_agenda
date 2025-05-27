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
        $content = Content::createFromEzContentObject($contentObject);
        return [
            'metadata' => [
                'remoteId' => $content->metadata->remoteId,
                'languages' => $content->metadata->languages,
                'parentNodes' => [$headers['X-Target-Node'] ?? 2],
                'classIdentifier' => 'event_link',
            ],
            'data' => [],
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
