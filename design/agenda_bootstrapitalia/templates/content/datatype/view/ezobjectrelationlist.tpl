{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false(),
    'context_class', false()
))}

{def $node_list = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}
    {if $relation_view|eq('list')}
        {include uri='design:atoms/list_with_icon.tpl' items=$node_list}
    {else}
        {if or($attribute.contentclass_attribute_identifier|eq('sub_event_of'), $relation_has_wrapper)|not()}
            <div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
        {/if}
{*        {def $hide_title = cond(and(count($node_list)|eq(1), openpaini('HideRelationsTitle', 'AttributeIdentifiers', array())|contains($attribute.contentclass_attribute_identifier)), true(), false())}*}
        {def $hide_title = false()}
        {foreach $node_list as $child}
            {node_view_gui content_node=$child view=card_teaser show_icon=true() hide_title=$hide_title image_class=widemedium}
        {/foreach}
        {undef $hide_title}
        {if or($attribute.contentclass_attribute_identifier|eq('sub_event_of'), $relation_has_wrapper)|not()}
            </div>
        {/if}
    {/if}

{/if}

{undef $node_list}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}
