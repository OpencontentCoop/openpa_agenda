<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector;
use Opencontent\Opendata\Api\Values\Content;

class PrivateOrganizationSettingsConnector extends OpendataConnector
{
    protected function load()
    {
        if (!self::$isLoaded) {
            $access = eZUser::currentUser()->hasAccessTo('agenda', 'config');
            if (empty(OpenPAINI::variable('OpenpaAgenda', 'OrganizationPrivateAttributes', []))
                || $access['accessWord'] !== 'yes'
            ) {
                throw new \Exception("User can not edit settings");
            }


            $this->language = \eZLocale::currentLocaleCode();

            $this->getHelper()->setSetting('language', $this->language);

            $this->object = eZContentObject::fetch((int)$this->getParameter('object'));
            if (!$this->object instanceof eZContentObject) {
                throw new \Exception("Content object not found #" . (int)$this->getParameter('object'));
            }

            $this->class = $this->object->contentClass();
            $parents = $this->object->assignedNodes(false);
            $parentsIdList = array_column($parents, 'parent_node_id');
            $this->getHelper()->setParameter('parent', $parentsIdList);

            if (!$this->object->canRead()) {
                throw new \Exception("User can not read object #" . $this->object->attribute('id'));
            }
            if (!$this->object->canEdit() && $this->getHelper()->getParameter('view') != 'display') {
                throw new \Exception("User can not edit object #" . $this->object->attribute('id'));
            }

            $this->classConnector = new PrivateOrganizationSettingsClassConnector($this->class, $this->getHelper());

            $data = (array)Content::createFromEzContentObject($this->object);
            $locale = \eZLocale::currentLocaleCode();
            if (isset($data['data'][$locale])) {
                $this->classConnector->setContent($data['data'][$locale]);
            } else {
                foreach ($data['data'] as $language => $datum) {
                    $this->classConnector->setContent($datum);
                    $this->translatingFrom = $language;
                    break;
                }
            }

            self::$isLoaded = true;
        }
    }
}
