<?php

$module = $Params['Module'];

$tpl = eZTemplate::factory();
$tpl->setVariable( 'agenda_home', true );
$tpl->setVariable( 'access_path', eZSys::indexDir() );
$tpl->setVariable( 'current_language', eZLocale::currentLocaleCode() );

$currentUser = eZUser::currentUser();

$ini = eZINI::instance();
$viewCacheEnabled = ( $ini->variable( 'ContentSettings', 'ViewCaching' ) == 'enabled' );

if ( $viewCacheEnabled )
{

    $cacheFilePath = OpenPAAgendaModuleFunctions::agendaGlobalCacheFilePath( $currentUser->isAnonymous() ? 'home-anon' : 'home' );
    $cacheFile = eZClusterFileHandler::instance( $cacheFilePath );
    $Result = $cacheFile->processCache(
        array( 'OpenPAAgendaModuleFunctions', 'agendaCacheRetrieve' ),
        array( 'OpenPAAgendaModuleFunctions', 'agendaHomeGenerate' ),
        null,
        null,
        compact( 'Params' ) );
}
else
{
    $data = OpenPAAgendaModuleFunctions::agendaHomeGenerate( false, compact( 'Params' ) );
    $Result = $data['content'];
}
return $Result;
