{set-block scope=root variable=cache_ttl}86400{/set-block}
<div class="point-list-wrapper my-4">

    {def $events = $attribute.content.events}

    {if count($events)|gt(10)}
        <p class="text-serif">{"L'evento si svolge"|i18n('bootstrapitalia')} dal {recurrences_strtotime($events[0].start)|datetime( 'custom', '%j %F %Y' )|downcase}, {$attribute.content.text|wash()} </p>
        {set $events = recurrences_next_events($events, 5)}
        {if count($events)|gt(0)}
            <p class="text-serif">{"I prossimi appuntamenti previsti sono:"|i18n('bootstrapitalia')}</p>
        {/if}
    {/if}

    {foreach $events as $event}

        {if recurrences_strtotime($event.start)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($event.end)|datetime( 'custom', '%j%m%Y' ))}

            <div class="point-list">
                <div class="point-list-aside point-list-warning">
                    <div class="point-date text-monospace">{recurrences_strtotime($event.start)|datetime( 'custom', '%d' )}</div>
                    <div class="point-month text-monospace">{recurrences_strtotime($event.start)|datetime( 'custom', '%M' )}</div>
                </div>
                <div class="point-list-content">
                    <div class="card card-teaser shadow p-4 rounded border">
                        <div class="card-body">
                            <h5 class="card-title">
                                {"Event start"|i18n('bootstrapitalia')} {recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )}
                            </h5>
                        </div>
                    </div>
                </div>
            </div>

            <div class="point-list">
                <div class="point-list-aside point-list-warning">
                    <div class="point-date text-monospace">{recurrences_strtotime($event.end)|datetime( 'custom', '%d' )}</div>
                    <div class="point-month text-monospace">{recurrences_strtotime($event.end)|datetime( 'custom', '%M' )}</div>
                </div>
                <div class="point-list-content">
                    <div class="card card-teaser shadow p-4 rounded border">
                        <div class="card-body">
                            <h5 class="card-title">
                                {"Event end"|i18n('bootstrapitalia')} {recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' )}
                            </h5>
                        </div>
                    </div>
                </div>
            </div>

        {else}

            <div class="point-list">
                <div class="point-list-aside point-list-warning">
                    <div class="point-date text-monospace">{recurrences_strtotime($event.start)|datetime( 'custom', '%d' )}</div>
                    <div class="point-month text-monospace">{recurrences_strtotime($event.start)|datetime( 'custom', '%M' )}</div>
                </div>
                <div class="point-list-content">
                    <div class="card card-teaser shadow p-4 rounded border">
                        <div class="card-body">
                            <h5 class="card-title">
                                {"Event start"|i18n('bootstrapitalia')} {recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )}
                                {if recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )|ne(recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' ))}
                                     - {"Event end"|i18n('bootstrapitalia')} {recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' )}
                                {/if}
                            </h5>
                        </div>
                    </div>
                </div>
            </div>

        {/if}
    {/foreach}
    {undef $events}

    {if fetch( 'content', 'reverse_related_objects_count', hash( 'object_id', $attribute.contentobject_id, 'attribute_identifier', 'event/sub_event_of' ) )|gt(0)}
    {include
        uri='design:parts/agenda.tpl'
        exclude=array('what')
        views=array('grid','geo','agenda')
        base_query=concat("classes [",agenda_event_class_identifier(),"] and sub_event_of.id = ", $attribute.contentobject_id, " and subtree [", calendar_node_id(), "] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc]")
        grid_view='mini'
        also_past=true()
        cal_view='listWeek'
        cal_responsive=false()
        icon_style=''
        style='pb-4'}
    {include uri='design:parts/views.tpl' views=array('grid','geo','agenda') view_style='pb-4'}
    {/if}
</div>
