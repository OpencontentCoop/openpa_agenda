{def $locales = fetch( 'content', 'translation_list' )}
{def $item_limit=20}
{def $query = false()}
{if $view_parameters.query}
    {set $query = concat('(*',$view_parameters.query|downcase(),'*) OR ',$view_parameters.query|downcase())}
{/if}
{def $search = fetch( ezfind, search, hash( query, $query, subtree_array, array( $moderator_parent_node_id ), limit, $item_limit, offset, $view_parameters.offset, sort_by, hash( 'name', 'asc' ) ) )}

{def $moderators_count = $search.SearchCount
     $moderators = $search.SearchResult}

<table class="table table-hover">
    {foreach $moderators as $moderator}
        {def $userSetting = $moderator|user_settings()}
        {if $userSetting.user_id}
        <tr>
            <td>
                {if $userSetting.is_enabled|not()}<span style="text-decoration: line-through">{/if}
                    <a href="{$moderator.url_alias|ezurl(no)}">{$moderator.name|wash()}</a>
                    {if $userSetting.is_enabled|not()}</span>{/if}
            </td>
            <td width="1">

            </td>
            <td>
                {foreach $moderator.object.available_languages as $language}
                    {foreach $locales as $locale}
                        {if $locale.locale_code|eq($language)}
                            <img src="{$locale.locale_code|flag_icon()}" />
                        {/if}
                    {/foreach}
                {/foreach}
            </td>
            <td width="1">
                <a href="{concat('social_user/setting/',$moderator.contentobject_id)|ezurl(no)}"><i class="fa fa-user"></i></a>
            </td>
            <td width="1">{include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$moderator redirect_if_discarded=$redirect redirect_after_publish=$redirect}</td>
            <td width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$moderator redirect_if_cancel=$redirect redirect_after_remove=$redirect}</td>
            {*<td width="1">
              {if fetch( 'user', 'has_access_to', hash( 'module', 'user', 'function', 'setting' ))}
                <form name="Setting" method="post" action={concat( 'user/setting/', $moderator.contentobject_id )|ezurl}>
                  <input type="hidden" name="is_enabled" value={if $userSetting.is_enabled|not()}"1"{else}""{/if} />
                  <button class="btn-link btn-xs" type="submit" name="UpdateSettingButton" title="{if $userSetting.is_enabled}{'Blocca'|i18n('agenda/config')}{else}{'Sblocca'|i18n('agenda/config')}{/if}">{if $userSetting.is_enabled}<i class="fa fa-ban"></i>{else}<i class="fa fa-check-circle"></i>{/if}</button>

                </form>
              {/if}
            </td>*}
        </tr>
        {/if}
        {undef $userSetting}
    {/foreach}
</table>

{include name=navigator
        uri='design:navigator/google.tpl'
        page_uri='agenda/config/moderators'
        item_count=$moderators_count
        view_parameters=$view_parameters
        item_limit=$item_limit}
