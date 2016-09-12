<?php

$programmi = eZContentObjectTreeNode::subTreeByNodeID(array(
    'SortBy' => array('published', false),
    'ClassFilterType' => 'include',
    'ClassFilterArray' => array('programma_eventi'),
    'Limit' => 1
), OpenPAAgenda::programNodeId());

if (isset($programmi[0]) && $programmi[0] instanceof eZContentObjectTreeNode){
    /** @var eZContentObjectTreeNode $current */
    $current = $programmi[0];
    try {
        $post = OCEditorialStuffHandler::instance('programma_eventi')->fetchByObjectId($current->attribute('contentobject_id'));

        $fileHandler = eZBinaryFileHandler::instance();
        $result = $fileHandler->handleDownload( $current->object(), $post->attribute('file_attribute'), eZBinaryFileHandler::TYPE_FILE );

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
