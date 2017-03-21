{if is_set($view_all)|not()}
    {def $view_all = false()}
{/if}
<div class="row">
    <div class="col-sm-9">
        {include uri='design:agenda/parts/calendar/view_tabs.tpl' views=$views}
    </div>
    <div class="col-sm-3">
        {include uri='design:agenda/parts/calendar/view_pills.tpl' views=$views}
        {include uri='design:agenda/parts/calendar/filters.tpl' view_all=$view_all}
    </div>
</div>
