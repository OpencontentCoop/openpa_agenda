<?php

if (!interface_exists('OCWebHookTriggerInterface')){
    interface OCWebHookTriggerInterface{}
}

class OpenAgendaPublishUpdateEventWebHookTrigger implements OCWebHookTriggerInterface
{
    const IDENTIFIER = 'openagenda_publish_update_content';

    public function getIdentifier()
    {
        return self::IDENTIFIER;
    }

    public function getName()
    {
        return 'Pubblicazione o aggiornamento di un evento';
    }

    public function getDescription()
    {
        return 'L\'evento viene scatenato alla pubblicazione, alla rimozione e all\'aggiornamento di un evento. Il payload è un OCOpenData API Content object (http://bit.ly/ocopendata-api)';
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
