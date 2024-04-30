<div class="panel-body" style="background: #fff">
    {def $discussion = $post.discussion}
    {if count( $discussion )|gt(0)}
        {foreach $discussion as $item}
            <div class="clearfix">
                <div
                    class="{if $item.user.contentobject_id|eq(fetch(user, current_user).contentobject_id)}bg-info pull-right{else}bg-100 text-left pull-left{/if}"
                    style="border-radius: 5px; padding: 20px;margin-{if $item.user.contentobject_id|eq(fetch(user, current_user).contentobject_id)}left{else}right{/if}:20px;margin-bottom:20px;display: inline-block;min-width:150px">
                    <small style="display: block;line-height: 2">{$item.created_time|l10n( shortdatetime )}</small>
                    <strong>{$item.user.contentobject.name|wash()}</strong>: {$item.params.text|wash()|nl2br}
                    {if $item.user.contentobject_id|eq(fetch(user, current_user).contentobject_id)}
                        <form style="display: inline"
                              action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}"
                              method="post">
                            <input type="hidden" name="ActionIdentifier" value="ActionRemoveDiscussion"/>
                            <input type="hidden" name="ActionParameters[]" value="{$item.id|wash()}"/>
                            <button class="btn btn-link" type="submit" name="ActionRemoveDiscussion"><i
                                    class="fa fa-trash"></i></button>
                        </form>
                    {/if}
                </div>
            </div>
        {/foreach}
    {/if}

    {if $post.object.can_edit}
    <form action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}" method="post" class="form my-3">
        <input type="hidden" name="ActionIdentifier" value="ActionDiscussion"/>
        <div class="row">
            <div class="col">
                <div class="input-group">
                    <label for="AddComment"
                           class="hide d-none">{'Content:'|i18n( 'ezcomments/comment/add/form' )}</label>
                    <input type="text" name="ActionParameters[]" class="form-control border" id="AddComment">
                    <div class="input-group-btn">
                        <button type="submit" name="ActionDiscussion"
                                class="btn btn-sm btn-primary rounded-0">{'Add comment'|i18n( 'ezcomments/comment/add/form' )}</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    {/if}
</div>
