<?php

require 'autoload.php';

$script = eZScript::instance(array('description' => ("Colloca gli oggetti del tipospecificato  nel nodo target"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true));

$script->startup();
$options = $script->getOptions(
    '[org:][num:][date:]',
    '',
    array(
        'org' => 'Organization ID (if missing create a new organization)',
        'num' => 'Number of demo events',
        'date' => 'Start date of demo events in format dd-mm-yyyy'
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

/** @var eZUser $user */
$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

try {
    $openAgenda = OpenPAAgenda::instance();
    $organizationId = (int)$options['org'];
    $organization = eZContentObject::fetch($organizationId);
    if (!$organization instanceof eZContentObject) {
        $organization = eZContentObject::fetchByRemoteID('demo_org');
        if (!$organization instanceof eZContentObject) {
            $cli->warning("org param not found: create demo organization");
            $params = [
                'class_identifier' => $openAgenda->getAssociationClassIdentifier(),
                'parent_node_id' => OpenPAAgenda::associationsNodeId(),
                'remote_id' => 'demo_org',
                'attributes' => [
                    'legal_name' => 'Demo Organization',
                    'description' => SQLIContentUtils::getRichContent('<p>The incredible demo org!</p>'),
                    'vat_code' => '12345678910',
                    'user_account' => 'demo|demo@ez.no|1234|md5_password|1',
                    'gdpr_acceptance' => 1
                ]
            ];
            $organization = eZContentFunctions::createAndPublishObject($params);
        } else {
            $cli->output("Use demo organization");
        }
    }

    if (!$organization instanceof eZContentObject) {
        throw new Exception("Can not create organization");
    }

    $num = (int)$options['num'];
    $startDate = $options['date'];

    $startTimestamp = null;
    if ($startDate){
        $startDate = DateTime::createFromFormat('d-m-Y' ,$startDate);
        $startTimestamp = $startDate->getTimestamp();
    }

    function getRandomText($type)
    {
        eZCLI::instance()->output(" - get random $type text");
        switch ($type) {
            case 'short':
                $data = file_get_contents('https://loripsum.net/api/1/veryshort/plaintext');

                return $data;

            case 'medium':
                $data = file_get_contents('https://loripsum.net/api/2/medium');

                return $data;

            case 'long':
                $data = file_get_contents('https://loripsum.net/api/6/decorate');

                return $data;
        }

        return '';
    }

    function getRandomVideo()
    {
        eZCLI::instance()->output(" - get random video");
        $data = file_get_contents('https://random-ize.com/random-youtube/goo-f.php');
        $doc = new DOMDocument();
        $doc->loadHTML(mb_convert_encoding($data, 'utf-8', mb_detect_encoding($data)));
        $elements = $doc->getElementsByTagName('iframe');
        foreach ($elements as $element) {
            return $element->getAttribute('src');
        }

        return '';
    }

    function getRandomImage($number, $parentNodeId)
    {
        eZCLI::instance()->output(" - get random $number images ", false);
        $ini = eZINI::instance();

        $localDir = $ini->variable('FileSettings', 'TemporaryDir');

        $data = [];
        for ($x = 1; $x <= $number; $x++) {
            $image = SQLIContent::create(new SQLIContentOptions(array(
                'class_identifier' => 'image'
            )));

            $random = file_get_contents('https://source.unsplash.com/random/800x600');
            $fileName = 'image-' . rand(1, 10000) . '.jpg';
            eZFile::create($fileName, $localDir, $random);

            $image->fields->name = $fileName;
            $image->fields->image = $localDir . '/' . $fileName;
            $image->addLocation(SQLILocation::fromNodeID($parentNodeId));
            SQLIContentPublisher::getInstance()->publish($image);

            $data[] = $image->id;
            eZCLI::instance()->output('.', false);
        }
        eZCLI::instance()->output();

        return implode('-', $data);
    }

    /** @var eZContentObjectTreeNode[] $topics */
    $topics = eZContentObjectTreeNode::subTreeByNodeID([
        'ClassFilterType' => 'include',
        'ClassFilterArray' => ['topic'],
    ], 1);

    function getRandomTopic()
    {
        global $topics;
        shuffle($topics);

        return $topics[0]->attribute('contentobject_id');
    }

    function getRandomTag($parentTagId)
    {
        $treeFetch = eZTagsFunctionCollection::fetchTagTree($parentTagId, false, false, false, 3, false, false);
        /** @var eZTagsObject[] $tree */
        $tree = $treeFetch['result'];
        shuffle($tree);
        $random = $tree[0];

        $returnArray = array();
        $returnArray[] = $random->attribute('id');
        $returnArray[] = $random->attribute('keyword');
        $returnArray[] = $random->attribute('parent_id');
        $returnArray[] = eZLocale::currentLocaleCode();

        return implode('|#', $returnArray);
    }

    function getRandomDates($startTimestamp = null)
    {
        $now = $startTimestamp? $startTimestamp : time();
        $until = $now + (60 * 60 * 24 * 30);

        $random = rand($now, $until);

        $startDate = new DateTime();
        $startDate->setTimestamp($random);

        $endDate = clone $startDate;
        $endDate->add(new DateInterval('PT4H'));

        $untilDate = clone $startDate;
        $untilDate->add(new DateInterval('P10D'));

        $rule = new \Recurr\Rule();
        $rule->setStartDate($startDate, true)
            ->setEndDate($endDate)
            ->setFreq(\Recurr\Rule::$freqs['DAILY'])
            ->setInterval(rand(1, 5))
            ->setUntil($untilDate);

        $string = $rule->getString();
        eZCLI::instance()->output(" - get random date: $string");

        return [
            'published' => $startDate->getTimestamp(),
            'pattern' => $string
        ];
    }

    for ($x = 1; $x <= $num; $x++) {

        $eventClass = eZContentClass::fetchByIdentifier($openAgenda->getEventClassIdentifier());

        $published = false;

        $attributes = [
            'organizer' => $organization->attribute('id'),
        ];

        /** @var eZContentClassAttribute $attribute */
        foreach ($eventClass->dataMap() as $identifier => $attribute) {

            $attributeContent = $attribute->content();

            switch ($attribute->attribute('data_type_string')) {
                case eZStringType::DATA_TYPE_STRING:
                    {
                        if ($identifier == 'has_video') {
                            $attributes[$identifier] = getRandomVideo();
                        } else {
                            $attributes[$identifier] = strip_tags(getRandomText('short'));
                        }
                    }
                    break;

                case eZXMLTextType::DATA_TYPE_STRING:
                    {
                        $attributes[$identifier] = SQLIContentUtils::getRichContent(getRandomText($identifier == 'event_abstract' ? 'medium' : 'long'));
                    }
                    break;

                case eZIntegerType::DATA_TYPE_STRING:
                    {
                        $attributes[$identifier] = rand(10, 50);
                    }
                    break;
            }

            switch ($identifier) {
                case 'image':
                    {
                        $attributes[$identifier] = getRandomImage(rand(1, 3), $attributeContent['default_placement']['node_id']);
                    }
                    break;

                case 'is_accessible_for_free':
                    {
                        $attributes[$identifier] = 1;
                    }
                    break;

                case 'topics':
                    {
                        $attributes[$identifier] = getRandomTopic();
                    }
                    break;

                case 'has_public_event_typology':
                case 'target_audience':
                    {
                        $attributes[$identifier] = getRandomTag($attribute->attribute(eZTagsType::SUBTREE_LIMIT_FIELD));
                    }
                    break;

                case 'time_interval':
                    {
                        $randomDate = getRandomDates($startTimestamp);
                        $published = $randomDate['published'];
                        $attributes[$identifier] = $randomDate['pattern'];
                    }
                    break;
            }
        }

        $params = [
            'class_identifier' => $openAgenda->getEventClassIdentifier(),
            'parent_node_id' => OpenPAAgenda::calendarNodeId(),
            'attributes' => $attributes
        ];

        $event = eZContentFunctions::createAndPublishObject($params);
        if ($published){
            $event->setAttribute('published', $published);
            $event->store();
            eZSearch::addObject($event, true);
        }
        $cli->warning("Published event #" . $event->ID);
    }


} catch (Exception $e) {
    $cli->error($e->getMessage());
}

$script->shutdown();
