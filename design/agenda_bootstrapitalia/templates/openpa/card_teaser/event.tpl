{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false(),
    'hide_title', false()
))}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow rounded" style="display: inline-flex;flex-direction: row !important;align-items: flex-start;flex-wrap: nowrap;">
    {def $attribute_content = $node|attribute('time_interval').content}
    {def $events = $attribute_content.events}
    {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
    {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
        {set $is_recurrence = true()}
    {/if}
    {if count($events)|gt(0)}
    <div class="card-calendar d-flex flex-column justify-content-center" style="position: static;height: 80px;margin-right: 20px;min-width: 80px;">
        <span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
        <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
    </div>
    {/if}
    {undef $events $is_recurrence}

    <div class="card-body{if $node|has_attribute('image')} pr-3 pe-3{/if}">
        {if $hide_title|not()}
        <h5 class="card-title mb-1">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
        </h5>
        {/if}
        <div class="card-text">

            {if $node|has_abstract()}
                <div class="card-text">
                    <p>{$node|abstract()|oc_shorten(250)}</p>
                </div>
            {/if}

            {if $attributes.show|contains('content_show_read_more')}
            <p class="mt-3"><a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{'Further details'|i18n('bootstrapitalia')}</a></p>
            {/if}
        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $attributes $attribute_content}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}

