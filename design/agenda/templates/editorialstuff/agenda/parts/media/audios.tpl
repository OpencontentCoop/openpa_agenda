{def $audios = array()}
{if $post.audios}
  {foreach $post.audios.content.relation_list as $relation_item}
    {set $audios = $audios|append(fetch('content','node',hash('node_id',$relation_item.node_id)))}
  {/foreach}
{/if}
{if count($audios)|gt(0)}
  <h3>Audio</h3>
  {def $modulo=3 $col-width=4}
  <div class="row"> 
	{foreach $audios as $item}
	<div class="col-sm-{$col-width}" style="margin-bottom: 10px;">	  	 	  
	  <div class="row">
		<div class="col-xs-6">
		  <p style="width: 100px;display:inline-block; height: 100px; background: #eee">
			<small>{$item.name|wash()}</small>
      {*<small>{attribute_view_gui attribute=$item.data_map.file}</small>*}
		  </p>
		</div>		
		<div class="col-xs-6">
		  <a class="btn btn-danger btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/remove/', $post.object.id, '/audio/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-trash-o"></i></a>
		  <a class="btn btn-warning btn-lg" href="{concat('editorialstuff/media/', $factory_identifier, '/edit/', $post.object.id, '/audio/', $item.contentobject_id )|ezurl(no)}"><i class="fa fa-pencil"></i></a>
		</div>
	  </div>
	</div>
    {delimiter modulo=$modulo}</div><div class="row"> {/delimiter}
	{/foreach}
  </div>
  {undef $modulo $col-width}
{/if}

