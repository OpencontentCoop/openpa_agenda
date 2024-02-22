<?php

class AgendaItem extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{
    public function onCreate()
    {
        $this->updateOwner();
        if ($this->getObject()->attribute('current_version') == 1 && OpenPAAgenda::instance()->isModerationEnabled()) {
            $states = $this->states();
            $default = 'moderation.draft';
            if (isset($states[$default])) {
                $this->getObject()->assignState($states[$default]);
            }
        }
        eZSearch::addObject($this->object, true);
        if (!OpenPAAgenda::instance()->isModerationEnabled()) {
            OpenPAAgenda::notifyModerationGroup($this, 'design:agenda/mail/agendaitem/to_moderators_on_create.tpl');
        }

        if ($this->is('accepted') || $this->is('skipped')) {
            $this->emit('publish');
        }
    }

    public function onChangeState(eZContentObjectState $beforeState, eZContentObjectState $afterState)
    {
        if ($afterState->attribute('identifier') == 'waiting' && !OpenPAAgenda::instance()->isModerationEnabled()) {
            $states = $this->states();
            $accepted = 'moderation.accepted';
            if (isset($states[$accepted])) {
                $this->getObject()->assignState($states[$accepted]);
                $this->flushObject();
                eZSearch::addObject($this->getObject(), true);
            }
        }else {
            $currentUserIsOwner = $this->attribute('organizer_id') == eZUser::currentUserID();

            $this->flushObject();
            switch ($afterState->attribute('identifier')) {
                case 'draft':
                    if (!$currentUserIsOwner) {
                        OpenPAAgenda::notifyEventOwner($this, 'design:agenda/mail/agendaitem/to_owner_on_draft.tpl');
                    }
                    break;
                case 'waiting':
                    if ($currentUserIsOwner) {
                        OpenPAAgenda::notifyModerationGroup(
                            $this,
                            'design:agenda/mail/agendaitem/to_moderators_on_waiting.tpl'
                        );
                    }
                    break;
                case 'accepted':
                    if (!$currentUserIsOwner) {
                        OpenPAAgenda::notifyEventOwner($this, 'design:agenda/mail/agendaitem/to_owner_on_accepted.tpl');
                    }
                    break;
                case 'refused':
                    if (!$currentUserIsOwner) {
                        OpenPAAgenda::notifyEventOwner($this, 'design:agenda/mail/agendaitem/to_owner_on_refused.tpl');
                    }
                    break;
            }
        }

        if ($beforeState->attribute('identifier') != $afterState->attribute('identifier')) {
            $this->setObjectLastModified();
        }

        return parent::onChangeState($beforeState, $afterState);
    }

    public function onRemove()
    {
        $this->emit('delete');
    }

    public function attributes()
    {
        return array_merge(parent::attributes(), ['is_published', 'associazione', 'organizer_id', 'discussion']);
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted');
        }

        if ($property == 'social_history') {
            return $this->getSocialHistory();
        }

        if ($property == 'discussion') {
            return $this->getDiscussion();
        }

        if ($property == 'organizer_id') {
            if (isset($this->dataMap['organizer']) && $this->dataMap['organizer']->hasContent()) {
                $organizerIdList = explode('-', $this->dataMap['organizer']->toString());
                return (int)array_shift($organizerIdList);
            }
            return 0;
        }

        if ($property == 'associazione') {
            if (isset($this->dataMap[$property]) && $this->dataMap[$property]->hasContent()) {
                return $this->dataMap[$property];
            } else {
                eZDebug::writeError("Object attribute '{$property}' is empty");
            }
        }

        return parent::attribute($property);
    }

    public function onUpdate()
    {
        eZSearch::addObject($this->object, true);
//        OpenPAAgenda::notifyModerationGroup($this);
        if ($this->is('accepted') || $this->is('skipped')) {
            $this->emit('publish');
        } else {
            $this->emit('delete');
        }
    }

    public function tabs()
    {
        $currentUser = eZUser::currentUser();
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = [
            [
                'identifier' => 'content',
                'name' => ezpI18n::tr('openpa_agenda', 'Content'),
                'template_uri' => "design:{$templatePath}/parts/content.tpl",
            ],
        ];
        if (eZINI::instance('openpa.ini')->variable('OpenpaAgenda', 'EnableOverlapGui') == 'enabled') {
            $tabs[] = [
                'identifier' => 'overlap',
                'name' => ezpI18n::tr('openpa_agenda', 'Overlap'),
                'template_uri' => "design:{$templatePath}/parts/overlap.tpl",
            ];
        }
        $access = $currentUser->hasAccessTo('editorialstuff', 'media');
        if ($access['accessWord'] == 'yes' && in_array('image', $this->factory->attributeIdentifiers())) {
            $tabs[] = [
                'identifier' => 'media',
                'name' => ezpI18n::tr('openpa_agenda', 'Image Gallery'),
                'template_uri' => "design:{$templatePath}/parts/media.tpl",
            ];
        }
        //        if ( $currentUser->hasAccessTo( 'editorialstuff', 'mail' ) )
        //        {
        //            $tabs[] = array(
        //                'identifier' => 'mail',
        //                'name' => 'Mail',
        //                'template_uri' => "design:{$templatePath}/parts/mail.tpl"
        //            );
        //        }
        $access = $currentUser->hasAccessTo('agenda', 'push');
        if (eZINI::instance('ngpush.ini')->hasVariable('PushNodeSettings', 'Blocks')
            && $access['accessWord'] == 'yes'
        ) {
            $blocks = (array)eZINI::instance('ngpush.ini')->variable('PushNodeSettings', 'Blocks');
            if (count($blocks) > 0) {
                $tabs[] = [
                    'identifier' => 'social',
                    'name' => ezpI18n::tr('openpa_agenda', 'Share'),
                    'template_uri' => "design:{$templatePath}/parts/social.tpl",
                ];
            }
        }

        if (OpenPAAgenda::instance()->isCommentEnabled()) {
            $tabs[] = [
                'identifier' => 'comments',
                'name' => ezpI18n::tr('openpa_agenda', 'Comments'),
                'template_uri' => "design:{$templatePath}/parts/public_comments.tpl",
            ];
        }

        $tabs[] = [
            'identifier' => 'tools',
            'name' => ezpI18n::tr('openpa_agenda', 'Press kit'),
            'template_uri' => "design:{$templatePath}/parts/tools.tpl",
        ];

        if (eZINI::instance('openpa.ini')->variable('OpenpaAgenda', 'EnableDiscussion') == 'enabled') {
            $tabs[] = [
                'identifier' => 'discussion',
                'name' => ezpI18n::tr('agenda', 'Discussione'),
                'template_uri' => "design:{$templatePath}/parts/discussion.tpl",
            ];
        }

        $tabs[] = [
            'identifier' => 'history',
            'name' => ezpI18n::tr('openpa_agenda', 'History'),
            'template_uri' => "design:{$templatePath}/parts/history.tpl",
        ];

        return $tabs;
    }

    public function addImage(eZContentObject $object)
    {
        parent::addImage($object);
        $this->setObjectLastModified();
    }

    public function makeDefaultImage($objectId)
    {
        parent::makeDefaultImage($objectId);
        $this->setObjectLastModified();
    }

    public function removeImage($objectId)
    {
        parent::removeImage($objectId);
        $this->setObjectLastModified();
    }

    private function getSocialHistory()
    {
        $data = [];
        $list = OCEditorialStuffHistory::fetchByHandler($this->id(), 'social_push');
        foreach ($list as $item) {
            $params = $item->attribute('params');
            $link = false;
            $type = $item->attribute('type');
            if ($item->attribute('type') == 'twitter') {
                if ($params['response']['status'] == 'success') {
                    $link = "http://twitter.com/{$params['response']['response']->user->id}/status/{$params['response']['response']->id}";
                }
                $type = 'Twitter';
            } elseif ($item->attribute('type') == 'facebook_feed') {
                if ($params['response']['status'] == 'success') {
                    $link = "https://www.facebook.com/{$params['response']['response']['id']}";
                }
                $type = 'Facebook';
            } else {
                $client = OpenPAAgendaPushClientLoader::instance($type);
                if ($client) {
                    $type = $client->name();
                    $link = $client->getRemoteUrl($params['response']);
                }
            }
            $itemNormalized = [
                'created_time' => $item->attribute('created_time'),
                'user' => $item->attribute('user'),
                'type' => $type,
                'params' => $params,
                'link' => $link,
            ];
            $data[] = $itemNormalized;
        }
        return $data;
    }

    private function getDiscussion()
    {
        return OCEditorialStuffHistory::fetchByHandler($this->id(), 'discussion');
    }

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        if ($actionIdentifier == 'ActionSetTargetSites') {
            $dataMap = $this->object->dataMap();
            if (isset($dataMap['target_site'])){
                $contentObjectAttribute = $dataMap['target_site'];
                $http = eZHTTPTool::instance();
                $base = 'ContentObjectAttribute';
                $dataType = $dataMap['target_site']->dataType();
                if ($dataType->fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)){
                    $contentObjectAttribute->store();
                    eZSearch::addObject($this->getObject(), true);
                    if ($module) {
                        $module->redirectTo("editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_tools");
                    }
                }
            }

        }

            if ($actionIdentifier == 'ActionDiscussion') {
            $text = $actionParameters[0];
            if (!empty($text)) {
                $item = new OCEditorialStuffHistory([]);
                $item->setAttribute('params', ['text' => $text]);
                $item->setAttribute('user_id', eZUser::currentUserID());
                $item->setAttribute('object_id', $this->id());
                $item->setAttribute('type', 'discussion');
                $item->setAttribute('handler', 'discussion');
                $item->setAttribute('created_time', time());
                $item->store();

//                if (eZUser::currentUserID() == $this->id()) {
//                    OpenPAAgenda::notifyModerationGroup(
//                        $this,
//                        'design:agenda/mail/agendaitem/to_moderators_on_create_discussion.tpl',
//                        ['discussion' => $item]
//                    );
//                } else {
//                    OpenPAAgenda::notifyEventOwner(
//                        $this,
//                        'design:agenda/mail/agendaitem/to_owner_on_create_discussion.tpl',
//                        ['discussion' => $item]
//                    );
//                }
            }

            if ($module) {
                $module->redirectTo(
                    "editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_discussion"
                );
            }
        }
        if ($actionIdentifier == 'ActionRemoveDiscussion') {
            $id = (int)$actionParameters[0];
            $discussion = OCEditorialStuffHistory::fetchObject(OCEditorialStuffHistory::definition(), null, [
                'id' => $id,
                'object_id' => $this->id(),
                'handler' => 'discussion',
                'type' => 'discussion',
                'user_id' => eZUser::currentUserID(),
            ]);
            if ($discussion instanceof OCEditorialStuffHistory) {
                eZPersistentObject::removeObject(OCEditorialStuffHistory::definition(), ['id' => $id]);
            }
            if ($module) {
                $module->redirectTo(
                    "editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_discussion"
                );
            }
        }

        if ($actionIdentifier == 'ActionPush') {
            $client = OpenPAAgendaPushClientLoader::instance($actionParameters[0]);
            $response = $client->push($this);
            if ($response['status'] != 'success') {
                SocialUser::addFlashAlert(implode(', ', $response['messages']), SocialUser::ALERT_ERROR);
            }

            if ($module) {
                $module->redirectTo("editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_social");
            }
        }

        if ($actionIdentifier == 'ActionCopy') {
            $newObject = OpenPAObjectTools::copyObject(
                $this->getObject(),
                false,
                OpenPAAgenda::instance()->calendarNodeId()
            );
            if (OpenPAAgenda::instance()->isModerationEnabled()) {
                $states = $this->states();
                $default = 'moderation.draft';
                if (isset($states[$default])) {
                    $newObject->assignState($states[$default]);
                }
            }

            $name = $newObject->attribute('name');
            $newObject->setName("Copia di $name");

            $language = eZLocale::currentLocaleCode();
            if ($module) {
                $module->redirectTo(
                    "content/edit/{$newObject->attribute('id')}/{$newObject->attribute('current_version')}/$language"
                );
            }
        }
    }

    protected function emit($type)
    {
        if (class_exists('OCWebHookEmitter') && eZModule::exists('webhook')) {
            if ($type == 'publish') {
                OpenPAAgendaEventEmitter::triggerPublishEvent($this);
            }
            if ($type == 'delete') {
                OpenPAAgendaEventEmitter::triggerDeleteEvent($this);
            }
        }
    }

    private function updateOwner()
    {
        if (OpenPAAgendaOperators::currentUserIsAgendaModerator()
            && OpenPAINI::variable('OpenpaAgenda', 'ForceOrganizerAsOwner', 'disabled') == 'enabled') {
            $organizerId = $this->attribute('organizer_id');
            if (eZUser::fetch($organizerId) instanceof eZUser
                && $this->getObject()->attribute('owner_id') != $organizerId) {
                $this->getObject()->setAttribute('owner_id', $organizerId);
                $this->getObject()->store();
            }
        }
    }
}
