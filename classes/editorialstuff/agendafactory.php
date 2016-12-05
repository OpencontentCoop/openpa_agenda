<?php


class AgendaFactory extends OCEditorialStuffPostDefaultFactory
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

    public function dashboardModuleResult( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        $tpl = $this->dashboardModuleResultTemplate( $parameters, $handler, $module );
        $Result = array();
        $Result['content'] = $tpl->fetch( "design:{$this->getTemplateDirectory()}/dashboard.tpl" );
        $contentInfoArray = array(
            'node_id' => null,
            'class_identifier' => null
        );
        $contentInfoArray['persistent_variable'] = array(
            'show_path' => true,
            'site_title' => 'Dashboard ' . $this->classIdentifier()
        );
        if ( is_array( $tpl->variable( 'persistent_variable' ) ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $tpl->variable( 'persistent_variable' ) );
        }
        if ( isset( $this->configuration['PersistentVariable'] ) && is_array( $this->configuration['PersistentVariable'] ) )
        {
            $contentInfoArray['persistent_variable'] = array_merge( $contentInfoArray['persistent_variable'], $this->configuration['PersistentVariable'] );
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array( array( 'url' => false, 'text' => isset( $this->configuration['Name'] ) ? $this->configuration['Name'] : 'Dashboard' ) );
        return $Result;
    }

    protected function dashboardModuleResultTemplate( $parameters, OCEditorialStuffHandlerInterface $handler, eZModule $module )
    {
        if ( isset( $this->configuration['UiContext'] ) && is_string( $this->configuration['UiContext'] ) )
            $module->setUIContextName( $this->configuration['UiContext'] );
        $tpl = eZTemplate::factory();
        $tpl->setVariable( 'factory_identifier', $this->configuration['identifier'] );
        $tpl->setVariable( 'factory_configuration', $this->getConfiguration() );
        $tpl->setVariable( 'template_directory', $this->getTemplateDirectory() );
        $tpl->setVariable( 'view_parameters', $parameters );
        $tpl->setVariable( 'post_count', 0);
        $tpl->setVariable( 'posts', array());
        $tpl->setVariable( 'states', $this->states() );
        $tpl->setVariable( 'site_title', false );
        return $tpl;
    }

}