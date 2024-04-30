{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false()
))}
{def $openpa = object_handler($node)}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card h-100 card-teaser {$node|access_style} p-3 position-relative overflow-hidden rounded border {$view_variation}">
    <div class="card-body{if $node|has_attribute('image')} pr-3 pe-3{/if}">
        {if $openpa.content_icon.class_icon}
            <div class="etichetta mb-2">
                {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$node.class_name}
            </div>
        {/if}

        {if $node|has_attribute('time_interval')}
            {def $attribute_content = $node|attribute('time_interval').content}
            {def $events = $attribute_content.events}
            {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
            {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
                {set $is_recurrence = true()}
            {/if}
            <p class="h6 mb-0 font-weight-normal">
                <a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{$node.name|wash()}</a>
            </p>
            {if count($events)|gt(0)}
                <small class="d-block mb-3">{if $is_recurrence}{'from'|i18n('openpa/search')} {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j %F %Y' )}</small>
            {/if}
            {undef $attribute_content $events $is_recurrence}
        {else}
            <p class="mb-3 h6 font-weight-normal">
                <a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{$node.name|wash()}</a>
            </p>
        {/if}
        <div class="card-text">
            <p>{$node|abstract()oc_shorten(400)|wash()}
        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $openpa $attributes}
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
