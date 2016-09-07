<?php


class AgendaFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $rootNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');

        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::rootRemoteId() . '_agenda_container' );
        if ($containerObject instanceof eZContentObject)
        {
            $rootNodeId = $containerObject->attribute('main_node_id');
        }

        $this->configuration['CreationRepositoryNode'] = $rootNodeId;
        $this->configuration['RepositoryNodes'] = array($rootNodeId);
    }

    public function instancePost( $data )
    {
        return new AgendaItem( $data, $this );
    }

    public function getTemplateDirectory()
    {
        return 'editorialstuff/agenda';
    }

}