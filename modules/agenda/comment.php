<?php
/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$forumId = $Params['ForumID'];
$forumReplyId = $Params['ForumReplyID'];
$ajax = $http->hasGetVariable( 'ajax' );
$forum = eZContentObjectTreeNode::fetch( $forumId );
$node = $reply = false;
if ( is_numeric( $forumReplyId ) )
{
    $reply = eZContentObjectTreeNode::fetch( $forumReplyId );
    $node = $reply;
    $anchor = 'reply-' . $forumReplyId;
}
else
{
    $forumReplyId = 0;
    $node = $forum;
    $anchor = 'edit';
}

$offset = 0;
if ( isset( $Params['UserParameters']['offset'] ) )
{
    $offset = $Params['UserParameters']['offset'];
}

$class = eZContentClass::fetchByIdentifier('comment');
$userInfo = SocialUser::current();

if ( $node instanceof eZContentObjectTreeNode && $class instanceof eZContentClass && !$userInfo->hasDenyCommentMode() )
{
    $languageCode = eZINI::instance()->variable( 'RegionalSettings', 'Locale' );
    $object = eZContentObject::createWithNodeAssignment( $node,
        $class->attribute( 'id' ),
        $languageCode,
        false );
    if ( $object )
    {
        if ( $ajax )
        {
            $contentModule = eZModule::exists( 'content' );
            $result = $contentModule->run(
                'edit',
                array( $object->attribute( 'id' ), $object->attribute( 'current_version' ), $languageCode ),
                false
            );
            echo $result['content'];
            eZExecution::cleanExit();
        }
        else
        {
            $module->redirectTo( 'content/edit/' . $object->attribute( 'id' ) . '/' . $object->attribute( 'current_version' ) . '/' . $languageCode . '/(forum)/' . $forumId . '/(reply)/' . $forumReplyId . '/(offset)/' . $offset . '#' . $anchor );
        }
    }
    else
        return $module->handleError( eZError::KERNEL_ACCESS_DENIED, 'kernel' );
}
else
    return $module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );