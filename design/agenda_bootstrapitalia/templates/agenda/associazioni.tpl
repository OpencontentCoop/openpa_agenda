{ezpagedata_set( 'has_container', true() )}

{def $subtree = ''}
{def $sort = 'sort [name=>asc]'}
{if $node}
    {set $subtree = concat('subtree [', $node.node_id, '] ')}
<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>
            {include uri='design:openpa/full/parts/main_attributes.tpl'}
        </div>
    </div>
</section>
{/if}

<div class="section section-muted section-inset-shadow p-4">
    {def $blocks = array(
        page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", concat($subtree, " classes [private_organization] ", $sort),
                "show_grid", "1",
                "show_map", "1",
                "show_search", "1",
                "limit", "9",
                "items_per_row", "3",
                "facets", "",
                "view_api", "banner",
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "1",
                "input_search_placeholder", ""
            )
        )
    )}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}

</div>

