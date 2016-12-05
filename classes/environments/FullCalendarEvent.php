<?php

/**
 * Class OpenPAAgendaFullCalendarEvent
 * @see https://fullcalendar.io/docs/event_data/Event_Object/
 */
class OpenPAAgendaFullCalendarEvent implements JsonSerializable
{
    private $content;

    private $id;

    private $title;

    private $allDay;

    private $start;

    private $end;

    private $url;

    private $className;

    private $editable;

    private $startEditable;

    private $durationEditable;

    private $resourceEditable;

    private $rendering;

    private $overlap;

    private $constraint;

    private $color;

    private $backgroundColor;

    private $borderColor;

    private $textColor;

    /**
     * @param mixed $content
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setContent($content)
    {
        $this->content = $content;

        return $this;
    }

    /**
     * @param mixed $id
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setId($id)
    {
        $this->id = $id;

        return $this;
    }

    /**
     * @param mixed $title
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setTitle($title)
    {
        $this->title = $title;

        return $this;
    }

    /**
     * @param mixed $allDay
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setAllDay($allDay)
    {
        $this->allDay = $allDay;

        return $this;
    }

    /**
     * @param mixed $start
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setStart($start)
    {
        $this->start = $start;

        return $this;
    }

    /**
     * @param mixed $end
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setEnd($end)
    {
        $this->end = $end;

        return $this;
    }

    /**
     * @param mixed $url
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setUrl($url)
    {
        $this->url = $url;

        return $this;
    }

    /**
     * @param mixed $className
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setClassName($className)
    {
        $this->className = $className;

        return $this;
    }

    /**
     * @param mixed $editable
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setEditable($editable)
    {
        $this->editable = $editable;

        return $this;
    }

    /**
     * @param mixed $startEditable
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setStartEditable($startEditable)
    {
        $this->startEditable = $startEditable;

        return $this;
    }

    /**
     * @param mixed $durationEditable
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setDurationEditable($durationEditable)
    {
        $this->durationEditable = $durationEditable;

        return $this;
    }

    /**
     * @param mixed $resourceEditable
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setResourceEditable($resourceEditable)
    {
        $this->resourceEditable = $resourceEditable;

        return $this;
    }

    /**
     * @param mixed $rendering
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setRendering($rendering)
    {
        $this->rendering = $rendering;

        return $this;
    }

    /**
     * @param mixed $overlap
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setOverlap($overlap)
    {
        $this->overlap = $overlap;

        return $this;
    }

    /**
     * @param mixed $constraint
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setConstraint($constraint)
    {
        $this->constraint = $constraint;

        return $this;
    }

    /**
     * @param mixed $color
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setColor($color)
    {
        $this->color = $color;

        return $this;
    }

    /**
     * @param mixed $backgroundColor
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setBackgroundColor($backgroundColor)
    {
        $this->backgroundColor = $backgroundColor;

        return $this;
    }

    /**
     * @param mixed $borderColor
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setBorderColor($borderColor)
    {
        $this->borderColor = $borderColor;

        return $this;
    }

    /**
     * @param mixed $textColor
     *
     * @return OpenPAAgendaFullCalendarEvent
     */
    public function setTextColor($textColor)
    {
        $this->textColor = $textColor;

        return $this;
    }

    function jsonSerialize()
    {
        $data = array();
        $reflection = new ReflectionClass($this);
        foreach($reflection->getProperties() as $property){
            $name = $property->getName();
            $value = $this->{$name};
            if ($value !== null){
                $data[$name] = $value;
            }
        }

        return $data;
    }
}