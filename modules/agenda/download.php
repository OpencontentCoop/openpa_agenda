<?php

/** @var eZModule $module */
$Module = $Params['Module'];

$latestProgram = OpenPAAgenda::latestProgram();

if ($latestProgram instanceof eZContentObjectTreeNode){
    try {
        $post = OCEditorialStuffHandler::instance('programma_eventi')->fetchByObjectId($latestProgram->attribute('contentobject_id'));

        $Module->redirectTo('content/download/' . $latestProgram->object()->attribute('id') . '/' . $post->attribute('file_attribute')->attribute('id') . '/file/agenda.pdf' );
        return;

    }catch(Exception $e) {
        eZDebug::writeError( $e->getMessage() );
        return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
    }
}

return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
