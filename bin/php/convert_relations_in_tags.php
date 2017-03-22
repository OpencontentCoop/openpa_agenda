<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "Converte relazioni oggetti in tag \n\n" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();

$options = $script->getOptions(
    '[class:][relations_attribute:][tags_attribute:][tag_root_id:]',
    '',
    array(
        'class'  => 'Identificatore di classe',
        'relations_attribute'  => 'Identificatore di classe',
        'tags_attribute'  => 'Identificatore di classe',
        'tag_root_id'  => 'Identificatore di classe'
    )
);

$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

OpenPALog::setOutputLevel( OpenPALog::ALL );

function createTag($name, $parentTagId, $locale)
{
    global $cli;

    $tagRepository = new \Opencontent\Opendata\Api\TagRepository();
    $struct = new \Opencontent\Opendata\Api\Structs\TagStruct();
    $struct->parentTagId = $parentTagId;
    $struct->keyword = $name;
    $struct->locale = $locale;
    $struct->alwaysAvailable = true;

    $result = $tagRepository->create($struct);
    if ($result['message'] == 'success'){
        $cli->warning(' - Created tag ' . $name);
    }
    return $result['tag'];
}

function convertObject(eZContentObject $object)
{
    global $cli, $options, $locale;

    /** @var eZContentObjectAttribute[] $dataMap */
    $dataMap = $object->attribute('data_map');

    $tags = array();

    if (isset($dataMap[$options['relations_attribute']]) && $dataMap[$options['relations_attribute']]->hasContent()){
        /** @var \Opencontent\Opendata\Api\Values\Tag[] $tags */
        $ids = explode('-', $dataMap[$options['relations_attribute']]->toString());
        foreach($ids as $id){
            $related = eZContentObject::fetch($id);
            if ($related instanceof eZContentObject){
                $name = $related->attribute('name');
                if ($name != 'Evento singolo' && $name != 'Manifestazione')
                    $tags[] = createTag($name, $options['tag_root_id'], $locale);
            }
        }
    }
    if (isset($dataMap[$options['tags_attribute']])){
        $idString = array();
        $keywordString = array();
        $parentString = array();
        $localeString = array();
        foreach($tags as $tag){
            $idString[] = $tag->id;
            $keywordString[] = $tag->keyword;
            $parentString[] = $tag->parentId;
            $localeString[] = $locale;
        }

        $tagString = implode( '|#', array_merge($idString, $keywordString, $parentString, $localeString) );
        $dataMap[$options['tags_attribute']]->fromString($tagString);
        $dataMap[$options['tags_attribute']]->store();
    }

    eZContentOperationCollection::registerSearchObject($object->attribute('id'));
}

/**
 * @param eZContentClass $class
 * @param $identifier
 * @param $type
 *
 * @return eZContentClassAttribute
 * @throws Exception
 */
function getClassAttribute(eZContentClass $class, $identifier, $type)
{
    $classAttribute = $class->fetchAttributeByIdentifier($identifier);
    if ($classAttribute instanceof eZContentClassAttribute
        && $classAttribute->DataTypeString == $type){
        return $classAttribute;
    }
    throw new Exception("Attribute {$identifier} not found or not valid");
}

try
{
    $locale = 'ita-IT';
    $class = eZContentClass::fetchByIdentifier($options['class']);
    if ($class instanceof eZContentClass){
        $relationsAttribute = getClassAttribute($class, $options['relations_attribute'], eZObjectRelationListType::DATA_TYPE_STRING);
        $tagsAttribute = getClassAttribute($class, $options['tags_attribute'], eZTagsType::DATA_TYPE_STRING);

        $count = $class->objectCount();
        $offset = 0;
        $limit = 50;
        $i = 0;
        do
        {
            /** @var eZContentObject[] $items */
            $items = eZContentObject::fetchFilteredList( array( 'contentclass_id' => $class->attribute('id') ), $offset, $limit );
            foreach($items as $object){
                $i++;
                $cli->warning($i . '/' . $count . " " . $object->attribute('name'));
                convertObject($object);
            }
            $offset = $offset + $limit;
        } while ( count( $items ) == $limit );

    }else{
        throw new Exception("Class {$options['class']} not found");
    }

    $script->shutdown();
}
catch( Exception $e )
{
    $cli->error($e->getMessage());
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}
