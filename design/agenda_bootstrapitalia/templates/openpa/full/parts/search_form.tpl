<form class="mb-5" action="{'content/search'|ezurl(no)}" method="get">
    <div class="form-group floating-labels">
        <div class="form-label-group">
            <input type="text"
                   class="form-control"
                   id="search-text"
                   name="SearchText"
                   placeholder="{'Search in'|i18n('agenda')} {$current_node.name|wash()}"
                   aria-invalid="false"/>
            <label class="" for="search-text">
                {'Search in'|i18n('agenda')} {$current_node.name|wash()}
            </label>
            <button type="submit" class="autocomplete-icon btn btn-link">
                {display_icon('it-search', 'svg', 'icon')}
            </button>
            <input type="hidden"
                   name="Subtree[]"
                   value="{$current_node.node_id}" />
        </div>
    </div>
</form>
