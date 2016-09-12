<?php

class Associazione extends OCEditorialStuffPostDefault
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
//        if ( eZINI::instance( 'ngpush.ini' )->hasVariable( 'PushNodeSettings', 'Blocks' ) && $currentUser->hasAccessTo( 'push', '*' ) )
//        {
//            $tabs[] = array(
//                'identifier' => 'social',
//                'name' => 'Social Network',
//                'template_uri' => "design:{$templatePath}/parts/social.tpl"
//            );
//        }
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
}
