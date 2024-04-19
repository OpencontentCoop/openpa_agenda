<?php

class OpenPAAgendaPageDataHandler extends ezjscServerFunctions implements OCPageDataHandlerInterface
{

    public function agenda()
    {
        return OpenPAAgenda::instance();
    }

    public function siteTitle()
    {
        return strip_tags($this->logoTitle());
    }

    public function siteUrl()
    {
        return $this->agenda()->siteUrl();
    }

    public function assetUrl()
    {
        $siteUrl = eZINI::instance()->variable('SiteSettings', 'SiteURL');
        $parts = explode('/', $siteUrl);
        if (count($parts) >= 2) {
            array_pop($parts);
            $siteUrl = implode('/', $parts);
        }
        return rtrim($siteUrl, '/');
    }

    public function logoPath()
    {
        return $this->agenda()->imagePath('logo');
    }

    public function logoTitle()
    {
        return $this->agenda()->getAttributeString('logo_title');
    }

    public function logoSubtitle()
    {
        return $this->agenda()->getAttributeString('logo_subtitle');
    }

    public function headImages()
    {
        return array(
            "apple-touch-icon-114x114-precomposed" => null,
            "apple-touch-icon-72x72-precomposed" => null,
            "apple-touch-icon-57x57-precomposed" => null,
            "favicon" => null
        );
    }

    public function needLogin()
    {
        $currentModuleParams = $GLOBALS['eZRequestedModuleParams'];
        $request = array(
            'module' => $currentModuleParams['module_name'],
            'function' => $currentModuleParams['function_name'],
            'parameters' => $currentModuleParams['parameters'],
        );

        return !eZUser::currentUser()->isRegistered() && $request['module'] == 'social_user';
    }

    public function attributeContacts()
    {
        return $this->agenda()->getAttribute('contacts');
    }

    public function attributeFooter()
    {
        return $this->agenda()->getAttribute('footer');
    }

    public function textCredits()
    {
        return OpenPAINI::variable('CreditsSettings', 'Agenda');
    }

    public function googleAnalyticsId()
    {
        return OpenPAINI::variable('Seo', 'GoogleAnalyticsAccountID', false);
    }

    public function cookieLawUrl()
    {
        $href = 'agenda/info/cookie';
        eZURI::transformURI($href, false, 'full');
        return $href;
    }

    public function menu()
    {
        $hasAccess = eZUser::currentUser()->hasAccessTo('agenda', 'use');
        if ($hasAccess['accessWord'] !== 'yes') {
            return array();
        }

        $mainMenu = OpenPAAgenda::instance()->getAttribute('main_menu');
        if ($mainMenu->attribute('data_type_string') == eZMatrixType::DATA_TYPE_STRING){
            $data = array();
            if ($mainMenu->hasContent()) {
                /** @var \eZMatrix $attributeContents */
                $mainMenuContents = $mainMenu->content();
                $columns = (array)$mainMenuContents->attribute('columns');
                $rows = (array)$mainMenuContents->attribute('rows');

                $keys = array();
                foreach ($columns['sequential'] as $column) {
                    $keys[] = $column['identifier'];
                }

                foreach ($rows['sequential'] as $row) {
                    $data[] = array_combine($keys, $row['columns']);
                }
            }

            return $data;
        }

        $infoChildren = array(
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'FAQ' ),
                'url' => 'agenda/info/faq',
                'has_children' => false,
            ),
            array(
                'name' => ezpI18n::tr('agenda/menu', 'Privacy'),
                'url' => 'agenda/info/privacy',
                'has_children' => false,
            ),
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Terms of use' ),
                'url' => 'agenda/info/terms',
                'has_children' => false,
            )
        );

        $menu = array();

        $eventsNode = eZContentObjectTreeNode::fetch(OpenPAAgenda::calendarNodeId());
        $eventsNodeUrl = $eventsNode->attribute('url_alias');

        $organizationsNode = eZContentObjectTreeNode::fetch(OpenPAAgenda::associationsNodeId());
        $organizationsNodeUrl = $organizationsNode->attribute('url_alias');

        $isSiteRoot = OpenPAAgenda::instance()->isSiteRoot();

        $menu[] = array(
            'name' => $isSiteRoot ? $eventsNode->attribute('name') : ezpI18n::tr( 'agenda/menu', 'Agenda' ),
            'url' => $isSiteRoot ? $eventsNodeUrl : '',
            'highlight' => false,
            'has_children' => false
        );

        if ($this->agenda()->isCollaborationModeEnabled()) {
            $menu[] = array(
                'name' => $isSiteRoot ? $organizationsNode->attribute('name') : ezpI18n::tr('agenda/menu', 'Organizations'),
                'url' => $isSiteRoot ? $organizationsNodeUrl : 'agenda/associazioni',
                'highlight' => false,
                'has_children' => false
            );
        }

        $menu[] = array(
            'name' => ezpI18n::tr( 'agenda/menu', 'Information' ),
            'url' => '',
            'highlight' => false,
            'has_children' => true,
            'children' => $infoChildren
        );

        return $menu;
    }

    public function userMenu()
    {
        $userMenu = array(
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Profile' ),
                'url' => 'user/edit',
                'highlight' => false,
                'has_children' => false
            )
        );

        $hasAccessConfig = eZUser::currentUser()->hasAccessTo('agenda', 'config');
        if ($hasAccessConfig['accessWord'] == 'yes') {
            $userMenu[] = array(
                'name' => ezpI18n::tr('agenda/menu', 'Settings'),
                'url' => 'agenda/config',
                'highlight' => false,
                'has_children' => false
            );
        }

        $hasAccess = eZUser::currentUser()->hasAccessTo('editorialstuff', 'dashboard');
        if ($hasAccess['accessWord'] == 'yes') {
            $userMenu[] = array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Manage events' ),
                'url' => 'editorialstuff/dashboard/agenda',
                'highlight' => false,
                'has_children' => false
            );
        }

        if ($hasAccessConfig['accessWord'] == 'yes') {
            $userMenu[] = array(
                'name' => ezpI18n::tr('agenda/menu', 'Manage organizations'),
                'url' => 'editorialstuff/dashboard/associazione',
                'highlight' => false,
                'has_children' => false
            );

            $userMenu[] = array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Manage PDF Programme' ),
                'url' => 'editorialstuff/dashboard/programma_eventi',
                'highlight' => false,
                'has_children' => false
            );
        }

        $hasAccess = eZUser::currentUser()->hasAccessTo('newsletter', 'index');
        if ($hasAccess['accessWord'] == 'yes') {
            $userMenu[] = array(
                'name' => 'Newsletter dashboard',
                'url' => 'newsletter/index',
                'highlight' => false,
                'has_children' => false
            );
        }

        $userMenu[] = array(
            'name' => ezpI18n::tr( 'agenda/menu', 'Logout' ),
            'url' => 'user/logout',
            'highlight' => false,
            'has_children' => false
        );

        return $userMenu;
    }

    public function bannerPath()
    {
        return $this->agenda()->imagePath('banner');
    }

    public function bannerTitle()
    {
        return $this->agenda()->getAttributeString('banner_title');
    }

    public function bannerSubtitle()
    {
        return $this->agenda()->getAttributeString('banner_subtitle');
    }

    public static function userInfo()
    {
        $user = eZUser::currentUser();
        if ($user->isRegistered()){
            $sessionKey = 'agenda_user_info_' . $user->id() . eZSiteAccess::current()['name'];
            $refresh = true;
            if (!eZHTTPTool::instance()->hasSessionVariable($sessionKey) || $refresh) {
                $userMenu = [];
                $userMenu['menu'] = (new static())->userMenu();
                $userMenu['name'] = $user->contentObject()->attribute('name');
                eZHTTPTool::instance()->setSessionVariable( $sessionKey, $userMenu);
            }

            return eZHTTPTool::instance()->sessionVariable($sessionKey);
        }
    }

    public static function overlapInfo($args)
    {
        $overlaps = ['totalCount' => 0];
        $currentEventId = (int)$args[0];
        $radius = isset($args[1]) && $args[1] != 'false' ? $args[1] : false;
        $contentSearch = new \Opencontent\Opendata\Api\ContentSearch();
        $env = new DefaultEnvironmentSettings();
        $contentSearch->setCurrentEnvironmentSettings($env);
        $currentEventSearch = $contentSearch->search('id = ' . $currentEventId, []);
        if ($currentEventSearch->totalCount > 0) {
            $content = $currentEventSearch->searchHits[0];
            $locale = eZLocale::currentLocaleCode();
            $events = isset($content['data'][$locale]['time_interval']['events']) ? $content['data'][$locale]['time_interval']['events'] : [];
            $takePlaceIn = isset($content['data'][$locale]['takes_place_in'][0]['id']) ? $content['data'][$locale]['takes_place_in'][0]['id'] : false;
            if (count($events) == 0) { //fallback in italian
                $events = isset($content['data']['ita-IT']['time_interval']['events']) ? $content['data']['ita-IT']['time_interval']['events'] : [];
            }
            if (!$takePlaceIn) { //fallback in italian
                $takePlaceIn = isset($content['data']['ita-IT']['takes_place_in'][0]['id']) ? $content['data']['ita-IT']['takes_place_in'][0]['id'] : false;
            }
            if (count($events) > 0) {
                $queryEvents = [];
                foreach ($events as $event) {
                    $queryEvents[] = 'calendar[time_interval] = [\'' . date('Y-m-d H:i', strtotime($event['start'])) . '\',\'' . date('Y-m-d H:i', strtotime($event['end'])) . '\']';
                }
                $query = "classes [event] and id != '$currentEventId' and (" . implode(' or ', $queryEvents) . ")";
                if ($radius && $takePlaceIn) {
                    $query .= ' and and raw['.ezfIndexSubAttributeGeo::RPT_FIELD.'] = \'"IsWithin\(POLYGON\(\(' . $radius . '\)\)\) distErrPct=0"\'';
                }
                $overlaps = $contentSearch->search($query);
            }
        }
        echo json_encode($overlaps);
        eZExecution::cleanExit();
    }
}
