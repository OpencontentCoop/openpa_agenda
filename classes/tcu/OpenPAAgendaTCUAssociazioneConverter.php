<?php

use Opencontent\Opendata\Api\ContentRepository;

class OpenPAAgendaTCUAssociazioneConverter implements OpenPAAgendaPushConverter
{
    private $node;

    private $content;

    private $languages;

    private $contentRepository;

    private $remoteClassDefinition;

    public function __construct(eZContentObjectTreeNode $node, $remoteClassDefinition)
    {
        $this->node = $node;
        $this->contentRepository = new ContentRepository();
        $this->content = $this->contentRepository->getGateway()->loadContent($node->attribute('contentobject_id'));
        $this->languages = $node->object()->availableLanguages();
        $this->remoteClassDefinition = $remoteClassDefinition;
    }

    public function convert()
    {
        $data = array();
        foreach($this->remoteClassDefinition as $identifier => $definition){
            foreach($this->languages as $language) {
                $fieldData = $this->map($identifier, $definition, $language);
                if (!empty( $fieldData )) {
                    $data[$language][$identifier] = $fieldData;
                }
            }
        }
        return $data;
    }

    private function map($identifier, $definition, $language)
    {
        switch($identifier){
            case 'user_account':
            case 'circoscrizione':
            case 'argomento':
            case 'rating':
            case 'codice': //problemi di indicizzazione
                return null;
                break;

            case 'image':
                $fileContent = $this->content->data[$language]['image']['content'];
                if (isset($fileContent['filename'])) {
                    $fileData = eZClusterFileHandler::instance(eZSys::rootDir() . $fileContent['url'])->fetchContents();

                    return array(
                        'filename' => $fileContent['filename'],
                        'file' => base64_encode($fileData)
                    );
                }else{
                    return null;
                }
                break;

            default:
                if(isset($this->content->data[$language][$identifier])
                   && $this->content->data[$language][$identifier]['datatype'] == $definition['type'])
                {
                    return $this->content->data[$language][$identifier]['content'];
                }

                return null;
        }
    }
}
