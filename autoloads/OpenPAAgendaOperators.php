<?php

class OpenPAAgendaOperators
{
    /**
     * Returns the list of template operators this class supports
     *
     * @return array
     */
    function operatorList()
    {
        return array(
            'latest_program',
            'calendar_node_id',
            'agenda_root_node',
            'is_collaboration_enabled',
            'is_moderation_enabled',
            'is_comment_enabled',
            'is_header_only_logo_enabled',
            'is_auto_registration_enabled',
            'agenda_root',
            'agenda_browse_helper',
            'current_user_is_agenda_moderator',
            'current_user_has_limited_edit_agenda_event',
            'current_user_has_limited_edit_agenda_event_attribute',
            'agenda_event_class_identifier',
            'agenda_association_class_identifier',
            'is_registration_enabled',
            'is_login_enabled',
            'associazioni_root_node_id',
            'fill_social_matrix',
            'social_matrix_fields',
            'social_links',
            'visibility_states',
            'base64_image_data',
            'openagenda_use_wkhtmltopdf',
            'openagenda_default_geolocation',
            'openagenda_contacts_node',
            'agenda_identifier',
        );
    }

    /**
     * Indicates if the template operators have named parameters
     *
     * @return bool
     */
    function namedParameterPerOperator()
    {
        return true;
    }

    /**
     * Returns the list of template operator parameters
     *
     * @return array
     */
    function namedParameterList()
    {
        return array(
            'agenda_browse_helper' => array(
                'browser' => array( 'type' => 'object', 'required' => true ),
            ),
            'current_user_has_limited_edit_agenda_event' => array(
                'object' => array( 'type' => 'object', 'required' => true ),
                'version' => array( 'type' => 'integer', 'required' => true ),
            ),
            'current_user_has_limited_edit_agenda_event_attribute' => array(
                'attribute' => array( 'type' => 'object', 'required' => true )
            ),
            'fill_social_matrix' => array(
                'attribute' => array('type' => 'object', 'required' => true),
                'fields' => array('type' => 'array', 'required' => false, 'default' => OpenPAAttributeSocialHandler::getContactsFields())
            ),
        );
    }

    public static function currentUserIsAgendaModerator()
    {
        $currentUser = eZUser::currentUser();
        $isAdminAccess = $currentUser->hasAccessTo('*', '*');
        if ($isAdminAccess['accessWord'] == 'yes'){
            return true;
        }

        /** @var eZContentObject[] $currentUserGroups */
        $currentUserGroups = $currentUser->groups(true);
        foreach($currentUserGroups as $group){
            if ($group->attribute('remote_id') == OpenPAAgenda::instance()->moderatorGroupRemoteId()){
                return true;
            }
        }
        return false;
    }

    /**
     * Executes the template operator
     *
     * @param eZTemplate $tpl
     * @param string $operatorName
     * @param mixed $operatorParameters
     * @param string $rootNamespace
     * @param string $currentNamespace
     * @param mixed $operatorValue
     * @param array $namedParameters
     * @param mixed $placement
     */
    function modify( $tpl, $operatorName, $operatorParameters, $rootNamespace, $currentNamespace, &$operatorValue, $namedParameters, $placement )
    {
        $agenda = OpenPAAgenda::instance();
        switch( $operatorName )
        {
            case 'agenda_identifier':
                $operatorValue = OpenPABase::getCurrentSiteaccessIdentifier();
                break;
            case 'openagenda_contacts_node':
                $operatorValue = OpenPAAgenda::contactsNodeId();
                break;

            case 'openagenda_default_geolocation':
                $map = $agenda->getAttribute('geo');
                if ($map instanceof eZContentObjectAttribute
                    && $map->attribute('data_type_string') == eZGmapLocationType::DATA_TYPE_STRING
                    && $map->hasContent()){
                    $operatorValue = $map->content();
                }
                break;

            case 'visibility_states':
                $operatorValue = OpenPAAgenda::instance()->getVisibilityStates();
                break;

            case 'social_links':
                $operatorValue = OpenPAAttributeSocialHandler::getContactsData(OpenPAAgenda::instance()->getAttribute('social'));
                break;

            case 'social_matrix_fields':
                $operatorValue = OpenPAAttributeSocialHandler::getContactsFields();
                break;

            case 'fill_social_matrix':
                $attribute = $namedParameters['attribute'];
                $fields = $namedParameters['fields'];
                $operatorValue = OpenPAAttributeSocialHandler::fillContactsData($attribute, $fields);
                break;

            case 'associazioni_root_node_id':
                return $operatorValue = OpenPAAgenda::associationsNodeId();
                break;

            case 'is_registration_enabled':
                return $operatorValue = $agenda->isRegistrationEnabled();
                break;

            case 'is_login_enabled':
                return $operatorValue = $agenda->isLoginEnabled();
                break;

            case 'agenda_event_class_identifier':
                return $operatorValue = $agenda->getEventClassIdentifier();
                break;

            case 'agenda_association_class_identifier':
                return $operatorValue = $agenda->getAssociationClassIdentifier();
                break;

            case 'current_user_has_limited_edit_agenda_event':
                $object = $namedParameters['object'];
                $version = $namedParameters['version'];
                $operatorValue = false;
                if ($object instanceof eZContentObject){
                    $operatorValue = (
                           $version > 1
                           && $object->attribute('class_identifier') == OpenPAAgenda::instance()->getEventClassIdentifier()
                           && self::currentUserIsAgendaModerator() === false
                           && count(array_intersect($object->attribute('state_identifier_array'), array('moderation/accepted', 'moderation/waiting'))) > 0
                    );
                }else{
                    eZDebug::writeError('Wrong parameter object', __METHOD__);
                }
                return $operatorValue;
                break;

            case 'current_user_has_limited_edit_agenda_event_attribute':
                $attribute = $namedParameters['attribute'];
                $operatorValue = true;
                if (count( (array) OpenPAINI::variable('OpenpaAgendaEditSettings', 'LimitEditAttributeIdentifiers', array()) ) > 0){
                    $operatorValue = in_array($attribute->attribute('contentclass_attribute_identifier'), (array)OpenPAINI::variable('OpenpaAgendaEditSettings', 'LimitEditAttributeIdentifiers'));
                }elseif ($attribute instanceof eZContentObjectAttribute){
                    $operatorValue = $attribute->attribute('is_required');
                }
                return $operatorValue;
                break;

            case 'current_user_is_agenda_moderator':
                return $operatorValue = self::currentUserIsAgendaModerator();
                break;

            case 'agenda_browse_helper':
                $operatorValue = null;
                $contentBrowse = $namedParameters['browser'];

                if ($contentBrowse instanceof eZContentBrowse){

                    $contentBrowse->setStartNode(OpenPAAgenda::instance()->rootNode()->attribute('node_id'));

                    $actionName = $contentBrowse->attribute('action_name');
                    $browseCustomAction = $contentBrowse->attribute('browse_custom_action');
                    $fromPage = $contentBrowse->attribute('from_page');

                    if ($actionName == 'ProgrammaEventiItemAddSelectedEvent'){

                        $operatorValue = 'calendar';

                    }elseif($actionName == 'AddNewBlockItem' || $actionName == 'AddNewBlockSource'  || $actionName == 'CustomAttributeBrowse'){

                        $parts = explode('/', trim($fromPage, '/'));
                        if (isset($parts[3]) && isset($parts[4])){
                            $id = $browseCustomAction['value'];
                            $version = $parts[3];
                            $language = $parts[4];
                            $attribute = eZContentObjectAttribute::fetch($id,$version);
                            if ($attribute instanceof eZContentObjectAttribute){
                                /** @var eZPage $page */
                                $page = $attribute->content();
                                if ($page instanceof eZPage) {
                                    $params = explode('-', trim($browseCustomAction['name'], ']'));
                                    $zone = $page->getZone($params[1]);
                                    if ($zone instanceof eZPageZone){
                                        $block = $zone->getBlock($params[2]);
                                        $type = $block->attribute('type');
                                        if (eZINI::instance('block.ini')->hasVariable($type, 'BrowseTemplate')){
                                            if (eZINI::instance('block.ini')->hasVariable($type, 'BrowseStartNode')){
                                                $upload = new eZContentUpload();
                                                $contentBrowse->setStartNode(
                                                    $upload->nodeAliasID(
                                                        eZINI::instance('block.ini')->variable($type, 'BrowseStartNode')
                                                    )
                                                );
                                            }
                                            $operatorValue = eZINI::instance('block.ini')->variable($type, 'BrowseTemplate');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                break;

            case 'agenda_root':
                $operatorValue = OpenPAAgenda::instance()->rootObject();
                break;

            case 'latest_program':
                $operatorValue = OpenPAAgenda::latestProgram();
                break;

            case 'calendar_node_id':
                $operatorValue = OpenPAAgenda::calendarNodeId();
                break;

            case 'agenda_root_node':
                $operatorValue = OpenPAAgenda::instance()->rootNode();
                break;

            case 'is_collaboration_enabled':
                $operatorValue = $agenda->isCollaborationModeEnabled();
                break;

            case 'is_comment_enabled':
                $operatorValue = $agenda->isCommentEnabled();
                break;

            case 'is_moderation_enabled':
                $operatorValue = $agenda->isModerationEnabled();
                break;

            case 'is_header_only_logo_enabled':
                $operatorValue = $agenda->isHeaderOnlyLogoEnabled();
                break;

            case 'is_auto_registration_enabled':
                $operatorValue = $agenda->isAutoRegistrationEnabled();
                break;

            case 'base64_image_data':
                $image = eZClusterFileHandler::instance($operatorValue);
                if ($image->exists()){
                    $data = $image->fetchContents();
                    $mime = $image->dataType();
                    $operatorValue = 'data:'.$mime.';base64,' . base64_encode($data);
                }else{
                    $operatorValue = false;
                }
                break;

            case 'openagenda_use_wkhtmltopdf':
                $operatorValue = ProgrammaEventiItem::useWkhtmltopdf();
                break;
        }
    }
}
