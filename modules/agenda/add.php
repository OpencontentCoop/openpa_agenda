<?php

use Opencontent\Opendata\Api\ContentRepository;

$module = $Params['Module'];
$class = $Params['Class'];

$data = array();

try {
    header('HTTP/1.1 200 OK');
    if ($class == 'iniziativa') {
        $struct = array(
            'metadata' => array(
                'classIdentifier' => 'iniziativa',
                'creatorId' => eZUser::currentUserID(),
                'parentNodes' => OpenPAAgenda::instance()->calendarNodeId()
            ),
            'data' => array(
                'titolo' => eZHTTPTool::instance()->postVariable('titolo', null),
                'abstract' => eZHTTPTool::instance()->postVariable('abstract', null),
                'argomento' => array(eZUser::currentUserID())
            )
        );

        $contentRepository = new ContentRepository();
        $data = $contentRepository
            ->setCurrentEnvironmentSettings(new DefaultEnvironmentSettings())
            ->create($struct);
    }else{
        throw new Exception("Class not allowed");
    }
} catch (Exception $e) {
    header('HTTP/1.1 500 Internal Server Error');
    $data = array('error' => $e->getMessage());
}

header('Content-Type: application/json');
echo json_encode($data);
eZExecution::cleanExit();
