<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$Part = $Params['Part'] ? $Params['Part'] : 'users';
$Offset = isset($Offset) ? $Offset : 0;
$viewParameters = array( 'offset' => $Offset, 'query' => null );
$currentUser = eZUser::currentUser();

$root = OpenPAAgenda::instance()->rootNode();

if ( $Http->hasVariable( 's' ) )
    $viewParameters['query'] = $Http->variable( 's' );

if ( $Http->hasPostVariable( 'AddModeratorLocation' ) )
{
    eZContentBrowse::browse( array( 'action_name' => 'AddModeratorLocation',
                                    'return_type' => 'NodeID',
                                    'class_array' => eZUser::fetchUserClassNames(),
                                    'start_node' => eZINI::instance('content.ini')->variable('NodeSettings','UserRootNode'),
                                    'cancel_page' => '/agenda/config/moderators',
                                    'from_page' => '/agenda/config/moderators' ), $Module );
    return;
}

if ( $Http->hasPostVariable( 'BrowseActionName' )
     && $Http->postVariable( 'BrowseActionName' ) == 'AddModeratorLocation' )
{
    $nodeIdList = $Http->postVariable( 'SelectedNodeIDArray' );

    foreach( $nodeIdList as $nodeId )
    {
        $node = eZContentObjectTreeNode::fetch($nodeId);
        if ($node instanceof eZContentObjectTreeNode){
            eZContentOperationCollection::addAssignment($nodeId, $node->attribute( 'contentobject_id' ), array(OpenPAAgenda::moderatorGroupNodeId()));
        }
    }
    $Module->redirectTo( '/agenda/config/moderators' );
    return;
}

if ( $Part == 'users' )
{
    $usersParentNode = eZContentObjectTreeNode::fetch( intval( eZINI::instance()->variable( "UserSettings", "DefaultUserPlacement" ) ) );
    $tpl->setVariable( 'user_parent_node', $usersParentNode );
}
elseif ( $Part == 'moderators' )
{
    $tpl->setVariable( 'moderators_parent_node_id', OpenPAAgenda::moderatorGroupNodeId() );
}


$tpl->setVariable( 'root', $root );
$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'persistent_variable', array() );
$tpl->setVariable( 'view_parameters', $viewParameters );
$tpl->setVariable( 'current_part', $Part );

$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['content'] = $tpl->fetch( 'design:agenda/config.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'agenda/config' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false )
{
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array();
