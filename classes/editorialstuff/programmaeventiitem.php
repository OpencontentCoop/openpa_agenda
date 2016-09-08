<?php

class ProgrammaEventiItem extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{

    protected $abstract_length = 270;
    protected $events = array();

    public function onCreate()
    {
        if ( $this->getObject()->attribute('current_version') == 1 ){
            $states = $this->states();
        }
    }

    /**
     * @return array
     */
    public function attributes()
    {
        $attributes = parent::attributes();
        $attributes[] = 'abstract_length';
        $attributes[] = 'events';
        return $attributes;
    }

    /**
     * @param $property
     */
    public function attribute($property)
    {
        if ( $property == 'abstract_length' )
        {
            return $this->abstract_length;
        }

        if ( $property == 'events' )
        {
            return $this->getEvents();
        }

        return parent::attribute( $property );
    }


    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        if ( $actionIdentifier == 'SaveAndGetLeaflet' )
        {
            $httpTool = eZHTTPTool::instance();
            $events = array();
            $inputEvents = $httpTool->postVariable('Events', false);
            if ($inputEvents)
            {
                foreach ($inputEvents as $k => $v)
                {
                    if (trim($v) != '')
                    {
                        $events []= implode('|', array($k, trim($v)));
                    }
                }
            }
            $params = array();
            $params['attributes'] = array(
                'events_layout' => implode( '&', $events )
            );
            eZContentFunctions::updateAndPublishObject( $this->getObject(), $params );

            $rootNode = eZContentObjectTreeNode::fetch( OpenPAAgenda::instance()->rootObject()->attribute('main_node_id'));

            $tpl = eZTemplate::factory();
            $tpl->resetVariables();
            $tpl->setVariable( 'root_node', $rootNode );
            $tpl->setVariable( 'programma_eventi', $this );
            $tpl->setVariable( 'columns', $httpTool->postVariable('Columns', 2) );
            $content = $tpl->fetch( 'design:pdf/programma_eventi/leaflet.tpl' );

            /** @var eZContentClass $objectClass */
            $objectClass = $this->getObject()->attribute( 'content_class' );
            $languageCode = eZContentObject::defaultLanguage();
            $fileName = $objectClass->urlAliasName( $this->getObject(), false, $languageCode );
            $fileName = eZURLAliasML::convertToAlias( $fileName ) . '.pdf';

            $parameters = array(
                'exporter' => 'paradox',
                'cache' => array(
                    'keys' => array(),
                    'subtree_expiry' => '',
                    'expiry' => -1,
                    'ignore_content_expiry' => false
                )
            );

            $paradoxPdf = new ParadoxPDF();
            if ( eZINI::instance()->variable( 'DebugSettings', 'DebugOutput' ) == 'enabled' )
            {
                echo $content;
                exit;
                echo '<pre>' . htmlentities($paradoxPdf->generatePDF( $content ));
                /*array(
                    'content' => $paradoxPdf->generatePDF( $content ),
                    'exporter' => $paradoxPdf
                )*/
                eZDisplayDebug();
            }
            else
            {
                $paradoxPdf->exportPDF(
                    $content,
                    $fileName,
                    $parameters['cache']['keys'],
                    $parameters['cache']['subtree_expiry'],
                    $parameters['cache']['expiry'],
                    $parameters['cache']['ignore_content_expiry']
                );
                return true;
            }
            eZExecution::cleanExit();

        }
        else if ( $actionIdentifier == 'BrowseEvent' )
        {
            $startNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');
            $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_agenda_container' );
            if ($containerObject instanceof eZContentObject)
            {
                $startNodeId = $containerObject->attribute('main_node_id');
            }

            eZContentBrowse::browse(
                array(
                    'action_name' => 'AddSelectedEvent',
                    'selection'   => 'multiple',
                    'from_page'   => '/editorialstuff/action/programma_eventi/' . $this->getObject()->ID . '#tab_leaflet',
                    'class_array' => array( 'event' ),
                    'start_node'  => $startNodeId,
                    'cancel_page' => '/editorialstuff/edit/programma_eventi/' . $this->getObject()->ID . '#tab_leaflet',
                    'persistent_data' => array(
                        'ActionIdentifier' => 'AddSelectedEvent',
                        'AddSelectedEvent' => 'true'
                    )
                ),
                $module
            );
        }
        else if ( $actionIdentifier == 'AddSelectedEvent' )
        {
            $http = eZHTTPTool::instance();
            if ( $http->hasPostVariable( 'SelectedNodeIDArray' ) && !empty( $http->postVariable( 'SelectedNodeIDArray' ) ) )
            {
                $selected = $http->postVariable( 'SelectedNodeIDArray' );
                $dataMap = $this->getObject()->dataMap();
                $events = explode( '-', $dataMap['events']->toString());

                foreach ($selected as $s)
                {
                    /** @var eZContentObjectTreeNode $node */
                    $node = eZContentObjectTreeNode::fetch($s);
                    if (!in_array($node->ContentObjectID, $events))
                    {
                        $events []= $node->ContentObjectID;
                    }
                }

                $params = array();
                $params['attributes'] = array(
                    'events' => implode( '-', $events )
                );
                eZContentFunctions::updateAndPublishObject( $this->getObject(), $params );
            }
        }
        else if ( $actionIdentifier == 'DeleteSelected' )
        {
            $http = eZHTTPTool::instance();
            if ( $http->hasPostVariable( 'SelectedEvents' ) && !empty( $http->postVariable( 'SelectedEvents' ) ) )
            {
                $selected = explode( '-', $http->postVariable( 'SelectedEvents' ));
                $dataMap = $this->getObject()->dataMap();
                $events = explode( '-', $dataMap['events']->toString());

                foreach ($events as $k => $v)
                {
                    if (in_array($v, $selected))
                    {
                        unset($events[$k]);
                    }
                }

                $params = array();
                $params['attributes'] = array(
                    'events' => implode( '-', $events )
                );
                eZContentFunctions::updateAndPublishObject( $this->getObject(), $params );
            }
        }
    }


    /**
     * @return Events[]
     */
    public function getEvents()
    {

        if ( empty( $this->events ) )
        {
            $events = array();
            $data_map = $this->getObject()->dataMap();
            $related_events = $data_map['events']->content();
            $events_array = $related_events['relation_list'];

            /** @var eZMatrix $eventsLayout */
            $eventsLayout = $data_map['events_layout']->content();
            $layoutRows = $eventsLayout->attribute('rows');

            $customEentsAttributes = array();
            foreach ($layoutRows['sequential'] as $row)
            {
                $customEentsAttributes[$row['columns'][0]] = array(
                    'abstract' => $row['columns'][1]
                );
            }

            foreach ($events_array as $event){
                /** @var eZContentObject $objectEvent */
                $objectEvent = eZContentObject::fetch($event['contentobject_id']);
                $eventDataMap = $objectEvent->dataMap();
                $key = $eventDataMap['from_time']->toString() . '-' . $objectEvent->ID;

                $events [$key] = array(
                    'id'   => $objectEvent->ID,
                    'main_node_id' => $objectEvent->mainNodeID(),
                    'name' => $objectEvent->attribute('name'),
                    'periodo_svolgimento' => $eventDataMap['periodo_svolgimento']->toString(),
                    'from_time' => $eventDataMap['from_time']->toString(),
                    'to_time' => $eventDataMap['to_time']->toString(),
                    'orario_svolgimento' => $eventDataMap['periodo_svolgimento']->toString(),
                    'durata' => $eventDataMap['durata']->toString(),
                    'luogo_svolgimento' => $eventDataMap['luogo_svolgimento']->toString(),
                    'abstract' => substr(strip_tags($eventDataMap['abstract']->hasContent() ? $eventDataMap['abstract']->toString() : $eventDataMap['text']->toString()), 0, $this->abstract_length),
                    'auto' => true
                );

                if (isset($customEentsAttributes[$objectEvent->ID]) && !empty($customEentsAttributes[$objectEvent->ID]['abstract']))
                {
                    $events [$key]['abstract'] = $customEentsAttributes[$objectEvent->ID]['abstract'];
                    $events [$key]['auto'] = false;
                }
            }
            ksort( $events );
            $this->events = $events;
        }
        return $this->events;
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
        /*if ( $currentUser->hasAccessTo( 'editorialstuff', 'media' ) && in_array( 'images', $this->factory->attributeIdentifiers() ) )
        {
            $tabs[] = array(
                'identifier' => 'media',
                'name' => 'Galleria immagini',
                'template_uri' => "design:{$templatePath}/parts/media.tpl"
            );
        }
        if ( $currentUser->hasAccessTo( 'editorialstuff', 'mail' ) )
        {
            $tabs[] = array(
                'identifier' => 'mail',
                'name' => 'Mail',
                'template_uri' => "design:{$templatePath}/parts/mail.tpl"
            );
        }
        if ( eZINI::instance( 'ngpush.ini' )->hasVariable( 'PushNodeSettings', 'Blocks' ) && $currentUser->hasAccessTo( 'push', '*' ) )
        {
            $tabs[] = array(
                'identifier' => 'social',
                'name' => 'Social Network',
                'template_uri' => "design:{$templatePath}/parts/social.tpl"
            );
        }*/

        $tabs[] = array(
            'identifier' => 'leaflet',
            'name' => 'Volantino',
            'template_uri' => "design:{$templatePath}/parts/leaflet.tpl"
        );


        /*$tabs[] = array(
            'identifier' => 'comments',
            'name' => 'Commenti',
            'template_uri' => "design:{$templatePath}/parts/public_comments.tpl"
        );

        $tabs[] = array(
            'identifier' => 'tools',
            'name' => 'Press kit',
            'template_uri' => "design:{$templatePath}/parts/tools.tpl"
        );*/

        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );
        return $tabs;
    }

}