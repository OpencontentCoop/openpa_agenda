<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\TagRepository;

class OpenPAAgendaWidgetFactory
{
	public static function instanceWidget($widgetId)
	{

    	$widget = new OpenPAAgendaWidget();
    	$widget->id = (int)$widgetId;
    	self::fillWidgetParams($widget);

    	try {
	        $contentSearch = new ContentSearch();
	        $contentSearch->setEnvironment(new DefaultEnvironmentSettings());
	        $widget->data = (array)$contentSearch->search($widget->query);
	    } catch (Exception $e) {
	        $widget->data = array(
	            'error_code' => $e->getCode(),
	            'error_message' => $e->getMessage(),
	            'trace' => $e->getTraceAsString(),
	            'query' => $widget->query
	        );
	    }

		$tpl = eZTemplate::factory();
	    $tpl->setVariable('widget', $widget);
    	$tpl->fetch('design:agenda/widget/template.tpl');

    	$widget->templates = array(
	        'events' => $tpl->variable('events'),
	        'header' => $tpl->variable('header'),
	        'footer' => $tpl->variable('footer'),
	    );

	    return $widget;
	}

	private static function fillWidgetParams($widget)
	{
		$baseQuery = 'classes [' . OpenPAAgenda::instance()->getEventClassIdentifier() . '] and subtree [' . OpenPAAgenda::instance()->calendarNodeId() . '] and state in [moderation.skipped,moderation.accepted]';
		$fromToQuery = array("'now'","'*'");
    	$sortQuery = 'sort [time_interval=>asc]';
    	$filters = '';
    	$limit = "'5'";

    	$showHeader = true;
    	$showFooter = true;
    	$showTitle = false;
    	$pageData = new OpenPAAgendaPageDataHandler();
    	$title = $pageData->siteTitle();

    	$widgetObject = eZContentObject::fetch($widget->id);
    	if ($widgetObject instanceof eZContentObject && $widgetObject->attribute('class_identifier') == 'agenda_widget'){
    		$dataMap = $widgetObject->dataMap();
    		if (isset($dataMap['from_time_filter']) && $dataMap['from_time_filter']->hasContent()){
    			$fromToQuery[0] = "'" . date('Y-m-d H:i', $dataMap['from_time_filter']->toString()) . "'";
    		}
    		if (isset($dataMap['to_time_filter']) && $dataMap['to_time_filter']->hasContent()){
    			$fromToQuery[1] = "'" . date('Y-m-d H:i', $dataMap['to_time_filter']->toString()) . "'";
    		}
            $filtersParts = [];
            if (isset($dataMap['type_filter']) && $dataMap['type_filter']->hasContent()){
                $typeContent = $dataMap['type_filter']->content();
                if ($typeContent instanceof eZTags) {
                    $filtersParts[] = 'and raw[ezf_df_tag_ids] in [' . implode(',', $typeContent->attribute('tag_ids')) . ']';
                }
    		}
            if (isset($dataMap['topic_filter']) && $dataMap['topic_filter']->hasContent()){
                $topicContent = explode('-', $dataMap['topic_filter']->toString());
                if (!empty($topicContent)) {
                    $filtersParts[] = 'and topics.id in [' . implode(',', $topicContent) . ']';
                }
            }
            if (isset($dataMap['organizer_filter']) && $dataMap['organizer_filter']->hasContent()){
                $organizerContent = explode('-', $dataMap['organizer_filter']->toString());
                if (!empty($organizerContent)) {
                    $filtersParts[] = 'and organizer.id in [' . implode(',', $organizerContent) . ']';
                }
            }
            if (count($filtersParts) > 0){
                $filters = 'and ' . implode(' and ', $filtersParts);
            }
    		if (isset($dataMap['query_limit']) && $dataMap['query_limit']->hasContent()){
    			$limit = (int)$dataMap['query_limit']->toString();
    		}
    		if (isset($dataMap['show_header'])){
    			$showHeader = (bool)$dataMap['show_header']->attribute('data_int');
    		}
    		if (isset($dataMap['show_footer'])){
    			$showFooter = (bool)$dataMap['show_footer']->attribute('data_int');
    		}
    		if (isset($dataMap['show_title'])){
    			$showTitle = (bool)$dataMap['show_title']->attribute('data_int');
    		}
    		if (isset($dataMap['title']) && $dataMap['title']->hasContent()){
    			$title = $dataMap['title']->toString();
    		}
    	}

    	$widget->query = $baseQuery . ' and calendar[time_interval] = [' . implode(',', $fromToQuery) . '] ' . $filters . ' ' . $sortQuery . ' limit ' . $limit;
    	$widget->show_header = $showHeader;
    	$widget->show_footer = $showFooter;
    	$widget->show_title = $showTitle;
    	$widget->title = $title;
	}

}
