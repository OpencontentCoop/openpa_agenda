<?php

class OpenAgendaDeleteEventLinkWebHookTrigger implements OCWebHookTriggerInterface,
                                                         OCWebHookCustomEndpointSerializerInterface,
                                                         OCWebHookCustomPayloadSerializerInterface
{
    const IDENTIFIER = 'openagenda_delete_event_link';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Spubblicazione di un placeholder evento';
    }

    public function getDescription()
    {
        return 'L\'evento viene scatenato alla rimozione e all\'aggiornamento di stato  di un evento.';
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

    public function serializeCustomEndpoint($originalEndpoint, $originalPayload, OCWebHook $webHook)
    {
        if (is_numeric($originalPayload)) {
            eZContentObject::clearCache();
            $contentObject = eZContentObject::fetch((int)$originalPayload);
            if ($contentObject instanceof eZContentObject) {
                $originalPayload = $contentObject->attribute('remote_id');
            }
        }
        return str_replace('{{id}}', $originalPayload, $originalEndpoint);
    }

    public function serializeCustomPayload($originalPayload, OCWebHook $webHook)
    {
        return [
            'original-id' => $originalPayload,
        ];
    }

    public function getPlaceholders()
    {
        return [];
    }

    public function getHelpText()
    {
        return '';
    }


}
