<?php

class OpenAgendaDeleteEventWebHookTrigger implements OCWebHookTriggerInterface, OCWebHookCustomEndpointSerializerInterface
{
    const IDENTIFIER = 'openagenda_delete_event';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Spubblicazione di un evento (opencity extraindex)';
    }

    public function getDescription()
    {
        return 'L\'evento viene scatenato alla rimozione e all\'aggiornamento di stato  di un evento.
        Il payload è compatibile con la funzionalità extra index di opencity (esempio endpoint: DELETE https://opencity.example.com/api/extraindex/v1/document/{{guid}})';
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
        eZDebug::writeError(var_export([$originalEndpoint, $originalPayload, str_replace('{{id}}', $originalPayload['guid'], $originalEndpoint)], 1), __METHOD__);
        $originalEndpoint = str_replace('{{id}}', '{{guid}}', $originalEndpoint);

        return str_replace('{{guid}}', $originalPayload['guid'], $originalEndpoint);
    }

}
