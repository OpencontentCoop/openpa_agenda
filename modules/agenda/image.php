<?php
/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$ObjectId = $Params['ObjectId'];
$object = eZContentObject::fetch($ObjectId);
if ($object instanceof eZContentObject && $object->canRead()){
    /** @var eZContentObjectAttribute[] $dataMap */
    $dataMap = $object->dataMap();
    if (isset($dataMap['image']) && $dataMap['image']->hasContent()){
        /** @var eZImageAliasHandler $image */
        $image = $dataMap['image']->content();
        $alias = $image->imageAlias('large');
        if (isset($alias['full_path'])) {
            $file = eZClusterFileHandler::instance($alias['full_path']);
            if ($file->exists()) {

                $filesize = $file->size();
                $mtime = $file->mtime();
                $datatype = $file->dataType();

                header( "Content-Type: {$datatype}" );
                header( "Connection: close" );
                header( 'Served-by: ' . $_SERVER["SERVER_NAME"] );
                header( "Last-Modified: " . gmdate( 'D, d M Y H:i:s', $mtime ) . ' GMT' );
                header( "ETag: $mtime-$filesize" );
                header( "Cache-Control: max-age=2592000 s-max-age=2592000" );

                $file->passthrough();
                eZExecution::cleanExit();
            }else{
                $message = 'File not found';
            }
        }else{
            $message = 'Alias path not found';
        }
    }else{
        $message = 'Datamap image not found';
    }
}else{
    $message = 'User con not read this content';
}

header( $_SERVER['SERVER_PROTOCOL'] . " 500 Internal Server Error" );
echo <<<EOF
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>500 Internal Server Error</title>
</head><body>
<h1>$message</h1>
</body></html>
EOF;
eZExecution::cleanExit();
