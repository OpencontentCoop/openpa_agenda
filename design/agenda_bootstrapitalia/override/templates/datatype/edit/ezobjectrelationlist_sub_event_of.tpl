{let class_content=$attribute.class_content
class_list=fetch( class, list, hash( class_filter, $class_content.class_constraint_list ) )
can_create=true()
new_object_initial_node_placement=false()
browse_object_start_node=false()}

{default html_class='full' placeholder=false()}

{if $placeholder}
    <label>{$placeholder}</label>
{/if}

{* If current selection mode is not 'browse'. *}
{if $class_content.selection_type|ne( 0 )}
{default attribute_base=ContentObjectAttribute}
{let parent_node_id=cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|eq( 0 )|not ), $class_content.default_placement.node_id, 1 )
parent_node=fetch(content,node,hash(node_id,$parent_node_id))
nodesList=cond( and( is_set( $class_content.class_constraint_list ), $class_content.class_constraint_list|count|ne( 0 ) ),
fetch( content, tree,
hash( parent_node_id, $parent_node_id,
class_filter_type,'include',
class_filter_array, $class_content.class_constraint_list,
sort_by, $parent_node.sort_array ) ),
fetch( content, list,
hash( parent_node_id, $parent_node_id,
sort_by, $parent_node.sort_array,
sort_by, array( 'priority', true() ),
main_node_only, true()
) )
)
}
{switch match=$class_content.selection_type}

{* Dropdown list *}
{case match=1}
    <input type="hidden" name="single_select_{$attribute.id}" value="1" />
{if ne( count( $nodesList ), 0)}
    <select class="{$html_class}" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]">
        {if $attribute.contentclass_attribute.is_required|not}
            <option value="no_relation" {if eq( $attribute.content.relation_list|count, 0 )} selected="selected"{/if}> </option>
        {/if}
        {section var=node loop=$nodesList}
            <option value="{$node.contentobject_id}"
                {if ne( count( $attribute.content.relation_list ), 0)}
                    {foreach $attribute.content.relation_list as $item}
                        {if eq( $item.contentobject_id, $node.contentobject_id )}
                            selected="selected"
                            {break}
                        {/if}
                    {/foreach}
                {/if}
            >
                {$node.name|wash}</option>
        {/section}
    </select>
{/if}
{/case}

{* radio buttons list *}
{case match=2}
    <input type="hidden" name="single_select_{$attribute.id}" value="1" />
{if $attribute.contentclass_attribute.is_required|not}
    <div class="form-check">
        <input id="radio-{$attribute.id}-no_relation"
               class="form-check-input"
               type="radio"
               name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]"
               value="no_relation"{if eq( $attribute.content.relation_list|count, 0 )} checked="checked"{/if} />
        <label class="form-check-label" for="radio-{$attribute.id}-no_relation">{'No relation'|i18n( 'design/standard/content/datatype' )}</label>
    </div>
{/if}

{section var=node loop=$nodesList}
    <div class="form-check">
        <input id="radio-{$attribute.id}-{$node.contentobject_id}"
               class="form-check-input"
               type="radio"
               name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]"
               value="{$node.contentobject_id}"
            {if ne( count( $attribute.content.relation_list ), 0)}
                {foreach $attribute.content.relation_list as $item}
                    {if eq( $item.contentobject_id, $node.contentobject_id )}
                        checked="checked"
                        {break}
                    {/if}
                {/foreach}
            {/if}
        />
        <label class="form-check-label" for="radio-{$attribute.id}-{$node.contentobject_id}">{$node.name|wash}</label>
    </div>
{/section}
{/case}

{case match=3} {* check boxes list *}
{section var=node loop=$nodesList}
    <div class="form-check">
        <input id="check-{$attribute.id}-{$node.contentobject_id}"
               class="form-check-input"
               type="checkbox"
               name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$node.node_id}]"
               value="{$node.contentobject_id}"
            {if ne( count( $attribute.content.relation_list ), 0)}
                {foreach $attribute.content.relation_list as $item}
                    {if eq( $item.contentobject_id, $node.contentobject_id )}
                        checked="checked"
                        {break}
                    {/if}
                {/foreach}
            {/if}
        />
        <label class="form-check-label" for="check-{$attribute.id}-{$node.contentobject_id}">{$node.name|wash}</label>
    </div>
{/section}
{/case}

{* Multiple List *}
{case match=4}
{if ne( count( $nodesList ), 0)}
    <select class="{$html_class}" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" size="10" multiple>
        {section var=node loop=$nodesList}
            <option value="{$node.contentobject_id}"
                {if ne( count( $attribute.content.relation_list ), 0)}
                    {foreach $attribute.content.relation_list as $item}
                        {if eq( $item.contentobject_id, $node.contentobject_id )}
                            selected="selected"
                            {break}
                        {/if}
                    {/foreach}
                {/if}
            >
                {$node.name|wash}</option>
        {/section}
    </select>
{/if}
{/case}

{* Template based, multi *}
{case match=5}
<div class="templatebasedeor">
    {section var=node loop=$nodesList}
    <<div class="checkbox"><label>
        <input type="checkbox" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$node.node_id}]" value="{$node.contentobject_id}"
            {if ne( count( $attribute.content.relation_list ), 0)}
                {foreach $attribute.content.relation_list as $item}
                    {if eq( $item.contentobject_id, $node.contentobject_id )}
                        checked="checked"
                        {break}
                    {/if}
                {/foreach}
            {/if}
        >
        {node_view_gui content_node=$node view=objectrelationlist}
    </label></<div>
        {/section}
    </div>
    {/case}

    {* Template based, single *}
    {case match=6}
    <div class="templatebasedeor">
        {if $attribute.contentclass_attribute.is_required|not}
        <div class="radio"><label>
                <input value="no_relation" type="radio" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" {if eq( $attribute.content.relation_list|count, 0 )} checked="checked"{/if}>{'No relation'|i18n( 'design/standard/content/datatype' )}<br />
            </label></<div>
            {/if}
            {section var=node loop=$nodesList}
            <div class="radio"><label>
                    <input type="radio" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" value="{$node.contentobject_id}"
                        {if ne( count( $attribute.content.relation_list ), 0)}
                            {foreach $attribute.content.relation_list as $item}
                                {if eq( $item.contentobject_id, $node.contentobject_id )}
                                    checked="checked"
                                    {break}
                                {/if}
                            {/foreach}
                        {/if}
                    >
                    {node_view_gui content_node=$node view=objectrelationlist}
                </label></<div>
                {/section}
            </div>
            {/case}
            {/switch}

            {if eq( count( $nodesList ), 0 )}
                <div class="alert alert-warning">{'There are no objects of allowed classes'|i18n( 'design/standard/content/datatype' )}</div>
            {/if}

            {* Create object *}
            {section show = and( is_set( $class_content.default_placement.node_id ), ne( 0, $class_content.default_placement.node_id ), ne( '', $class_content.object_class ) )}
                {def $defaultNode = fetch( content, node, hash( node_id, $class_content.default_placement.node_id ))}
                {if and( is_set( $defaultNode ), $defaultNode.can_create )}
                    <div id='create_new_object_{$attribute.id}' style="display:none;">
                        <p>{'Create new object with name'|i18n( 'design/standard/content/datatype' )}:</p>
                        <input name="attribute_{$attribute.id}_new_object_name" id="attribute_{$attribute.id}_new_object_name"/>
                    </div>
                    <input class="button" type="button" value="Create New" name="CustomActionButton[{$attribute.id}_new_object]"
                           onclick="var divfield=document.getElementById('create_new_object_{$attribute.id}');divfield.style.display='block';
                               var editfield=document.getElementById('attribute_{$attribute.id}_new_object_name');editfield.focus();this.style.display='none';return false;" />
                {/if}
            {/section}

            {/let}
            {/default}
            {* Standard mode is browsing *}
            {else}
            <div class="block relations-searchbox" id="ezobjectrelationlist_browse_{$attribute.id}">
                {if is_set( $attribute.class_content.default_placement.node_id )}
                    {set browse_object_start_node = $attribute.class_content.default_placement.node_id}
                {/if}

                {* Optional controls. *}
                {include uri='design:content/datatype/edit/ezobjectrelationlist_controls.tpl'}
                <div class="table-responsive">
                    <table class="table table-striped table-condensed{if $attribute.content.relation_list|not} hide{/if}" cellspacing="0">
                        <thead>
                        <tr>
                            <th class="tight"></th>
                            <th>{'Name'|i18n( 'design/standard/content/datatype' )}</th>
                            <th>{'Section'|i18n( 'design/standard/content/datatype' )}</th>
                            <th class="tight">{'Order'|i18n( 'design/standard/content/datatype' )}</th>
                        </tr>
                        </thead>
                        <tbody>
                        {if $attribute.content.relation_list}
                            {foreach $attribute.content.relation_list as $item}
                                {include name=relation_item uri='design:ezjsctemplate/relation_list_row.tpl' arguments=array( $item.contentobject_id, $attribute.id, $item.priority )}
                            {/foreach}
                        {/if}
                        <tr class="hide">
                            <td>
                                <input type="checkbox" name="{$attribute_base}_selection[{$attribute.id}][]" value="--id--" />
                                <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" value="no_relation" />
                            </td>
                            <td></td>
                            <td><small></small></td>
                            <td><input size="2" type="text" name="{$attribute_base}_priority[{$attribute.id}][]" value="0" /></td>
                        </tr>
                        <tr class="buttons">
                            <td colspan="4">
                                <button class="btn btn-sm btn-danger ezobject-relation-remove-button {if $attribute.content.relation_list|not()}hide{/if}" type="submit" name="CustomActionButton[{$attribute.id}_remove_objects]">
                                    {'Remove selected'|i18n( 'design/standard/content/datatype' )}
                                </button>
                            </td>
                        </tr>
                        </tbody>
                    </table>

                </div>


                {if $browse_object_start_node}
                    <input type="hidden" name="{$attribute_base}_browse_for_object_start_node[{$attribute.id}]" value="{$browse_object_start_node|wash}" />
                {/if}

                {if is_set( $attribute.class_content.class_constraint_list[0] )}
                    <input type="hidden" name="{$attribute_base}_browse_for_object_class_constraint_list[{$attribute.id}]" value="{$attribute.class_content.class_constraint_list|implode(',')}" />
                {/if}

                <div class="clearfix">

                    {include uri='design:content/datatype/edit/ezobjectrelationlist_browse_and_search.tpl'}

                    <div id="browse_and_search_{$attribute.id}" class="mt-3 mb-3"></div>
                    <div id="create_new_{$attribute.id}" class="shadow px-3 py-3 mt-3 mb-3 bg-white" style="display: none;"></div>

                </div>



            </div>
            {/if}
            {/default}
            {/let}
