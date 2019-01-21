{def $openpa = object_handler($node)
$current_user = fetch(user, current_user)}
{include uri=$openpa.control_template.full}

{ezpagedata_set('current_main_style', $openpa.content_pagestyle.main_style)}

{def $homepage = fetch('openpa', 'homepage')}

{if $homepage.node_id|eq($node.node_id)}
  {ezpagedata_set('is_homepage', true())}
{/if}
{if $openpa.control_area_tematica.is_area_tematica}
  {ezpagedata_set('is_area_tematica', $openpa.control_area_tematica.area_tematica.contentobject_id)}
{/if}

{ezpagedata_set('current_main_style', $openpa.content_pagestyle.main_style)}

{include uri='design:parts/load_website_toolbar.tpl'}
