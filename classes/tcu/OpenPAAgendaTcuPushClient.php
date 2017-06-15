<?php

class OpenPAAgendaTcuPushClient implements OpenPAAgendaPushClient
{
    const REMOTE_ID_PREFIX = 'tcu_push_';

    /**
     * @var OpenPAAgendaTCUHttpClient
     */
    private $client;

    /**
     * @var OpenPAAgendaPushConverter
     */
    private $converter;

    public function __construct()
    {
        $this->client = new OpenPAAgendaTCUHttpClient();
    }

    public function name()
    {
        return 'Trentino Cultura';
    }

    private function loadDepsByClass(OCEditorialStuffPost $post)
    {
        if ($post instanceof AgendaItem){
            $this->client->setEndpointType('eventi');
            $this->converter = new OpenPAAgendaTCUEventConverter($post->getMainNode(), $this->client->definition());

        }elseif ($post instanceof Associazione){
            $this->client->setEndpointType('associazioni');
            $this->converter = new OpenPAAgendaTCUAssociazioneConverter($post->getMainNode(), $this->client->definition());

        }else{
            throw new Exception("Cannot push {$post->getFactory()->classIdentifier()} contents");
        }
    }

    /**
     * @param OCEditorialStuffPost $post
     *
     * @return array
     * @throws Exception
     */
    public function push(OCEditorialStuffPost $post)
    {
        $data = $this->convert($post);

        try{

            if ($this->client->getEndpointType() == 'eventi'){
                $data = $this->decorateAgendaItem($post, $data);
            }


            if ($this->isAlreadyPushed($post)) {
                $result = $this->client->update(
                    $this->getRemoteId($post),
                    $data
                );

            }else {
                $result = $this->client->create($data);
                if (isset( $result['metadata'] )) {
                    $this->storeRemoteId($post, $result['metadata']['id']);
                }
            }

            $response = array(
                'status' => 'success',
                'messages' => array(),
                'id' => $result['metadata']['id']
            );
        }catch(Exception $e){

            eZDebug::writeError($e->getTraceAsString(), $e->getMessage());
            eZDebug::writeError($data);

            eZLog::write(
                $e->getMessage() . ' ' . $e->getTraceAsString() . ' ' . var_export($data, 1),
                OpenPABase::getCurrentSiteaccessIdentifier() . '_agenda__push_tcu.log'
            );

            $response = array(
                'status' => 'error',
                'messages' => array($e->getMessage())
            );
        }

        OCEditorialStuffHistory::addSocialHistoryToObjectId(
            $post->id(),
            'tcu',
            $response
        );

        return $response;
    }

    public function convert(OCEditorialStuffPost $post)
    {
        $this->loadDepsByClass($post);
        return $this->converter->convert();
    }

    public function getRemoteUrl($response)
    {
        if (isset($response['id'])){
            $settings = OpenPAINI::group('OpenpaAgendaPushSettingsTcu');
            return $settings['TrentinoCulturaServer'] . '/openpa/object/' . $response['id'];
        }
        return null; //@todo
    }

    private function decorateAgendaItem($post, $data)
    {
        $associazioneRemoteIdList = array();
        $pusher = new OpenPAAgendaTcuPushClient();
        if ($post instanceof AgendaItem){
            $associazioneAttribute = $post->attribute('associazione');
            if ($associazioneAttribute instanceof eZContentObjectAttribute){
                $associazioneIdList = explode('-', $associazioneAttribute->toString());
                foreach($associazioneIdList as $associazioneId){
                    /** @var OCEditorialStuffPost $associazione */
                    $associazione = OCEditorialStuffHandler::instance('associazione')
                                                   ->getFactory()
                                                   ->instancePost(array('object_id' => $associazioneId));
                    try{
                        $result = $pusher->push($associazione);
                        $associazioneRemoteIdList[] = $result['id'];
                    }catch(Exception $e){
                        eZDebug::writeError($e->getTraceAsString(), $e->getMessage());
                    }
                }

            }
        }

        if (!empty($associazioneRemoteIdList)){
            foreach($data as $locale => $values){
                $data[$locale]['soggetto'] = $associazioneRemoteIdList;
            }
        }

        return $data;
    }

    private function isAlreadyPushed(OCEditorialStuffPost $post)
    {
        try{
            $data = $this->client->get($this->getRemoteId($post));
            return isset( $data['metadata'] );
        }catch(Exception $e){
            return false;
        }
    }

    private function getRemoteId(OCEditorialStuffPost $post)
    {
        $mainNode = $post->getMainNode();

        return str_replace(self::REMOTE_ID_PREFIX, '', $mainNode->attribute('remote_id'));
    }

    private function storeRemoteId(OCEditorialStuffPost $post, $data)
    {
        $mainNode = $post->getMainNode();
        $mainNode->setAttribute('remote_id', self::REMOTE_ID_PREFIX . $data);
        $mainNode->store();
    }

}
