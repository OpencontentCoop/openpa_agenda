<?php
/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$NodeId = $Params['NodeId'];
$Client = $Params['Client'];
$data = null;

try {

    $pusher = OpenPAAgendaPushClientLoader::instance($Client);

    $post = null;
    if (is_numeric($NodeId) && OpenPAAgenda::instance()->checkAccess($NodeId)) {
        $node = eZContentObjectTreeNode::fetch($NodeId);
        if ($node instanceof eZContentObjectTreeNode ) {

            if ($node->attribute('class_identifier') == 'event') {
                $post = OCEditorialStuffHandler::instance('agenda')
                    ->getFactory()
                    ->instancePost(array('object_id' => $node->attribute('contentobject_id')));
            }

            if ($node->attribute('class_identifier') == 'associazione') {
                $post = OCEditorialStuffHandler::instance('associazione')
                    ->getFactory()
                    ->instancePost(array('object_id' => $node->attribute('contentobject_id')));
            }
        }else{
            throw new Exception("Node not found");
        }
    }
    if (!$post instanceof OCEditorialStuffPost){
        throw new Exception("Post type unhandled");
    }

    if ($http->hasGetVariable('convert')){
        try {
            $data = $pusher->convert($post);
        } catch (Exception $e) {
            $data = array(
                'result' => 'error',
                'error' => $e->getMessage(),
                'error_trace' => $e->getTraceAsString()
            );
        }
    }else {
        try {
            $data = array(
                'result' => 'success',
                'data' => $pusher->push($post)
            );
        } catch (Exception $e) {
            $data = array(
                'result' => 'error',
                'error' => $e->getMessage(),
                'error_trace' => $e->getTraceAsString()
            );
        }
    }

} catch (Exception $e) {
    $data = array(
        'result' => 'error',
        'error' => $e->getMessage(),
        'error_trace' => $e->getTraceAsString()
    );
}

if (eZHTTPTool::instance()->hasGetVariable('debug')) {
    echo '<pre>';
    print_r($data);
    echo '</pre>';
    eZDisplayDebug();
}else{
    header('Content-Type: application/json');
    header('HTTP/1.1 200 OK');
    echo json_encode($data);
}

eZExecution::cleanExit();
