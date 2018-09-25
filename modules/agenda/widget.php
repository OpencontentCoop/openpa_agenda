<?php

/** @var eZModule $module */
$Module = $Params['Module'];
$widgetId = (int)$Params['WidgetId'];

function packFiles($cssFiles, $subPath, $fileExtension)
{
    eZINI::instance()->setVariable('TemplateSettings', 'DevelopmentMode', 'enabled');
    eZINI::instance('ezjscore.ini')->setVariable('eZJSCore', 'Packer', 2);
    $files = ezjscPacker::packFiles($cssFiles, $subPath, $fileExtension);
    if (count($files) > 0) {
        return $files[0];
    }

    return null;
}

$css = packFiles(array(
    'openpa_agenda_widget.css',
), 'stylesheets/', '.css');

$http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$tpl->setVariable('css', $css);

if ($widgetId > 0) {
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
} else {
    header('Content-Type: application/javascript');
    $tpl->setVariable('height', $http->getVariable('height', 200) . 'px');
    echo $tpl->fetch('design:agenda/widget/script.tpl');
}

eZExecution::cleanExit();
