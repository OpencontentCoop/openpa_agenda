<?php

use Opencontent\OpenApi\EndpointFactory;

class OpenAgendaCalendarEndpointFactory extends EndpointFactory
{
    public function provideSchemaFactories()
    {
        return [new OpenPaAgendaCalendarSchemaFactory()];
    }

    protected function generateId()
    {
        return 'OpenagendaCalendar';
    }
}
