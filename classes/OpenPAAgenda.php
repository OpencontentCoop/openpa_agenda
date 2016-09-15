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

    public static $programStateGroupIdentifier = 'programma_eventi';
    public static $programStateIdentifiers = array(
        'public' => "Pubblico",
        'private' => "Privato"
    );

    public static $privacyStateGroupIdentifier = 'privacy';
    public static $privacyStateIdentifiers = array(
        'public' => "Pubblico",
        'private' => "Privato"
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

    public function needModeration(eZContentObject $contentObject)
    {
        //@todo
        return $contentObject->attribute('current_version') == 1;
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

    private static function getNodeIdFromRemoteId($remote)
    {
        $db = eZDB::instance();
        $results = $db->arrayQuery("SELECT ezcotn.main_node_id, ezco.remote_id FROM ezcontentobject_tree as ezcotn, ezcontentobject as ezco WHERE ezco.id = ezcotn.contentobject_id AND ezco.remote_id = '{$remote}'");
        foreach($results as $result){
            return $result['main_node_id'];
        }
        return OpenPAAppSectionHelper::instance()->rootNode()->attribute('node_id');
    }

    public static function calendarRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_agenda_container';
    }

    public static function calendarNodeId()
    {
        return self::getNodeIdFromRemoteId(self::calendarRemoteId());
    }

    public static function programRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_programs_container';
    }

    public static function programNodeId()
    {
        return self::getNodeIdFromRemoteId(self::programRemoteId());
    }

    public static function associationsRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_associations';
    }

    public static function associationsNodeId()
    {
        return self::getNodeIdFromRemoteId(self::associationsRemoteId());
    }

    public static function moderatorGroupRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_moderators';
    }

    public static function moderatorGroupNodeId()
    {
        return self::getNodeIdFromRemoteId(self::moderatorGroupRemoteId());
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

    public static function notifyEventOwner( OCEditorialStuffPost $post )
    {
        $object = $post->getObject();
        if ( $object instanceof eZContentObject )
        {
            $owner = $object->owner();
            if ( $owner instanceof eZContentObject )
            {
                /** @var eZUser $user */
                $user = eZUser::fetch( $owner->attribute( 'id' ) );
                if ( $user instanceof eZUser )
                {
                    $templatePath = 'design:agenda/mail/notify_owner.tpl';
                    if ( !OCEditorialStuffActionHandler::sendMail(
                        $post,
                        array( $user ),
                        $templatePath,
                        array(
                            'post' => $post,
                            'is_comment' => $post->getObject()->attribute('class_identifier') == 'comment',
                            'event' => $post->getObject()->attribute('class_identifier') == 'comment' ? eZContentObjectTreeNode::fetch( $post->getObject()->attribute('main_parent_node_id') ) : null
                        )
                    ) )
                    {
                        eZDebug::writeError( "Fail sending mail", __METHOD__ );
                    }
                }
                else
                {
                    eZDebug::writeError( "Owner user not found", __METHOD__ );
                }
            }
            else
            {
                eZDebug::writeError( "Owner object not found", __METHOD__ );
            }
        }
        else
        {
            eZDebug::writeError( "Object not found", __METHOD__ );
        }
    }

    public static function notifyModerationGroup( OCEditorialStuffPost $post )
    {
        $object = $post->getObject();
        if ( $object instanceof eZContentObject )
        {
            $users = array();
            $userClasses = eZUser::contentClassIDs();
            $children = eZContentObjectTreeNode::subTreeByNodeID(
                array(
                    'ClassFilterType' => 'include',
                    'ClassFilterArray' => $userClasses,
                    'Limitation' => array(),
                    'AsObject' => false
                ), self::moderatorGroupNodeId()
            );
            foreach ( $children as $child )
            {
                $id = isset( $child['contentobject_id'] ) ? $child['contentobject_id'] : $child['id'];
                $user = eZUser::fetch( $id );
                if ( $user instanceof eZUser )
                {
                    $users[] = $user;
                }
                else
                {
                    eZDebug::writeError(
                        "User {$id} not found",
                        __METHOD__
                    );
                }
            }

            if ( !empty( $users ) )
            {
                $templatePath = 'design:agenda/mail/notify_moderators.tpl';
                if ( !OCEditorialStuffActionHandler::sendMail(
                    $post,
                    $users,
                    $templatePath,
                    array(
                        'post' => $post
                    )
                ) )
                {
                    eZDebug::writeError( "Fail sending mail", __METHOD__ );
                }
            }
            else
            {
                eZDebug::writeError( "Users not found", __METHOD__ );
            }

        }
        else
        {
            eZDebug::writeError( "Object not found", __METHOD__ );
        }
    }
    
    public static function notifyCommentOwner( OCEditorialStuffPost $post )
    {
        $object = $post->getObject();
        if ( $object instanceof eZContentObject )
        {
            $owner = $object->owner();
            if ( $owner instanceof eZContentObject )
            {
                /** @var eZUser $user */
                $user = eZUser::fetch( $owner->attribute( 'id' ) );
                if ( $user instanceof eZUser )
                {
                    $templatePath = 'design:agenda/mail/notify_comment_owner.tpl';
                    if ( !OCEditorialStuffActionHandler::sendMail(
                        $post,
                        array( $user ),
                        $templatePath,
                        array(
                            'post' => $post,
                            'event' => eZContentObjectTreeNode::fetch( $post->getObject()->attribute('main_parent_node_id') )
                        )
                    ) )
                    {
                        eZDebug::writeError( "Fail sending mail", __METHOD__ );
                    }
                }
                else
                {
                    eZDebug::writeError( "Owner user not found", __METHOD__ );
                }
            }
            else
            {
                eZDebug::writeError( "Owner object not found", __METHOD__ );
            }
        }
        else
        {
            eZDebug::writeError( "Object not found", __METHOD__ );
        }
    }
}
