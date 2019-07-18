<div class="panel-body" style="background: #fff">

    {def $node = $post.object.main_node
         $openpa = object_handler($post.object)}
    <section class="container mt-3">
        <div class="row">
            <div class="col-lg-8 px-lg-4 py-lg-2">

                <h1>{$node.name|wash()}</h1>

                {include uri='design:openpa/full/parts/main_attributes.tpl'}

                {include uri='design:openpa/full/parts/info.tpl'}

            </div>
            <div class="col-lg-3 offset-lg-1">
                {include uri='design:openpa/full/parts/taxonomy.tpl'}
            </div>
        </div>
    </section>
    {include uri='design:openpa/full/parts/main_image.tpl'}

    <section class="container">
        {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object show_all_attributes=true()}
    </section>


</div>
