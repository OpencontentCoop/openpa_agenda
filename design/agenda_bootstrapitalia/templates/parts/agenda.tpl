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
        {literal}
        $(document).ready(function () {
            $('#searchModal').agendaSearchGui({
                'spritePath': '{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}',
                'allText': '{/literal}{'Even past events'|i18n('agenda')}{literal}'
            });
        });
        {/literal}
    </script>

</div>
