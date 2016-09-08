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
                'parent-node' => 'Nodo id contenitore di sensor (Applicazioni di default)',
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

        OpenPALog::warning( "Installazione Sensor root" );
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
            self::installSensorPostStuff( $root, $section, $this->installOnlyStep === null );
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
                'class_identifier' => 'sensor_root',
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
                throw new Exception( 'Failed creating Sensor root node' );
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
        return OpenPABase::initStateGroup(
            OpenPAAgenda::$stateGroupIdentifier,
            OpenPAAgenda::$stateIdentifiers
        );
    }

    protected static function installSensorPostStuff( eZContentObject $rootObject, eZSection $section, $installDemoContent = true )
    {
        // Events Container
        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_agenda_container' );
        if ( !$containerObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::rootRemoteId() . '_agenda_container',
                'class_identifier' => 'folder',
                'attributes' => array(
                    'name' => 'Eventi',
                    'short_description' => 'short_description',
                    'description' => 'description',
                    'image' => ''
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
            $containerObject = $conversionFunctions->convertObject( $containerObject->attribute('id'), eZContentClass::classIDByIdentifier( 'sensor_post_root' ), $mapping );
            if ( !$containerObject )
            {
                throw new Exception( "Errore nella conversione dell'oggetto contentitore" );
            }
        }*/

        // Programs Container
        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_programs_container' );
        if ( !$containerObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::rootRemoteId() . '_programs_container',
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


        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_associations' );
        if ( !$groupObject instanceof eZContentObject )
        {
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => OpenPAAgenda::rootRemoteId() . '_associations',
                'class_identifier' => 'user_group',
                'attributes' => array(
                    'name' => 'Associazioni'
                )
            );
            /** @var eZContentObject $groupObject */
            $groupObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$groupObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Association group node' );
            }
        }
    }


    protected static function installRoles( eZSection $section, array $states )
    {
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
                )
            ),
            "Agenda Anonymous" => array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => array(
                            eZContentClass::classIDByIdentifier( 'comment' ),
                            eZContentClass::classIDByIdentifier( 'event' ),
                            eZContentClass::classIDByIdentifier( 'associazione' )
                        ),
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_moderation' => array(
                            $states['moderation.skipped']->attribute( 'id' ),
                            $states['moderation.accepted']->attribute( 'id' )
                        )
                    )
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
                    'FunctionName' => ' call ',
                    'Limitation' => array(
                        'FunctionList' => 'ezstarrating_rate'
                    )
                ),
                array(
                    'ModuleName' => 'opendata',
                    'FunctionName' => 'api'
                ),
                array(
                    'ModuleName' => 'opendata',
                    'FunctionName' => ' environment',
                    'Limitation' => array(
                        'PresetList' => array('content', 'datatable', 'geo')
                    )
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'login',
                    'Limitation' => array(
                        'SiteAccess' => eZSys::ezcrc32( OpenPABase::getCustomSiteaccessName( 'eventi', false ) )
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

        $groupObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_associations' );
        /** @var eZRole $operatorRole */
        $operatorRole = eZRole::fetchByName( "Agenda Associations" );
        if ( !$operatorRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $anonymousRole->assignToUser( $groupObject->attribute( 'id' ) );
        $operatorRole->assignToUser( $groupObject->attribute( 'id' ) );

    }

    protected static function installIniParams( $saSuffix )
    {
        OpenPALog::warning( 'Salvo configurazioni' );
        OpenPALog::error('Metodo non ancora implemetato ' . __METHOD__);
    }

}