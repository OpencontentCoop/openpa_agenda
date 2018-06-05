<?php

use Opencontent\Opendata\Api\ContentRepository;

class OpenPAAgendaTCUEventConverter implements OpenPAAgendaPushConverter
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

    private function getImage($language)
    {
        $data = array();
        $fileContent = $this->content->data[$language]['image']['content'];
        if (isset($fileContent['filename'])) {
            $fileData = eZClusterFileHandler::instance(ltrim($fileContent['url'], '/'))->fetchContents();
            $data = array(
                'filename' => $fileContent['filename'],
                'file' => base64_encode($fileData)
            );
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
                    $fileData = eZClusterFileHandler::instance(ltrim($fileContent['url'], '/'))->fetchContents();
                    return array(
                        'filename' => $fileContent['filename'],
                        'file' => base64_encode($fileData)
                    );
                }else{
                    return null;
                }
                break;

            case 'immagini':
                $data = array();
                $fileContent = (array)$this->content->data[$language]['images']['content'];
                foreach($fileContent as $item){
                    $image = $this->contentRepository->getGateway()->loadContent($item['id']);
                    $imageContent = $image->data[$language]['image']['content'];
                    if (isset($imageContent['filename'])) {
                        $imageContentData = eZClusterFileHandler::instance(ltrim($fileContent['url'], '/'))->fetchContents();
                        $data[] = array(
                            'filename' => $imageContent['filename'],
                            'file' => base64_encode($imageContentData)
                        );
                    }
                }
                $image = $this->getImage($language);
                if (!empty($image)){
                    $data[] = $image;
                }
                return $data;
                break;

            case 'preview_image':
            case 'image':
                //     $image = $this->getImage($language);
                //     if (!empty($image)){
                //         if ($identifier == 'preview_image'){
                //             return array($image);
                //         }
                //         return $image;
                //     }
                return null;
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
                $pageData = new OpenPAAgendaPageDataHandler();
                return $url . '|' . $pageData->siteTitle();
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
