<?php

class OpenPAAgendaTcuPushClient implements OpenPAAgendaPushClient
{

    private $client;

    public function __construct()
    {
        $this->client = new OpenPAAgendaTCUHttpClient();
    }

    public function name()
    {
        return 'Trentino Cultura';
    }

    /**
     * @param AgendaItem $post
     *
     * @return array
     */
    public function push(AgendaItem $post)
    {
        $mainNode = $post->getMainNode();
        try{
            $result = $this->client->push($mainNode);
            return array(
                'status' => 'success',
                'messages' => array(),
                'id' => $result['metadata']['id']
            );
        }catch(Exception $e){
            eZDebug::writeError($e->getTraceAsString(), $e->getMessage());

            $converter = new OpenPAAgendaTCUEventConverter($mainNode);
            $data = $converter->convert();
            eZDebug::writeError($data);

            return array(
                'status' => 'error',
                'messages' => array($e->getMessage())
            );
        }

    }

    public function getRemoteUrl($response)
    {
        if (isset($response['id'])){
            $settings = OpenPAINI::group('OpenpaAgendaPushSettingsTcu');
            return $settings['TrentinoCulturaServer'] . '/openpa/object/' . $response['id'];
        }
        return null; //@todo
    }

}
