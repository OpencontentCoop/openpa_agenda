<?php

class OpenPAAgendaPageDataHandler implements OCPageDataHandlerInterface
{

    public function agenda()
    {
        return OpenPAAgenda::instance();
    }

    public function siteTitle()
    {
        return strip_tags( $this->logoTitle() );
    }

    public function siteUrl()
    {
        return $this->agenda()->siteUrl();
    }

    public function assetUrl()
    {
        $siteUrl = eZINI::instance()->variable( 'SiteSettings', 'SiteURL' );
        $parts = explode( '/', $siteUrl );
        if ( count( $parts ) >= 2 )
        {
            array_pop( $parts );
            $siteUrl = implode( '/', $parts );
        }
        return rtrim( $siteUrl, '/' );
    }

    public function logoPath()
    {
        return $this->agenda()->imagePath('logo');
    }

    public function logoTitle()
    {
        return $this->agenda()->getAttributeString( 'logo_title' );
    }

    public function logoSubtitle()
    {
        return $this->agenda()->getAttributeString( 'logo_subtitle' );
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
        return OpenPAINI::variable( 'Seo', 'GoogleAnalyticsAccountID', false );
    }

    public function cookieLawUrl()
    {
        $href = 'agenda/info/cookie';
        eZURI::transformURI( $href, false, 'full' );
        return $href;
    }

    public function menu()
    {
        $hasAccess = eZUser::currentUser()->hasAccessTo( 'agenda', 'use' );
        if ( $hasAccess['accessWord'] !== 'yes' ){
            return array();
        }
        $infoChildren = array(
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Faq' ),
                'url' => 'agenda/info/faq',
                'has_children' => false,
            ),
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Privacy' ),
                'url' => 'agenda/info/privacy',
                'has_children' => false,
            ),
            array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Termini di utilizzo' ),
                'url' => 'agenda/info/terms',
                'has_children' => false,
            )
        );

        $menu = array();

        $menu[] = array(
            'name' => ezpI18n::tr( 'agenda/menu', 'Agenda' ),
            'url' => '',
            'highlight' => false,
            'has_children' => false
        );

        if ($this->agenda()->isCollaborationModeEnabled()) {
            $menu[] = array(
                'name' => ezpI18n::tr('agenda/menu', 'Associazioni'),
                'url' => 'agenda/associazioni',
                'highlight' => false,
                'has_children' => false
            );
        }

        $hasAccess = eZUser::currentUser()->hasAccessTo( 'editorialstuff', 'dashboard' );
        if ( $hasAccess['accessWord'] == 'yes' )
        {
            $menu[] = array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Gestisci eventi' ),
                'url' => 'editorialstuff/dashboard/agenda',
                'highlight' => false,
                'has_children' => false
            );            
        }
        
        $menu[] = array(
            'name' => ezpI18n::tr( 'agenda/menu', 'Informazioni' ),
            'url' => 'agenda/info',
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
                'name' => ezpI18n::tr( 'agenda/menu', 'Profilo' ),
                'url' => 'user/edit',
                'highlight' => false,
                'has_children' => false
            ),
//            array(
//                'name' => ezpI18n::tr( 'agenda/menu', 'Notifiche' ),
//                'url' => 'notification/settings',
//                'highlight' => false,
//                'has_children' => false
//            )
        );

        $hasAccess = eZUser::currentUser()->hasAccessTo( 'agenda', 'config' );
        if ( $hasAccess['accessWord'] == 'yes' ) {
            $userMenu[] = array(
                'name' => ezpI18n::tr('agenda/menu', 'Settings'),
                'url' => 'agenda/config',
                'highlight' => false,
                'has_children' => false
            );
        
            $userMenu[] = array(
                'name' => ezpI18n::tr('agenda/menu', 'Gestisci associazioni'),
                'url' => 'editorialstuff/dashboard/associazione',
                'highlight' => false,
                'has_children' => false
            );
        
            $userMenu[] = array(
                'name' => ezpI18n::tr( 'agenda/menu', 'Gestisci programma in pdf' ),
                'url' => 'editorialstuff/dashboard/programma_eventi',
                'highlight' => false,
                'has_children' => false
            );
        }
        $userMenu[] = array(
            'name' => ezpI18n::tr( 'agenda/menu', 'Esci' ),
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
        return $this->agenda()->getAttributeString( 'banner_title' );
    }

    public function bannerSubtitle()
    {
        return $this->agenda()->getAttributeString( 'banner_subtitle' );
    }
}
