{def $images = array()
     $main_image = false()
     $priorities = array()}

{if and($post.images, $post.images.has_content)}
    {foreach $post.images.content.relation_list as $relation_item}
        {if $relation_item.priority|eq(1)}
            {set $main_image = fetch('content','node',hash('node_id',$relation_item.node_id))}
        {else}
            {set $images = $images|append(fetch('content','node',hash('node_id',$relation_item.node_id)))}
        {/if}
    {/foreach}

    {def $modulo=3 $col-width=4}
    <div class="row my-3">
        <div class="col-sm-12 mb-5">
            <div class="bg-light p-3 clearfix">
                <p class="pull-right">
                    <a class="btn btn-success btn-md"
                       href="{concat('editorialstuff/media/', $factory_identifier, '/edit/', $post.object.id, '/image/', $main_image.contentobject_id )|ezurl(no)}"><i class="fa fa-pencil"></i></a>
                    <a class="btn btn-danger btn-md"
                       href="{concat('editorialstuff/media/', $factory_identifier, '/remove/', $post.object.id, '/image/', $main_image.contentobject_id )|ezurl(no)}"><i class="fa fa-trash-o"></i></a>
                </p>
                <a class="gallery-strip-thumbnail"
                   href={$main_image|attribute('image').content['imagefull'].url|ezroot} title="{$main_image.name|wash()}"
                   data-gallery>
                    {attribute_view_gui attribute=$main_image|attribute('image') image_class=large fluid=false()}
                    {$main_image.name|wash()}
                </a>
            </div>
        </div>
    </div>
    <div class="row">
    {foreach $images as $item}
        <div class="col-sm-{$col-width} mb-5"">
            <div class="row">
                <div class="col-md-6">
                    <a class="gallery-strip-thumbnail"
                       href={$item|attribute('image').content['imagefull'].url|ezroot} title="{$item.name|wash()}"
                       data-gallery>
                        {attribute_view_gui attribute=$item|attribute('image') image_class=squarethumb fluid=false()}
                        <small class="d-block">{$item.name|wash()}</small>
                    </a>
                </div>
                <div class="col-md-6">
                    <p>
                        <a class="btn btn-success btn-md"
                           href="{concat('editorialstuff/media/', $factory_identifier, '/edit/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-pencil"></i></a>
                        <a class="btn btn-danger btn-md"
                           href="{concat('editorialstuff/media/', $factory_identifier, '/remove/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-trash-o"></i></a>
                    </p>
                    <p><a class="btn btn-info btn-xs"
                          href="{concat('editorialstuff/media/', $factory_identifier, '/updatepriority/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}">{'Set main'|i18n('design/admin/class/view')}</a></p>

                </div>
            </div>
        </div>
        {delimiter modulo=$modulo}</div><div class="row"> {/delimiter}
    {/foreach}
    </div>
    {undef $modulo}

{/if}
