<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\EnvironmentLoader;

abstract class AbstractOpenPAAgendaStatFactory
{
    const DEFAULT_INTERVAL = 'monthly';

    /**
     * @var string
     */
    protected $eventClassIdentifier;

    /**
     * @var eZContentClass
     */
    protected $eventClass;

    /**
     * @var eZContentClassAttribute[]
     */
    protected $eventClassDataMap;

    protected $parameters;

    protected $data;

    abstract public function getIdentifier();

    abstract public function getName();

    abstract public function getDescription();

    abstract public function getData();

    public function __construct()
    {
        $this->eventClassIdentifier = OpenPAAgenda::instance()->getEventClassIdentifier();
        $this->eventClass = eZContentClass::fetchByIdentifier($this->eventClassIdentifier);
        if (!$this->eventClass instanceof eZContentClass) {
            throw new RuntimeException("Agenda Event class not found");
        }
        $this->eventClassDataMap = $this->eventClass->dataMap();
    }

    /**
     * @return mixed
     */
    public function getParameters()
    {
        return $this->parameters;
    }

    /**
     * @param mixed $parameters
     */
    public function setParameters($parameters)
    {
        $this->parameters = $parameters;
    }

    public function getParameter($name)
    {
        return isset($this->parameters[$name]) ? $this->parameters[$name] : null;
    }

    public function hasParameter($name)
    {
        return isset($this->parameters[$name]);
    }

    public function setParameter($name, $value)
    {
        $this->parameters[$name] = $value;
    }

    public function attributes()
    {
        return ['name', 'identifier', 'description'];
    }

    public function hasAttribute($name)
    {
        return in_array($name, $this->attributes());
    }

    public function attribute($name)
    {
        if ($name == 'name') {
            return $this->getName();
        }

        if ($name == 'identifier') {
            return $this->getIdentifier();
        }

        if ($name == 'description') {
            return $this->getDescription();
        }

        return null;
    }

    protected function getIntervalFilter()
    {
        $interval = $this->hasParameter('interval') ? $this->getParameter('interval') : self::DEFAULT_INTERVAL;

        switch ($interval) {
            case 'monthly':
                $byInterval = 'extra_stat_month_i';
                break;

            case 'quarterly':
                $byInterval = 'extra_stat_quarter_i';
                break;

            case 'half-yearly':
                $byInterval = 'extra_stat_semester_i';
                break;

            case 'yearly':
                $byInterval = 'extra_stat_year_i';
                break;

            default:
                $byInterval = 'extra_stat_year_i';
        }

        return $byInterval;
    }

    protected function getIntervalNameParser()
    {
        $interval = $this->hasParameter('interval') ? $this->getParameter('interval') : self::DEFAULT_INTERVAL;
        $intervalNameParser = false;
        switch ($interval) {
            case 'monthly':
                $intervalNameParser = function ($value) {
                    $year = substr($value, 0, 4);
                    $month = substr($value, -2);
                    return "{$year} {$month}";
                };
                break;

            case 'quarterly':
                $intervalNameParser = function ($value) {
                    $year = substr($value, 0, 4);
                    $part = substr($value, -1);

                    return "{$year} {$part}°";
                };
                break;

            case 'half-yearly':
                $intervalNameParser = function ($value) {
                    $year = substr($value, 0, 4);
                    $part = substr($value, -1);

                    return "{$year} {$part}°";
                };
                break;

            case 'yearly':
                $intervalNameParser = function ($value) {
                    return $value;
                };
                break;

        }

        return $intervalNameParser;
    }

    protected function search($query)
    {
        $contentSearch = new ContentSearch();
        $currentEnvironment = EnvironmentLoader::loadPreset('content');
        $contentSearch->setEnvironment($currentEnvironment);
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        return $contentSearch->search($query);
    }
}
