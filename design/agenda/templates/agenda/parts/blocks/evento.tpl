{def $event = fetch(content, node, hash( node_id, $block.custom_attributes.node))
     $image = false()}

{if $event|has_attribute( 'images' )}
    {set $image = fetch(content,object,hash(object_id, $event|attribute('images').content.relation_list[0].contentobject_id)).data_map.image.content}
{elseif $event|has_attribute( 'image' )}
    {set $image = $event|attribute('image').content}
{/if}

<div class="service_teaser vertical agenda-block" style="{if $image}background-image: url('{$image['large'].url|ezroot(no)}');background-size: contain;background-repeat: no-repeat;background-position: center{else}background:#fff{/if}">
    <div class="service_details">
        <h2 class="section_header skincolored" style="">
            <a href="{concat('agenda/event/',$event.object.main_node_id)|ezurl(no)}"><b>{$event.name|wash()}</b></a>
            {if $event|has_attribute( 'from_time' )}
            <small>
                <i class="fa fa-calendar-o"></i>
                {include uri='design:atoms/dates.tpl' item=$event show_time=cond($event|has_attribute( 'orario_svolgimento' ),false(),true())}
            </small>
            {/if}
            {if $block.custom_attributes.text|ne('')}
                <small>{$block.custom_attributes.text|wash()}</small>
            {/if}
        </h2>
    </div>
</div>
{undef $event $image}
