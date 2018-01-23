<section class="hgroup">
    <h1>{$tag.keyword|wash}</h1>
</section>

{include uri='design:agenda/parts/calendar/views.tpl' views=array('list')}

{include
    uri='design:agenda/parts/calendar/calendar.tpl'
    name=agenda_calendar
    calendar_identifier=$tag.id
    filters=array('date')
    base_query=concat("classes [",agenda_event_class_identifier(),"] and tipo_evento.tag_ids = ",$tag.id," and subtree [", calendar_node_id(), "] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]")
}
