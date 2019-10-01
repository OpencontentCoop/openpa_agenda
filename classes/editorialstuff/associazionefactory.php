<?php


class AssociazioneFactory extends OCEditorialStuffPostDefaultFactory
{
    public function __construct($configuration)
    {
        parent::__construct($configuration);
        $rootNodeId = OpenPAAgenda::instance()->rootObject()->attribute('main_node_id');

        $containerObject = eZContentObject::fetchByRemoteID( OpenPAAgenda::associationsRemoteId() );
        if ($containerObject instanceof eZContentObject)
        {
            $rootNodeId = $containerObject->attribute('main_node_id');
        }

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

    public function dashboardModuleResult( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        //eZINI::instance('ezfind.ini')->setVariable('LanguageSearch', 'SearchMainLanguageOnly', 'disabled');

        return parent::dashboardModuleResult( $parameters, $handler, $module );
    }

}