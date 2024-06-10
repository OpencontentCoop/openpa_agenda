<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector\MatrixField;

class HasOnlineContactPointMatrixField extends MatrixField
{
    public function getSchema()
    {
        $schema = parent::getSchema();
        $schema["items"]["properties"]['type']['required'] = true;
        $schema["items"]["properties"]['value']['required'] = true;
        return $schema;
    }

    public function getOptions()
    {
        $options = parent::getOptions();
        $options['items'] = [
            'fields' => [
                'type' => [
                    'helper' => 'Inserisci qui la tipologia di contatto (es. Telefono, Email, Sito web, Fax, PEC)',
                    'type' => 'text',
                    'showMessages' => false,
                    'typeahead' => [
                        'config' => [
                            'autoselect' => true,
                            'highlight' => true,
                            'hint' => true,
                            'minLength' => 1,
                        ],
                        'datasets' => [
                            'type' => 'local',
                            'source' => ['Telefono', 'Email', 'Sito web', 'Fax', 'PEC'],
                        ],
                    ],
                ],
                'value' => [
                    'helper' => "Inserisci qui il valore del contatto (es. il numero di telefono, l'url, l'indirizzo email, ...)",
                    'type' => 'text',
                    'showMessages' => false,
                ],
                'contact' => [
                    'helper' => "Specifica qui il tipo di contatto (es. Amministrazione, Segreteria, Supporto specialistico). Questo valore è facoltativo.",
                    'type' => 'hidden',
                ],
            ],
        ];

        return $options;
    }

}
