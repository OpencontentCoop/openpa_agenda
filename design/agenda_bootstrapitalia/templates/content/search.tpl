{def $params = parse_search_get_params()}

{set $page_limit = 20}
{def $filters = $params._search_hash.filter|merge(array(concat('meta_object_states_si:',visibility_states().public.id)))
     $search_hash = $params._search_hash|merge(
        hash(
            'offset', $view_parameters.offset,
            'limit', $page_limit,
            'class_id', array('event', 'private_organization', 'place'),
            'filter', $filters
        ))
     $search = fetch( ezfind, search, $search_hash )}

{def $classes = fetch(class, list, hash(class_filter, array('event', 'private_organization', 'place'), sort_by, array( 'name', true() )))}

<div class="row">
    <div class="col-12 mt-5 pb-4 border-bottom">
        <h2>Risultati della ricerca{if $params.text|ne('')} di <em>{$params.text|wash()}</em>{/if}</h2>
    </div>
</div>


{def $subtree_facets = $search.SearchExtras.facet_fields[0].countList
     $topic_facets = $search.SearchExtras.facet_fields[1].countList
     $class_facets = $search.SearchExtras.facet_fields[2].countList}

<form class="mt-3 mb-5" action="{'content/search'|ezurl(no)}" method="get">

    <div class="d-block d-lg-none d-xl-none text-center">
        <a href="#categoryCollapse" role="button" class="btn btn-primary btn-lg text-uppercase collapsed" data-toggle="collapse" aria-expanded="false" aria-controls="categoryCollapse">Filtri</a>
    </div>

    <div class="row">
        <aside class="col-lg-3">
            <div class="d-lg-block d-xl-block collapse mt-5" id="categoryCollapse">

                <div class="form-group floating-labels">
                    <div class="form-label-group pr-2">
                        <input type="text"
                               class="form-control pl-0"
                               id="search-text"
                               name="SearchText"
                               value="{$params.text|wash()}"
                               placeholder="{'Search'|i18n('agenda')}"
                               aria-invalid="false"/>
                        <label class="pl-0" for="search-text">{'Search'|i18n('agenda')}</label>
                        <button type="submit" class="autocomplete-icon btn btn-link">
                            {display_icon('it-search', 'svg', 'icon')}
                        </button>
                    </div>
                </div>
                <div class="pt-4 pt-lg-0">
                    <h6 class="text-uppercase">{'Sections'|i18n('agenda')}</h6>
                    <div class="mt-4">
                    {def $subtree = array('_openpa_agenda_agenda_container')}
                    {if is_collaboration_enabled()}
                        {set $subtree = array('_openpa_agenda_agenda_container', '_openpa_agenda_associations', '_openpa_agenda_locations')}
                    {/if}
                    {foreach $subtree as $remote_suffix}
                        {def $subtree_node = fetch(content, object, hash(remote_id, concat(agenda_identifier(), $remote_suffix))).main_node}
                        <div class="form-check custom-control custom-checkbox">
                            <input name="Subtree[]" id="subtree-{$subtree_node.node_id}" value={$subtree_node.node_id} {if $params.subtree|contains($subtree_node.node_id)}checked="checked"{/if} class="custom-control-input" type="checkbox" />
                            <label class="custom-control-label" for="subtree-{$subtree_node.node_id}">{$subtree_node.name|wash()} {if is_set($subtree_facets[$id])}<small>({$subtree_facets[$id]})</small>{/if}</label>
                        </div>
                        {undef $subtree_node}
                    {/foreach}
                    </div>
                </div>

{*                {if count($classes)}*}
{*                    <div class="pt-4 pt-lg-5">*}
{*                        <h6 class="text-uppercase">{'Content type'|i18n('agenda')}</h3>*}
{*                        {foreach $classes as $class}*}
{*                            <div class="form-check custom-control custom-checkbox">*}
{*                                <input name="Class[]" id="class-{$class.id}" value={$class.id|wash()} {if $params.class|contains($class.id)}checked="checked"{/if} class="custom-control-input" type="checkbox">*}
{*                                <label class="class="custom-control-label" for="class-{$class.id}">{$class.name|wash()} {if is_set($class_facets[$class.id])}<small>({$class_facets[$class.id]})</small>{/if}</label>*}
{*                            </div>*}
{*                        {/foreach}*}
{*                    </div>*}
{*                {/if}*}

                <div class="pt-4 pt-lg-5">
                    <button type="submit" class="btn btn-primary">
                        {'Apply filters'|i18n('agenda')}
                    </button>
                </div>

            </div>
        </aside>

        <section class="col-lg-9">
            <div class="search-results mb-4 pl-lg-5 mt-3 mt-lg-5">
                {if $search.SearchCount|gt(0)}

                    <div class="row">
                        <div class="col-md-12 col-lg-3 mb-3 text-center text-lg-left">
                            {if $search.SearchCount|eq(1)}
                                <p class="m-0 text-nowrap"><small>{'Found a result'|i18n('openpa/search')}</small></p>
                            {else}
                                <p class="m-0 text-nowrap"><small>{'Found %count results'|i18n('openpa/search',,hash('%count', $search.SearchCount))}</small></p>
                            {/if}
                        </div>
                        <div class="col-sm-12 col-md-5 col-lg-4 mb-4 text-center text-md-right">
                            <label class="d-inline-block text-black" for="Sort"><small>{'Sorting by'|i18n('openpa/search')}</small></label>
                            <select class="d-inline-block w-50 form-control form-control-sm" id="Sort" name="Sort">
                                <option {if $params.sort|eq('score')} selected="selected"{/if} value="score">{'Score'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('published')} selected="selected"{/if} value="published">{'Publication date'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('class_name')} selected="selected"{/if} value="class_name">{'Content type'|i18n('openpa/search')}</option>
                                <option {if $params.sort|eq('name')} selected="selected"{/if} value="name">{'Name'|i18n('openpa/search')}</option>
                            </select>
                        </div>
                        <div class="col-sm-12 col-md-5 col-lg-4 mb-4 text-center text-md-right">
                            <label class="d-inline-block text-black" for="Order"><small>{'Sorting'|i18n('openpa/search')}</small></label>
                            <select class="d-inline-block w-50 form-control form-control-sm" id="Order" name="Order">
                                <option {if $params.order|eq('desc')} selected="selected"{/if} value="desc">{'Descending'|i18n('openpa/search')}</option>
                                <option {if $params.order|eq('asc')} selected="selected"{/if} value="asc">{'Ascending'|i18n('openpa/search')}</option>
                            </select>
                        </div>
                        <div class="col-sm-12 col-md-2 col-lg-1 mb-4 text-center text-md-right">
                            <button type="submit" class="btn btn-primary btn-xs">
                                {'Apply'|i18n('design/standard/ezoe')}
                            </button>
                        </div>
                    </div>

                    <div class="card-wrapper card-teaser-wrapper card-teaser-embed mb-4">
                        {foreach $search.SearchResult as $child}
                            {node_view_gui content_node=$child view=search_result show_icon=true() image_class=widemedium}
                        {/foreach}
                    </div>

                    {include name=Navigator
                             uri='design:navigator/google.tpl'
                             page_uri='content/search'
                             page_uri_suffix=$params._uri_suffix
                             item_count=$search.SearchCount
                             view_parameters=$view_parameters
                             item_limit=$page_limit}
                {else}
                    <p><small>{'No results found'|i18n('agenda')}</small></p>
                    {if $search.SearchExtras.hasError}<div class="alert alert-danger">{$search.SearchExtras.error|wash}</div>{/if}
                {/if}
            </div>
        </section>

    </div>
</form>

{literal}
<script>
$(document).ready(function () {
    $('[data-indeterminate]').prop('indeterminate', true);
    $('[data-checkbox-container]').on('click', function(){
        var isChecked = $(this).is(':checked');
        $(this).parent().next().find('input').prop('checked', isChecked);
    });
    $('[data-checkbox-child]').on('click', function(){
        var length = $(this).parents('div').find('input').length;
        var checked = $(this).parents('div').find('input:checked').length;
        var container = $(this).parents('div').prev().find('input');
        if (checked === length){
            container.prop('checked', true);
        } else if (checked > 0) {
            container.prop('indeterminate', true);
        } else {
            container.prop('checked', false);
        }
    });
{/literal}
   $('#searchModal').on('search_gui_initialized', function (event, searchGui) {ldelim}
        {if $params.subtree|count()}
        {foreach $params.subtree as $subtree}
            searchGui.activateSubtree({$subtree});
        {/foreach}
        {elseif $params.subtree_boundary}
        searchGui.activateSubtree({$params.subtree_boundary});
        {/if}
        {if $params.topic|count()}
        {foreach $params.topic as $topic}
        searchGui.activateTopic({$topic});
        {/foreach}
        {/if}
        {if $params.from}
        searchGui.activateFrom("{$params.from|datetime( 'custom', '%j/%m/%Y' )}");
        {/if}
        {if $params.to}
        searchGui.activateTo("{$params.to|datetime( 'custom', '%j/%m/%Y' )}");
        {/if}
        {if $params.only_active}
        searchGui.activateActiveContent();
        {/if}
        {if $params.text}
        $('#search-gui-text').val('{$params.text|wash()}');
        {/if}
    {rdelim});
{literal}
});
</script>
<style>
.custom-checkbox .custom-control-input:indeterminate ~ .custom-control-label::after {
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 4 4'%3e%3cpath stroke='%23fff' d='M0 2h4'/%3e%3c/svg%3e");
    border-color: #bbb;
    background-color: #bbb;
    z-index: 0;
}
</style>
{/literal}
