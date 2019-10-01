{def $locales = fetch( 'content', 'translation_list' )}
{def $item_limit=30}
{def $query = false()}
{if $view_parameters.query}
    {set $query = concat('(*',$view_parameters.query|downcase(),'*) OR ',$view_parameters.query|downcase())}
{/if}

{def $search = fetch( ezfind, search, hash( query, $query, subtree_array, array( $user_parent_node.node_id ), limit, $item_limit, offset, $view_parameters.offset, sort_by, hash( 'name', 'asc' ) ) )}

{def $users_count = $search.SearchCount
     $users = $search.SearchResult}

<table class="table table-hover">
    {foreach $users as $user}
        {def $userSetting = $user|user_settings()}
        <tr>
            <td>
                {if $userSetting.is_enabled|not()}<span style="text-decoration: line-through">{/if}
                    {*<a href="{$user.url_alias|ezurl(no)}">{$user.name|wash()}</a>*}{$user.name|wash()} <small><em>{$user.data_map.user_account.content.email|wash()}</em></small>
                    {if $userSetting.is_enabled|not()}</span>{/if}
            </td>
            <td width="1">
                {*include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$user*}
                <a href="{concat('social_user/setting/',$user.contentobject_id)|ezurl(no)}"><i class="fa fa-user"></i></a>
            </td>
            <td width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$user redirect_if_cancel='/agenda/config/users' redirect_after_remove='/agenda/config/users'}</td>
            {*<td width="1">
              {if fetch( 'user', 'has_access_to', hash( 'module', 'user', 'function', 'setting' ))}
                <form name="Setting" method="post" action={concat( 'user/setting/', $operator.contentobject_id )|ezurl}>
                  <input type="hidden" name="is_enabled" value={if $userSetting.is_enabled|not()}"1"{else}""{/if} />
                  <button class="btn-link btn-xs" type="submit" name="UpdateSettingButton" title="{if $userSetting.is_enabled}{'Lock'|i18n('agenda/config')}{else}{'Unlock'|i18n('agenda/config')}{/if}">{if $userSetting.is_enabled}<i class="fa fa-ban"></i>{else}<i class="fa fa-check-circle"></i>{/if}</button>

                </form>
              {/if}
            </td>*}
        </tr>
        {undef $userSetting}
    {/foreach}

</table>

{include name=navigator
         uri='design:navigator/google.tpl'
         page_uri='agenda/config/users'
         item_count=$users_count
         view_parameters=$view_parameters
         item_limit=$item_limit}
