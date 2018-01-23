<?php

class ProgrammaEventiItem extends OCEditorialStuffPostDefault implements OCEditorialStuffPostInputActionInterface
{

    protected $abstract_length = 220;
    protected $layouts = array(
        array(
            'id'                   => 2,
            'columns'              => 2,
            'events_per_page'      => 6,
            'title'                => 'Due colonne (18 eventi)',
            'displayed_attributes' => array(
                'name'                => 'Titolo',
                'abstract'            => 'Abstract',
                'periodo_svolgimento' => 'Periodo',
                'orario_svolgimento'  => 'Orario',
                'durata'              => 'Durata',
                'luogo_svolgimento'   => 'Luogo svolgimento'
            )
        ),
        array(
            'id'              => 3,
            'columns'         => 3,
            'events_per_page' => 4,
            'title'           => 'Tre colonne (20 eventi)',
            'displayed_attributes' => array(
                'name'                => 'Titolo',
                'abstract'            => 'Abstract',
                'periodo_svolgimento' => 'Periodo',
                'orario_svolgimento'  => 'Orario',
                'durata'              => 'Durata',
                'luogo_svolgimento'   => 'Luogo svolgimento'
            )
        ),
        array(
            'id'                   => 4,
            'columns'              => 3,
            'events_per_page'      => 8,
            'title'                => 'Tre colonne (40 eventi)',
            'displayed_attributes' => array(
                'name'                => 'Titolo',
                'periodo_svolgimento' => 'Periodo',
                'orario_svolgimento'  => 'Orario',
                'durata'              => 'Durata',
                'luogo_svolgimento'   => 'Luogo svolgimento'
            )
        )
    );

    protected $events = array();

    public function onCreate()
    {
        if ($this->getObject()->attribute('current_version') == 1) {
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
        $attributes[] = 'layouts';
        $attributes[] = 'events';
        $attributes[] = 'file_attribute';

        return $attributes;
    }

    /**
     * @param $property
     *
     * @return mixed
     */
    public function attribute($property)
    {
        if ($property == 'abstract_length') {
            return $this->abstract_length;
        }

        if ($property == 'layouts') {
            return $this->layouts;
        }

        if ($property == 'events') {
            return $this->getEvents();
        }

        if ($property == 'file_attribute') {
            return $this->getFileAttribute();
        }

        return parent::attribute($property);
    }

    protected function getFileAttribute()
    {
        if (isset( $this->dataMap['file'] )) {
            return $this->dataMap['file'];
        }

        return false;
    }

    private function saveProgram()
    {
        $httpTool = eZHTTPTool::instance();
        $events = array();
        $inputEvents = $httpTool->postVariable('Events', false);
        if ($inputEvents) {
            foreach ($inputEvents as $k => $v) {
                if (trim($v) != '') {
                    $events [] = implode('|', array($k, trim($v)));
                }
            }
        }
        $params = array();
        $params['attributes'] = array(
            'events_layout' => implode('&', $events)
        );
        eZContentFunctions::updateAndPublishObject($this->getObject(), $params);
        $this->flushObject();
        $this->dataMap = $this->getObject()->attribute('data_map');

        $rootNode = eZContentObjectTreeNode::fetch(OpenPAAgenda::instance()->rootObject()->attribute('main_node_id'));

        $currentLayout = $httpTool->postVariable('layout');
        foreach($this->layouts as $layout){
            if ($layout['id'] == $currentLayout){
                $currentLayout = $layout;
            }
        }

        $tpl = eZTemplate::factory();
        $tpl->resetVariables();
        $tpl->setVariable('root_node', $rootNode);
        $tpl->setVariable('programma_eventi', $this);
        $tpl->setVariable('root_dir', eZSys::rootDir());
        $tpl->setVariable('layout', $currentLayout);
        $content = $tpl->fetch('design:pdf/programma_eventi/leaflet.tpl');

        /** @var eZContentClass $objectClass */
        $objectClass = $this->getObject()->attribute('content_class');
        $languageCode = eZContentObject::defaultLanguage();
        $fileName = $objectClass->urlAliasName($this->getObject(), false, $languageCode);
        $fileName = eZURLAliasML::convertToAlias($fileName) . '.pdf';

        $paradoxPdf = new ParadoxPDF();
        $pdfContent = $paradoxPdf->generatePDF($content);

        $ini = eZINI::instance();
        $viewCacheEnabled = ( $ini->variable( 'ContentSettings', 'ViewCaching' ) == 'enabled' );
        if ( !$viewCacheEnabled ){
            echo $content;
            eZExecution::cleanExit();
        }

        eZFile::create($fileName, eZSys::cacheDirectory(), $pdfContent);
        if (isset( $this->dataMap['file'] )) {
            $this->dataMap['file']->fromString(eZSys::cacheDirectory() . '/' . $fileName);
            $this->dataMap['file']->store();
            $this->flushObject();
        }
    }

    public function executeAction($actionIdentifier, $actionParameters, eZModule $module = null)
    {
        $http = eZHTTPTool::instance();
        $subActionIdentifier = $http->postVariable($actionIdentifier);

        if ($subActionIdentifier == 'SaveAndGetProgram') {

            $this->saveProgram();
            $fileHandler = eZBinaryFileHandler::instance();
            $fileHandler->handleDownload($this->getObject(), $this->getFileAttribute(), eZBinaryFileHandler::TYPE_FILE);

        } elseif ($subActionIdentifier == 'BrowseEvent') {

            $startNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');
            $containerObject = eZContentObject::fetchByRemoteID(OpenPAAgenda::rootRemoteId() . '_agenda_container');
            if ($containerObject instanceof eZContentObject) {
                $startNodeId = $containerObject->attribute('main_node_id');
            }

            eZContentBrowse::browse(
                array(
                    'action_name' => 'ProgrammaEventiItemAddSelectedEvent',
                    'selection' => 'multiple',
                    'from_page' => '/editorialstuff/action/programma_eventi/' . $this->getObject()->ID . '#tab_leaflet',
                    'class_array' => array(OpenPAAgenda::instance()->getEventClassIdentifier()),
                    'start_node' => $startNodeId,
                    'cancel_page' => '/editorialstuff/edit/programma_eventi/' . $this->getObject()->ID . '#tab_leaflet',
                    'persistent_data' => array(
                        'ActionIdentifier' => 'AddSelectedEvent',
                        'AddSelectedEvent' => 'true'
                    )
                ),
                $module
            );
        } elseif ($subActionIdentifier == 'DeleteSelected') {

            if ($http->hasPostVariable('SelectEvent') && !empty( $http->postVariable('SelectEvent') )) {
                $selected = $http->postVariable('SelectEvent');
                $dataMap = $this->getObject()->dataMap();
                $events = explode('-', $dataMap['events']->toString());

                foreach ($events as $k => $v) {
                    if (in_array($v, $selected)) {
                        unset( $events[$k] );
                    }
                }

                $params = array();
                $params['attributes'] = array(
                    'events' => implode('-', $events)
                );
                eZContentFunctions::updateAndPublishObject($this->getObject(), $params);
            }
        }

        if ($actionIdentifier == 'AddSelectedEvent') {

            if ($http->hasPostVariable('SelectedNodeIDArray') && !empty( $http->postVariable('SelectedNodeIDArray') )) {
                $selected = $http->postVariable('SelectedNodeIDArray');
                $dataMap = $this->getObject()->dataMap();
                $events = explode('-', $dataMap['events']->toString());

                foreach ($selected as $s) {
                    /** @var eZContentObjectTreeNode $node */
                    $node = eZContentObjectTreeNode::fetch($s);
                    if (!in_array($node->attribute('contentobject_id'), $events)) {
                        $events [] = $node->attribute('contentobject_id');
                    }
                }
                $params = array();
                $params['attributes'] = array(
                    'events' => implode('-', $events)
                );
                eZContentFunctions::updateAndPublishObject($this->getObject(), $params);
            }
        }
    }


    /**
     * @return array[]
     */
    public function getEvents()
    {

        if (empty( $this->events )) {
            $events = array();
            $data_map = $this->getObject()->dataMap();
            $relatedEvents = $data_map['events']->content();
            $relationList = $relatedEvents['relation_list'];

            /** @var eZMatrix $eventsLayout */
            $eventsLayout = $data_map['events_layout']->content();
            $layoutRows = $eventsLayout->attribute('rows');

            $customEventsAttributes = array();
            foreach ($layoutRows['sequential'] as $row) {
                $customEventsAttributes[$row['columns'][0]] = array(
                    'abstract' => $row['columns'][1]
                );
            }

            foreach ($relationList as $index => $event) {
                /** @var eZContentObject $objectEvent */
                $objectEvent = eZContentObject::fetch($event['contentobject_id']);
                $eventDataMap = $objectEvent->dataMap();
                $key = $eventDataMap['from_time']->toString() . '.' . $objectEvent->ID;

                $events[$key] = array(
                    'id' => $objectEvent->ID,
                    'main_node_id' => $objectEvent->mainNodeID(),
                    'name' => $objectEvent->attribute('name'),
                    'periodo_svolgimento' => $eventDataMap['periodo_svolgimento']->toString(),
                    'from_time' => $eventDataMap['from_time']->toString(),
                    'to_time' => $eventDataMap['to_time']->toString(),
                    'orario_svolgimento' => $eventDataMap['orario_svolgimento']->toString(),
                    'durata' => $eventDataMap['durata']->toString(),
                    'luogo_svolgimento' => $eventDataMap['luogo_svolgimento']->toString(),
                    'abstract' => substr(strip_tags($eventDataMap['abstract']->hasContent() ? $eventDataMap['abstract']->toString() : $eventDataMap['text']->toString()),
                        0, $this->abstract_length),
                    'auto' => true,
                    'index' => $index,
                    'key' => $key,
                    'qrcode_file_url' => OpenPAAgendaQRCode::getFile($objectEvent->mainNodeID())->filePath
                );

                if (isset( $customEventsAttributes[$objectEvent->ID] ) && !empty( $customEventsAttributes[$objectEvent->ID]['abstract'] )) {
                    $events[$key]['abstract'] = $customEventsAttributes[$objectEvent->ID]['abstract'];
                    $events[$key]['auto'] = false;
                }
            }
            ksort($events);
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

        if ($this->getObject()->canEdit()) {
            $tabs[] = array(
                'identifier' => 'leaflet',
                'name' => 'Volantino',
                'template_uri' => "design:{$templatePath}/parts/leaflet.tpl"
            );
        }

        $tabs[] = array(
            'identifier' => 'history',
            'name' => 'Cronologia',
            'template_uri' => "design:{$templatePath}/parts/history.tpl"
        );

        return $tabs;
    }

}
