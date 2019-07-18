{def $params = parse_search_get_params()}

{set $page_limit = 20}
{def $filters = array()
     $search_hash = $params._search_hash|merge(hash('offset', $view_parameters.offset,'limit', $page_limit ))
     $search = fetch( ezfind, search, $search_hash )}

{def $classes = array()}
{if openpaini('MotoreRicerca', 'IncludiClassi', array())|count()}
    {set $classes = fetch(class, list, hash(class_filter, openpaini('MotoreRicerca', 'IncludiClassi'), sort_by, array( 'name', true() )))}
{/if}

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
                        {def $subtree_node = fetch(content, object, hash(remote_id, concat(site_identifier(), $remote_suffix))).main_node}
                        <div class="form-check custom-control custom-checkbox">
                            <input name="Subtree[]" id="subtree-{$subtree_node.node_id}" value={$subtree_node.node_id} {if $params.subtree|contains($subtree_node.node_id)}checked="checked"{/if} class="custom-control-input" type="checkbox" />
                            <label class="custom-control-label" for="subtree-{$subtree_node.node_id}">{$subtree_node.name|wash()} {if is_set($subtree_facets[$id])}<small>({$subtree_facets[$id]})</small>{/if}</label>
                        </div>
                        {undef $subtree_node}
                    {/foreach}
                    </div>
                </div>
                
                
                <div class="pt-4 pt-lg-5">
                        <h6 class="text-uppercase">{'Topics'|i18n('agenda')}</h6>
                        {def $topics = fetch(content, object, hash(remote_id, 'topics'))
                             $topic_list = tree_menu( hash( 'root_node_id', $topics.main_node_id, 'scope', 'side_menu'))
                             $topic_list_children = $topic_list.children
                             $already_displayed = array()
                             $count = 0 
                             $max = 6 
                             $total = count($topic_list_children)
                             $sub_count = 0}

                        {foreach $topic_list_children as $child}                    
                            {if $params.topic|contains($child.item.node_id)}
                                <div class="form-check custom-control custom-checkbox">
                                    <input name="Topic[]" id="topic-{$child.item.node_id}" value={$child.item.node_id} checked="checked" class="custom-control-input" type="checkbox">
                                    <label class="class="custom-control-label" for="topic-{$child.item.node_id}">{$child.item.name|wash()}  {if is_set($topic_facets[$child.item.node_id])}<small>({$topic_facets[$child.item.node_id]})</small>{/if}                                
                                </div>
                                {set $count = $count|inc()}
                                {set $already_displayed = $already_displayed|append($child.item.node_id)}
                            {/if}
                        {/foreach}

                        {if $count|lt($max)}                            
                            {foreach $topic_list_children as $child} 
                                {if and($already_displayed|contains($child.item.node_id)|not(), is_set($topic_facets[$child.item.node_id]))}
                                    <div class="form-check custom-control custom-checkbox">
                                        <input name="Topic[]" id="topic-{$child.item.node_id}" value={$child.item.node_id} class="custom-control-input" type="checkbox">
                                        <label class="class="custom-control-label" for="topic-{$child.item.node_id}">{$child.item.name|wash()}  {if is_set($topic_facets[$child.item.node_id])}<small>({$topic_facets[$child.item.node_id]})</small>{/if}                                
                                    </div>
                                    {set $count = $count|inc()}
                                    {set $already_displayed = $already_displayed|append($child.item.node_id)}
                                    {if $count|eq($max)}{break}{/if}
                                {/if}
                            {/foreach}
                        {/if}

                        {if $count|lt($max)}
                            {set $sub_count = $max|sub($count)}
                            {foreach $topic_list_children as $child max $sub_count} 
                                {if $already_displayed|contains($child.item.node_id)|not()}
                                    <div class="form-check custom-control custom-checkbox">
                                        <input name="Topic[]" id="topic-{$child.item.node_id}" value={$child.item.node_id} class="custom-control-input" type="checkbox">
                                        <label class="class="custom-control-label" for="topic-{$child.item.node_id}">{$child.item.name|wash()}  {if is_set($topic_facets[$child.item.node_id])}<small>({$topic_facets[$child.item.node_id]})</small>{/if}                                
                                    </div>
                                    {set $count = $count|inc()}
                                    {set $already_displayed = $already_displayed|append($child.item.node_id)}
                                {/if}
                            {/foreach}
                        {/if}

                        {if $count|lt($total)}
                            <a href="#more-topics" data-toggle="collapse" aria-expanded="false" aria-controls="more-topics">
                                {display_icon('it-more-items', 'svg', 'icon icon-primary right')}                    
                            </a>
                            <div class="collapse" id="more-topics">
                            {foreach $topic_list_children as $child} 
                                {if $already_displayed|contains($child.item.node_id)|not()}
                                    <div class="form-check custom-control custom-checkbox">
                                        <input name="Topic[]" id="topic-{$child.item.node_id}" value={$child.item.node_id} class="custom-control-input" type="checkbox">
                                        <label class="class="custom-control-label" for="topic-{$child.item.node_id}">{$child.item.name|wash()}  {if is_set($topic_facets[$child.item.node_id])}<small>({$topic_facets[$child.item.node_id]})</small>{/if}                                
                                    </div>                                
                                {/if}
                            {/foreach}
                            </div>
                        {/if}

                        
                        {undef $topics $topic_list $count $max $total $already_displayed $sub_count}
                </div>

                {if count($classes)}
                    <div class="pt-4 pt-lg-5">
                        <h6 class="text-uppercase">{'Content type'|i18n('agenda')}</h3>
                        {foreach $classes as $class}
                            <div class="form-check custom-control custom-checkbox">
                                <input name="Class[]" id="class-{$class.id}" value={$class.id|wash()} {if $params.class|contains($class.id)}checked="checked"{/if} class="custom-control-input" type="checkbox">
                                <label class="class="custom-control-label" for="class-{$class.id}">{$class.name|wash()} {if is_set($class_facets[$class.id])}<small>({$class_facets[$class.id]})</small>{/if}</label>                                
                            </div>
                        {/foreach}
                    </div>
                {/if}

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
                
                    {if $search.SearchCount|eq(1)}
                        <p><small>{'Found a result'|i18n('agenda')}</small></p>
                    {else}
                        <p><small>{'Found %number results'|i18n('agenda', '', hash('%number', $search.SearchCount))}</small></p>
                    {/if}                    

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
