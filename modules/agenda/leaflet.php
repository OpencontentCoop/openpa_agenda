<?php

$module = $Params['Module'];

$object = eZContentObject::fetch((int)$Params['Id']);
if (!$object instanceof eZContentObject) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
if (!$object->attribute('can_read')) {
    return $module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
}
try {
    $handler = OCEditorialStuffHandler::instance('programma_eventi');
    /** @var ProgrammaEventiItem $post */
    $post = $handler->fetchByObjectId($object->attribute('id'));

    $layouts = $post->attribute('layouts');
    $currentLayout = eZHTTPTool::instance()->variable('layout', $layouts[0]['id']);
    foreach ($layouts as $layout) {
        if ($layout['id'] == $currentLayout) {
            $currentLayout = $layout;
        }
    }

    $debug = isset($_GET['debug']);

    $data = $post->generatePdf($currentLayout, $debug);
    if (!$debug) {
        $size = strlen($data);
        ob_clean();
        header("Pragma: ");
        header("Cache-Control: ");
        header("Last-Modified: ");
        header("Expires: " . gmdate('D, d M Y H:i:s', time() + 1) . ' GMT');
        header('Content-Type: application/pdf');
        header('Content-Disposition: inline; filename="Preview"');
        header('Content-Length: ' . $size);
        header('Content-Transfer-Encoding: binary');
        header('Accept-Ranges: bytes');
        ob_end_clean();
    }

    echo $data;

    eZExecution::cleanExit();

} catch (Exception $e) {
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
