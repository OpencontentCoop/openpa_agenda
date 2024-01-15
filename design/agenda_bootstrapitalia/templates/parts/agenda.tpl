<div class="agenda-calendar {if is_set($style)}{$style}{/if}">

    {include uri='design:parts/filters_and_pills.tpl' views=$views}
    {include uri='design:parts/tpl-spinner.tpl'}
    {include uri='design:parts/tpl-empty.tpl'}
    {include uri='design:parts/tpl-grid.tpl'}
    {include uri='design:parts/tpl-list.tpl'}
    {include uri='design:parts/search-modal.tpl'}
    {include uri='design:parts/preview-modal.tpl'}
    {include uri='design:parts/js-include.tpl'}

    <script>
        $(document).ready(function () {ldelim}
            $('#searchModal').agendaSearchGui({ldelim}
                'spritePath': '{'images/svg/sprite.svg'|ezdesign(no)}',
                'allText': '{'Even past events'|i18n('agenda')}'
            {if is_set($cal_view)},'defaultCalendarView': '{$cal_view}'{/if}
            {if is_set($cal_responsive)},'responsiveCalendar': {cond($cal_responsive, 'true', 'false')}{/if}
            {if is_set($also_past)},'onInit': function (plugin) {ldelim}plugin.alsoPastCheck.attr('checked', 'checked').trigger('change');{rdelim}{/if}
            {rdelim});
        {rdelim});
    </script>

</div>
