{def $images = array()
     $main_image = false() 
     $priorities = array()}

{if $post.images}
  {foreach $post.images.content.relation_list as $relation_item}
    {if $relation_item.priority|eq(1)}
      {set $main_image = fetch('content','node',hash('node_id',$relation_item.node_id))}
    {else}
      {set $images = $images|append(fetch('content','node',hash('node_id',$relation_item.node_id)))}
    {/if}
  {/foreach}
{/if}

{if $post.images}
  <h3>Immagini</h3>
  
  {ezscript_require( array( "ezjsc::jquery", "plugins/blueimp/jquery.blueimp-gallery.min.js" ) )}
  {ezcss_require( array( "plugins/blueimp/blueimp-gallery.css" ) )}
    
  {def $modulo=3 $col-width=4}
  
  <div class="row">
    <div class="col-sm-12" style="margin-bottom: 10px;">
      <div class="well well-sm clearfix">
        <p class="pull-right">
          <a class="btn btn-danger btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/remove/', $post.object.id, '/image/', $main_image.contentobject_id )|ezurl(no)}"><i class="fa fa-trash-o"></i></a>
          <a class="btn btn-warning btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/edit/', $post.object.id, '/image/', $main_image.contentobject_id )|ezurl(no)}"><i class="fa fa-pencil"></i></a>
        </p> 
        <a class="gallery-strip-thumbnail" href={$main_image|attribute('image').content['imagefullwide'].url|ezroot} title="{$main_image.name|wash()}" data-gallery>		
        {attribute_view_gui attribute=$main_image|attribute('image') image_class=large fluid=false()}
        {$main_image.name|wash()}
        </a>
      </div> 
    </div>
  </div>
  
  <div class="row"> 
	{foreach $images as $item}  
    <div class="col-sm-{$col-width}" style="margin-bottom: 10px;">
      <div class="row">
      <div class="col-xs-6">
        <a class="gallery-strip-thumbnail" href={$item|attribute('image').content['imagefullwide'].url|ezroot} title="{$item.name|wash()}" data-gallery>		
        {attribute_view_gui attribute=$item|attribute('image') image_class=squarethumb fluid=false()}
        <small>{$item.name|wash()}</small>
        </a>
      </div>
      <div class="col-xs-6">
        <p>
          <a class="btn btn-danger btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/remove/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-trash-o"></i></a>
          <a class="btn btn-warning btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/edit/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-pencil"></i></a>
        </p>
        <p><a class="btn btn-info btn-xs" href="{concat('editorialstuff/media/', $factory_identifier, '/updatepriority/', $post.object.id, '/image/', $item.contentobject_id )|ezurl(no)}">Usa come principale</a></p>
        
      </div>
      </div>
    </div>
    {delimiter modulo=$modulo}</div><div class="row"> {/delimiter}    
	{/foreach}
  </div>  
  {undef $modulo}
  
{/if}