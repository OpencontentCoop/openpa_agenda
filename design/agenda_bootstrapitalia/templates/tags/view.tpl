{ezpagedata_set( 'has_container', true() )}

<h1>{$tag.keyword|wash}</h1>


{def $agenda_query_custom = concat(' (raw[ezf_df_tag_ids] = ', $tag.id, ')')}

<div class=" p-0">
    <div class="section-content">
        {include
            uri='design:parts/agenda.tpl'
            views=array('grid','geo','agenda')
            base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] and ', $agenda_query_custom)
            style='py-3'
        }
        {include uri='design:parts/views.tpl' views=array('grid','geo','agenda') view_style='py-3'}
    </div>
</div>
