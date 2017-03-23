<?php

require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "Aggiornamento a agenda 1.5" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();

$options = $script->getOptions();

$createMissing = true;

$script->initialize();
$script->setUseDebugAccumulators( true );
try
{
    $agendaCalendarClassIdentifier = 'agenda_calendar';
    $agendaCalendarClass = eZContentClass::fetchByIdentifier($agendaCalendarClassIdentifier);
    if (!$agendaCalendarClass instanceof eZContentClass){
        $tools = new OpenPAClassTools( $agendaCalendarClassIdentifier, true ); // creo se non esiste
        $tools->sync( true, true ); // forzo e rimuovo attributi in più
    }
    
    $section = OpenPABase::initSection(
        OpenPAAgenda::SECTION_NAME,
        OpenPAAgenda::SECTION_IDENTIFIER,
        OpenPAAppSectionHelper::NAVIGATION_IDENTIFIER
    );
    
    $rootObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() );
    
    $params = array(
        'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
        'section_id' => $section->attribute( 'id' ),
        'remote_id' => OpenPAAgenda::rootRemoteId() . '_calendars',
        'class_identifier' => 'folder',
        'attributes' => array(
            'name' => 'Calendari tematici',
            'tags' => $agendaCalendarClassIdentifier            
        )
    );
        
    /** @var eZContentObject $containerObject */
    $containerObject = eZContentFunctions::createAndPublishObject( $params );
    if( !$containerObject instanceof eZContentObject )
    {
        throw new Exception( 'Failed creating Programs container node' );
    }
    
    $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::externalUsersGroupRemoteId() );
    if ( !$groupObject instanceof eZContentObject )
    {
        $params = array(
            'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
            'section_id' => $section->attribute( 'id' ),
            'remote_id' => OpenPAAgenda::externalUsersGroupRemoteId(),
            'class_identifier' => 'user_group',
            'attributes' => array(
                'name' => 'Utenti esterni'
            )
        );
        /** @var eZContentObject $groupObject */
        $groupObject = eZContentFunctions::createAndPublishObject( $params );
        if( !$groupObject instanceof eZContentObject )
        {
            throw new Exception( 'Failed creating Moderatori group node' );
        }
    }
    
    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}


$roles = array(
    "Agenda Anonymous" => array(            
        array(
            'ModuleName' => 'content',
            'FunctionName' => 'read',
            'Limitation' => array(
                'Class' => array(
                    eZContentClass::classIDByIdentifier( 'agenda_calendar' ),
                    eZContentClass::classIDByIdentifier( 'iniziativa' ),
                ),
                'Section' => $section->attribute( 'id' )
            )
        ),                
    ),
    "Agenda Associations" => array(
         array(
            'ModuleName' => 'content',
            'FunctionName' => 'read',
            'Limitation' => array(
                'Class' => array(
                    eZContentClass::classIDByIdentifier( 'agenda_calendar' ),
                    eZContentClass::classIDByIdentifier( 'iniziativa' ),
                ),
                'Section' => $section->attribute( 'id' )
            )
        ),
        array(
            'ModuleName' => 'content',
            'FunctionName' => 'create',
            'Limitation' => array(
                'Class' => array(
                    eZContentClass::classIDByIdentifier( 'iniziativa' )
                ),
                'Section' => $section->attribute( 'id' ),
                'ParentClass' => array(
                    eZContentClass::classIDByIdentifier( 'event_calendar' )
                )
            )
        ),
         array(
            'ModuleName' => 'content',
            'FunctionName' => 'edit',
            'Limitation' => array(
                'Class' => array(
                    eZContentClass::classIDByIdentifier( 'image' ),
                    eZContentClass::classIDByIdentifier( 'iniziativa' )
                ),
                'Owner' => 1,
            )
        ),
    )
);