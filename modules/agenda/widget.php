<?php

/** @var eZModule $module */
$Module = $Params['Module'];
$widgetId = (int)$Params['WidgetId'];
$widgetView = $Params['View'];

$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$tpl->setVariable('css', 'extension/openpa_agenda/design/standard/stylesheets/openpa_agenda_widget.css');
$height = intval($http->getVariable('height', false));
if ($height === 0){
    $height = false;
}
if ($widgetId > 0) {
    if ($widgetView == 'iframe') {
        header('Content-Type: text/html');
        $tpl->setVariable('widget_id', $widgetId);
        $tpl->setVariable('height', $height);
        echo $tpl->fetch('design:agenda/widget/iframe.tpl');
    }else {
        $callback = eZHTTPTool::instance()->getVariable('callback', false);
        $widget = OpenPAAgendaWidgetFactory::instanceWidget($widgetId);
        $result = json_encode($widget);
        if ($callback) {
            header('Content-Type: application/json');
            echo "/**/$callback($result)";
        } else {
            header('Content-Type: application/json');
            echo $result;
            //@todo reirect to template
        }
    }
} else {
    header('Content-Type: application/javascript');
    $tpl->setVariable('height', $height . 'px');
    echo $tpl->fetch('design:agenda/widget/script.tpl');
}


eZExecution::cleanExit();
