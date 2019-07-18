<aside class="agenda-views">
    <ul class="nav nav-pills">
        {if $views|contains('list')}
        <li class="active">
            <a data-toggle="tab" href="#list">
                <i class="fa fa-th fa-2x" aria-hidden="true"></i> <span class="sr-only"> {'List'|i18n('agenda')}</span>
            </a>
        </li>
        {/if}
        {if $views|contains('geo')}
        <li>
            <a data-toggle="tab" href="#geo">
                <i class="fa fa-map fa-2x" aria-hidden="true"></i> <span class="sr-only">{'On the map'|i18n('agenda')}</span>
            </a>
        </li>
        {/if}
        {if $views|contains('agenda')}
        <li class="hidden-xs">
            <a data-toggle="tab" href="#agenda">
                <i class="fa fa-calendar fa-2x" aria-hidden="true"></i> <span class="sr-only">{'Calendar'|i18n('agenda')}</span>
            </a>
        </li>
        {/if}
    </ul>
</aside>
