<?php

$id = $Params['Id'];
$current = $Params['Current'];

$object = eZContentObject::fetch($id);

if ($object instanceof eZContentObject && $object->attribute('can_edit')){

    $stateGroupIdentifier = OpenPAAgenda::$stateGroupIdentifier;
    $stateIdentifiers = OpenPAAgenda::$stateIdentifiers;
    $states = OpenPABase::initStateGroup($stateGroupIdentifier, $stateIdentifiers);

    $statesKeys = array_keys($states);
    $key = (int)array_search($stateGroupIdentifier.'.'.$current, $statesKeys);
    ++$key;
    $offset = $key == count($statesKeys) ? 0 : $key;
    $statesKey = $statesKeys[$offset];
    $newState = $states[$statesKey];
    eZContentOperationCollection::updateObjectState($id, array($newState->attribute('id')));
    $newStateIdentifiers = $object->attribute('state_identifier_array');
    foreach($newStateIdentifiers as $newStateIdentifier){
        list($group,$identifier) = explode('/', $newStateIdentifier);
        if ($group == $stateGroupIdentifier){
            echo $identifier;
        }
    }
}
else{
    echo $current;
}

eZExecution::cleanExit();