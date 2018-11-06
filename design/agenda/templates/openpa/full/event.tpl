{include uri='design:agenda/event.tpl' node=$node comment_form=false() current_reply=false()}
{if $node|has_attribute('json_ld')}
{attribute_view_gui attribute=$node|attribute('json_ld')}
{/if}