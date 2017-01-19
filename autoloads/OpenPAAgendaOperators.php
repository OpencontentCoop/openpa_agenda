<?php

class OpenPAAgendaOperators
{
    /**
     * Returns the list of template operators this class supports
     *
     * @return array
     */
    function operatorList()
    {
        return array(
            'is_collaboration_enabled',
            'is_comment_enabled',
            'is_header_only_logo_enabled',
        );
    }

    /**
     * Indicates if the template operators have named parameters
     *
     * @return bool
     */
    function namedParameterPerOperator()
    {
        return true;
    }

    /**
     * Returns the list of template operator parameters
     *
     * @return array
     */
    function namedParameterList()
    {
        return array();
    }

    /**
     * Executes the template operator
     *
     * @param eZTemplate $tpl
     * @param string $operatorName
     * @param mixed $operatorParameters
     * @param string $rootNamespace
     * @param string $currentNamespace
     * @param mixed $operatorValue
     * @param array $namedParameters
     * @param mixed $placement
     */
    function modify( $tpl, $operatorName, $operatorParameters, $rootNamespace, $currentNamespace, &$operatorValue, $namedParameters, $placement )
    {
        $agenda = OpenPAAgenda::instance();
        switch( $operatorName )
        {
            case 'is_collaboration_enabled':
                $operatorValue = $agenda->isCollaborationModeEnabled();
                break;

            case 'is_comment_enabled':
                $operatorValue = $agenda->isCommentEnabled();
                break;

            case 'is_header_only_logo_enabled':
                $operatorValue = $agenda->isHeaderOnlyLogoEnabled();
                break;
        }
    }
}
