{ezpagedata_set( 'has_container', true() )}
{def $root_node = agenda_root_node()}
<section class="container">
    <div class="row">
        <div class="col px-lg-4 py-lg-2" style="min-height: 200px">

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

            {def $hide_collections = cond($root_node|has_attribute('main_calendar_hide_collections'), $root_node|attribute('main_calendar_hide_collections').data_int, false())}
            {if $hide_collections}
                {set $agenda_query_custom = $agenda_query_custom|append('raw[extra_event_collection_i] = 0')}
            {/if}
            {def $view = 'dayGridWeek'
                 $views = array()}
            {if $root_node|has_attribute('main_calendar_agenda_view')}
                {foreach $root_node|attribute('main_calendar_agenda_view').class_content.options as $option}
                    {if $root_node|attribute('main_calendar_agenda_view').content|contains($option.id)}
                        {set $view = $option.name}
                    {/if}
                {/foreach}
            {/if}
            {if $root_node|has_attribute('main_calendar_views')}
                {foreach $root_node|attribute('main_calendar_views').class_content.options as $option}
                    {if $root_node|attribute('main_calendar_views').content|contains($option.id)}
                        {set $views = $views|append($option.name)}
                    {/if}
                {/foreach}
            {/if}
            {if or(count($views)|eq(0), $views[0]|eq('default'))}
                {set $views = array('grid','geo','agenda')}
            {/if}

            {include
                uri='design:parts/agenda.tpl'
                add_time_buttons=true()
                views=$views
                cal_view=$view
                base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] ', cond($agenda_query_custom|count()|gt(0), ' and ', false()), $agenda_query_custom|implode(' and '))
            }

        </div>
    </div>
</section>


{include uri='design:parts/views.tpl' views=$views}
