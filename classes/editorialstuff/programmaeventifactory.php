<?php


class ProgrammaEventiFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $rootNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');
        $this->configuration['CreationRepositoryNode'] = $rootNodeId;
        $this->configuration['RepositoryNodes'] = array($rootNodeId);
    }

    public function instancePost( $data )
    {
        return new ProgrammaEventiItem( $data, $this );
    }

    public function getTemplateDirectory()
    {
        return 'editorialstuff/programma_eventi';
    }

}