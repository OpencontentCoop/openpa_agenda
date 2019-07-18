<?php

/** @var eZModule $module */
$module = $Params['Module'];
$parentNodeId = $Params['ParentNodeId'];

$response = [];

try{
    $parentNode = eZContentObjectTreeNode::fetch((int)$parentNodeId);
    if (!$parentNode instanceof eZContentObjectTreeNode){
        throw new Exception('Parent node not found', 1);
    }

    $input = file_get_contents( "php://input" );
    $data = $_POST;
    if (empty($data)){
        throw new Exception("Empty data", 1);
    }

    if (!$parentNode->canCreate()){
        throw new Exception("Current user can not create place in node $parentNodeId", 1);
    }

    $input = [];
    foreach ($data as $key => $value){
        if (strpos($key, 'place_') !== false){
            $key = str_replace('place_', '', $key);
            $input[$key] = $value;
        }
    }

    $input = array_merge([
        'osm_type_id' => false,
        'address' => false,
        'latitude' => false,
        'longitude' => false,
        'name' => false,
    ], $input);

    if (empty($input['latitude']) || empty($input['longitude']) || empty($input['address'])){
        throw new Exception("Invalid data", 1);
    }

    if (empty($input['name'])){
        $input['name'] = $input['address'];
    }

    if (!empty($input['osm_type_id'])){
        $remoteId = $input['osm_type_id'];
    }else{
        $remoteId = eZRemoteIdUtility::generate('object');
    }

    $insertData = [
        'class_identifier' => 'place',
        'creator_id' => eZUser::currentUserID(),
        'parent_node_id' => $parentNodeId,
        'remote_id' => $remoteId,
        'attributes' => [
            'name' => $input['name'],
            'has_address' => '1|#' . $input['latitude'] . '|#' .$input['longitude'] . '|#' . $input['address']
        ]
    ];

    $object = eZContentObject::fetchByRemoteID($remoteId);
    if (!$object instanceof eZContentObject){
        $states = OpenPAAgenda::instance()->getVisibilityStates();
        if ($states['private'] instanceof eZContentObjectState) {
            $object = eZContentFunctions::createAndPublishObject($insertData);
            $object->assignState($states['private']);
            eZSearch::addObject($object, true);

            $response['status'] = 'success';
            $response['data'] = [
                'id' => $object->attribute('id'),
                'name' => $object->attribute('name')
            ];
        }
    }else{
        $dataMap = $object->dataMap();
        /** @var \eZGmapLocation $hasAddress */
        $hasAddress = $dataMap['has_address']->content();
        $existingData = [
            'place_osm_type_id' => $object->attribute('remote_id'),
            'place_name' => $dataMap['name']->toString(),
            'place_latitude' => (float)$hasAddress->attribute( 'latitude' ),
            'place_longitude' => (float)$hasAddress->attribute( 'longitude' ),
            'place_address' => $hasAddress->attribute( 'address' ),
            'id' => $object->attribute('id'),
            'name' => $object->attribute('name'),
        ];

        $response['status'] = 'wait';
        $response['data'] = [
            'input' => $data,
            'current' => $existingData
        ];
    }

}catch (Exception $e){
    $response['status'] = 'error';
    $response['data'] = $e->getMessage();
}


header('Content-Type: application/json');
echo json_encode($response);

eZExecution::cleanExit();
