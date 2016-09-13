<?php

class AgendaItem extends OCEditorialStuffPostDefault
{
    public function onCreate()
    {
        if ( $this->getObject()->attribute('current_version') == 1 ){
            $states = $this->states();
            $default = 'moderation.waiting';
            if ( isset( $states[$default] ) ) {
                $this->getObject()->assignState($states[$default]);
            }
        }
        eZSearch::addObject( $this->object, true );
        OpenPAAgenda::notifyModerationGroup($this);        
    }

    public function onUpdate()
    {
        eZSearch::addObject( $this->object, true );
        OpenPAAgenda::notifyModerationGroup($this);
    }

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
        $access = $currentUser->hasAccessTo( 'editorialstuff', 'media' );
        if ( $access['accessWord'] == 'yes' && in_array( 'images', $this->factory->attributeIdentifiers() ) )
        {
            $tabs[] = array(
                'identifier' => 'media',
                'name' => 'Galleria immagini',
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
        $access = $currentUser->hasAccessTo( 'push', '*' );
        if ( eZINI::instance( 'ngpush.ini' )->hasVariable( 'PushNodeSettings', 'Blocks' ) && $access['accessWord'] == 'yes' )
        {
            $tabs[] = array(
                'identifier' => 'social',
                'name' => 'Social Network',
                'template_uri' => "design:{$templatePath}/parts/social.tpl"
            );
        }

        $tabs[] = array(
            'identifier' => 'comments',
            'name' => 'Commenti',
            'template_uri' => "design:{$templatePath}/parts/public_comments.tpl"
        );

        $tabs[] = array(
            'identifier' => 'tools',
            'name' => 'Press kit',
            'template_uri' => "design:{$templatePath}/parts/tools.tpl"
        );

        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );
        return $tabs;
    }

}
