{ezpagedata_set( 'has_container', true() )}
{def $root_node = agenda_root_node()}
<section class="container">
    <div class="row">
        <div class="col px-lg-4 py-lg-2" style="min-height: 200px">

            {include uri='design:openpa/full/parts/home-blocks.tpl'}

            {def $hide_tags = cond($root_node|has_attribute('hide_tags'), $root_node|attribute('hide_tags').content.tag_ids, array())
                 $hide_iniziative = array()}
            {if $root_node|has_attribute('hide_tags')}
                {set $hide_tags = $root_node|attribute('hide_tags').content.tag_ids}
            {/if}
            {if $root_node|has_attribute('hide_iniziative')}
                {foreach $root_node|attribute('hide_iniziative').content.relation_list as $item}
                    {set $hide_iniziative = $hide_iniziative|append($item.contentobject_id)}
                {/foreach}
            {/if}

            {def $agenda_query_custom = array()}
            {if count($hide_tags)|gt(0)}
                {foreach $hide_tags as $tag}
                    {set $agenda_query_custom = $agenda_query_custom|append(concat("tipo_evento.tag_ids != '", $tag, "'"))}
                {/foreach}
            {/if}
            {if count($hide_iniziative)|gt(0)}
                {foreach $hide_iniziative as $iniziativa}
                    {set $agenda_query_custom = $agenda_query_custom|append(concat("iniziativa.id != '", $iniziativa, "'"))}
                {/foreach}
            {/if}

            {include
                uri='design:parts/agenda.tpl'
                views=array('grid','geo','agenda')
                base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] ', cond($agenda_query_custom|count()|gt(0), ' and ', false()), $agenda_query_custom|implode(' and '))
            }

        </div>
    </div>
</section>


{include uri='design:parts/views.tpl' views=array('grid','geo','agenda')}
