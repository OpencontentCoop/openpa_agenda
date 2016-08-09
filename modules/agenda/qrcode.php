<?php
use Endroid\QrCode\QrCode;

/** @var eZModule $module */
$module = $Params['Module'];
$httpTool = eZHTTPTool::instance();
$NodeId = $Params['NodeId'];
$size = $httpTool->getVariable('size', 300);
$padding = $httpTool->getVariable('padding', 10);

if (is_numeric($NodeId) && OpenPAAgenda::instance()->checkAccess($NodeId)) {

    $cacheFile = $NodeId . '-' . $size . '-' . $padding . '.png';
    $cacheFilePath = eZDir::path(
        array( eZSys::cacheDirectory(), 'openpa_agenda', 'qrcode', $cacheFile )
    );

    $cacheFileHandler = eZClusterFileHandler::instance( $cacheFilePath );
    $cacheFileHandler->processCache(
        function ( $file, $mtime, $identifier ) {
            $content = include( $file );
            return $content;
        },
        function ($file, $args)
        {
            $NodeId = $args['NodeId'];
            $size = $args['size'];
            $padding = $args['padding'];

            $url = 'agenda/event/' . $NodeId;
            eZURI::transformURI($url, false, 'full');
            $qrCode = new QrCode();
            $qrCode
                ->setText($url)
                ->setSize($size)
                ->setPadding($padding)
                ->setErrorCorrection('high')
                ->setForegroundColor(array('r' => 0, 'g' => 0, 'b' => 0, 'a' => 0))
                ->setBackgroundColor(array('r' => 255, 'g' => 255, 'b' => 255, 'a' => 0))
                ->setImageType(QrCode::IMAGE_TYPE_PNG);

            ob_start();
            imagepng($qrCode->getImage());
            $content = ob_get_clean();

            return array(
                'binarydata' => $content,
                'scope' => 'openpa_agenda-cache',
                'datatype' => $qrCode->getContentType(),
                'store' => true
            );
        },
        null,
        null,
        array('NodeId' => $NodeId, 'size' => $size, 'padding' => $padding)
    );;

    header('Content-Type: image/png');
    header( "Last-Modified: " . gmdate( 'D, d M Y H:i:s', $mtime ) . ' GMT' );
    $cacheFileHandler->passthrough();

}
eZExecution::cleanExit();
