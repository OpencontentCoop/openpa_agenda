{set_defaults(hash('use_search_text', false()))}
<form action="{'content/search'|ezurl(no)}" method="get">
    <div class="search-form-filters">
        <a href="#" class="chip chip-lg selected no-minwith" data-all="all">
            <span class="chip-label">{'All'|i18n('agenda')}</span>
        </a>
        {if $use_search_text}
            <a class="search-query chip chip-lg no-minwith align-top">
                <input class="chip-label" name="q" placeholder="{'Search'|i18n('agenda')}" style="width: 150px;background: none;border: none;height: auto;transform: none;" />
                {display_icon('it-search', 'svg', 'icon filter-remove icon-sm start-search')}
                {display_icon('it-close', 'svg', 'hide icon filter-remove reset-search')}
            </a>
        {/if}
        <a href="#"
           class="btn btn-outline-primary btn-icon btn-xs align-top ml-1 mt-1"
           id="toggleSearch">
            {display_icon('it-plus', 'svg', 'icon icon-primary mr-1')} {'Add filter'|i18n('agenda')}
        </a>
    </div>
</form>
{unset_defaults(array('use_search_text'))}
