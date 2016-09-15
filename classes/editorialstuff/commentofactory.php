<?php


class CommentoFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $rootNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');

        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::calendarRemoteId() );
        if ($containerObject instanceof eZContentObject)
        {
            $rootNodeId = $containerObject->attribute('main_node_id');
        }
        
        $this->configuration['RepositoryNodes'] = array($rootNodeId);
    }
    
    public function instancePost( $data )
    {
        return new Commento( $data, $this );
    }
}