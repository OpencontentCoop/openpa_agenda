<?php

use Opencontent\OpenApi\OperationFactory\ContentObject\PayloadBuilder;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;
use Opencontent\Opendata\Api\Values\Content;

class NextScheduledEventsFactoryProvider extends ContentMetaPropertyFactory
{
    public function providePropertyIdentifier()
    {
        return 'next_schedule';
    }

    public function provideProperties()
    {
        return [
            "type" => "array",
            "description" => 'Schedule for next events',
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
        $nextEvents = [];
        $now = time();
        if (isset($content->data[$locale][$identifier])) {
            $events = $content->data[$locale][$identifier]['content']['events'];
            foreach ($events as $event){
                $start = explode('-', $event['id'])[0];
                if ($start >= $now){
                    $nextEvents[] = $event;
                }
            }
        }

        return $nextEvents;
    }

    public function serializePayload(PayloadBuilder $payloadBuilder, array $payload, $locale)
    {
    }
}
