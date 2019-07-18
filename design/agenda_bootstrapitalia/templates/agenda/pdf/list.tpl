<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="{'stylesheets/openpa_agenda_pdf.css'|ezdesign(no)|ezroot(no,full)}" />
</head>
<body>
<div id="header">
</div>
<div id="footer">
</div>
<div id="content">

    <h1>{$start.start|datetime('custom','%F')} {$start.start|datetime('custom','%Y')}</h1>

    <table class="table table-striped day-container">
        <tbody>
            {foreach $events_by_day as $day_collector}
            {if count( $day_collector.events )}
                <tr>
                    <td>
                        <div class="calendar-date">
                           <span class="month">{$day_collector.day.start|datetime( 'custom', '%l' )}</span>
                           <span class="day">{$day_collector.day.start|datetime( 'custom', '%j' )}</span>
                       </div>
                    </td>
                    <td>
                        <table class="table event-container">

                               {foreach $day_collector.events as $event}
                                <tr>



                                    <td>
                                        <ul class="unstyled">
                                            <li>
                                                {if $event.data[$language].periodo_svolgimento}
                                                    {$event.data[$language].periodo_svolgimento}
                                                {else}
                                                    {$event._start.start|datetime('custom', '%j %F')}
                                                    {if $event._start.identifier|ne($event._end.identifier)}
                                                        - {$event._end.start|datetime('custom', '%j %F')}
                                                    {/if}
                                                {/if}

                                                {if $event.data[$language].orario_svolgimento}
                                                    - {$event.data[$language].orario_svolgimento}
                                                {/if}

                                                {if $event.data[$language].durata}
                                                - {$event.data[$language].durata}
                                                {/if}

                                            </li>




                                            {if or( $event.data[$language].luogo_svolgimento, $event.data[$language].comune)}
                                                <li>
                                                    {if $event.data[$language].luogo_svolgimento}
                                                        {$event.data[$language].luogo_svolgimento}
                                                    {/if}

                                                    {if $event.data[$language].comune}
                                                        {$event.data[$language].comune}
                                                    {/if}
                                                </li>
                                            {/if}

                                        </ul>


                                        <h4>{$event.data[$language].titolo}</h4>
                                        {if $event.data[$language].abstract}
                                            {$event.data[$language].abstract}
                                        {*elseif $event.data[$language].informazioni}
                                            {$event.data[$language].informazioni*}
                                        {/if}

                                        {if $event.data[$language].associazione}
                                        <p><small>
                                            {foreach $event.data[$language].associazione as $associazione}
                                                {$associazione.name[$language]}{delimiter}, {/delimiter}
                                            {/foreach}
                                        </small></p>
                                        {/if}
                                    </td>

                                    <td width="80px">
                                        <img src="{concat('/agenda/qrcode/',$event.metadata.mainNodeId)|ezurl(no,full)}" alt="" height="80px"/>
                                    </td>

                                </tr>
                               {/foreach}

                       </table>
                    </td>
                </tr>
            {/if}
           {/foreach}
        </tbody>
    </table>

</div>
<!--DEBUG_REPORT-->
</body>
</html>