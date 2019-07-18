{def $index = 0}
{foreach $post.states as $key => $state}
  <div class="btn-group" role="group" style="margin-top: 10px; margin-bottom: 10px;">
  {set $index = $index|inc()}
  {if $state.id|eq( $post.current_state.id )}
    <span title="{'Current state is'|i18n('editorialstuff/dashboard')} {$state.current_translation.name|wash}" data-toggle="tooltip" data-placement="top" class="btn btn-success has-tooltip" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </span>
  {else}
    {if $post.object.allowed_assign_state_id_list|contains($state.id)}
    <a title="{'Change state to'|i18n('editorialstuff/dashboard')} {$state.current_translation.name|wash}" data-toggle="tooltip" data-placement="top" class="btn btn-info has-tooltip" href="{concat('editorialstuff/state_assign/', $factory_identifier, '/', $key, "/", $post.object.id )|ezurl(no)}" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </a>
    {else}
    <span class="btn btn-default" style="overflow: hidden; text-overflow: ellipsis;">
      {$state.current_translation.name|wash}
    </span>
    {/if}
  {/if}  
  </div>
{/foreach}
{undef $index}