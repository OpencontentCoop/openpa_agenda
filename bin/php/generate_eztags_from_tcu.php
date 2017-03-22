<?php

require 'autoload.php';

use Opencontent\Opendata\Api\TagRepository;

$script = eZScript::instance(array('description' => ("Importa oggetti tipo_evento da cultura trentino"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();
$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

function createTag($name, $parentTagId, $locale = 'ita-IT')
{
    global $cli;
    global $tagRepository;

    $struct = new \Opencontent\Opendata\Api\Structs\TagStruct();
    $struct->parentTagId = $parentTagId;
    $struct->keyword = $name;
    $struct->locale = $locale;
    $struct->alwaysAvailable = true;

    $result = $tagRepository->create($struct);
    if ($result['message'] == 'success') {
        $cli->warning(' - Created tag ' . $name);
    }
    return $result['tag'];
}

$tagRepository = new \Opencontent\Opendata\Api\TagRepository();
$locale = 'ita-IT';
try {

    try{
        $root = $tagRepository->read('Tipologia di evento');
    }catch(Exception $e){
        $root = createTag('Tipologia di evento', 0);
    }

    $treeNode = 'https://www.cultura.trentino.it/api/opendata/v1/content/node/200420';
    $treeUrl = $treeNode . '/list/offset/0/limit/1000';

    $dataTree = json_decode(OpenPABase::getDataByURL($treeUrl), true);
    if ($dataTree) {
        foreach ($dataTree['childrenNodes'] as $item) {

            $item = new OpenPAApiChildNode($item);

            $cli->output($item->objectName);
            $itemTag = createTag($item->objectName, $root->id);

            foreach ($item->getChildren() as $child) {

                $cli->output(' |- ' . $child->objectName);
                $childTag = createTag($child->objectName, $itemTag->id);

                foreach ($child->getChildren() as $subChild) {

                    $cli->output('     |- ' . $subChild->objectName);
                    $subChildTag = createTag($subChild->objectName, $childTag->id);

                    foreach ($subChild->getChildren() as $subSubChild) {

                        $cli->output('         |- ' . $subSubChild->objectName);
                        $subSubChildTag = createTag($subSubChild->objectName, $subChildTag->id);
                    }
                }
            }
        }
    }else{
        throw new Exception("Url $treeUrl not found");
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
