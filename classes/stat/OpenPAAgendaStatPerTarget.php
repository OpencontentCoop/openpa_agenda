<?php

class OpenPAAgendaStatPerTarget extends AbstractOpenPAAgendaStatFactory
{
    public function __construct()
    {
        parent::__construct();
        if (!isset($this->eventClassDataMap['target_audience']) || $this->eventClassDataMap['target_audience']->attribute('data_type_string') != eZTagsType::DATA_TYPE_STRING) {
            throw new RuntimeException("Invalid Agenda Event Target attribute");
        }
    }

    public function getIdentifier()
    {
        return 'target';
    }

    public function getName()
    {
        return $this->eventClassDataMap['target_audience']->attribute('name');
    }

    public function getDescription()
    {
        // TODO: Implement getDescription() method.
    }

    public function getData()
    {
        if ($this->data === null) {

            $rootTagId = (int)$this->eventClassDataMap['target_audience']->attribute(eZTagsType::SUBTREE_LIMIT_FIELD);
            $ignoreKeywords = [];
            if ($rootTagId > 0){
                $rootTag = eZTagsObject::fetch($rootTagId);
                if ($rootTag instanceof eZTagsObject){
                    $ignoreKeywords[] = strtolower($rootTag->attribute('keyword'));
                    foreach ($rootTag->getPath() as $tag) {
                        $ignoreKeywords[] = strtolower($tag->attribute('keyword'));
                    }
                }
            }

            $byInterval = $this->getIntervalFilter();
            $intervalNameParser = $this->getIntervalNameParser();

            $query = "classes [$this->eventClassIdentifier] limit 1 facets [raw[attr_target_audience_lk]|alpha|100] pivot [facet=>[attr_target_audience_lk,{$byInterval}],mincount=>1]";
            $search = $this->search($query);
            $this->data = [
                'intervals' => [],
                'series' => [],
            ];
            $pivotItems = $search->pivot["attr_target_audience_lk,{$byInterval}"];
            foreach ($pivotItems as $pivotItem) {
                if (in_array($pivotItem['value'], $ignoreKeywords)){
                    continue;
                }
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
