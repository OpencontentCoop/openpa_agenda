<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnectorFactory;

class OfferClassConnector extends ClassConnector
{
    public function getFieldConnectors()
    {
        if ($this->fieldConnectors === null) {
            /** @var \eZContentClassAttribute[] $classDataMap */
            $classDataMap = $this->class->dataMap();
            $defaultCategory = \eZINI::instance('content.ini')->variable('ClassAttributeSettings', 'DefaultCategory');
            foreach ($classDataMap as $identifier => $attribute) {
                $category = $attribute->attribute('category');
                if (empty($category)) {
                    $category = $defaultCategory;
                }

                $add = true;

                if ((bool)$this->getHelper()->getSetting('OnlyRequired')) {
                    $add = (bool)$attribute->attribute('is_required')
                        || $identifier === 'has_price_specification';
                }

                if ($add == true && $this->getHelper()->hasSetting('ShowCategories')) {
                    $add = in_array($category, (array)$this->getHelper()->getSetting('Categories'));
                }

                if ($add == true && $this->getHelper()->hasSetting('HideCategories')) {
                    $add = !in_array($category, (array)$this->getHelper()->getSetting('HideCategories'));
                }

                if ($add) {
                    $this->fieldConnectors[$identifier] = FieldConnectorFactory::load(
                        $attribute,
                        $this->class,
                        $this->getHelper()
                    );
                } else {
                    $this->copyFieldFromPrevVersion($identifier);
                }
            }
        }

        return $this->fieldConnectors;
    }

}
