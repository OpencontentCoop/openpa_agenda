{def $index = 0}
<div class="row">
{foreach $post.states as $key => $state}
  <div class="col-xs-12 col-sm-4 col-md-2" style="margin-top: 10px; margin-bottom: 10px;">
  {*if $index|gt(0)}
  <i class="fa fa-arrow-right" style="margin-left: 5px"></i>
  {/if*}
  {set $index = $index|inc()}
  {if $state.id|eq( $post.current_state.id )}
    <span title="Lo stato corrente è {$state.current_translation.name|wash}" data-toggle="tooltip" data-placement="top" class="btn btn-success btn-block btn-lg has-tooltip" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </span>
  {else}
    {if $post.object.allowed_assign_state_id_list|contains($state.id)}
    <a title="Clicca per impostare lo stato a {$state.current_translation.name|wash}" data-toggle="tooltip" data-placement="top" class="btn btn-info btn-block  btn-lg has-tooltip" href="{concat('editorialstuff/state_assign/', $factory_identifier, '/', $key, "/", $post.object.id )|ezurl(no)}" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </a>
    {else}
    <span class="btn btn-default btn-block btn-lg" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </span>
    {/if}
  {/if}  
  </div>
{/foreach}
</div>
{undef $index}