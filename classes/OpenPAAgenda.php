<?php


class OpenPAAgenda
{
    const SECTION_IDENTIFIER = "agenda";
    const SECTION_NAME = "Agenda";

    public static $stateGroupIdentifier = 'moderation';
    public static $stateIdentifiers = array(
        'skipped' => "Non necessita di moderazione",
        'waiting' => "In attesa di moderazione",
        'accepted' => "Accettato",
        'refused' => "Rifiutato"
    );

    /**
     * @var eZContentObject
     */
    protected $root;

    /**
     * @var eZContentObjectAttribute[]
     */
    protected $rootDataMap = array();

    private static $_instance;

    public static function instance()
    {
        if (self::$_instance === null) {
            self::$_instance = new OpenPAAgenda();
        }

        return self::$_instance;
    }

    protected function __construct()
    {
        $this->root = eZContentObject::fetchByRemoteID(self::rootRemoteId());
        if ($this->root instanceof eZContentObject) {
            $this->rootDataMap = $this->root->attribute('data_map');
        }
    }

    public function checkAccess($nodeId)
    {
        //@todo
        $result = eZDB::instance()->arrayQuery("SELECT path_string FROM ezcontentobject_tree WHERE node_id = " . intval($nodeId));
        if (isset($result[0]['path_string'])){
            return strpos( $result[0]['path_string'], '/'.$this->rootNode()->attribute('node_id').'/') !== false;
        }
        return false;
    }

    public function rootObject()
    {
        return $this->root;
    }

    public function rootNode()
    {
        return $this->root->attribute('main_node');
    }


    public function rootHasAttribute($identifier)
    {
        return isset($this->rootDataMap[$identifier]);
    }

    /**
     * Remote id di rootNode
     *
     * @return string
     */
    public static function rootRemoteId()
    {
        return OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_agenda';
    }

    public static function classIdentifiers()
    {
        return array('agenda_root');
    }

    /**
     * @param string $identifier
     *
     * @return string
     */
    public function getAttributeString($identifier)
    {
        $data = '';
        if (isset( $this->rootDataMap[$identifier] )) {
            if ($this->rootDataMap[$identifier] instanceof eZContentObjectAttribute) {
                $data = self::replaceBracket($this->rootDataMap[$identifier]->toString());
            }
        }

        return $data;
    }

    /**
     * @param string $identifier
     *
     * @return eZContentObjectAttribute
     */
    public function getAttribute($identifier)
    {
        $data = new eZContentObjectAttribute(array());
        if (isset( $this->rootDataMap[$identifier] )) {
            $data = $this->rootDataMap[$identifier];
        }

        return $data;
    }

    public function siteUrl()
    {
        $currentSiteaccess = eZSiteAccess::current();
        $sitaccessIdentifier = $currentSiteaccess['name'];
        if ( !self::isAgendaSiteAccessName( $sitaccessIdentifier ) )
        {
            $sitaccessIdentifier = self::getAgendaSiteAccessName();
        }
        $path = "settings/siteaccess/{$sitaccessIdentifier}/";
        $ini = new eZINI( 'site.ini.append', $path, null, null, null, true, true );
        return rtrim( $ini->variable( 'SiteSettings', 'SiteURL' ), '/' );
    }

    public static function isAgendaSiteAccessName( $currentSiteAccessName )
    {
        return OpenPABase::getCustomSiteaccessName( 'agenda' ) == $currentSiteAccessName;
    }

    public static function getAgendaSiteAccessName()
    {
        return OpenPABase::getCustomSiteaccessName( 'agenda' );
    }

    public function imagePath($identifier)
    {
        $data = false;
        if (isset( $this->rootDataMap[$identifier] )) {
            if ( $this->rootDataMap[$identifier] instanceof eZContentObjectAttribute
                 && $this->rootDataMap[$identifier]->hasContent() )
            {
                /** @var eZImageAliasHandler $content */
                $content = $this->rootDataMap[$identifier]->content();
                $original = $content->attribute( 'original' );
                $data = $original['full_path'];
            }
            else
            {
                $data = '/extension/openpa_agenda/design/standard/images/logo_default.png';
            }
        }
        return $data;
    }


    /**
     * Replace [ ] with strong html tag
     *
     * @param string $string
     *
     * @return string
     */
    private static function replaceBracket($string)
    {
        $string = str_replace('[', '<strong>', $string);
        $string = str_replace(']', '</strong>', $string);

        return $string;
    }
}