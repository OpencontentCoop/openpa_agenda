{def $calendar = $block.valid_nodes[0]
     $image = false()}

{if $calendar|has_attribute( 'images' )}
    {set $image = fetch(content,object,hash(object_id, $calendar|attribute('images').content.relation_list[0].contentobject_id)).data_map.image.content}
{elseif $calendar|has_attribute( 'image' )}
    {set $image = $calendar|attribute('image').content}
{/if}

<div class="service_teaser vertical agenda-block"
     style="{if $image}background-image: url('{$image['large'].url|ezroot(no)}');background-size: cover;background-repeat: no-repeat;background-position: center{else}background:#fff{/if}">
    <div class="service_details">
        <h2 class="section_header skincolored" style="">
            <a href="{concat('agenda/event/',$calendar.object.main_node_id)|ezurl(no)}"><b>{$calendar.name|wash()}</b></a>
            {if $calendar|has_attribute( 'abstract' )}
                <small>{attribute_view_gui attribute=$calendar|attribute('abstract')}</small>
            {/if}
        </h2>
    </div>
</div>
{undef $calendar $image}
