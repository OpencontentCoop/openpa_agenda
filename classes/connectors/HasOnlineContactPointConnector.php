<?php

use Opencontent\Ocopendata\Forms\Connectors\AbstractBaseConnector;

class HasOnlineContactPointConnector extends AbstractBaseConnector
{
    private $context;

    public static function generateRemoteId(int $objectId): string
    {
        return 'contact_' . $objectId;
    }

    public function runService($serviceIdentifier)
    {
        $this->context = eZContentObject::fetchByRemoteID(
            self::generateRemoteId((int)$this->getHelper()->getParameter('context'))
        );
        return parent::runService($serviceIdentifier); // TODO: Change the autogenerated stub
    }

    protected function getData()
    {
        $contacts = [
            [
                'type' => '',
                'value' => '',
                'contact' => '',
            ],
        ];
        if ($this->context instanceof eZContentObject) {
            $locale = eZLocale::currentLocaleCode();
            $content = \Opencontent\Opendata\Api\Values\Content::createFromEzContentObject($this->context);
            $contacts = $content->data[$locale]['contact']['content'] ?? $content->data['ita-IT']['contact']['content'] ?? [];
        }
        return [
            'contacts' => $contacts,
        ];
    }

    protected function getSchema()
    {
        return [
            'type' => 'object',
            'properties' => [
                'contacts' => [
                    'type' => 'array',
                    'minItems' => 1,
                    'items' => [
                        'type' => 'object',
                        'properties' => [
                            'type' => [
                                'title' => 'Tipo',
                                'type' => 'string',
                                'required' => true,
                            ],
                            'value' => [
                                'title' => 'Valore',
                                'type' => 'string',
                                'required' => true,
                            ],
                            'contact' => [
                                'title' => 'Tipo di contatto',
                                'type' => 'string',
                            ],
                        ],
                    ],
                ],
            ],
        ];
    }

    protected function getOptions()
    {
        $options = [
            'form' => [
                'attributes' => [
                    "action" => $this->getHelper()->getServiceUrl('action', $this->getHelper()->getParameters()),
                    'method' => 'post',
                    'enctype' => 'multipart/form-data',
                ],
            ],
            'fields' => [
                'contacts' => [
                    'type' => 'table',
                    'fields' => [
                        'type' => [
                            'type' => 'text',
                        ],
                    ],
                ],
            ],
        ];

        return $options;
    }

    protected function getView()
    {
        return [
            "parent" => "bootstrap-edit",
            "locale" => "it_IT",
        ];
    }

    protected function submit()
    {
        $data = $_POST['contacts'] ?? [];
        foreach ($data as $index => $item) {
            $data[$index] = array_merge([
                'type' => '',
                'value' => '',
                'contact' => '',
            ], $item);
        }
        $privateOrganization = eZContentObject::fetch((int)$this->getHelper()->getParameter('context'));
        if ($privateOrganization instanceof eZContentObject || eZHTTPTool::instance()->hasSessionVariable(
                "RegisterAgendaAssociazioneID"
            )) {
            $name = $privateOrganization ? $privateOrganization->attribute('name') : '';
            $payload = new \Opencontent\Opendata\Rest\Client\PayloadBuilder();
            $payload->setRemoteId(self::generateRemoteId((int)$this->getHelper()->getParameter('context')));
            $payload->setParentNode(OpenPAAgenda::contactsNodeId());
            $payload->setClassIdentifier('online_contact_point');
            $payload->setLanguages(['ita-IT']);
            $payload->setData('ita-IT', 'name', 'Contatti ' . $name);
            $payload->setData('ita-IT', 'contact', $data);
            $repository = new \Opencontent\Opendata\Api\ContentRepository();
            $repository->setEnvironment(new DefaultEnvironmentSettings());
            $allowAccess = eZHTTPTool::instance()->hasSessionVariable(
                    "RegisterAgendaAssociazioneID"
                ) || eZUser::currentUserID() == $privateOrganization->attribute('id');
            $onlineContactPoint = $repository->createUpdate($payload->getArrayCopy(), $allowAccess);
            return $onlineContactPoint['content']['metadata']['id'] ?? null;
        }

        throw new Exception('Organization not found');
    }

    protected function upload()
    {
        throw new Exception("Method not allowed", 1);
    }

}
