<?php

class Associazione extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{
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
//        if ( $currentUser->hasAccessTo( 'editorialstuff', 'media' ) && in_array( 'image', $this->factory->attributeIdentifiers() ) )
//        {
//            $tabs[] = array(
//                'identifier' => 'media',
//                'name' => 'Media',
//                'template_uri' => "design:{$templatePath}/parts/media.tpl"
//            );
//        }
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

        $access = $currentUser->hasAccessTo('agenda', 'config');
        if (!empty(OpenPAINI::variable('OpenpaAgenda', 'OrganizationPrivateAttributes', []))
            && $access['accessWord'] == 'yes'
        ) {
            $tabs[] = [
                'identifier' => 'settings',
                'name' => ezpI18n::tr('openpa_agenda', 'Settings'),
                'template_uri' => "design:{$templatePath}/parts/settings.tpl",
            ];
        }

        $tabs[] = [
            'identifier' => 'history',
            'name' => ezpI18n::tr('openpa_agenda', 'History'),
            'template_uri' => "design:{$templatePath}/parts/history.tpl",
        ];
        return $tabs;
    }

    public function onCreate()
    {
        $this->updateOwner();
        if ($this->getObject()->attribute('current_version') == 1 && eZUser::currentUser()->isAnonymous()) {
            $states = $this->states();
            $default = 'privacy.private';
            if (isset($states[$default])) {
                $this->getObject()->assignState($states[$default]);
            }
            $this->disableUser();
            $this->flushObject();
            eZSearch::addObject($this->getObject(), true);
        }
        OpenPAAgenda::notifyModerationGroup($this, 'design:agenda/mail/associazione/to_moderators_on_create.tpl');
        OpenPAAgenda::notifyEventOwner($this, 'design:agenda/mail/associazione/to_owner_on_create.tpl');
    }

    public function onChangeState(eZContentObjectState $beforeState, eZContentObjectState $afterState)
    {
        if ($afterState->attribute('identifier') == 'private') {
            $this->disableUser();
            $this->flushObject();
        } elseif ($afterState->attribute('identifier') == 'public') {
            $this->enableUser();
            $this->flushObject();
            OpenPAAgenda::notifyEventOwner($this, 'design:agenda/mail/associazione/to_owner_on_public.tpl');
        }

        if ($beforeState->attribute('identifier') != $afterState->attribute('identifier')) {
            $this->setObjectLastModified();
        }

        return parent::onChangeState($beforeState, $afterState);
    }

    private function disableUser()
    {
        $userSetting = eZUserSetting::fetch($this->id());
        if ($userSetting instanceof eZUserSetting) {
            if ($userSetting->attribute("is_enabled") != 0) {
                eZContentCacheManager::clearContentCacheIfNeeded($this->id());
                eZContentCacheManager::generateObjectViewCache($this->id());
            }
            $userSetting->setAttribute("is_enabled", 0);
            $userSetting->store();
        }
    }

    private function enableUser()
    {
        $userSetting = eZUserSetting::fetch($this->id());
        if ($userSetting instanceof eZUserSetting) {
            if ($userSetting->attribute("is_enabled") != 1) {
                eZContentCacheManager::clearContentCacheIfNeeded($this->id());
                eZContentCacheManager::generateObjectViewCache($this->id());
            }
            $userSetting->setAttribute("is_enabled", 1);
            $userSetting->store();
        }
    }

    public function onUpdate()
    {
        $this->updateOwner();
        OpenPAAgenda::notifyModerationGroup($this, 'design:agenda/mail/associazione/to_moderators_on_update.tpl');
    }

    public function attributes()
    {
        return array_merge(parent::attributes(), ['is_published', 'user']);
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('public');
        }

        if ($property == 'social_history') {
            return $this->getSocialHistory();
        }

        if ($property == 'user') {
            return eZUser::fetch($this->id());
        }

        return parent::attribute($property);
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

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
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
    }

    private function updateOwner()
    {
        if ($this->getObject()->attribute('owner_id') != $this->id()) {
            $this->getObject()->setAttribute('owner_id', $this->id());
            $this->getObject()->store();
        }
    }
}
