<div class="mb-5">
    {if $post.object.can_edit}
        <form method="post" action="{"content/action"|ezurl(no)}" style="display: inline;">
            <input type="hidden" name="ContentObjectLanguageCode"
                   value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}"/>
            <button class="btn btn-sm btn-info rounded-0 text-white" type="submit" name="EditButton">
                <i class="fa fa-pencil mr-2"></i> {'Edit'|i18n('agenda/dashboard')}
            </button>
            <input type="hidden" name="HasMainAssignment" value="1"/>
            <input type="hidden" name="ContentObjectID" value="{$post.object.id}"/>
            <input type="hidden" name="NodeID" value="{$post.node.node_id}"/>
            <input type="hidden" name="ContentNodeID" value="{$post.node.node_id}"/>
            {* If a translation exists in the siteaccess' sitelanguagelist use default_language, otherwise let user select language to base translation on. *}
            {def $avail_languages = $post.object.available_languages
            $content_object_language_code = ''
            $default_language = $post.object.default_language}
            {if and( $avail_languages|count|ge( 1 ), $avail_languages|contains( $default_language ) )}
                {set $content_object_language_code = $default_language}
            {else}
                {set $content_object_language_code = ''}
            {/if}
            <input type="hidden" name="ContentObjectLanguageCode"
                   value="{$content_object_language_code}"/>
            <input type="hidden" name="RedirectIfDiscarded"
                   value="{concat('editorialstuff/edit/', $factory_identifier, '/',$post.object.id)}"/>
            <input type="hidden" name="RedirectURIAfterPublish"
                   value="{concat('editorialstuff/edit/', $factory_identifier, '/',$post.object.id)}"/>
        </form>
    {/if}

    <form action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}" method="post" style="display: inline;">
        <input type="hidden" name="ActionParameters[]" value="" />
        <input type="hidden" name="ActionIdentifier" value="ActionCopy" />
        <button class="btn btn-sm btn-info rounded-0 text-white"
                type="submit"
                name="ActionCopy">
            <i class="fa fa-copy mr-2"></i> {'Copy'|i18n('design/standard/content/copy')}
        </button>
    </form>
    {if $post.object.can_remove}
        <form method="post" action="{"content/action"|ezurl(no)}" style="display: inline;">

            <button class="btn btn-sm btn-info rounded-0  text-white" type="submit" name="ActionRemove">
                <i class="fa fa-trash mr-2"></i> {'Delete'|i18n('design/standard/gui')}
            </button>

            <input type="hidden" name="ContentObjectID" value="{$post.object.id}" />
            <input type="hidden" name="NodeID" value="{$post.object.main_node_id}" />
            <input type="hidden" name="ContentNodeID" value="{$post.object.main_node_id}" />

            <input type="hidden" name="RedirectIfCancel" value="{$post.editorial_url}" />
            <input type="hidden" name="RedirectURIAfterRemove" value="{concat('editorialstuff/dashboard/', $factory_identifier)}" />

        </form>
    {/if}
    <a class="btn btn-sm btn-info rounded-0 text-white" href="{$post.node.url_alias|ezurl(no)}">
        <i class="fa fa-eye mr-2"></i> {'View on website'|i18n('editorialstuff/dashboard')}
    </a>

    {def $assignable_states = hash()}
    {foreach $post.states as $key => $state}
        {if and($post.object.allowed_assign_state_id_list|contains($state.id), $state.id|ne($post.current_state.id))}
            {set $assignable_states = $assignable_states|merge(hash($key,$state))}
        {/if}
    {/foreach}
    <div class="btn-group pull-right">
        <div class="btn px-0">
        {'Current state is'|i18n('editorialstuff/dashboard')} <div class="d-inline-block rounded py-1 px-2 mx-1 label-{$post.current_state.identifier|wash()}">{$post.current_state.current_translation.name|wash}</div>
        </div>
        <button type="button" class="py-2 btn btn-link rounded-0 text-black dropdown-toggle text-decoration-none" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            {if count($assignable_states)|gt(0)}
            {'Change state to'|i18n('editorialstuff/dashboard')}...
            {display_icon('it-expand', 'svg', 'icon-expand icon icon-sm')}
            {/if}
        </button>
        {if count($assignable_states)|gt(0)}
        <div class="dropdown-menu">
            <div class="link-list-wrapper">
                <ul class="link-list">
                    {foreach $assignable_states as $key => $state}
                        <li>
                            <a class="list-item" href="{concat('editorialstuff/state_assign/', $factory_identifier, '/', $key, "/", $post.object.id )|ezurl(no)}">
                                <span><div class="d-inline-block mr-1 ml-1 rounded label-{$state.identifier|wash()}" style="vertical-align:middle; width: 13px;height: 13px"></div> {$state.current_translation.name|wash}</span>
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </div>
        </div>
        {/if}
    </div>
</div>
