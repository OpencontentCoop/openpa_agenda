<?php

use Endroid\QrCode\QrCode;

class OpenPAAgendaQRCode
{
    /**
     * @param $NodeId
     * @param int $size
     * @param int $padding
     *
     * @return eZClusterFileHandlerInterface
     */
    public static function getFile($NodeId, $size = 300, $padding = 10)
    {
        $cacheFile = $NodeId . '-' . $size . '-' . $padding . '.png';
        $cacheFilePath = eZDir::path(
            array( eZSys::cacheDirectory(), 'openpa_agenda', 'qrcode', $cacheFile )
        );

        $cacheFileHandler = eZClusterFileHandler::instance( $cacheFilePath );
        $cacheFileHandler->processCache(
            function ( $file, $mtime, $identifier ) {
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
        );

        return $cacheFileHandler;
    }
}
