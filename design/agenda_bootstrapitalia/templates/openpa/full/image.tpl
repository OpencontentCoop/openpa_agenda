{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
    </div>
</section>


{include uri='design:openpa/full/parts/main_image.tpl'}

<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object show_all_attributes=true()}
</section>

{if fetch( 'content', 'reverse_related_objects_count', hash( 'object_id', $node.contentobject_id, 'all_relations', true() ) )|gt(0)}
<div class="section section-muted section-inset-shadow p-4">
    <div class="row mx-lg-n3">
    {foreach fetch( 'content', 'reverse_related_objects', hash( 'object_id', $node.contentobject_id, 'all_relations', true() ) ) as $child }
        <div class="col-md-6 col-lg-4 px-lg-3 pb-lg-3">
            {node_view_gui content_node=$child.main_node view=card image_class=large}
        </div>
    {/foreach}
    </div>
</div>
{/if}


