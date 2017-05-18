{def $per_page = $layout.events_per_page
     $offset = 0
     $last_page_columns = $layout.columns|sub(1)
     $prefix = concat('file://', $root_dir)
     $displayed_attributes = array()}

{foreach $layout.displayed_attributes as $k => $v}
    {set $displayed_attributes = $displayed_attributes|append($k)}
{/foreach}



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="{$prefix}{'stylesheets/print-default.css'|ezdesign(no)|ezroot(no)}" />
</head>
<body class="layout-{$layout.id}">
<div id="header">
</div>
<div id="footer">
</div>

<div id="second-page" class="page-break-after">
    <table>
        <tr>
            {for 1 to $layout.columns as $counter}
                <td class="columns-{$layout.columns}">
                    <table class="table event-container">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            <tr>
                                <td>
                                    <ul class="unstyled">
                                        <li><small>
                                            {if $displayed_attributes|contains( 'periodo_svolgimento' )}
                                                {if $event.periodo_svolgimento}
                                                    {$event.periodo_svolgimento}
                                                {else}
                                                    {$event.from_time|datetime('custom', '%j %F')}
                                                    {if sub($event.to_time,$event.from_time)|gt(86399)}
                                                        - {$event.to_time|datetime('custom', '%j %F')}
                                                    {/if}
                                                {/if}
                                            {/if}

                                            {if and($event.orario_svolgimento, $displayed_attributes|contains( 'orario_svolgimento' ))}
                                                - {$event.orario_svolgimento}
                                            {/if}

                                            {if and($event.durata, $displayed_attributes|contains( 'durata' ))}
                                                - {$event.durata}
                                            {/if}
                                        </small></li>

                                        {if and($event.luogo_svolgimento, $displayed_attributes|contains( 'luogo_svolgimento' ))}
                                            <li><small>
                                                {if $event.luogo_svolgimento}
                                                    {$event.luogo_svolgimento}
                                                {/if}
                                            </small></li>
                                        {/if}

                                    </ul>


                                    <h4>{$event.name|wash()}</h4>
                                    {if and($event.abstract, $displayed_attributes|contains( 'abstract' ))}
                                        <div class="event-abstract"> {$event.abstract}</div>
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
                                    <img src="{$prefix}/{$event.qrcode_file_url}" alt="" height="80px"/>
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
                <td class="columns-{$layout.columns}">
                    <table class="table event-container">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            <tr>
                                <td>
                                    <ul class="unstyled">
                                        <li><small>
                                            {if $displayed_attributes|contains( 'periodo_svolgimento' )}
                                                {if $event.periodo_svolgimento}
                                                    {$event.periodo_svolgimento}
                                                {else}
                                                    {$event.from_time|datetime('custom', '%j %F')}
                                                    {if sub($event.to_time,$event.from_time)|gt(86399)}
                                                        - {$event.to_time|datetime('custom', '%j %F')}
                                                    {/if}
                                                {/if}
                                            {/if}

                                            {if and($event.orario_svolgimento, $displayed_attributes|contains( 'orario_svolgimento' ))}
                                                - {$event.orario_svolgimento}
                                            {/if}

                                            {if and($event.durata, $displayed_attributes|contains( 'durata' ))}
                                                - {$event.durata}
                                            {/if}
                                        </small></li>

                                        {if and($event.luogo_svolgimento, $displayed_attributes|contains( 'luogo_svolgimento' ))}
                                            <li><small>
                                                {if $event.luogo_svolgimento}
                                                    {$event.luogo_svolgimento}
                                                {/if}
                                            </small></li>
                                        {/if}

                                    </ul>


                                    <h4>{$event.name|wash()}</h4>
                                    {if and($event.abstract, $displayed_attributes|contains( 'abstract' ))}
                                        <div class="event-abstract"> {$event.abstract}</div>
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
                                    <img src="{$prefix}/{$event.qrcode_file_url}" alt="" height="80px"/>
                                </td>

                            </tr>
                        {/foreach}
                    </table>
                </td>
                {set $offset = $offset|sum($per_page)}
            {/for}
            <td class="columns-{$layout.columns} text-center">
                <div id="copertina">
                  <h1 class="title">{$programma_eventi.object.data_map.title.content}</h1>
                  <hr />
                  <h3 class="subtitle">{$programma_eventi.object.data_map.subtitle.content}</h3>
                  {attribute_view_gui attribute=$programma_eventi.object.data_map.description}
                  <br />
                  <br />
                  <img src="{$prefix}{$root_node.data_map.logo.content.medium.url|ezroot(no)}" alt="" />
                  <br />
                  <br />
                  <div class="contacts">
                    {attribute_view_gui attribute=$root_node.data_map.contacts}
                  </div>
                </div>
            </td>
        </tr>
    </table>
</div>

<!--DEBUG_REPORT-->
</body>
</html>
