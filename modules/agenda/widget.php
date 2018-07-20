<?php

use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\TagRepository;


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


$tpl = eZTemplate::factory();
$tpl->setVariable('css', $css);

if ($widgetId > 0) {
  $widget = array(
    'id' => $widgetId,
    'query' => 'classes [' . OpenPAAgenda::instance()->getEventClassIdentifier() . '] and subtree [' . OpenPAAgenda::instance()->calendarNodeId() . '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc] limit 5',
    'show_header' => true,
    'show_footer' => true,
    'show_title' => true,
    'title' => 'Da non perdere'
  );

  try {
    $contentSearch = new ContentSearch();
    $contentSearch->setEnvironment(new DefaultEnvironmentSettings());
    $data = (array)$contentSearch->search($widget['query']);
  } catch (Exception $e) {
    $data = array(
      'error_code' => $e->getCode(),
      'error_message' => $e->getMessage(),
      'trace' => $e->getTraceAsString()
    );
  }
  $widget['data'] = $data;
  $tpl->setVariable('widget', $widget);
  $tpl->fetch('design:agenda/widget/template.tpl');
  $widget['templates'] = array(
    'events' => $tpl->variable('events'),
    'header' => $tpl->variable('header'),
    'footer' => $tpl->variable('footer'),
  );
  $callback = eZHTTPTool::instance()->getVariable('callback', false);
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
  $tpl->setVariable('height', '200px');
  echo $tpl->fetch('design:agenda/widget/script.tpl');
}

eZExecution::cleanExit();
