{def $calendar_filters = array()
     $calendar_views = array()
     $calendar_types = $node|attribute('calendar_types').content.tag_ids}
{foreach $node|attribute('calendar_views').class_content.options as $option}
    {if $node|attribute('calendar_views').content|contains( $option.id )}
        {set $calendar_views = $calendar_views|append($option.name)}
    {/if}
{/foreach}

{foreach $node|attribute('calendar_filters').class_content.options as $option}
    {if $node|attribute('calendar_filters').content|contains( $option.id )}
        {set $calendar_filters = $calendar_filters|append($option.name)}
    {/if}
{/foreach}

<section class="hgroup">
    <h1>{$node.name|wash()}</h1>
    <div class="lead">
        {attribute_view_gui attribute=$node|attribute('abstract')}
    </div>
</section>

{include uri='design:agenda/parts/calendar/views.tpl' views=$calendar_views}

{include
    uri='design:agenda/parts/calendar/calendar.tpl'
    name=agenda_calendar
    calendar_identifier=$node.contentobject_id
    filters=$calendar_filters
    base_query=concat("classes [",agenda_event_class_identifier(),"] and tipo_evento.tag_ids in ['", $calendar_types|implode("','"), "'] and subtree [", calendar_node_id(), "] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]")
}
