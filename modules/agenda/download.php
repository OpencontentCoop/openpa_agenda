<?php

/** @var eZModule $module */
$Module = $Params['Module'];

$latestProgram = OpenPAAgenda::latestProgram();

if ($latestProgram instanceof eZContentObjectTreeNode){
    try {
        $post = OCEditorialStuffHandler::instance('programma_eventi')->fetchByObjectId($latestProgram->attribute('contentobject_id'));

        $fileHandler = eZBinaryFileHandler::instance();
        $result = $fileHandler->handleDownload( $latestProgram->object(), $post->attribute('file_attribute'), eZBinaryFileHandler::TYPE_FILE );

        if ( $result == eZBinaryFileHandler::RESULT_UNAVAILABLE )
        {
            eZDebug::writeError( "The specified file could not be found." );
            return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
        }

    }catch(Exception $e) {
        eZDebug::writeError( $e->getMessage() );
        return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
    }
}

return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
