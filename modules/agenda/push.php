<?php
/** @var eZModule $module */
$module = $Params['Module'];
$httpTool = eZHTTPTool::instance();
$NodeId = $Params['NodeId'];
$data = null;
try {
    if (is_numeric($NodeId) && OpenPAAgenda::instance()->checkAccess($NodeId)) {
        $node = eZContentObjectTreeNode::fetch($NodeId);
        if ($node instanceof eZContentObjectTreeNode && $node->attribute('class_identifier') == 'event') {

            $client = new OpenPAAgendaTCUHttpClient();
            $data = array(
                'result' => 'success',
                'data' => $client->push($node)
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
