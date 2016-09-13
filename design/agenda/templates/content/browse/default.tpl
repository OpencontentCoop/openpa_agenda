
<div class="content-browse row">
<div class="col-md-6 col-md-offset-3">
    
{let item_type=ezpreference( 'admin_list_limit' )
     number_of_items=min( $item_type, 3)|choose( 10, 10, 25, 50 )
     select_name='SelectedObjectIDArray'
     select_type='checkbox'
     select_attribute='contentobject_id'
     browse_list_count=0
     page_uri_suffix=false()
     node_array=array()
     bookmark_list=fetch('content','bookmarks',array())}
{if is_set( $node_list )}
    {def $page_uri=$requested_uri }
    {set browse_list_count = $node_list_count
         node_array        = $node_list
         page_uri_suffix   = concat( '?', $requested_uri_suffix)}
{else}
    {def $page_uri=concat( '/content/browse/', $main_node.node_id )}

    {set browse_list_count=fetch( content, list_count, hash( parent_node_id, $node_id, depth, 1, objectname_filter, $view_parameters.namefilter) )}
    {if $browse_list_count}
        {set node_array=fetch( content, list, hash( parent_node_id, $node_id, depth, 1, offset, $view_parameters.offset, limit, $number_of_items, sort_by, $main_node.sort_array, objectname_filter, $view_parameters.namefilter ) )}
    {/if}
{/if}

{if eq( $browse.return_type, 'NodeID' )}
    {set select_name='SelectedNodeIDArray'}
    {set select_attribute='node_id'}
{/if}

{if eq( $browse.selection, 'single' )}
    {set select_type='radio'}
{/if}


{if $browse.description_template}
    {include name=Description uri=$browse.description_template browse=$browse main_node=$main_node}
{else}
    <div class="attribute-header">
    <h1 class="long">{'Browse'|i18n( 'design/ocbootstrap/content/browse' )} - {$main_node.name|wash}</h1>
    </div>

    <p>{'To select objects, choose the appropriate radiobutton or checkbox(es), and click the "Select" button.'|i18n( 'design/ocbootstrap/content/browse' )}</p>
    <p>{'To select an object that is a child of one of the displayed objects, click the parent object name to display a list of its children.'|i18n( 'design/ocbootstrap/content/browse' )}</p>
{/if}

<form action="{"/content/search"|ezurl(no)}" role="search">
  <div class="input-group">
    <input type="text" placeholder="{'Search'|i18n('design/ezwebin/pagelayout')}" name="SearchText" class="form-control">
    <input type="hidden" value="Cerca" name="SearchButton" />
    <span class="input-group-btn">
        <button name="SearchButton" type="submit" class="btn btn-primary"><i class="fa fa-search"></i></button>
    </span>
    <input name="Mode" type="hidden" value="browse" />
  </div>
</form>

<form name="browse" action={$browse.from_page|ezurl()} method="post">

<div class="panel panel-default">
  

{def $current_node=fetch( content, node, hash( node_id, $browse.start_node ) )}
{if $browse.start_node|gt( 1 )}
    <div class="panel-heading">
    <a href={concat( '/content/browse/', $main_node.parent_node_id, '/' )|ezurl}><span class="glyphicon glyphicon-arrow-up"></span></a>
    {$current_node.name|wash}&nbsp;[{$current_node.children_count}]</div>
{/if}

{include uri='design:content/browse_mode_list.tpl'}

{include name=Navigator
         uri='design:navigator/google.tpl'
         page_uri=concat('/content/browse/',$main_node.node_id)
         item_count=$browse_list_count
         view_parameters=$view_parameters
         item_limit=$number_of_items}

{if $browse.persistent_data|count()}
{foreach $browse.persistent_data as $key => $data_item}
    <input type="hidden" name="{$key|wash}" value="{$data_item|wash}" />
{/foreach}
{/if}


<input type="hidden" name="BrowseActionName" value="{$browse.action_name}" />
{if $browse.browse_custom_action}
<input type="hidden" name="{$browse.browse_custom_action.name}" value="{$browse.browse_custom_action.value}" />
{/if}
</div>
    

    <button class="pull-left btn btn-primary" type="submit" name="SelectButton">{'Select'|i18n('design/ocbootstrap/content/browse')}</button>
    {if $cancel_action}
    <input type="hidden" name="BrowseCancelURI" value="{$cancel_action|wash}" />
    {/if}
    <button class="pull-right btn btn-large btn-default" type="submit" name="BrowseCancelButton">{'Cancel'|i18n( 'design/ocbootstrap/content/browse' )}</button>

</form>

{/let}
</div>
</div>
