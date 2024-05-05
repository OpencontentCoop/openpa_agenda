{set_defaults(hash('icon_style', 'fa-2x'))}
<ul class="nav nav-pills nav-fill float-lg-right">
    {foreach $views as $index => $view}
    {if $view|eq('grid')}
        <li class="nav-item mr-3">
            <a data-toggle="tab"
               class="nav-link {if $index|eq(0)}active {/if}rounded-0 agenda-view-selector"
               href="#grid">
                <i class="fa fa-th {$icon_style}" aria-hidden="true"></i> <span
                    class="sr-only"> {'List'|i18n('agenda')}</span>
            </a>
        </li>
    {elseif $view|eq('list')}
        <li class="nav-item mr-3">
            <a data-toggle="tab"
               class="nav-link {if $index|eq(0)}active {/if}rounded-0 agenda-view-selector"
               href="#list">
                <i class="fa fa-list {$icon_style}" aria-hidden="true"></i> <span
                    class="sr-only"> {'List'|i18n('agenda')}</span>
            </a>
        </li>
    {elseif $view|eq('geo')}
        <li class="nav-item mr-3">
            <a data-toggle="tab"
               class="nav-link {if $index|eq(0)}active {/if}rounded-0 agenda-view-selector"
               href="#geo">
                <i class="fa fa-map {$icon_style}" aria-hidden="true"></i> <span
                    class="sr-only">{'On the map'|i18n('agenda')}</span>
            </a>
        </li>
    {elseif $view|eq('agenda')}
        <li class="nav-item mr-3">
            <a data-toggle="tab"
               class="nav-link {if $index|eq(0)}active {/if}rounded-0 agenda-view-selector"
               href="#agenda">
                <i class="fa fa-calendar {$icon_style}" aria-hidden="true"></i> <span
                    class="sr-only">{'Calendar'|i18n('agenda')}</span>
            </a>
        </li>
    {/if}
    {/foreach}
</ul>
{unset_defaults(array('icon_style'))}
