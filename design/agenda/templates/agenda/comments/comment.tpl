{def $owner = $reply.object.owner}

<div id="reply-{$reply.node_id}" class="row{if and( is_set( $current_reply.contentobject_id ), $current_reply.contentobject_id|eq($reply.contentobject_id) )} alert alert-warning{/if}">

    <figure class="col-sm-1 col-md-1 col-md-offset-{$recursion}">
        {include uri='design:parts/user_image.tpl' object=$owner}
    </figure>

    <div class="col-sm-{10|sub($recursion|mul(2))} col-md-{10|sub($recursion|mul(2))}">

        <div class="comment_name">
            {if $owner}{$owner.name|wash}{else}?{/if}


            {if $comment_form|not()}
                <div class="pull-right">
                    {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$reply}
                    {include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$reply}                    
                </div>
            {/if}

            {foreach $reply.object.author_array as $author}
                {if ne( $reply.object.owner_id, $author.contentobject_id )}
                    {'Moderated by'|i18n( 'design/ocbootstrap/full/forum_topic' )}: {$author.contentobject.name|wash}
                {/if}
            {/foreach}

        </div>
        <div class="comment_date">
            <i class="fa fa-clock-o"></i> {$reply.object.published|datetime( 'custom', '%l, %d %F %Y %H:%i' )} {if $reply.object.current_version|gt(1)}<em> <i class="fa fa-pencil"></i> Modificato</em>{/if}
            {if $reply.object.state_identifier_array|contains('moderation/waiting')}
              <em>{'In attesa di moderazione'|i18n( 'agenda/states' )}</em>
            {/if}
        </div>

        <div class="the_comment">
            <p>{$reply.object.data_map.message.content|simpletags|wordtoimage}</p>
        </div>

        {if $reply.object.data_map.file.has_content}
            <div class="reply-attachments">
                <strong>Allegato</strong>
                <p>{attribute_view_gui attribute=$reply.data_map.file}</p>
            </div>
        {/if}

    </div>

    {*<div class="col-sm-1 col-md-1">
        {include uri='design:agenda/comments/rating.tpl' attribute=$reply.object.data_map.like_rating}
    </div>*}


</div>
{undef $owner}

<div class="row">
    <div class="col-sm-12">
        {if and( $comment_form, is_set( $current_reply.contentobject_id ), $current_reply.contentobject_id|eq($reply.contentobject_id) )}
            {$comment_form}
        {/if}
    </div>
</div>