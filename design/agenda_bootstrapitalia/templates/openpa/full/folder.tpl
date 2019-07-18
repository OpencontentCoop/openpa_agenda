{ezpagedata_set( 'has_container', true() )}
<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>
            {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
            {include uri='design:openpa/full/parts/main_attributes.tpl'}
        </div>
    </div>
</section>

<div class="section section-muted section-inset-shadow p-4">
    {node_view_gui content_node=$node view=children view_parameters=$view_parameters current_view_tag=$current_view_tag}
</div>
