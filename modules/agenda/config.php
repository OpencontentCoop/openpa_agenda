<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$Http = eZHTTPTool::instance();
$tpl = eZTemplate::factory();
$Part = $Params['Part'] ? $Params['Part'] : 'moderators';
$Offset = (int)$Params['Offset'];
$viewParameters = array( 'offset' => $Offset, 'query' => null );
$currentUser = eZUser::currentUser();

$root = OpenPAAgenda::instance()->rootNode();

if ( $Http->hasVariable( 's' ) )
    $viewParameters['query'] = $Http->variable( 's' );

if ( $Http->hasPostVariable( 'AddModeratorLocation' ) || $Http->hasPostVariable( 'AddExternalUsersLocation' )  )
{
    $action = $Http->hasPostVariable( 'AddModeratorLocation' ) ? 'AddModeratorLocation' : 'AddExternalUsersLocation';

    eZContentBrowse::browse( array( 'action_name' => $action,
                                    'return_type' => 'NodeID',
                                    'class_array' => eZUser::fetchUserClassNames(),
                                    'start_node' => eZINI::instance('content.ini')->variable('NodeSettings','UserRootNode'),
                                    'cancel_page' => '/agenda/config/moderators',
                                    'from_page' => '/agenda/config/moderators' ), $Module );
    return;
}

if ($Http->hasPostVariable('BrowseActionName')
    && ( $Http->postVariable('BrowseActionName') == 'AddModeratorLocation' || $Http->postVariable('BrowseActionName') == 'AddExternalUsersLocation' )
) {
    $nodeIdList = $Http->postVariable( 'SelectedNodeIDArray' );

    $newLocation = $Http->postVariable('BrowseActionName') == 'AddModeratorLocation' ? OpenPAAgenda::moderatorGroupNodeId(): OpenPAAgenda::externalUsersGroupNodeId();

    $redirect = $Http->postVariable('BrowseActionName') == 'AddModeratorLocation' ? 'moderators': 'external_users';

    foreach( $nodeIdList as $nodeId )
    {
        $node = eZContentObjectTreeNode::fetch($nodeId);
        if ($node instanceof eZContentObjectTreeNode){
            eZContentOperationCollection::addAssignment($nodeId, $node->attribute( 'contentobject_id' ), array($newLocation));
        }
    }
    $Module->redirectTo( '/agenda/config/' . $redirect );
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
elseif ( $Part == 'external_users' )
{
    $tpl->setVariable( 'external_users_parent_node_id', OpenPAAgenda::externalUsersGroupNodeId() );
}

$data = array();
/** @var eZContentObjectTreeNode[] $otherFolders */
$otherFolders = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include',
                                                                 'ClassFilterArray' => array( 'folder' ),
                                                                 'Depth' => 1, 'DepthOperator' => 'eq', ),
                                                         $root->attribute( 'node_id' ) );
foreach( $otherFolders as $folder )
{
    if ( $folder->attribute( 'node_id' ) != OpenPAAgenda::programNodeId() )
    {
        $data[] = $folder;
    }
}

$Http->removeSessionVariable('RedirectURIAfterPublish');
$Http->removeSessionVariable('RedirectIfDiscarded');

$tpl->setVariable( 'root', $root );
$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'persistent_variable', array() );
$tpl->setVariable( 'view_parameters', $viewParameters );
$tpl->setVariable( 'current_part', $Part );
$tpl->setVariable( 'index', $Params['Part'] );
$tpl->setVariable( 'data', $data );

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
