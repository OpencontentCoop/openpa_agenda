<section class="hgroup">
    <h1>{$node.name|wash()}</h1>
    <div class="lead">
        {attribute_view_gui attribute=$node|attribute('abstract')}
    </div>
</section>

{include uri='design:agenda/parts/calendar/views.tpl' views=array('list','geo','agenda') view_all=true()}

{include
    uri='design:agenda/parts/calendar/calendar.tpl'
    name=iniziativa_calendar
    calendar_identifier=$node.contentobject_id
    filters=array('date', 'target')
    base_query=concat('classes [event] and iniziativa.id in [', $node.contentobject_id, '] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]')
}
