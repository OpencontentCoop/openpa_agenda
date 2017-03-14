<section class="hgroup noborder home-agenda">

    {include uri='design:agenda/parts/home_layout.tpl'}

    {include uri='design:agenda/parts/calendar/views.tpl' views=array('list','geo','agenda')}

</section>

{include
    uri='design:agenda/parts/calendar/calendar.tpl'
    name=home_calendar
    calendar_identifier=$site_identifier
    filters=array('date', 'type', 'target', 'iniziativa')
    base_query=concat('classes [event] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]')
}
