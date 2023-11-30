{set_defaults(hash('show_icon', true(), 'image_class', 'large', 'view_variation', 'big'))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{def $has_media = false()}
{foreach class_extra_parameters($node.object.class_identifier, 'table_view').main_image as $identifier}
    {if and($node|has_attribute($identifier), or($node|attribute($identifier).data_type_string|eq('ezimage'), $identifier|eq('image')))}
        {set $has_media = true()}
        {break}
    {/if}
{/foreach}


<div data-object_id="{$node.contentobject_id}" class="card-wrapper card-space">
    <div class="card {if $has_media} card-img{/if} card-bg {if $has_media|not()}card-big{/if} rounded shadow">

    {include uri='design:openpa/card/parts/image.tpl' view_variation='big'}

    <div class="card-body">
        <h5 class="card-title{if and($has_media|not(), $view_variation|eq('big')|not())} big-heading{/if}">
            {if and($show_icon, $has_media|not(), $node|has_attribute('time_interval'), $node.class_identifier|contains('event'))}
                {def $events = $node|attribute('time_interval').content.events}
                {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                {if count($events)|gt(0)}
                    <div class="card-calendar d-flex flex-column justify-content-center" style="font-size: 0.67em;height: 80px;position: relative;float: right;right: -20px;top: -35px;">
                        <span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                        <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                    </div>
                {/if}
                {undef $events $is_recurrence}
            {/if}
            <a class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
            {include uri='design:parts/card_title_suffix.tpl'}
        </h5>
        {if $node|has_abstract()}
            <div class="card-text">
                <p>{$node|abstract()|oc_shorten(250)}</p>
            </div>
        {/if}
        <a class="read-more" href="{$openpa.content_link.full_link}#page-content">
            <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>
    </div>

    </div>
</div>

{undef $has_image $has_video}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}


