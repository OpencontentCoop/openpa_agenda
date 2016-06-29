<?php

$Module = $Params['Module'];
$identifier = $Params['Page'];


$ini = eZINI::instance();
$viewCacheEnabled = ( $ini->variable( 'ContentSettings', 'ViewCaching' ) == 'enabled' );

if ( $viewCacheEnabled )
{
    $cacheFilePath = OpenPAAgendaModuleFunctions::agendaGlobalCacheFilePath( 'info-' . $identifier );
    $cacheFile = eZClusterFileHandler::instance( $cacheFilePath );
    $Result = $cacheFile->processCache( array( 'OpenPAAgendaModuleFunctions', 'agendaCacheRetrieve' ),
                                        array( 'OpenPAAgendaModuleFunctions', 'agendaInfoGenerate' ),
                                        null,
                                        null,
                                        compact( 'Params' ) );
}
else
{    
    $data = OpenPAAgendaModuleFunctions::agendaInfoGenerate( false, compact( 'Params' ) );
    $Result = $data['content']; 
}
return $Result;
