<?php

class AgendaItem extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{
    public function onCreate()
    {
        if ($this->getObject()->attribute('current_version') == 1) {
            $states = $this->states();
            $default = 'moderation.draft';
            if (isset( $states[$default] )) {
                $this->getObject()->assignState($states[$default]);
            }
        }
        eZSearch::addObject($this->object, true);
        OpenPAAgenda::notifyModerationGroup($this);
    }

    public function attributes()
    {
        return array_merge(parent::attributes(), array('is_published'));
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('accepted');
        }

        if ($property == 'social_history') {
            return $this->getSocialHistory();
        }

        return parent::attribute($property);
    }

    public function onUpdate()
    {
        eZSearch::addObject($this->object, true);
        OpenPAAgenda::notifyModerationGroup($this);
    }

    public function tabs()
    {
        $currentUser = eZUser::currentUser();
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = array(
            array(
                'identifier' => 'content',
                'name' => ezpI18n::tr('openpa_agenda', 'Contenuto'),
                'template_uri' => "design:{$templatePath}/parts/content.tpl"
            )
        );
        $access = $currentUser->hasAccessTo('editorialstuff', 'media');
        if ($access['accessWord'] == 'yes' && in_array('images', $this->factory->attributeIdentifiers())) {
            $tabs[] = array(
                'identifier' => 'media',
                'name' => ezpI18n::tr('openpa_agenda', 'Galleria immagini'),
                'template_uri' => "design:{$templatePath}/parts/media.tpl"
            );
        }
        //        if ( $currentUser->hasAccessTo( 'editorialstuff', 'mail' ) )
        //        {
        //            $tabs[] = array(
        //                'identifier' => 'mail',
        //                'name' => 'Mail',
        //                'template_uri' => "design:{$templatePath}/parts/mail.tpl"
        //            );
        //        }
        $access = $currentUser->hasAccessTo('push', '*');
        if (eZINI::instance('ngpush.ini')->hasVariable('PushNodeSettings', 'Blocks')
            && $access['accessWord'] == 'yes'
        ) {
            $tabs[] = array(
                'identifier' => 'social',
                'name' => ezpI18n::tr('openpa_agenda', 'Share'),
                'template_uri' => "design:{$templatePath}/parts/social.tpl"
            );
        }

        if (OpenPAAgenda::instance()->isCommentEnabled()) {
            $tabs[] = array(
                'identifier' => 'comments',
                'name' => ezpI18n::tr('openpa_agenda', 'Commenti'),
                'template_uri' => "design:{$templatePath}/parts/public_comments.tpl"
            );
        }

        $tabs[] = array(
            'identifier' => 'tools',
            'name' => ezpI18n::tr('openpa_agenda', 'Press kit'),
            'template_uri' => "design:{$templatePath}/parts/tools.tpl"
        );

        $tabs[] = array(
            'identifier' => 'history',
            'name' => ezpI18n::tr('openpa_agenda', 'Cronologia'),
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );

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
        $data = array();
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
            }else{
                $client = OpenPAAgendaPushClientLoader::instance($type);
                if ($client){
                    $type = $client->name();
                    $link = $client->getRemoteUrl($params['response']);
                }
            }
            $itemNormalized = array(
                'created_time' => $item->attribute('created_time'),
                'user' => $item->attribute('user'),
                'type' => $type,
                'params' => $params,
                'link' => $link
            );
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

            OCEditorialStuffHistory::addSocialHistoryToObjectId(
                $this->id(),
                'tcu',
                $response
            );

            if ($module) {
                $module->redirectTo("editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_social");
            }
        }
    }

}
