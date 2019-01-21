<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;

$Module = $Params['Module'];
$Environment = 'fullcalendar';
$Filters = isset($_GET['filters']) ? $_GET['filters'] : array();
$Query = '';
foreach ($Filters as $filter) {
    if (is_array($filter)) {
        foreach ($filter as $item) {
            if (isset($item['field'])
                && isset($item['operator'])
                && isset($item['value'])
                && is_array($item['value'])) {
                $Query .= $item['field'] . ' ' . $item['operator'] . ' [\'' . implode("','", $item['value']) . '\'] and ';
            }
        }
    }
}
if (!OpenPAAgendaOperators::currentUserIsAgendaModerator()) {
    //$Query .= "owner_id = '" . eZUser::currentUserID() . "' ";
}
$Query .= "classes [" . OpenPAAgenda::instance()->getEventClassIdentifier() . "] subtree [" . OpenPAAgenda::calendarNodeId() . "] sort [published=>desc]";

try {
    $contentSearch = new ContentSearch();

    $currentEnvironment = EnvironmentLoader::loadPreset($Environment);
    $contentSearch->setEnvironment($currentEnvironment);

    $parser = new ezpRestHttpRequestParser();
    $request = $parser->createRequest();
    $currentEnvironment->__set('request', $request);
    $data = (array)$contentSearch->search($Query, array());

} catch (Exception $e) {

    $data = array(
        'error_code' => $e->getCode(),
        'error_message' => $e->getMessage()
    );
    if ($Debug) {
        $data['file'] = $e->getFile();
        $data['line'] = $e->getLine();
        $data['trace'] = $e->getTraceAsString();
    }
}

header('Content-Type: application/json');
echo json_encode($data);

eZExecution::cleanExit();

