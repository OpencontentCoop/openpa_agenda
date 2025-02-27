<?php

class OpenPAAgendaEventCollectionIndexPlugin implements ezfIndexPlugin
{
    private static $key = 'extra_event_collection_i';

    private static $patched = [];

    public function modify(eZContentObject $contentObject, &$docList)
    {
        if ($contentObject->attribute('class_identifier') === 'event') {
            $dataMap = $contentObject->dataMap();
            $states = OpenPABase::initStateGroup(
                OpenPAAgenda::$stateGroupIdentifier,
                OpenPAAgenda::$stateIdentifiers
            );
            $skipped = (int)$states['moderation.skipped']->attribute('id');
            $accepted = (int)$states['moderation.accepted']->attribute('id');


            if (isset($dataMap['sub_event_of']) && $dataMap['sub_event_of']->hasContent()) {
                $objects = OpenPABase::fetchObjects(explode('-', $dataMap['sub_event_of']->toString()));
                $isAccepted = in_array($skipped, $contentObject->stateIDArray()) || in_array($accepted, $contentObject->stateIDArray());
                foreach ($objects as $object) {
                    if ($isAccepted){
                        $this->patchEventAsCollection($object);
                    } else {
                        eZSearch::addObject($object);
                    }
                }
            }

            $toContentobjectId = (int)$contentObject->attribute('id');
            $contentClassAttributeId = (int)eZContentClassAttribute::classAttributeIDByIdentifier('event/sub_event_of');
            $query = "SELECT COUNT( outer_object.id ) AS count
                FROM ezcontentobject outer_object, ezcontentobject inner_object, ezcontentobject_link outer_link
                INNER JOIN ezcontentobject_link inner_link ON outer_link.id = inner_link.id
                WHERE outer_object.id = outer_link.from_contentobject_id
                    AND outer_object.status = 1
                    AND inner_object.id = inner_link.from_contentobject_id
                    AND inner_object.status = 1
                    AND inner_link.to_contentobject_id = $toContentobjectId
                    AND inner_link.from_contentobject_version = inner_object.current_version
                    AND inner_link.contentclassattribute_id = $contentClassAttributeId
                    AND ( inner_link.relation_type & 8 ) <> 0
                    AND inner_object.id IN (
                        SELECT contentobject_id
                            FROM ezcobj_state_link
                            WHERE contentobject_state_id in ($skipped,$accepted)
                    )";
            $reverseRelationsCount = eZDB::instance()->arrayQuery($query)[0]['count'] ?? 0;
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
        if (isset(self::$patched[$contentObject->attribute('id')])) {
            return;
        }
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
                eZDebug::writeDebug('Patch object ' . $contentObject->attribute('id'), __METHOD__ . ' tries ' . $tries);
                self::$patched[$contentObject->attribute('id')] = true;
                break;
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
    }

}
