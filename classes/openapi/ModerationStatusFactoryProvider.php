<?php

use Opencontent\OpenApi\OperationFactory\ContentObject\PayloadBuilder;
use Opencontent\OpenApi\SchemaFactory\ContentMetaPropertyFactory;
use Opencontent\Opendata\Api\Values\Content;

class ModerationStatusFactoryProvider extends ContentMetaPropertyFactory
{
    public function providePropertyIdentifier()
    {
        return 'need_moderation';
    }

    public function provideProperties()
    {
        return [
            "type" => "boolean",
            "description" => 'Moderation status of the content',
            "default" => true,
            "readOnly" => true,
        ];
    }

    public function serializeValue(Content $content, $locale)
    {
        $stateIdentifiers = $content->metadata->stateIdentifiers;

        return !in_array('moderation.accepted', $stateIdentifiers)
            && !in_array('moderation.skipped', $stateIdentifiers);
    }

    public function serializePayload(PayloadBuilder $payloadBuilder, array $payload, $locale)
    {
        if (isset($payload[$this->providePropertyIdentifier()])) {
            $isAccepted = (bool)$payload[$this->providePropertyIdentifier()];
            if ($isAccepted) {
                $payloadBuilder->setStateIdentifier('privacy.accepted');
            } else {
                $payloadBuilder->setStateIdentifier('privacy.refused');
            }
        }
    }
}
