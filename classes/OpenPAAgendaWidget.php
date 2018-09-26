<?php

class OpenPAAgendaWidget
{
	private $attributes;

	public $id;

	public $query;

	public $show_header;	
	
	public $show_footer;	
	
	public $show_title;	
	
	public $title;	
	
	public $data;

	public $templates;

	public function attributes()
    {
        if ($this->attributes === null) {
            $this->attributes = array();
            try {
                $reflect = new ReflectionClass($this->package);
                $properties = $reflect->getProperties(ReflectionProperty::IS_PUBLIC);
                foreach ($properties as $property) {
                    $this->attributes[] = $property->getName();
                }
            } catch (Exception $e) {
                eZDebug::writeError($e->getMessage(), __FILE__);
            }
        }
        return $this->attributes;
    }

    public function hasAttribute($key)
    {
        return in_array($key, $this->attributes());
    }

    public function attribute($key)
    {
    	return $this->{$key};
    }

}