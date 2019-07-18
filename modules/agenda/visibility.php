<?php

/** @var eZModule $module */
$module = $Params['Module'];
$objectId = $Params['ID'];
$visibility = $Params['Visibility'];

$object = eZContentObject::fetch((int)$objectId);
if ($object instanceof eZContentObject && $object->canEdit()){
    $stateGroup = eZContentObjectStateGroup::fetchByIdentifier('privacy');
    if ($stateGroup instanceof eZContentObjectStateGroup){
        $state = $stateGroup->stateByIdentifier($visibility);
        if ($state instanceof eZContentObjectState){
            if ($object->assignState($state)){
                $object->setAttribute('modified', time());
                $object->store();
                eZSearch::addObject($object, true);
                // reindicizza gli eventi che hanno questo luogo selezionato
                $reverseList = $object->reverseRelatedObjectList();
                foreach ($reverseList as $reverse){
                    eZSearch::addObject($reverse, true);
                }
                $data = 'success';
            }
        }else{
            $data = 'error: state not found';
        }
    }else{
        $data = 'error: state group not found';
    }
}else{
    $data = 'error: object not found or current user does not have sufficient permissions';
}

header('Content-Type: application/json');
echo json_encode($data);

eZExecution::cleanExit();

