<?php

class OpenPAAgendaEventCollectionIndexPlugin implements ezfIndexPlugin
{
    private static $key = 'extra_event_collection_i';

    public function modify(eZContentObject $contentObject, &$docList)
    {
        $dataMap = $contentObject->dataMap();
        if (isset($dataMap['sub_event_of']) && $dataMap['sub_event_of']->hasContent()) {
            $objects = OpenPABase::fetchObjects(explode('-', $dataMap['sub_event_of']->toString()));
            foreach ($objects as $object) {
                $this->patchEventAsCollection($object);
            }
        }
        if ($contentObject->attribute('class_identifier') === 'event') {
            $reverseRelationsCount = $contentObject->reverseRelatedObjectCount(
                false,
                eZContentClassAttribute::classAttributeIDByIdentifier('event/sub_event_of'),
                [
                    'AllRelations' => eZContentFunctionCollection::contentobjectRelationTypeMask(['attribute']),
                ]
            );
            $version = $contentObject->currentVersion();
            if ($version === false) {
                return;
            }
            $availableLanguages = $version->translationList(false, false);
            $value = (int)($reverseRelationsCount > 0);
            foreach ($availableLanguages as $languageCode) {
                if ($docList[$languageCode] instanceof eZSolrDoc) {
                    $doc = $docList[$languageCode]->Doc;
                    if ($doc instanceof DOMDocument) {
                        $xpath = new DomXpath($doc);
                        if ($xpath->evaluate('//field[@name="' . self::$key . '"]')->length == 0) {
                            $docList[$languageCode]->addField(self::$key, $value);
                        }
                    } elseif (is_array($doc) && !isset($doc[self::$key])) {
                        $docList[$languageCode]->addField(self::$key, $value);
                    }
                }
            }
        }
    }

    private function patchEventAsCollection(eZContentObject $contentObject): void
    {
        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }
        $availableLanguages = $version->translationList(false, false);

        $solr = new eZSolr();
        $collectedData = [];
        foreach ($availableLanguages as $languageCode) {
            $collectedData[$languageCode] = [
                'meta_guid_ms' => $solr->guid((int)$contentObject->attribute('id'), $languageCode),
            ];
            $collectedData[$languageCode][self::$key] = [
                'set' => 1,
            ];
        }

        $data = [];
        foreach ($collectedData as $values) {
            $data[] = $values;
        }
        $postData = json_encode($data);

        $errorMessage = 'Error updating solr data';
        $solrBase = new \eZSolrBase();
        $maxRetries = (int)\eZINI::instance('solr.ini')->variable('SolrBase', 'ProcessMaxRetries');
        \eZINI::instance('solr.ini')->setVariable('SolrBase', 'ProcessTimeout', 60);
        if ($maxRetries < 1) {
            $maxRetries = 1;
        }
        $commitParam = 'true';
        $tries = 0;
        while ($tries < $maxRetries) {
            try {
                $tries++;
                $solrBase->sendHTTPRequest(
                    $solrBase->SearchServerURI . '/update?commit=' . $commitParam,
                    $postData,
                    'application/json',
                    'OpenAgenda'
                );
            } catch (\ezfSolrException $e) {
                $doRetry = false;
                $errorMessage = $e->getMessage();
                switch ($e->getCode()) {
                    case \ezfSolrException::REQUEST_TIMEDOUT : // Code error 28. Server is most likely overloaded
                    case \ezfSolrException::CONNECTION_TIMEDOUT : // Code error 7, same thing
                        $errorMessage .= ' // Retry #' . $tries;
                        $doRetry = true;
                        break;
                }

                if (!$doRetry) {
                    break;
                }
                eZDebug::writeError($errorMessage);
            }
        }
        eZDebug::writeDebug('Patch object ' . $contentObject->attribute('id'), __METHOD__ . ' tries ' . $tries);
    }

}
