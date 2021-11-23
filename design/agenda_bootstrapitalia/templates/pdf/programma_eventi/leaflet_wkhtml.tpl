{def $per_page = $layout.events_per_page
$offset = 0
$displayed_attributes = array()
$events = $programma_eventi.events
$count_events = count($events)}

{foreach $layout.displayed_attributes as $k => $v}
    {set $displayed_attributes = $displayed_attributes|append($k)}
{/foreach}


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link href="https://fonts.googleapis.com/css2?family=Titillium+Web:ital,wght@0,300;0,400;0,600;0,700;1,200;1,400;1,600&display=swap" rel="stylesheet">
    {include uri="design:pdf/programma_eventi/style.tpl"}
</head>
<body class="A4">
<div id="header"></div>
<div id="footer"></div>


<table>
    <tr>
        <td>
            <img src="{$root_node.data_map.logo.content.medium.url|base64_image_data()}" alt=""/>
        </td>
        <td>
            <p><small>{social_pagedata().logo_title|wash()} - {$root_node.url|ezurl(no, full)}</small></p>
            <h1>{$programma_eventi.object.data_map.title.content}</h1>
            <h2>{$programma_eventi.object.data_map.subtitle.content}</h2>
            {attribute_view_gui attribute=$programma_eventi.object.data_map.description}
        </td>
    </tr>
</table>

{foreach $events as $event}
    {def $recurrences = $event.object|attribute('time_interval').content.events}
    {def $is_recurrence = cond(count($recurrences)|gt(1), true(), false())}
    {def $first_event_start = recurrences_strtotime($recurrences[0].start)}
    {def $first_event_end = recurrences_strtotime($recurrences[0].end)}
    <table class="p-all">
        <tr>
            <td style="vertical-align: top;padding-right: 10pt;position: relative;{if $programma_eventi.show_qrcode}height:170px{/if}">
                <div class="calendar">
                    <span class="date">
                        {$first_event_start|datetime( 'custom', '%j' )}
                    </span>
                    <span>{$first_event_start|datetime( 'custom', '%F' )}</span>
                </div>
                {if $programma_eventi.show_qrcode}
                    <div style="position: absolute;bottom: 0">
                        <img width="80" height="80" src="{$event.qrcode_base64_src}" alt=""/>
                    </div>
                {/if}
            </td>
            <td style="vertical-align: top">
                <h3>{$event.object.name|wash()}</h3>
                {if $event.object|has_attribute('short_event_title')}
                    <h4>{attribute_view_gui attribute=$event.object|attribute('short_event_title')}</h4>
                {/if}
                {if $event.luogo_svolgimento}
                    <p>
                        {include uri="design:pdf/programma_eventi/marker-icon.tpl"} {$event.luogo_svolgimento|wash()}
                    </p>
                {/if}
                <p>
                    {include uri="design:pdf/programma_eventi/clock-icon.tpl"}
                    {if $first_event_start|datetime( 'custom', '%j%F' )|eq($first_event_end|datetime( 'custom', '%j%F' ))}
                        {$first_event_start|datetime( 'custom', '%H:%i' )} - {$first_event_end|datetime( 'custom', '%H:%i' )}
                    {else}
                        {$first_event_start|datetime( 'custom', '%j %F %H:%i' )} - {$first_event_end|datetime( 'custom', '%j %F %H:%i' )}
                    {/if}
                    {if $event.periodo_svolgimento}&middot; {$event.periodo_svolgimento|wash()}{/if}
                </p>
                {if $event.object|has_attribute('target_audience')}
                    <p> {include uri="design:pdf/programma_eventi/tag-icon.tpl"}
                        {foreach $event.object|attribute('target_audience').content.tags as $tag}
                            {$tag.keyword|wash}
                        {/foreach}
                    </p>
                {/if}
                {if $event.object|has_attribute('event_abstract')}
                    {attribute_view_gui attribute=$event.object|attribute('event_abstract')}
                {/if}
            </td>
        </tr>
    </table>
    {undef $recurrences $is_recurrence $first_event_start $first_event_end}
{/foreach}

<!--DEBUG_REPORT-->
</body>
</html>
