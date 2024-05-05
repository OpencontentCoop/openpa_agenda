<?php


class OpenPAAgenda
{
    const SECTION_IDENTIFIER = "agenda";

    const SECTION_NAME = "Agenda";

    public static $stateGroupIdentifier = 'moderation';

    public static $stateIdentifiers = [
        'skipped' => "Non necessita di moderazione",
        'draft' => "In lavorazione",
        'waiting' => "In attesa di moderazione",
        'accepted' => "Accettato",
        'refused' => "Rifiutato",
    ];

    public static $programStateGroupIdentifier = 'programma_eventi';

    public static $programStateIdentifiers = [
        'public' => "Pubblico",
        'private' => "Privato",
    ];

    public static $privacyStateGroupIdentifier = 'privacy';

    public static $privacyStateIdentifiers = [
        'public' => "Pubblico",
        'private' => "Privato",
    ];

    /**
     * @var eZContentObject
     */
    protected $root;

    /**
     * @var eZContentObjectAttribute[]
     */
    protected $rootDataMap = [];

    private static $_instance;

    private $eventClassType;

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
        } else {
            $this->root = new eZContentObject([]);
        }
    }

    public function getEventClassIdentifier()
    {
        return eZINI::instance('editorialstuff.ini')->variable('agenda', 'ClassIdentifier');
    }

    public function getEventClassType()
    {
        if ($this->eventClassType === null) {
            $eventClassIdentifier = OpenPAAgenda::instance()->getEventClassIdentifier();
            $eventClass = eZContentClass::fetchByIdentifier($eventClassIdentifier);
            if (!$eventClass instanceof eZContentClass) {
                $this->eventClassType = false;
            } else {
                $eventClassDataMap = $eventClass->dataMap();
                $this->eventClassType = isset($eventClassDataMap['time_interval']) ? 'CPEV' : 'default';
            }
        }

        return $this->eventClassType;
    }

    public function getAssociationClassIdentifier()
    {
        return eZINI::instance('editorialstuff.ini')->variable('associazione', 'ClassIdentifier');
    }

    public function checkAccess($nodeId)
    {
        //@todo
        return true;
    }

    /**
     * @return eZContentObject
     */
    public function rootObject()
    {
        return $this->root;
    }

    /**
     * @return eZContentObjectTreeNode
     */
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

    public function getAgendaCacheDir()
    {
        $cacheFilePath = eZDir::path(
            [eZSys::cacheDirectory(), 'openpa_agenda']
        );
        return $cacheFilePath;
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

    private static function getNodeIdFromRemoteId($remote, $createIfNotExists = true, $params = [])
    {
        $db = eZDB::instance();
        $results = $db->arrayQuery(
            "SELECT ezcotn.main_node_id, ezco.remote_id FROM ezcontentobject_tree as ezcotn, ezcontentobject as ezco WHERE ezco.id = ezcotn.contentobject_id AND ezco.remote_id = '{$remote}'"
        );
        foreach ($results as $result) {
            return $result['main_node_id'];
        }
        if ($createIfNotExists) {
            $newObject = eZContentFunctions::createAndPublishObject(
                array_merge([
                    'parent_node_id' => OpenPAAppSectionHelper::instance()->rootNode()->attribute('node_id'),
                    'remote_id' => $remote,
                    'class_identifier' => 'folder',
                    'attributes' => ['name' => $remote],
                ], $params)
            );
            if ($newObject instanceof eZContentObject) {
                return $newObject->attribute('main_node_id');
            }
        }
        return OpenPAAppSectionHelper::instance()->rootNode()->attribute('node_id');
    }

    public static function calendarRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_agenda_container';
    }

    public static function calendarNodeId()
    {
        return self::getNodeIdFromRemoteId(self::calendarRemoteId(), ['class_identifier' => 'event_calendar']);
    }

    public static function programRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_programs_container';
    }

    public static function programNodeId()
    {
        return self::getNodeIdFromRemoteId(self::programRemoteId());
    }

    public static function contactsNodeId()
    {
        return self::getNodeIdFromRemoteId(OpenPAAgenda::rootRemoteId() . '_contacts', false);
    }

    /**
     * @return eZContentObjectTreeNode|null
     */
    public static function latestProgram()
    {
        $params = [];
        $programStateGroup = eZContentObjectStateGroup::fetchByIdentifier(self::$programStateGroupIdentifier);
        if ($programStateGroup instanceof eZContentObjectStateGroup) {
            $programStatePublic = eZContentObjectState::fetchByIdentifier(
                'public',
                $programStateGroup->attribute('id')
            );
            if ($programStatePublic instanceof eZContentObjectState) {
                $params['AttributeFilter'] = [['state', "=", $programStatePublic->attribute('id')]];
            }
        }

        $programs = eZContentObjectTreeNode::subTreeByNodeID(array_merge($params, [
            'Language' => eZLocale::currentLocaleCode(),
            'SortBy' => ['published', false],
            'ClassFilterType' => 'include',
            'ClassFilterArray' => ['programma_eventi'],
            'Limit' => 1,
        ]), OpenPAAgenda::programNodeId());
        if (isset($programs[0]) && $programs[0] instanceof eZContentObjectTreeNode) {
            return $programs[0];
        }
        return null;
    }

    public static function associationsRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_associations';
    }

    public static function associationsNodeId()
    {
        return self::getNodeIdFromRemoteId(self::associationsRemoteId(), ['class_identifier' => 'user_group']);
    }

    public static function moderatorGroupRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_moderators';
    }

    public static function externalUsersGroupRemoteId()
    {
        return OpenPAAgenda::rootRemoteId() . '_external_users';
    }

    public static function moderatorGroupNodeId()
    {
        return self::getNodeIdFromRemoteId(self::moderatorGroupRemoteId(), ['class_identifier' => 'user_group']);
    }

    public static function externalUsersGroupNodeId()
    {
        return self::getNodeIdFromRemoteId(self::externalUsersGroupRemoteId(), ['class_identifier' => 'user_group']);
    }

    public static function classIdentifiers()
    {
        return ['agenda_root', 'agenda_calendar', 'programma_eventi'];
    }

    /**
     * @param string $identifier
     *
     * @return string
     */
    public function getAttributeString($identifier)
    {
        $data = '';
        if (isset($this->rootDataMap[$identifier])) {
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
        $data = new eZContentObjectAttribute([]);
        if (isset($this->rootDataMap[$identifier])) {
            $data = $this->rootDataMap[$identifier];
        }

        return $data;
    }

    public function siteUrl()
    {
        $currentSiteaccess = eZSiteAccess::current();
        $sitaccessIdentifier = $currentSiteaccess['name'];
        if (!self::isAgendaSiteAccessName($sitaccessIdentifier)) {
            $sitaccessIdentifier = self::getAgendaSiteAccessName();
        }
        $path = "settings/siteaccess/{$sitaccessIdentifier}/";
        $ini = new eZINI('site.ini.append.php', $path, null, null, null, true, true);
        if ($ini->hasVariable('SiteSettings', 'SiteURL')) {
            return rtrim($ini->variable('SiteSettings', 'SiteURL'), '/');
        }

        return rtrim(eZINI::instance()->variable('SiteSettings', 'SiteURL'), '/');
    }

    public static function isAgendaSiteAccessName($currentSiteAccessName)
    {
        return OpenPABase::getCustomSiteaccessName('agenda') == $currentSiteAccessName;
    }

    public static function getAgendaSiteAccessName()
    {
        return OpenPABase::getCustomSiteaccessName('agenda');
    }

    public function imagePath($identifier, $aliasName = 'original')
    {
        $data = false;
        if (isset($this->rootDataMap[$identifier])) {
            if ($this->rootDataMap[$identifier] instanceof eZContentObjectAttribute
                && $this->rootDataMap[$identifier]->hasContent()) {
                /** @var eZImageAliasHandler $content */
                $content = $this->rootDataMap[$identifier]->content();
                $original = $content->attribute($aliasName);
                $data = $original['full_path'];
            } else {
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

    public static function notifyEventOwner(
        OCEditorialStuffPost $post,
        $templatePath = 'design:agenda/mail/notify_owner.tpl',
        $templateVariables = []
    ) {
        $object = $post->getObject();
        if ($object instanceof eZContentObject) {
            $owner = $object->owner();
            if ($owner instanceof eZContentObject) {
                /** @var eZUser $user */
                $user = eZUser::fetch($owner->attribute('id'));
                if ($user instanceof eZUser) {
                    if (!OCEditorialStuffActionHandler::sendMail(
                        $post,
                        [$user],
                        $templatePath,
                        array_merge([
                            'post' => $post,
                            'is_comment' => $post->getObject()->attribute('class_identifier') == 'comment',
                            'event' => $post->getObject()->attribute(
                                'class_identifier'
                            ) == 'comment' ? eZContentObjectTreeNode::fetch(
                                $post->getObject()->attribute('main_parent_node_id')
                            ) : null,
                        ], $templateVariables)
                    )) {
                        eZDebug::writeError("Fail sending mail", __METHOD__);
                    }
                } else {
                    eZDebug::writeError("Owner user not found", __METHOD__);
                }
            } else {
                eZDebug::writeError("Owner object not found", __METHOD__);
            }
        } else {
            eZDebug::writeError("Object not found", __METHOD__);
        }
    }

    public static function notifyModerationGroup(
        OCEditorialStuffPost $post,
        $templatePath = 'design:agenda/mail/notify_moderators.tpl',
        $templateVariables = []
    ) {
        $object = $post->getObject();
        if ($object instanceof eZContentObject) {
            $users = [];

            $mainAddress = self::instance()->getAttributeString('main_recipient');
            if (eZMail::validate($mainAddress)){
                $users[] = new eZUser([
                    'email' => $mainAddress,
                    'login' => '',
                ]);
            }

            if (empty($users)) {
                $moderatorGroup = eZContentObjectTreeNode::fetch(self::moderatorGroupNodeId());
                if ($moderatorGroup instanceof eZContentObjectTreeNode) {
                    /** @var eZContentObjectAttribute[] $dataMap */
                    $dataMap = $moderatorGroup->attribute('data_map');
                    if (isset($dataMap['email']) && $dataMap['email']->hasContent()) {
                        $users[] = new eZUser([
                            'email' => $dataMap['email']->toString(),
                            'login' => $moderatorGroup->attribute('name'),
                        ]);
                    }
                }
            }

            if (empty($users)) {
                $userClasses = eZUser::contentClassIDs();
                $children = eZContentObjectTreeNode::subTreeByNodeID(
                    [
                        'ClassFilterType' => 'include',
                        'ClassFilterArray' => $userClasses,
                        'Limitation' => [],
                        'AsObject' => false,
                    ],
                    self::moderatorGroupNodeId()
                );
                foreach ($children as $child) {
                    $id = isset($child['contentobject_id']) ? $child['contentobject_id'] : $child['id'];
                    $user = eZUser::fetch($id);
                    if ($user instanceof eZUser) {
                        $users[] = $user;
                    } else {
                        eZDebug::writeError(
                            "User {$id} not found",
                            __METHOD__
                        );
                    }
                }
            }

            if (!empty($users)) {
                if (!OCEditorialStuffActionHandler::sendMail(
                    $post,
                    $users,
                    $templatePath,
                    array_merge([
                        'post' => $post,
                    ], $templateVariables)
                )) {
                    eZDebug::writeError("Fail sending mail", __METHOD__);
                }
            } else {
                eZDebug::writeError("Users not found", __METHOD__);
            }
        } else {
            eZDebug::writeError("Object not found", __METHOD__);
        }
    }

    public static function notifyCommentOwner(OCEditorialStuffPost $post)
    {
        $object = $post->getObject();
        if ($object instanceof eZContentObject) {
            $owner = $object->owner();
            if ($owner instanceof eZContentObject) {
                /** @var eZUser $user */
                $user = eZUser::fetch($owner->attribute('id'));
                if ($user instanceof eZUser) {
                    $templatePath = 'design:agenda/mail/notify_comment_owner.tpl';
                    if (!OCEditorialStuffActionHandler::sendMail(
                        $post,
                        [$user],
                        $templatePath,
                        [
                            'post' => $post,
                            'event' => eZContentObjectTreeNode::fetch(
                                $post->getObject()->attribute('main_parent_node_id')
                            ),
                        ]
                    )) {
                        eZDebug::writeError("Fail sending mail", __METHOD__);
                    }
                } else {
                    eZDebug::writeError("Owner user not found", __METHOD__);
                }
            } else {
                eZDebug::writeError("Owner object not found", __METHOD__);
            }
        } else {
            eZDebug::writeError("Object not found", __METHOD__);
        }
    }

    public function isCollaborationModeEnabled()
    {
        return (bool)$this->getAttributeString('collaboration_mode') == 1;
    }

    public function isCommentEnabled()
    {
        return (bool)$this->getAttributeString('enable_comment') == 1;
    }

    public function isHeaderOnlyLogoEnabled()
    {
        return (bool)$this->getAttributeString('enable_header_only_logo') == 1;
    }

    public function isAutoRegistrationEnabled()
    {
        return (bool)$this->getAttributeString('enable_auto_registration') == 1;
    }

    public function isModerationEnabled()
    {
        return $this->getAttributeString('enable_moderation') == 1;
    }

    public function isLoginEnabled()
    {
        return $this->getAttributeString('enable_login') == 1;
    }

    public function isRegistrationEnabled()
    {
        return $this->getAttributeString('enable_registration') == 1;
    }

    public function getVisibilityStates()
    {
        $stateGroup = eZContentObjectStateGroup::fetchByIdentifier('privacy');
        if ($stateGroup instanceof eZContentObjectStateGroup) {
            $visibilityStates = [];
            /** @var eZContentObjectState $state */
            foreach ($stateGroup->states() as $state) {
                $visibilityStates[$state->attribute('identifier')] = $state;
            }

            return $visibilityStates;
        }

        return [];
    }

    public function isSiteRoot()
    {
        return $this->rootNode()->attribute('node_id') == eZINI::instance('content.ini')->variable(
                'NodeSettings',
                'RootNode'
            );
    }

    public static function restoreContactPoints(eZCLI $cli = null, $skipExisting = false)
    {
        /** @var eZContentObjectTreeNode[] $privateOrganizations */
        $privateOrganizations = eZContentObjectTreeNode::subTreeByNodeID([
            'ClassFilterType' => 'include',
            'ClassFilterArray' => ['private_organization'],
        ], 1);

        foreach ($privateOrganizations as $privateOrganization) {
            if ($cli) {
                $cli->warning("Restore contact points to " . $privateOrganization->attribute('name'));
            }
            $relatedContactPointRemoteId = HasOnlineContactPointConnector::generateRemoteId(
                (int)$privateOrganization->attribute('contentobject_id')
            );
            $relatedContactPoint = eZContentObject::fetchByRemoteID($relatedContactPointRemoteId);
            if ($relatedContactPoint instanceof eZContentObject && $skipExisting) {
                continue;
            }
            $dataMap = $privateOrganization->dataMap();
            if (isset($dataMap['has_online_contact_point'])) {
                $current = false;
                $currentContacts = [];
                $currentIdList = array_filter(explode('-', $dataMap['has_online_contact_point']->toString()));
                if (!empty($currentIdList)) {
                    foreach ($currentIdList as $currentId){
                        $current = eZContentObject::fetch((int)$currentId);
                        if ($current instanceof eZContentObject){
                            if ($current->attribute('remote_id') !== $relatedContactPointRemoteId) {
                                $current->setAttribute('remote_id', $relatedContactPointRemoteId);
                                $current->store();
                            }
                            $content = \Opencontent\Opendata\Api\Values\Content::createFromEzContentObject($current);
                            $currentContacts = $content->data['ita-IT']['contact']['content'] ?? [];
                            break;
                        }
                    }
                }
                if (isset($dataMap['main_phone']) && $dataMap['main_phone']->hasContent()) {
                    $phone = $dataMap['main_phone']->toString();
                    $currentContacts[] = [
                        'type' => 'Recapito telefonico',
                        'value' => $phone,
                        'contact' => ''
                    ];
                }
                if (isset($dataMap['main_person']) && $dataMap['main_person']->hasContent()) {
                    $person = $dataMap['main_person']->toString();
                    $currentContacts[] = [
                        'type' => 'Responsabile',
                        'value' => $person,
                        'contact' => ''
                    ];
                }
                if ($user = eZUser::fetch((int)$privateOrganization->attribute('contentobject_id'))){
                    $currentContacts[] = [
                        'type' => 'Email',
                        'value' => $user->attribute('email'),
                        'contact' => ''
                    ];
                }

                $payload = new \Opencontent\Opendata\Rest\Client\PayloadBuilder();
                $payload->setRemoteId($relatedContactPointRemoteId);
                $payload->setParentNode(self::contactsNodeId());
                $payload->setClassIdentifier('online_contact_point');
                $payload->setLanguages(['ita-IT']);
                $payload->setData('ita-IT', 'name', 'Contatti ' . $privateOrganization->attribute('name'));
                $payload->setData('ita-IT', 'contact', $currentContacts);
                $repository = new \Opencontent\Opendata\Api\ContentRepository();
                $repository->setEnvironment(new DefaultEnvironmentSettings());
                $onlineContactPoint = $repository->createUpdate($payload->getArrayCopy());
                $onlineContactPointId = $onlineContactPoint['content']['metadata']['id'] ?? null;
                if ($onlineContactPointId){
                    $dataMap['has_online_contact_point']->fromString($onlineContactPointId);
                    $dataMap['has_online_contact_point']->store();
                }
            }
        }
    }
}
