<?php

use Opencontent\OpenApi\SchemaFactory;
use erasys\OpenApi\Spec\v3 as OA;

class OpenPaAgendaCalendarSchemaFactory extends SchemaFactory
{
    public function generateSchema()
    {
        $schema = new OA\Schema();
        $schema->title = 'Calendar';
        $schema->type = 'array';
        $schema->items = [
            'type' => 'object',
            'properties' => [
                'date' => [
                    'type' => 'string',
                ],
                'has_events' => [
                    'type' => 'boolean',
                ]
            ]
        ];

        return $schema;
    }

    public function generateRequestBody()
    {
        // TODO: Implement generateRequestBody() method.
    }

    public function serialize()
    {
        // TODO: Implement serialize() method.
    }

}
