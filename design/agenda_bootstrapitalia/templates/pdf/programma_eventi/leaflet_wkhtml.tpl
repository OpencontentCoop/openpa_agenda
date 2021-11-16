{def $per_page = $layout.events_per_page
     $offset = 0
     $last_page_columns = $layout.columns|sub(1)
     $displayed_attributes = array()}

{foreach $layout.displayed_attributes as $k => $v}
    {set $displayed_attributes = $displayed_attributes|append($k)}
{/foreach}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    {include uri="design:pdf/programma_eventi/style.tpl"}
</head>
<body class="flyer-body layout-{$layout.id}">
<div id="second-page" class="page-break-after">
    <table>
        <tr>
            {for 1 to $layout.columns as $counter}
                <td class="columns-{$layout.columns}">
                    <table class="table event-container" style="height:100%">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            {include uri="design:pdf/programma_eventi/leaflet_event_row.tpl" use_base64_src=true()}
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
                    <table class="table event-container" style="height:100%">
                        {foreach $programma_eventi.events as $event max $per_page offset $offset}
                            {include uri="design:pdf/programma_eventi/leaflet_event_row.tpl" use_base64_src=true()}
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
                  <img src="{$logo_base64_src}{$root_node.data_map.logo.content.medium.url|ezroot(no)}" alt="" />
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
