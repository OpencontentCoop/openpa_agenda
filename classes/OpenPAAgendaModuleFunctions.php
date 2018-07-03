<?php

class OpenPAAgendaModuleFunctions
{
    const GLOBAL_PREFIX = 'global-';

    public static function onClearObjectCache($nodeList)
    {
        try {
            $rootNode = OpenPAAgenda::instance()->rootNode();
            if ($rootNode instanceof eZContentObjectTreeNode
                && in_array($rootNode->attribute('node_id'), $nodeList)
            ) {
                self::clearAgendaCache(self::GLOBAL_PREFIX);
            }
        } catch (Exception $e) {
            eZDebugSetting::writeError('agenda', $e->getMessage(), __METHOD__);
        }

        return $nodeList;
    }

    protected static function clearAgendaCache($prefix)
    {
        $ini = eZINI::instance();
        if ($ini->hasVariable('SiteAccessSettings', 'RelatedSiteAccessList')
            && $relatedSiteAccessList = $ini->variable('SiteAccessSettings', 'RelatedSiteAccessList')
        ) {
            if (!is_array($relatedSiteAccessList)) {
                $relatedSiteAccessList = array($relatedSiteAccessList);
            }
            $relatedSiteAccessList[] = $GLOBALS['eZCurrentAccess']['name'];
            $siteAccesses = array_unique($relatedSiteAccessList);
        }

        if (!empty( $siteAccesses )) {
            $cacheBaseDir = eZDir::path(array(eZSys::cacheDirectory(), 'agenda'));
            $fileHandler = eZClusterFileHandler::instance();
            $fileHandler->fileDeleteByDirList($siteAccesses, $cacheBaseDir, $prefix);
        }
    }

    public static function agendaHomeGenerate($file, $args)
    {
        $currentUser = eZUser::currentUser();

        $tpl = eZTemplate::factory();
        $tpl->setVariable('current_user', $currentUser);
        $tpl->setVariable('persistent_variable', array());
        $tpl->setVariable('agenda_home', true);

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable('persistent_variable');
        $Result['content'] = $tpl->fetch('design:agenda/home.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => 'agenda/home');
        $contentInfoArray['persistent_variable'] = array('agenda_home' => true);
        if ($tpl->variable('persistent_variable') !== false) {
            $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
            $contentInfoArray['persistent_variable']['agenda_home'] = true;
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();
        $returnValue = array('content' => $Result, 'scope' => 'agenda');

        return $returnValue;
    }

    public static function agendaViewGenerate($file, $args)
    {
        $currentUser = eZUser::currentUser();

        $tpl = eZTemplate::factory();
        $tpl->setVariable('current_user', $currentUser);
        $tpl->setVariable('persistent_variable', array());
        $tpl->setVariable('agenda_home', true);

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable('persistent_variable');
        $Result['content'] = $tpl->fetch('design:agenda/view.tpl');
        $Result['node_id'] = 0;

        $contentInfoArray = array('url_alias' => 'agenda/view');
        $contentInfoArray['persistent_variable'] = array();
        if ($tpl->variable('persistent_variable') !== false) {
            $contentInfoArray['persistent_variable'] = $tpl->variable('persistent_variable');
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();
        $returnValue = array('content' => $Result, 'scope' => 'agenda');

        return $returnValue;
    }

    public static function agendaInfoGenerate($file, $args)
    {
        extract($args);
        if (isset( $Params ) && $Params['Module'] instanceof eZModule) {
            $tpl = eZTemplate::factory();
            $identifier = $Params['Page'];
            if (OpenPAAgenda::instance()->rootHasAttribute($identifier)) {
                $currentUser = eZUser::currentUser();

                $tpl->setVariable('current_user', $currentUser);
                $tpl->setVariable('persistent_variable', array());
                $tpl->setVariable('identifier', $identifier);
                $tpl->setVariable('page', OpenPAAgenda::instance()->getAttribute($identifier));

                $Result = array();

                $Result['persistent_variable'] = $tpl->variable('persistent_variable');
                $Result['content'] = $tpl->fetch('design:agenda/info.tpl');
                $Result['node_id'] = 0;

                $contentInfoArray = array('url_alias' => 'agenda/info');
                $contentInfoArray['persistent_variable'] = false;
                if ($tpl->variable('persistent_variable') !== false) {
                    $contentInfoArray['persistent_variable'] = $tpl->variable(
                        'persistent_variable'
                    );
                }
                $Result['content_info'] = $contentInfoArray;
                $Result['path'] = array();

                $returnValue = array(
                    'content' => $Result,
                    'scope' => 'agenda'
                );
            } else {
                /** @var eZModule $module */
                $module = $Params['Module'];
                $returnValue = array(
                    'content' => $module->handleError(
                        eZError::KERNEL_NOT_AVAILABLE,
                        'kernel'
                    ),
                    'store' => false
                );
            }
        } else {
            $returnValue = array(
                'content' => 'error',
                'store' => false
            );
        }

        return $returnValue;
    }


    public static function agendaCacheRetrieve($file)
    {
        $Result = include( $file );

        return $Result;
    }

    public static function agendaGlobalCacheFilePath($fileName)
    {
        $currentSiteAccess = $GLOBALS['eZCurrentAccess']['name'];
        $cacheFile = self::GLOBAL_PREFIX . $fileName . '.php';
        $cachePath = eZDir::path(array(eZSys::cacheDirectory(), 'agenda', $currentSiteAccess, $cacheFile));

        return $cachePath;
    }

    public static function clearCache()
    {
        self::clearAgendaCache('');
    }
}
