<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ConnectorHelper;

class AgendaRootClassConnector extends ClassConnector
{
    private $agendaViews = [
        'dayGridWeek' => 'Settimanale',
        'dayGridMonth' => 'Mensile',
        'list' => 'Giornaliero',
    ];

    private $calendarViews = [
        'agenda' => 'Calendario',
        'grid' => 'Griglia',
        'geo' => 'Mappa',
    ];

    public function __construct(eZContentClass $class, $helper)
    {
        parent::__construct($class, $helper);
        if ($helper instanceof ConnectorHelper){
            $helper->setSetting('SplitAttributeCategories', true);
            $helper->setSetting('HideCategories', ['hidden']);
        }
    }

    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema['title'] = '';
        $schema['description'] = '';
        $schema['properties']['main_calendar_agenda_view']['enum'] = array_keys($this->agendaViews);
        $schema['properties']['main_calendar_views']['enum'] = array_keys($this->calendarViews);
        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();
        $options['fields']['social']['showActionsColumn'] = false;
        $options['fields']['main_calendar_agenda_view']['optionLabels'] = array_values($this->agendaViews);
        $options['fields']['main_calendar_agenda_view']['hideNone'] = true;
        $options['fields']['main_calendar_views']['optionLabels'] = array_values($this->calendarViews);
        return $options;
    }
    protected function getSplitAttributeCategoriesLayout()
    {
        $categories = $this->getFieldCategories();
        $bindings = array();
        $tabs = '<ul class="nav nav-tabs mb-5">';
        $panels = '<div class="tab-content">';
        $i = 0;

        foreach ($categories as $identifier => $category) {
            $tabClass = $i == 0 ? ' class="nav-item active"' : ' class="nav-item"';
            $panelClass = $i == 0 ? ' active' : '';
            $tabs .= '<li' . $tabClass . '><a class="text-decoration-none nav-link" data-bs-toggle="tab" data-toggle="tab" href="#attribute-group-' . $identifier . '">' . $category['name'] . '</a></li>';
            $panels .= '<div class="clearfix tab-pane' . $panelClass . '" id="attribute-group-' . $identifier . '"></div>';
            foreach ($category['identifiers'] as $field) {
                $bindings[$field] = 'attribute-group-' . $identifier;
            }
            $i++;
        }
        $tabs .= '</ul>';
        $panels .= '</div>';

        if (!$this->getHelper()->hasParameter('parent')) {
            $panels .= '<div class="clearfix" id="attribute-group-' . self::SELECT_PARENT_FIELD_IDENTIFIER . '"></div>';
            $bindings[self::SELECT_PARENT_FIELD_IDENTIFIER] = 'attribute-group-' . self::SELECT_PARENT_FIELD_IDENTIFIER;
        }

        if (count($categories) == 1) {
            $tabs = '';
        }

        return array(
            'template' => '<div><legend class="alpaca-container-label">{{options.label}}</legend>' . $tabs . $panels . '</div>',
            'bindings' => $bindings
        );
    }

    protected function getFieldCategories()
    {
        $override = [
            'content'=> 'Generale',
            'view'=> 'Homepage',
            'config'=> 'Configurazioni',
            'date'=> 'Eventi',
        ];

        if ($this->fieldCategories === null) {

            $this->fieldCategories = array();

            if ($this->getHelper()->hasSetting('SplitAttributeCategories')) {
                $defaultCategory = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'DefaultCategory');
                $categoryNames = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'CategoryList');

                foreach ($this->getFieldConnectors() as $identifier => $fieldConnector) {
                    $category = $fieldConnector->getAttribute()->attribute('category');
                    if (empty( $category )) {
                        $category = $defaultCategory;
                    }
                    if (!isset( $this->fieldCategories[$category] )) {
                        $this->fieldCategories[$category] = array(
                            'name' => $override[$category] ?? $categoryNames[$category],
                            'identifiers' => array()
                        );
                    }
                    $this->fieldCategories[$category]['identifiers'][] = $identifier;
                }
            }
        }

        return $this->fieldCategories;
    }
}
