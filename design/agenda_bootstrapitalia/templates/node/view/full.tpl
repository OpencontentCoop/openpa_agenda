{def $openpa = object_handler($node)}
{include uri=$openpa.control_template.full}

{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{if and(fetch( 'user', 'has_access_to', hash( 'module', 'websitetoolbar', 'function', 'use' ) ), module_params().function_name|ne('versionview'))}
    {include uri='design:parts/load_website_toolbar.tpl' current_user=fetch(user, current_user)}
{/if}

{def $homepage = fetch('openpa', 'homepage')}
{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{undef $openpa}
