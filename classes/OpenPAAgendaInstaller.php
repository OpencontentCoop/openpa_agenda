<?php

class OpenPAAgendaInstaller implements OpenPAInstaller
{
    protected $options = array();

    public function setScriptOptions(eZScript $script)
    {
        return $script->getOptions(
            '[parent-node:][sa_suffix:]',
            '',
            array(
                'parent-node' => 'Nodo id contenitore di sensor (Applicazioni di default)',
                'sa_suffix' => 'Suffisso del siteaccess (default: eventi)'
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

        OpenPALog::warning( "Installazione ruoli" );
        self::installRoles( $section, $states );

        OpenPALog::warning( 'Salvo configurazioni' );
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

    protected static function installRoles( eZSection $section, array $states )
    {
        OpenPALog::error('Metodo non ancora implemetato ' . __METHOD__);
    }

    protected static function installIniParams( $saSuffix )
    {
        OpenPALog::error('Metodo non ancora implemetato ' . __METHOD__);
    }

}