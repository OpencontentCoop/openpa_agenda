<?php

class OpenPAAgendaInstaller implements OpenPAInstaller
{

    protected $options = array();
    protected $steps = array(
        'a' => '[a] alberatura',
        'r' => '[r] ruoli'
    );
    protected $installOnlyStep;

    public function setScriptOptions(eZScript $script)
    {
        return $script->getOptions(
            '[parent-node:][step:][sa_suffix:]',
            '',
            array(
                'parent-node' => 'Nodo id contenitore di agenda (Applicazioni di default)',
                'step'        => 'Esegue solo lo step selezionato: gli step possibili sono' . implode( ', ', $this->steps ),
                'sa_suffix'   => 'Suffisso del siteaccess (default: eventi)'
            )
        );
    }

    public function beforeInstall($options = array())
    {
        eZContentClass::removeTemporary();
        $this->options = $options;

        if ( !isset( $this->options['sa_suffix'] ) )
        {
            $this->options['sa_suffix'] = 'eventi';
        }

        if ( isset( $this->options['step'] ) )
        {
            if ( array_key_exists( $this->options['step'], $this->steps ) )
                $this->installOnlyStep = $this->options['step'];
            else
                throw new Exception( "Step {$this->options['step']} not found, run script with -h for help" );
        }
    }

    public function install()
    {
        OpenPALog::warning( "Controllo classi" );
        self::installClasses();

        OpenPALog::warning( "Controllo sezioni" );
        $section = self::installSections();

        OpenPALog::warning( "Controllo stati" );
        $states = self::installStates();
        OpenPALog::warning( "Installazione Agenda root" );
        if ( isset( $this->options['parent-node'] ) ) {
            $parentNodeId = $this->options['parent-node'];
        }
        else
        {
            $parentNodeId = OpenPAAppSectionHelper::instance()->rootNode()->attribute('node_id');
        }
        $root = self::installAppRoot( $parentNodeId, $section, $this->options );

        // Alberatura
        if ( ( $this->installOnlyStep !== null && $this->installOnlyStep == 'a' ) || $this->installOnlyStep === null )
        {
            OpenPALog::warning( "Installazione Alberatura" );
            self::installAgendaStuff( $root, $section, $this->installOnlyStep === null );
        }

        // Ruoli
        if ( ( $this->installOnlyStep !== null && $this->installOnlyStep == 'r' ) || $this->installOnlyStep === null )
        {
            OpenPALog::warning( "Installazione Ruoli" );
            self::installRoles( $section, $states );
        }

        // Configurazioni ini
        self::installIniParams( $this->options['sa_suffix'] );

        eZCache::clearById( 'global_ini' );
        eZCache::clearById( 'template' );

    }

    public function afterInstall()
    {
        return false;
    }

    protected static function installClasses()
    {
        OpenPAClassTools::installClasses( OpenPAAgenda::classIdentifiers() );
    }

    protected static function installAppRoot( $parentNodeId, eZSection $section, $options = array() )
    {
        $rootObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() );
        if ( !$rootObject instanceof eZContentObject )
        {

            // root
            $params = array(
                'parent_node_id' => $parentNodeId,
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::rootRemoteId(),
                'class_identifier' => 'agenda_root',
                'attributes' => array(
                    'name' => 'Agenda',
                    'logo' => 'extension/openpa_agenda/doc/default/logo.png',
                    'logo_title' => 'Agenda[Città]',
                    'logo_subtitle' => 'Agenda del territorio',
                    'banner' => 'extension/openpa_agenda/doc/default/banner.png',
                    'banner_title' => "[Agenda]: il [respiro] del tuo comune",
                    'banner_subtitle' => "Le [associazioni] in prima fila",
                    'faq' => '',
                    'privacy' => '',
                    'terms' => '',
                    'footer' => '',
                    'contacts' => ''
                )
            );
            /** @var eZContentObject $rootObject */
            $rootObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$rootObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Agenda root node' );
            }
        }
        return $rootObject;
    }

    protected static function installSections()
    {
        $section = OpenPABase::initSection(
            OpenPAAgenda::SECTION_NAME,
            OpenPAAgenda::SECTION_IDENTIFIER,
            OpenPAAppSectionHelper::NAVIGATION_IDENTIFIER
        );
        return $section;
    }

    protected static function installStates()
    {
        return array_merge(
            OpenPABase::initStateGroup(
                OpenPAAgenda::$stateGroupIdentifier,
                OpenPAAgenda::$stateIdentifiers
            ),
            OpenPABase::initStateGroup(
                OpenPAAgenda::$programStateGroupIdentifier,
                OpenPAAgenda::$programStateIdentifiers
            ),
            OpenPABase::initStateGroup(
                OpenPAAgenda::$privacyStateGroupIdentifier,
                OpenPAAgenda::$privacyStateIdentifiers
            )
        );
    }

    protected static function installAgendaStuff( eZContentObject $rootObject, eZSection $section, $installDemoContent = true )
    {
        // Events Container
        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::calendarRemoteId() );
        if ( !$containerObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::calendarRemoteId(),
                'class_identifier' => 'event_calendar',
                'attributes' => array(
                    'title' => 'Eventi'
                )
            );
            /** @var eZContentObject $containerObject */
            $containerObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$containerObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Events container node' );
            }
        }
        /*if ( $containerObject->attribute( 'class_identifier' ) == 'folder' )
        {
            $mapping = array(
                "name" => "name",
                "short_description" => "short_description",
                "description" => "description",
                "image" => ""
            );

            $conversionFunctions = new conversionFunctions();
            $containerObject = $conversionFunctions->convertObject( $containerObject->attribute('id'), eZContentClass::classIDByIdentifier( 'agenda_post_root' ), $mapping );
            if ( !$containerObject )
            {
                throw new Exception( "Errore nella conversione dell'oggetto contentitore" );
            }
        }*/

        // Programs Container
        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::programRemoteId() );
        if ( !$containerObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::programRemoteId(),
                'class_identifier' => 'folder',
                'attributes' => array(
                    'name' => 'Programmi',
                    'short_description' => 'short_description',
                    'description' => 'description',
                    'image' => ''
                )
            );
            /** @var eZContentObject $containerObject */
            $containerObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$containerObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Programs container node' );
            }
        }


        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::associationsRemoteId() );
        if ( !$groupObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::associationsRemoteId(),
                'class_identifier' => 'user_group',
                'attributes' => array(
                    'name' => 'Associazioni'
                )
            );
            /** @var eZContentObject $groupObject */
            $groupObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$groupObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Organizations group node' );
            }
        }

        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::moderatorGroupRemoteId() );
        if ( !$groupObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::moderatorGroupRemoteId(),
                'class_identifier' => 'user_group',
                'attributes' => array(
                    'name' => 'Moderatori'
                )
            );
            /** @var eZContentObject $groupObject */
            $groupObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$groupObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Moderatori group node' );
            }
        }

        $agendaCalendarClassIdentifier = 'agenda_calendar';
        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_calendars' );
        if ( !$containerObject instanceof eZContentObject ){
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
                throw new Exception( 'Failed creating _calendars container node' );
            }
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
                throw new Exception( 'Failed creating External users group node' );
            }
        }

    }

    /**
     * @param eZSection $section
     * @param eZContentObjectState[] $states
     *
     * @throws Exception
     */
    public static function installRoles( eZSection $section, array $states )
    {
        $mediaSectionId = eZContentObjectTreeNode::fetch(
            eZINI::instance('content.ini')->variable('NodeSettings','MediaRootNode')
        )->attribute('object')->attribute('section_id');

        $roles = array(
            "Agenda Associations" => array(
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'password'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'preferences'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'selfedit'
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'browse'
                ),
                array(
                    'ModuleName' => 'ezoe',
                    'FunctionName' => 'editor'
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier(),
                            'iniziativa'
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'image'
                        )),
                        'Section' => $mediaSectionId
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'edit',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            'iniziativa',
                            'image'
                        )),
                        'Owner' => 1
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'edit',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier()
                        )),
                        'Owner' => 1,
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_moderation' => array(
                            $states['moderation.skipped']->attribute( 'id' ),
                            $states['moderation.draft']->attribute( 'id' ),
                            $states['moderation.waiting']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'state',
                    'FunctionName' => 'assign',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier()
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_moderation' => array(
                            $states['moderation.draft']->attribute( 'id' ),
                            $states['moderation.waiting']->attribute( 'id' )
                        ),
                        'NewState' => array(
                            $states['moderation.draft']->attribute( 'id' ),
                            $states['moderation.waiting']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment',
                            'agenda_calendar',
                            'iniziativa',
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier()
                        )),
                        'Owner' => 1,
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'state',
                    'FunctionName' => 'assign',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment'
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'NewState' => array(
                            $states['moderation.skipped']->attribute( 'id' ),
                            $states['moderation.waiting']->attribute( 'id' ),
                            $states['moderation.accepted']->attribute( 'id' ),
                            $states['moderation.accepted']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'editorialstuff',
                    'FunctionName' => 'dashboard'
                ),
                array(
                    'ModuleName' => 'editorialstuff',
                    'FunctionName' => 'media'
                )
            ),
            "Agenda Moderators" => array(
                array(
                    'ModuleName' => 'agenda',
                    'FunctionName' => '*'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'password'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'preferences'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'selfedit'
                ),
                array(
                    'ModuleName' => 'ezoe',
                    'FunctionName' => 'editor'
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier(),
                            'programma_eventi',
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            'comment'
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'image'
                        )),
                        'Section' => $mediaSectionId
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'iniziativa'
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'ParentClass' => self::getClassIdList(array(
                            'event_calendar'
                        ))
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'edit',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'programma_eventi',                            
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            OpenPAAgenda::instance()->getEventClassIdentifier(),
                            'comment',
                            'image',
                            'iniziativa'
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'programma_eventi',
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            OpenPAAgenda::instance()->getEventClassIdentifier(),
                            'comment',
                            'agenda_calendar',
                            'iniziativa'
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            'agenda_calendar',
                            'iniziativa'
                        ))
                    )
                ),
                array(
                    'ModuleName' => 'state',
                    'FunctionName' => 'assign',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                        ))
                    )
                ),
                array(
                    'ModuleName' => 'state',
                    'FunctionName' => 'assign',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'programma_eventi',
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                            'comment',
                            OpenPAAgenda::instance()->getEventClassIdentifier(),
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'editorialstuff',
                    'FunctionName' => 'full_dashboard'
                ),
                array(
                    'ModuleName' => 'editorialstuff',
                    'FunctionName' => 'media'
                )
            ),
            "Agenda Anonymous" => array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'agenda_calendar',
                            'iniziativa',
                        )),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment',
                            OpenPAAgenda::instance()->getEventClassIdentifier()
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_moderation' => array(
                            $states['moderation.skipped']->attribute( 'id' ),
                            $states['moderation.accepted']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'programma_eventi'
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_programma_eventi' => array(
                            $states['programma_eventi.public']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getAssociationClassIdentifier(),
                        )),
                        'StateGroup_privacy' => array(
                            $states['privacy.public']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'social_user',
                    'FunctionName' => 'signup'
                ),
                array(
                    'ModuleName' => 'agenda',
                    'FunctionName' => 'download'
                ),
                array(
                    'ModuleName' => 'agenda',
                    'FunctionName' => 'qrcode'
                ),
                array(
                    'ModuleName' => 'agenda',
                    'FunctionName' => 'use'
                ),
                array(
                    'ModuleName' => 'ezjscore',
                    'FunctionName' => 'call',
                    'Limitation' => array(
                        'FunctionList' => array('ezstarrating_rate')
                    )
                ),
                array(
                    'ModuleName' => 'opendata',
                    'FunctionName' => 'api'
                ),
                array(
                    'ModuleName' => 'opendata',
                    'FunctionName' => 'environment',
                    'Limitation' => array(
                        'PresetList' => array('content', 'datatable', 'geo')
                    )
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'login',
                    'Limitation' => array(
                        'SiteAccess' => eZSys::ezcrc32( OpenPABase::getCustomSiteaccessName( 'agenda', false ) )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'image',
                            'argomento',
//                            'tipo_evento'
                        ))
                    )
                ),
            ),
            "Agenda Member" => array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment'
                        )),
                        'Section' => $section->attribute( 'id' ),
                        'ParentClass' => self::getClassIdList(array(
                            OpenPAAgenda::instance()->getEventClassIdentifier()
                        ))
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment'
                        )),
                        'Owner' => 1,
                        'Section' => $section->attribute( 'id' )
                    ),
                    'StateGroup_moderation' => array(
                        $states['moderation.skipped']->attribute( 'id' ),
                        $states['moderation.waiting']->attribute( 'id' ),
                        $states['moderation.accepted']->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'edit',
                    'Limitation' => array(
                        'Class' => self::getClassIdList(array(
                            'comment'
                        )),
                        'Owner' => 1,
                        'Section' => $section->attribute( 'id' )
                    ),
                    'StateGroup_moderation' => array(
                        $states['moderation.waiting']->attribute( 'id' )
                    )
                )
            )
        );

        foreach( $roles as $roleName => $policies )
        {
            OpenPABase::initRole( $roleName, $policies, true );
        }

        $anonymousUserId = eZINI::instance()->variable( 'UserSettings', 'AnonymousUserID' );
        /** @var eZRole $anonymousRole */
        $anonymousRole = eZRole::fetchByName( "Agenda Anonymous" );
        if ( !$anonymousRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $anonymousRole->assignToUser( $anonymousUserId );

        /** @var eZRole $memberRole */
        $memberRole = eZRole::fetchByName( "Agenda Member" );
        if ( !$memberRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $memberNodeId = eZINI::instance()->variable( 'UserSettings', 'DefaultUserPlacement' );
        $members = eZContentObject::fetchByNodeID( $memberNodeId );
        if ( $members instanceof eZContentObject )
        {
            $anonymousRole->assignToUser( $members->attribute( 'id' ) );
            $memberRole->assignToUser( $members->attribute( 'id' ) );
        }

        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::associationsRemoteId() );
        /** @var eZRole $associationRole */
        $associationRole = eZRole::fetchByName( "Agenda Associations" );
        if ( !$associationRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $anonymousRole->assignToUser( $groupObject->attribute( 'id' ) );
        $memberRole->assignToUser( $groupObject->attribute( 'id' ) );
        $associationRole->assignToUser( $groupObject->attribute( 'id' ) );

        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::externalUsersGroupRemoteId() );
        $anonymousRole->assignToUser( $groupObject->attribute( 'id' ) );
        $memberRole->assignToUser( $groupObject->attribute( 'id' ) );
        $associationRole->assignToUser( $groupObject->attribute( 'id' ) );

        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::moderatorGroupRemoteId() );
        /** @var eZRole $moderatorRole */
        $moderatorRole = eZRole::fetchByName( "Agenda Moderators" );
        if ( !$moderatorRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $anonymousRole->assignToUser( $groupObject->attribute( 'id' ) );
        $memberRole->assignToUser( $groupObject->attribute( 'id' ) );
        $associationRole->assignToUser( $groupObject->attribute( 'id' ) );
        $moderatorRole->assignToUser( $groupObject->attribute( 'id' ) );

    }

    protected static function installIniParams( $saSuffix )
    {
        OpenPALog::warning( 'Salvo configurazioni' );
        OpenPALog::error('Metodo non ancora implemetato ' . __METHOD__);
        OpenPALog::error('Attiva workflow editorial stuff (occhio ad attivare l\'estensione anche in backend)' . __METHOD__);
    }

    protected static function getClassIdList($identifierList)
    {
        $idList = array();
        foreach ($identifierList as $identifier) {
            $id = (int)eZContentClass::classIDByIdentifier($identifier);
            if ($id === 0){
                throw new Exception("Class $identifier not found", 1);
                
            }            
            $idList[] = $id;
            if ($identifier == 'private_organization'){
                $idList = array_merge($idList, self::getClassIdList(array(
                    'sede',
                    'punto_di_contatto',  
                    'referente',
                )));
            }
        }

        return array_unique($idList);
    }

}
