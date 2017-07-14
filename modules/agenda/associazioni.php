<?php
/** @var eZModule $Module */
$Module = $Params['Module'];
$tpl = eZTemplate::factory();
$Action = $Params['Action'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

if (OpenPAAgenda::instance()->isCollaborationModeEnabled() || eZUser::currentUser()->hasAccessTo('agenda', 'config')) {

    if ($Action == 'activate' && OpenPAAgenda::instance()->isAutoRegistrationEnabled()) {

        $tpl->setVariable('success', true);

        $Result = array();
        $Result['content'] = $tpl->fetch('design:register_associazione.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => 'agenda/associazioni');
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();


    } elseif ($Action == 'register' && OpenPAAgenda::instance()->isAutoRegistrationEnabled()) {

        eZPageData::setPersistentVariable('need_login', false, $tpl);

        if (isset( $Params['UserParameters'] )) {
            $UserParameters = $Params['UserParameters'];
        } else {
            $UserParameters = array();
        }
        $viewParameters = array();
        $viewParameters = array_merge($viewParameters, $UserParameters);

        $Params['TemplateName'] = "design:register_associazione.tpl";
        $EditVersion = 1;


        $tpl = eZTemplate::factory();
        $tpl->setVariable('view_parameters', $viewParameters);
        $tpl->setVariable('success', false);
        $Params['TemplateObject'] = $tpl;

        $db = eZDB::instance();
        $db->begin();

        // Fix issue EZP-22524
        if ($http->hasSessionVariable("RegisterAgendaAssociazioneID")) {
            if ($http->hasSessionVariable('StartedRegistrationAgendaAssociazione')) {
                eZDebug::writeWarning('Cancel module run to protect against multiple form submits', 'user/register');
                $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');
                $db->commit();

                return eZModule::HOOK_STATUS_CANCEL_RUN;
            }

            $objectId = $http->sessionVariable("RegisterAgendaAssociazioneID");

            $object = eZContentObject::fetch($objectId);
            if ($object === null) {
                $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');
            }
        } else {
            if ($http->hasSessionVariable('StartedRegistrationAgendaAssociazione')) {
                eZDebug::writeWarning('Cancel module run to protect against multiple form submits', 'user/register');
                $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');
                $db->commit();

                return eZModule::HOOK_STATUS_CANCEL_RUN;
            } else if ($http->hasPostVariable('PublishButton') or $http->hasPostVariable('CancelButton')) {
                $http->setSessionVariable('StartedRegistrationAgendaAssociazione', 1);
            }

            $handler = OCEditorialStuffHandler::instance('associazione');

            $class = eZContentClass::fetchByIdentifier($handler->getFactory()->classIdentifier());
            if (!$class instanceof eZContentClass) {
                return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
            }

            $parent = OpenPAAgenda::associationsNodeId();
            $node = eZContentObjectTreeNode::fetch(intval($parent));

            if ($node instanceof eZContentObjectTreeNode && $class->attribute('id')) {
                $languageCode = eZINI::instance()->variable('RegionalSettings', 'Locale');

                $sectionID = $node->attribute('object')->attribute('section_id');

                $object = eZContentObject::createWithNodeAssignment($node,
                    $class->attribute('id'),
                    $languageCode,
                    false);


                $object = $class->instantiateIn($languageCode, false, $sectionID, false,
                    eZContentObjectVersion::STATUS_INTERNAL_DRAFT);
                $nodeAssignment = $object->createNodeAssignment(
                    $node->attribute('node_id'),
                    true,
                    'agenda_' . eZRemoteIdUtility::generate('eznode_assignment'),
                    $class->attribute('sort_field'),
                    $class->attribute('sort_order'));

                if ($object) {
                    $http->setSessionVariable('RedirectURIAfterPublish', '/agenda/associazioni/activate');
                    $http->setSessionVariable('RedirectIfDiscarded', '/');

                    $http->setSessionVariable("RegisterAgendaAssociazioneID", $object->attribute('id'));
                    $objectId = $object->attribute('id');

                } else {
                    $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                    $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');

                    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel');
                }
            } else {
                $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');

                return $Module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
            }
        }

        $Params['ObjectID'] = $objectId;

        if (!function_exists('checkContentActions')) {
            /**
             * @param eZModule $Module
             * @param eZContentClass $class
             * @param eZContentObject $object
             * @param eZContentObjectVersion $version
             *
             * @return int
             */
            function checkContentActions(
                $Module,
                $class,
                $object,
                $version
            ) {
                if ($Module->isCurrentAction('Cancel')) {
                    $Module->redirectTo('/');

                    $version->removeThis();

                    $http = eZHTTPTool::instance();
                    $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                    $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');

                    return eZModule::HOOK_STATUS_CANCEL_RUN;
                }

                if ($Module->isCurrentAction('Publish')) {

                    if (!SocialUserRegister::captchaIsValid()) {
                        $Module->redirectTo('/agenda/associazioni/register');

                        return eZModule::HOOK_STATUS_CANCEL_RUN;
                    }

                    $operationResult = eZOperationHandler::execute('content', 'publish', array(
                        'object_id' => $object->attribute('id'),
                        'version' => $version->attribute('version')
                    ));

                    if ($operationResult['status'] !== eZModuleOperationInfo::STATUS_CONTINUE) {
                        eZDebug::writeError('Unexpected operation status: ' . $operationResult['status'], __FILE__);
                    }

                    $http = eZHTTPTool::instance();
                    $http->removeSessionVariable("GeneratedPassword");
                    $http->removeSessionVariable("RegisterAgendaAssociazioneID");
                    $http->removeSessionVariable('StartedRegistrationAgendaAssociazione');
                    $Module->redirectTo('agenda/associazioni/activate');

                    return eZModule::HOOK_STATUS_OK;
                }
            }
        }
        $Module->addHook('action_check', 'checkContentActions');

        $OmitSectionSetting = true;

        $includeResult = include( 'kernel/content/attribute_edit.php' );

        $db->commit();

        if ($includeResult != 1) {
            return $includeResult;
        }


    }elseif (is_numeric($Action)) {
            $contentModule = eZModule::exists('content');

            return $contentModule->run(
                'view',
                array('full', $Action)
            );

    } else {
        $currentUser = eZUser::currentUser();

        $tpl->setVariable('current_user', $currentUser);
        $tpl->setVariable('persistent_variable', array());

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable('persistent_variable');
        $Result['content'] = $tpl->fetch('design:agenda/associazioni.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => 'agenda/associazioni');
        $contentInfoArray['persistent_variable'] = array();
        if ($tpl->variable('persistent_variable') !== false) {
            $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();
    }

} else {
    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED);
}
