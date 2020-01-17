<?php

/** @var eZModule $module */
$module = $Params['Module'];
$identifier = $Params['Identifier'];

try {
    $stat = new OpenPAAgendaStat();
    $factories = $stat->getStatisticFactories();

    if ($identifier
        && ('application/json' == strtolower($_SERVER['HTTP_ACCEPT'])
            || (eZHTTPTool::instance()->hasGetVariable('ContentType') && eZHTTPTool::instance()->getVariable('ContentType') == 'json'))) {

        $factory = $stat->getStatisticFactory($identifier);
        $factory->setParameters($_GET);
        header('Content-Type: application/json');
        echo json_encode($factory->getData());
        eZExecution::cleanExit();

    } else {
        $tpl = eZTemplate::factory();
        $tpl->setVariable('factories', $factories);

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable('persistent_variable');
        $Result['content'] = $tpl->fetch('design:agenda/stat.tpl');
        $Result['node_id'] = 0;
        $Result['title_path'] = ezpI18n::tr('agenda/stat', 'Statistics');
        $contentInfoArray = array('url_alias' => 'agenda/stat');
        $contentInfoArray['persistent_variable'] = array();
        if ($tpl->variable('persistent_variable') !== false) {
            $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array(
            array(
                'url' => 'agenda/stat',
                'text' => ezpI18n::tr('agenda/stat', 'Statistics')
            )
        );
    }

} catch (Exception $e) {
    eZDebug::writeError($e->getMessage());
    return $module->handleError(eZError::KERNEL_NOT_AVAILABLE, 'kernel');
}
