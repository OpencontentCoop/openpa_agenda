<?php

use Opencontent\Opendata\Api\Values\SearchResults;
use Opencontent\Opendata\Api\QueryLanguage\EzFind\QueryBuilder;
use Opencontent\Opendata\Api\Values\Content;

class OpenPAAgendaFullcalendarEnvironmentSettings extends DefaultEnvironmentSettings
{
    protected $maxSearchLimit = 300;

    public function filterContent(Content $content)
    {
        return $content;
    }


    /**
     * @see https://fullcalendar.io/docs/event_data/events_json_feed/
     *
     * @param SearchResults $searchResults
     * @param ArrayObject $query
     * @param QueryBuilder $builder
     *
     * @return array
     */
    public function filterSearchResult(
        \Opencontent\Opendata\Api\Values\SearchResults $searchResults,
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    )
    {
        //return parent::filterSearchResult($searchResults, $query, $builder);

        $events = [];
        if ($searchResults->totalCount > 0){
            foreach($searchResults->searchHits as $content){
                $events[] = $this->convertContentToFullcalendarItem($content);
            }
        }
        return $events;
    }

    private function convertContentToFullcalendarItem(Content $content)
    {
        $data = $this->getFirstLocale($content->data);
        $from = isset($data['from_time']['content']) ? $data['from_time']['content'] : $content->metadata->published;
        $to = isset($data['to_time']['content']) ? $data['to_time']['content'] : null;
        $allDay = false;
        if ($to){
            $fromDateTime = DateTime::createFromFormat(DateTime::ISO8601, $from);
            $toDateTime = DateTime::createFromFormat(DateTime::ISO8601, $to);
            if ($fromDateTime instanceof DateTime && $toDateTime instanceof DateTime ){
                $diff = $toDateTime->diff($fromDateTime);
                if ($diff instanceof DateInterval){
                    $allDay = (bool)$diff->days;
                }
            }
        }
        $event = new OpenPAAgendaFullCalendarEvent();
        $event->setId($content->metadata->id)
            ->setTitle($this->getFirstLocale($content->metadata->name))
            ->setStart($from)
            ->setEnd($to)
            ->setAllDay($allDay)
            ->setContent(parent::filterContent($content));
        return $event;
    }

    private function getFirstLocale($value)
    {
        $language = eZLocale::currentLocaleCode();
        return isset($value[$language]) ? $value[$language] : array_shift($value);
    }

    /**
     * @see https://fullcalendar.io/docs/event_data/events_json_feed/
     *
     * @param ArrayObject $query
     * @param QueryBuilder $builder
     *
     * @return ArrayObject
     */
    public function filterQuery(
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    )
    {
        $parameters = $this->request->get;
        $start = $parameters['start'];
        $end = $parameters['end'];
        $calendarQuery = "calendar[] = [$start,$end]";
        $queryObject = $builder->instanceQuery($calendarQuery);
        $calendarQuery = $queryObject->convert();
        $query['Filter'][] = $calendarQuery->getArrayCopy()['Filter'];

        if (isset($query['SearchLimit'])) {
            if ($query['SearchLimit'] > $this->maxSearchLimit) {
                $query['SearchLimit'] = $this->maxSearchLimit;
            }
        } else {
            $query['SearchLimit'] = $this->maxSearchLimit;
        }

        if (!isset($query['SearchOffset'])) {
            $query['SearchOffset'] = 0;
        }

        return $query;
    }
}
