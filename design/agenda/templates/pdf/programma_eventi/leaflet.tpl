{def $per_page = $programma_eventi.events_per_page
     $offset = 0
     $last_page_columns = $columns|sub(1)}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="{'stylesheets/print-default.css'|ezdesign(no)|ezroot(no,full)}" />
</head>
<body>
<div id="header">
</div>
<div id="footer">
</div>

<div id="second-page" class="page-break-after">
    <table>
        <tr>
            {for 1 to $columns as $counter}
                <td class="columns-{$columns}">
                    <table class="table event-container">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            <tr>
                                <td>
                                    <ul class="unstyled">
                                        <li>
                                            {if $event.periodo_svolgimento}
                                                {$event.periodo_svolgimento}
                                            {else}
                                                {$event.from_time|datetime('custom', '%j %F')}
                                                {if $event.from_time|ne($event.to_time)}
                                                    - {$event.to_time|datetime('custom', '%j %F')}
                                                {/if}
                                            {/if}

                                            {if $event.orario_svolgimento}
                                                - {$event.orario_svolgimento}
                                            {/if}

                                            {if $event.durata}
                                                - {$event.durata}
                                            {/if}
                                        </li>

                                        {if $event.luogo_svolgimento}
                                            <li>
                                                {if $event.luogo_svolgimento}
                                                    {$event.luogo_svolgimento}
                                                {/if}
                                            </li>
                                        {/if}

                                    </ul>


                                    <h4>{$event.name}</h4>
                                    {if $event.abstract}
                                        {$event.abstract}
                                    {/if}

                                    {*if $event.associazione}
                                        <p>
                                            <small>
                                                {foreach $event.associazione.relation_list as $associazione}
                                                    {$associazione.name[$language]}{delimiter}, {/delimiter}
                                                {/foreach}
                                            </small>
                                        </p>
                                    {/if*}
                                </td>

                                <td width="80px">
                                    <img src="{concat('/agenda/qrcode/',$event.main_node_id)|ezurl(no,full)}" alt="" height="80px"/>
                                </td>

                            </tr>
                        {/foreach}
                    </table>
                </td>
                {set $offset = $offset|sum($per_page)}
            {/for}
        </tr>
    </table>
</div>

<div id="first-page">
    <table>
        <tr>
            {for 1 to $last_page_columns as $counter}
                <td class="columns-{$columns}">
                    <table class="table event-container">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            <tr>
                                <td>
                                    <ul class="unstyled">
                                        <li>
                                            {if $event.periodo_svolgimento}
                                                {$event.periodo_svolgimento}
                                            {else}
                                                {$event.from_time|datetime('custom', '%j %F')}
                                                {if $event.from_time|ne($event.to_time)}
                                                    - {$event.to_time|datetime('custom', '%j %F')}
                                                {/if}
                                            {/if}

                                            {if $event.orario_svolgimento}
                                                - {$event.orario_svolgimento}
                                            {/if}

                                            {if $event.durata}
                                                - {$event.durata}
                                            {/if}
                                        </li>

                                        {if $event.luogo_svolgimento}
                                            <li>
                                                {if $event.luogo_svolgimento}
                                                    {$event.luogo_svolgimento}
                                                {/if}
                                            </li>
                                        {/if}

                                    </ul>


                                    <h4>{$event.name}</h4>
                                    {if $event.abstract}
                                        {$event.abstract}
                                    {/if}

                                    {*if $event.associazione}
                                        <p>
                                            <small>
                                                {foreach $event.associazione.relation_list as $associazione}
                                                    {$associazione.name[$language]}{delimiter}, {/delimiter}
                                                {/foreach}
                                            </small>
                                        </p>
                                    {/if*}
                                </td>

                                <td width="80px">
                                    <img src="{concat('/agenda/qrcode/',$event.main_node_id)|ezurl(no,full)}" alt="" height="80px"/>
                                </td>

                            </tr>
                        {/foreach}
                    </table>
                </td>
                {set $offset = $offset|sum($per_page)}
            {/for}
            <td class="col50 text-center">
                <h1>{$programma_eventi.object.data_map.title.content}</h1>
                <hr />
                <h3>{$programma_eventi.object.data_map.subtitle.content}</h3>
                {attribute_view_gui attribute=$programma_eventi.object.data_map.description}
                <br />
                <br />
                {attribute_view_gui attribute=$root_node.data_map.logo image_class=medium}
                <br />
                <br />
                {attribute_view_gui attribute=$root_node.data_map.contacts}
            </td>
        </tr>
    </table>
</div>

<!--DEBUG_REPORT-->
</body>
</html>