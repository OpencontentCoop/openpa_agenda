<?php

class Associazione extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{
    public function tabs()
    {
        $currentUser = eZUser::currentUser();
        $templatePath = $this->getFactory()->getTemplateDirectory();
        $tabs = array(
            array(
                'identifier' => 'content',
                'name' => 'Contenuto',
                'template_uri' => "design:{$templatePath}/parts/content.tpl"
            )
        );
        if ( $currentUser->hasAccessTo( 'editorialstuff', 'media' ) && in_array( 'image', $this->factory->attributeIdentifiers() ) )
        {
            $tabs[] = array(
                'identifier' => 'media',
                'name' => 'Media',
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

        $access = $currentUser->hasAccessTo('agenda', 'push');
        if (eZINI::instance('ngpush.ini')->hasVariable('PushNodeSettings', 'Blocks')
            && $access['accessWord'] == 'yes'
        ) {
            $blocks = (array)eZINI::instance('ngpush.ini')->variable('PushNodeSettings', 'Blocks');
            if (count($blocks) > 0) {
                $tabs[] = array(
                    'identifier' => 'social',
                    'name' => ezpI18n::tr('openpa_agenda', 'Share'),
                    'template_uri' => "design:{$templatePath}/parts/social.tpl"
                );
            }
        }

        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );
        return $tabs;
    }

    public function onCreate()
    {
        OpenPAAgenda::notifyModerationGroup($this);
    }

    public function onUpdate()
    {
        OpenPAAgenda::notifyModerationGroup($this);
    }

    public function attributes()
    {
        return array_merge(parent::attributes(), array('is_published'));
    }

    public function attribute($property)
    {
        if ($property == 'is_published') {
            return $this->is('public');
        }

        if ($property == 'social_history') {
            return $this->getSocialHistory();
        }

        return parent::attribute($property);
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

            if ($module) {
                $module->redirectTo("editorialstuff/edit/{$this->getFactory()->identifier()}/{$this->id()}#tab_social");
            }
        }
    }
}
