{if not( is_set( $self_edit ) )}
  {def $self_edit=false()}
{/if}

{if not( is_set( $self_delete ) )}
  {def $self_delete=false()}
{/if}

{def $can_edit=fetch( 'comment', 'has_access_to_function', hash( 'function', 'edit',
                                                                 'contentobject', $contentobject,
                                                                 'language_code', $language_code,
                                                                 'comment', $comment,
                                                                 'scope', 'role',
                                                                 'node', $node ) )
     $can_delete=fetch( 'comment', 'has_access_to_function', hash( 'function', 'delete',
                                                                   'contentobject', $contentobject,
                                                                   'language_code', $language_code,
                                                                   'comment', $comment,
                                                                   'scope', 'role',
                                                                   'node', $node ) )
     $user_display_limit_class=concat( ' class="limitdisplay-user limitdisplay-user-', $comment.user_id, '"' )}
            
<div class="clearfix">
<p class="{if $comment.user_id|eq(fetch( 'user', 'current_user' ).contentobject.id)}bg-success text-right pull-right{else}bg-info text-left pull-left{/if}" style="border-radius: 5px; padding: 5px;margin-{if $comment.user_id|eq(fetch( 'user', 'current_user' ).contentobject.id)}left{else}right{/if}:20px;display: inline-block">
  <small><small style="display: block;line-height: .9">{$comment.created|l10n( 'shortdatetime' )}</small><strong>{$comment.name|wash}</strong></small><br />  
  {$comment.text|wash|nl2br}
  {if or( $can_edit, $can_self_edit, $can_delete, $can_self_delete )}
   {if or( $can_edit, $can_self_edit )}
	   {if and( $can_self_edit, not( $can_edit ) )}
		   {def $displayAttribute=$user_display_limit_class}
	   {else}
		   {def $displayAttribute=''}
	   {/if}
	   <span{$displayAttribute}>
		   <a href={concat( '/comment/edit/', $comment.id )|ezurl}><i class="fa fa-pencil"></i></a>
	   </span>
	   {undef $displayAttribute}
   {/if}
   {if or( $can_delete, $can_self_delete )}
	   {if and( $can_self_delete, not( $can_delete ) )}
		   {def $displayAttribute=$user_display_limit_class}
	   {else}
		   {def $displayAttribute=''}
	   {/if}
	   <span {$displayAttribute}>
		   <a href={concat( '/comment/delete/',$comment.id )|ezurl}>
			   <i class="fa fa-trash"></i>
		   </a>
	   </span>
	   {undef $displayAttribute}
   {/if}
  {/if} 
</p>
</div>
{undef $can_edit $can_delete}