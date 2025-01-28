<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;
use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnectorFactory;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\EnvironmentLoader;

class PrivateOrganizationSettingsClassConnector extends ClassConnector
{
    public function getFieldConnectors()
    {
        if ($this->fieldConnectors === null) {
            $settingsAttributes = OpenPAINI::variable('OpenpaAgenda', 'OrganizationPrivateEditAttributes', []);
            /** @var \eZContentClassAttribute[] $classDataMap */
            $classDataMap = $this->class->dataMap();
            foreach ($classDataMap as $identifier => $attribute) {
                $add = false;
                if (in_array($identifier, $settingsAttributes)) {
                    $add = true;
                }

                if ($add) {
                    $this->fieldConnectors[$identifier] = FieldConnectorFactory::load(
                        $attribute,
                        $this->class,
                        $this->getHelper()
                    );
                }
            }
        }

        return $this->fieldConnectors;
    }

    public function getSchema()
    {
        $data = parent::getSchema();
        $data['title'] = '';
        $data['description'] = '';

        return $data;
    }

    public function getOptions()
    {
        $options = parent::getOptions();
        $options['helper'] = '';

        return $options;
    }

    public function submit()
    {
        $payload = $this->getPayloadFromArray($this->getSubmitData());
        $payload->setOption('update_null_field', false);
        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment(EnvironmentLoader::loadPreset('content'));
        $result = $contentRepository->update($payload->getArrayCopy());

        $this->cleanup();

        return $result;
    }
}
