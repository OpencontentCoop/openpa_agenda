<?php

use Opencontent\Opendata\Api\ContentRepository;

class OpenPAAgendaTCUEventConverter
{
    private $node;

    private $content;

    private $languages;

    private $contentRepository;

    public function __construct(eZContentObjectTreeNode $node)
    {
        $this->node = $node;
        $this->contentRepository = new ContentRepository();
        $this->content = $this->contentRepository->getGateway()->loadContent($node->attribute('contentobject_id'));
        $this->languages = $node->object()->availableLanguages();
    }

    public function convert()
    {
        $data = array();
        foreach(OpenPAAgendaTCUHttpClient::definition() as $identifier => $definition){
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
            case 'titolo':
                return $this->content->data[$language]['titolo']['content'];
                break;

            case 'short_title':
                return $this->content->data[$language]['short_title']['content'];
                break;

            case 'tipo_evento':
            case 'luogo_della_cultura':
            case 'utenza_target':
                $localIdentifier = ($identifier == 'utenza_target') ? 'target' : $identifier;
                if (isset($this->content->data[$language][$localIdentifier])) {
                    $data = array();
                    $contentList = (array)$this->content->data[$language][$localIdentifier]['content'];
                    foreach ($definition['dictionary'] as $item) {
                        if (in_array($item['name'], $contentList)) {
                            $data[] = $item['id'];
                        }
                    }

                    return $data;
                }else{
                    return null;
                }
                break;

            case 'file':
                $fileContent = $this->content->data[$language]['file']['content'];
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

            case 'preview_image':
            case 'immagini':
                $fileContent = (array)$this->content->data[$language]['images']['content'];
                foreach($fileContent as $item){
                    $data = array();
                    $image = $this->contentRepository->getGateway()->loadContent($item['id']);
                    $imageContent = $image->data[$language]['image']['content'];
                    if (isset($imageContent['filename'])) {
                        $imageContentData = eZClusterFileHandler::instance(eZSys::rootDir() . $imageContent['url'])->fetchContents();
                        $data[] = array(
                            'filename' => $imageContent['filename'],
                            'file' => base64_encode($imageContentData)
                        );
                    }
                    return $data;
                }
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

            case 'iniziativa_text':
                $iniziative = (array)$this->content->data[$language]['iniziativa']['content'];
                foreach($iniziative as $iniziativa){
                    return $iniziativa['name'][$language];
                }
                return null;
                break;

            case 'short_description':
                return $this->content->data[$language]['abstract']['content'];
                break;

            case 'informazioni':
                return $this->content->data[$language]['text']['content'];
                break;

            case 'note':
                return $this->content->data[$language]['informazioni']['content'];
                break;

            case 'articoli':
            case 'progressivo':
            case 'associazione':
            case 'fonte':
            case 'abbonamenti_text':
            case 'prevendita':
            case 'codice':
            case 'abbonamenti':
            case 'iniziativa':
            case 'circoscrizione':
            case 'argomento':
            case 'text':
                return null;
                break;

            case 'url':
                $url = 'agenda/event/' . $this->node->attribute('node_id');
                eZURI::transformURI($url, false, 'full');
                return $url;
                break;

            default:
                if(isset($this->content->data[$language][$identifier])
                   && $this->content->data[$language][$identifier]['datatype'] == $definition['type'])
                {
                    return $this->content->data[$language][$identifier]['content'];
                }

                return null;
        }

        return null;
    }

}
