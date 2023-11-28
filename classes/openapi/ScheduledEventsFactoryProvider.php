<?php

use Opencontent\OpenApi\OperationFactory\ContentObject\PayloadBuilder;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;
use Opencontent\Opendata\Api\Values\Content;

class ScheduledEventsFactoryProvider extends ContentMetaPropertyFactory
{
    public function providePropertyIdentifier()
    {
        return 'schedule';
    }

    public function provideProperties()
    {
        return [
            "type" => "array",
            "description" => 'Schedule for all repeating events',
            "default" => true,
            "readOnly" => true,
            "items" => [
                "type" => "object",
                "properties" => [
                    "id" => [
                        "type" => "string",
                    ],
                    "from" => [
                        "type" => "string",
                        "format" => "date-time"
                    ],
                    "to" => [
                        "type" => "string",
                        "format" => "date-time"
                    ],
                ],
            ],
        ];
    }

    public function serializeValue(Content $content, $locale)
    {
        $identifier = 'time_interval';
        if (isset($content->data[$locale][$identifier])) {
            return $content->data[$locale][$identifier]['content']['events'];
        }

        return [];
    }

    public function serializePayload(PayloadBuilder $payloadBuilder, array $payload, $locale)
    {
    }
}
