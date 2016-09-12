<?php

$module = $Params['Module'];

$tpl = eZTemplate::factory();
$tpl->setVariable( 'agenda_home', true );
$tpl->setVariable( 'access_path', eZSys::indexDir() );
$tpl->setVariable( 'current_language', eZLocale::currentLocaleCode() );
$tpl->setVariable( 'current_user', eZUser::currentUser() );
$tpl->setVariable( 'site_identifier', OpenPABase::getCurrentSiteaccessIdentifier() );
$tpl->setVariable( 'calendar_node_id', OpenPAAgenda::calendarNodeId() );

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
