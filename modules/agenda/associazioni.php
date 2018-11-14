<?php
/** @var eZModule $Module */
$Module = $Params['Module'];
$tpl = eZTemplate::factory();
$Action = $Params['Action'];
$http = eZHTTPTool::instance();

if (OpenPAAgenda::instance()->isCollaborationModeEnabled() || eZUser::currentUser()->hasAccessTo('agenda', 'config')) {

    if (is_numeric($Action)) {
            $contentModule = eZModule::exists('content');

            return $contentModule->run(
                'view',
                array('full', $Action)
            );

    } else {
        $currentUser = eZUser::currentUser();

        $tpl->setVariable('current_user', $currentUser);
        $tpl->setVariable('persistent_variable', array());

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable('persistent_variable');
        $Result['content'] = $tpl->fetch('design:agenda/associazioni.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => 'agenda/associazioni');
        $contentInfoArray['persistent_variable'] = array();
        if ($tpl->variable('persistent_variable') !== false) {
            $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();
    }

} else {
    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED);
}
