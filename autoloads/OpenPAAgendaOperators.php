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
            'is_comment_enabled',
            'is_header_only_logo_enabled',
            'agenda_root',
            'agenda_browse_helper',
            'current_user_is_agenda_moderator',
            'current_user_has_limited_edit_agenda_event',
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
            )
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
            case 'current_user_has_limited_edit_agenda_event':
                $object = $namedParameters['object'];
                $version = $namedParameters['version'];
                $operatorValue = false;
                if ($object instanceof eZContentObject){
                    $operatorValue = (
                           $version > 1
                           && $object->attribute('class_identifier') == 'event'
                           && self::currentUserIsAgendaModerator() === false
                           && count(array_intersect($object->attribute('state_identifier_array'), array('moderation/accepted', 'moderation/waiting'))) > 0
                    );
                }else{
                    eZDebug::writeError('Wrong parameter object', __METHOD__);
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

            case 'is_header_only_logo_enabled':
                $operatorValue = $agenda->isHeaderOnlyLogoEnabled();
                break;
        }
    }
}
