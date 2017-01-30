<?php
/** @var eZModule $module */
$module = $Params['Module'];
$httpTool = eZHTTPTool::instance();
$NodeId = $Params['NodeId'];
$size = $httpTool->getVariable('size', 300);
$padding = $httpTool->getVariable('padding', 10);

if (is_numeric($NodeId) && OpenPAAgenda::instance()->checkAccess($NodeId)) {

    $cacheFileHandler = OpenPAAgendaQRCode::getFile($NodeId, $size, $padding);

    header('Content-Type: image/png');
    header( "Last-Modified: " . gmdate( 'D, d M Y H:i:s', $mtime ) . ' GMT' );
    $cacheFileHandler->passthrough();

}
eZExecution::cleanExit();
