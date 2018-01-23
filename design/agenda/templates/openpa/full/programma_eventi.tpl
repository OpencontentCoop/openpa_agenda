<section class="hgroup">

    <h1>
        {$node.name|wash()}
    </h1>

    <p>
        <small>{$node.object.published|l10n(shortdatetime)}</small>
        {if $node.object.current_version|gt(1)}
            <small>Ultima modifica di <a
                        href={$node.object.main_node.creator.main_node.url_alias|ezurl}>{$node.object.main_node.creator.name}</a>
                il {$node.object.modified|l10n(shortdatetime)}</small>
        {/if}
    </p>
    <div class="lead">
        {attribute_view_gui attribute=$node|attribute('file')}
    </div>
</section>

{def $events_ids = array()}
{foreach $node|attribute('events').content.relation_list as $item}
    {set $events_ids = $events_ids|append($item.contentobject_id)}
{/foreach}

{include uri='design:agenda/parts/calendar/views.tpl' views=array('list','geo','agenda') view_all=true()}

{include
    uri='design:agenda/parts/calendar/calendar.tpl'
    name=iniziativa_calendar
    calendar_identifier=$node.contentobject_id
    filters=array('date', 'target')
    base_query=concat('classes [',agenda_event_class_identifier(),'] and id in [', $events_ids|implode(','), '] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]')
}
