<?php

class OpenPAAgendaStatPerPlace extends AbstractOpenPAAgendaStatFactory
{
    public function __construct()
    {
        parent::__construct();
        if (!isset($this->eventClassDataMap['takes_place_in']) || $this->eventClassDataMap['takes_place_in']->attribute('data_type_string') != eZObjectRelationListType::DATA_TYPE_STRING){
            throw new RuntimeException("Invalid Agenda Event Place attribute");
        }
    }

    public function getIdentifier()
    {
        return 'place';
    }

    public function getName()
    {
        return $this->eventClassDataMap['takes_place_in']->attribute('name');
    }

    public function getDescription()
    {
        // TODO: Implement getDescription() method.
    }

    public function getData()
    {
        if ($this->data === null) {
            $byInterval = $this->getIntervalFilter();
            $intervalNameParser = $this->getIntervalNameParser();

            $query = "classes [$this->eventClassIdentifier] limit 1 facets [raw[subattr_takes_place_in___name____s]|alpha|100] pivot [facet=>[subattr_takes_place_in___name____s,{$byInterval}],mincount=>1]";
            $search = $this->search($query);
            $this->data = [
                'intervals' => [],
                'series' => [],
            ];
            $pivotItems = $search->pivot["subattr_takes_place_in___name____s,{$byInterval}"];
            foreach ($pivotItems as $pivotItem) {
                $item = [
                    'name' => $pivotItem['value'],
                    'data' => []
                ];
                $item['data'][] = [
                    'interval' => 'all',
                    'count' => $pivotItem['count']
                ];
                $this->data['intervals']['all'] = 'all';
                foreach ($pivotItem['pivot'] as $value) {
                    $intervalName = is_callable($intervalNameParser) ? $intervalNameParser($value['value']) : $value['value'];
                    $item['data'][] = [
                        'interval' => $intervalName,
                        'count' => $value['count']
                    ];
                    $this->data['intervals'][$value['value']] = $intervalName;
                }
                $this->data['series'][] = $item;
            }
            $this->data['intervals'] = array_values($this->data['intervals']);
            sort($this->data['intervals']);
            usort($this->data['series'], function ($a, $b) {
                return strcmp($a["name"], $b["name"]);
            });
        }
        return $this->data;
    }

}
