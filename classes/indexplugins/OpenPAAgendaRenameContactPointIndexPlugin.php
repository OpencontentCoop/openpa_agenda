<?php

class OpenPAAgendaRenameContactPointIndexPlugin implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        if ($contentObject->attribute('class_identifier') === 'private_organization') {
            $remoteId = HasOnlineContactPointConnector::generateRemoteId((int)$contentObject->attribute('id'));
            $contactPoint = eZContentObject::fetchByRemoteID($remoteId);
            if ($contactPoint instanceof eZContentObject && $contactPoint->attribute('name') === 'Contatti Nuovo Organizzazione privata') {
                $name = 'Contatti ' . $contentObject->attribute('name');
                $contactPointDataMap = $contactPoint->dataMap();
                if (isset($contactPointDataMap['name'])){
                    $contactPointDataMap['name']->fromString($name);
                    $contactPointDataMap['name']->store();
                }
                $contactPoint->setName($name);
                $contactPoint->store();
                eZSearch::addObject($contactPoint);
            }
        }
    }
}
