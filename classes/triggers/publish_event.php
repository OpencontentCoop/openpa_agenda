<?php

class OpenAgendaPublishEventWebHookTrigger implements OCWebHookTriggerInterface
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

}
