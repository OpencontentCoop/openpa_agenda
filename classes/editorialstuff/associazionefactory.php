<?php


class AssociazioneFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $rootNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');
        $this->configuration['CreationRepositoryNode'] = $rootNodeId;
        $this->configuration['RepositoryNodes'] = array(1,$rootNodeId);
    }

    public function instancePost( $data )
    {
        return new Associazione( $data, $this );
    }

    public function getTemplateDirectory()
    {
        return 'editorialstuff/associazione';
    }

}