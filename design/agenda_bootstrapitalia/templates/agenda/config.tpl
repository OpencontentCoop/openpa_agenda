{def $locales = fetch( 'content', 'translation_list' )}
{def $class_identifiers = array()}
{def $parent_node_id = false()}
{def $extra_buttons = array()}
{def $request_url = false()}
{def $is_user = false()}
{def $state_toggle = false()}
<section class="hgroup">
    <h1>{'Settings'|i18n('agenda/menu')}</h1>
</section>

{set $data = $data|append(fetch(content, node, hash(node_id, 51)))}

<div class="row">
    <div class="col-md-12">
        <div class="row mt-5">
            <div class="col-md-2">
                <ul class="nav nav-pills">
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $index|eq('')} active{/if}"
                            href="{'agenda/config'|ezurl(no)}">{'Settings'|i18n('agenda/config')}</a></li>
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $index|eq('moderators')} active{/if}"
                            href="{'agenda/config/moderators'|ezurl(no)}">{'Moderators'|i18n('agenda/config')}</a></li>
                    {if is_registration_enabled()}
                        <li role="presentation" class="nav-item w-100"><a
                                class="text-decoration-none nav-link{if $index|eq('users')} active{/if}"
                                href="{'agenda/config/users'|ezurl(no)}">{'Users'|i18n('agenda/config')}</a></li>
                    {/if}
                    {if openpaini('OpenpaAgenda', 'UseExternalUsers', 'enabled')|eq('enabled')}
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $index|eq('external_users')} active{/if}"
                            href="{'agenda/config/external_users'|ezurl(no)}">{'External Users'|i18n('agenda/config')}</a></li>
                    {/if}
                    {if $data|count()|gt(0)}
                        {foreach $data as $item}
                            {if $item.object.remote_id|eq(concat(openpa_instance_identifier(),'_openpa_agenda_stuff'))}{skip}{/if}
                            <li role="presentation" class="nav-item w-100"><a
                                    class="text-decoration-none nav-link{if $index|eq(concat('data-',$item.contentobject_id))} active{/if}"
                                    href="{concat('agenda/config/data-',$item.contentobject_id)|ezurl(no)}">{$item.name|wash()}</a></li>
                        {/foreach}
                    {/if}
                </ul>
            </div>

            <div class="col-md-10">
                <div class="tab-pane active" id="page-{$index}">
                    {if $index|eq('')}
                        {include uri='design:agenda/config/main.tpl'}
                    {else}
                        {include uri='design:agenda/config/part.tpl'}
                    {/if}
                </div>
            </div>

        </div>
    </div>
</div>
