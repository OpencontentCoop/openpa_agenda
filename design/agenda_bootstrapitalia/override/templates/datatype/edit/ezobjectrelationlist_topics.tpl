{let class_content=$attribute.class_content
     class_list=fetch( class, list, hash( class_filter, $class_content.class_constraint_list ) )
     can_create=true()
     new_object_initial_node_placement=false()
     browse_object_start_node=false()}

{default html_class='full' placeholder=false()}

{if $placeholder}
<label>{$placeholder}</label>
{/if}

{def $has_custom_topics = false()}
{def $custom_topic_container = false()}

{* If current selection mode is not 'browse'. *}
{if $class_content.selection_type|ne( 0 )}
        {default attribute_base=ContentObjectAttribute}
        {let parent_node_id=fetch(content, object, hash(remote_id, 'topics')).main_node_id
             parent_node=fetch(content,node,hash(node_id,$parent_node_id))
             nodesList=fetch( content, list, hash( parent_node_id, $parent_node_id,
                                                   class_filter_type,'include',
                                                   class_filter_array, $class_content.class_constraint_list,
                                                   sort_by, $parent_node.sort_array,
                                                   sort_by, array( 'name', true() )
                                                 ))}


        {* Dropdown list *} {* radio buttons list *} {* Multiple List *}
        {if array(1,2,4,6)|contains($class_content.selection_type)}
            <input type="hidden" name="single_select_{$attribute.id}" value="1" />
            {if ne( count( $nodesList ), 0)}
            <select class="{$html_class}" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" {if $class_content.selection_type|eq(4)}multiple{/if}>
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
                    >{$node.name|wash}</option>
                    {if $node.children_count}
                        {foreach $node.children as $child}
                            <option value="{$child.contentobject_id}"
                                {if ne( count( $attribute.content.relation_list ), 0)}
                                {foreach $attribute.content.relation_list as $item}
                                     {if eq( $item.contentobject_id, $child.contentobject_id )}
                                        selected="selected"
                                        {break}
                                     {/if}
                                {/foreach}
                                {/if}
                                >&nbsp;{$child.name|wash}</option>
                            {if $child.children_count}
                                {foreach $child.children as $sub_child}
                                    <option value="{$sub_child.contentobject_id}"
                                            {if ne( count( $attribute.content.relation_list ), 0)}
                                                {foreach $attribute.content.relation_list as $item}
                                                    {if eq( $item.contentobject_id, $sub_child.contentobject_id )}
                                                        selected="selected"
                                                        {break}
                                                    {/if}
                                                {/foreach}
                                            {/if}
                                    >&nbsp;&nbsp;{$sub_child.name|wash}</option>
                                    {if $sub_child.children_count}
                                        {foreach $sub_child.children as $sub_sub_child}
                                            <option value="{$sub_sub_child.contentobject_id}"
                                                    {if ne( count( $attribute.content.relation_list ), 0)}
                                                        {foreach $attribute.content.relation_list as $item}
                                                            {if eq( $item.contentobject_id, $sub_sub_child.contentobject_id )}
                                                                selected="selected"
                                                                {break}
                                                            {/if}
                                                        {/foreach}
                                                    {/if}
                                            >&nbsp;&nbsp;&nbsp;{$sub_sub_child.name|wash}</option>
                                        {/foreach}
                                    {/if}
                                {/foreach}
                            {/if}
                        {/foreach}
                    {/if}
                {/section}
            </select>
            {/if}
        {/if}


        {* check boxes list *}
        {if array(3,5)|contains($class_content.selection_type)}

            {set $custom_topic_container = fetch(content, object, hash(remote_id, 'custom_topics'))}
            {set $has_custom_topics = cond(and($custom_topic_container, $custom_topic_container.main_node.children_count))}

            {ezscript_require(array( 'ezjsc::jquery' ))}
            {literal}
            <script type="text/javascript">
                $(document).ready(function () {
                    var doCheck = function(element){
                        element.parent().siblings("ul:hidden").show();
                    };
                    $('ul.incremental-select ul').hide();
                    $('ul.incremental-select li input:checked').each(function () {
                        doCheck($(this));
                    });
                    $('ul.incremental-select li input').on('change', function () {
                        if ($(this).is(":checked")) {
                            doCheck($(this));
                        } else {
                            $(this).parent().siblings("ul").hide().find("input:checked").prop("checked", false);
                        }
                    });
                    {/literal}{if and($attribute.is_required, $has_custom_topics)}{literal}
                    $('[name="PublishButton"]').on('click', function (e) {
                        if ($('ul.incremental-select input:checked').length === 0 && $('ul.custom_topics input:checked').length > 0){
                            alert("{/literal}{'You must select at least one topic not included in %custom_topics_name'|i18n('bootstrapitalia',,hash('%custom_topics_name', $custom_topic_container.name|wash(javascript)))}{literal}");
                            e.preventDefault();
                        }
                    });
                    {/literal}{/if}{literal}
                });
            </script>
            {/literal}
            {if $has_custom_topics}
                <div class="row">
                    <div class="col-md-7">
            {/if}
            <ul class="list-unstyled incremental-select row">
            {section var=node loop=$nodesList}
            <li class="col-6">
                {def $node_has_children = $node.children_count}
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
                  <label class="form-check-label" for="check-{$attribute.id}-{$node.contentobject_id}">{$node.name|wash}{if $node_has_children} <i aria-hidden="true" class="fa fa-plus-square-o"></i>{/if}</label>
                </div>
                {if $node_has_children}
                <ul class="list-unstyled ml-3 ms-3">
                    {foreach $node.children as $child}
                    <li>
                        {def $child_has_children = $child.children_count}
                        <div class="form-check">
                            <input id="check-{$attribute.id}-{$child.contentobject_id}"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$child.node_id}]"
                                   value="{$child.contentobject_id}"
                                    {if ne( count( $attribute.content.relation_list ), 0)}
                                        {foreach $attribute.content.relation_list as $item}
                                            {if eq( $item.contentobject_id, $child.contentobject_id )}
                                                checked="checked"
                                                {break}
                                            {/if}
                                        {/foreach}
                                    {/if}
                            />
                            <label class="form-check-label" for="check-{$attribute.id}-{$child.contentobject_id}">{$child.name|wash}{if $child_has_children} <i aria-hidden="true" class="fa fa-plus-square-o"></i>{/if}</label>
                        </div>
                        {if $child_has_children}
                        <ul class="list-unstyled ml-3 ms-3">
                            {foreach $child.children as $sub_child}
                            <li>
                                {def $sub_child_has_children = $sub_child.children_count}
                                <div class="form-check">
                                    <input id="check-{$attribute.id}-{$sub_child.contentobject_id}"
                                           class="form-check-input"
                                           type="checkbox"
                                           name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$sub_child.node_id}]"
                                           value="{$sub_child.contentobject_id}"
                                            {if ne( count( $attribute.content.relation_list ), 0)}
                                                {foreach $attribute.content.relation_list as $item}
                                                    {if eq( $item.contentobject_id, $sub_child.contentobject_id )}
                                                        checked="checked"
                                                        {break}
                                                    {/if}
                                                {/foreach}
                                            {/if}
                                    />
                                    <label class="form-check-label" for="check-{$attribute.id}-{$sub_child.contentobject_id}">{$sub_child.name|wash}{if $sub_child_has_children} <i aria-hidden="true" class="fa fa-plus-square-o"></i>{/if}</label>
                                </div>
                                {if $sub_child_has_children}
                                <ul class="list-unstyled ml-3 ms-3">
                                    {foreach $sub_child.children as $sub_sub_child}
                                    <li>
                                        <div class="form-check">
                                            <input id="check-{$attribute.id}-{$sub_sub_child.contentobject_id}"
                                                   class="form-check-input"
                                                   type="checkbox"
                                                   name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$sub_sub_child.node_id}]"
                                                   value="{$sub_sub_child.contentobject_id}"
                                                    {if ne( count( $attribute.content.relation_list ), 0)}
                                                        {foreach $attribute.content.relation_list as $item}
                                                            {if eq( $item.contentobject_id, $sub_sub_child.contentobject_id )}
                                                                checked="checked"
                                                                {break}
                                                            {/if}
                                                        {/foreach}
                                                    {/if}
                                            />
                                            <label class="form-check-label" for="check-{$attribute.id}-{$sub_sub_child.contentobject_id}">{$sub_sub_child.name|wash}</label>
                                        </div>
                                    </li>
                                    {/foreach}
                                </ul>
                                {/if}
                                {undef $sub_child_has_children}
                            </li>
                            {/foreach}
                        </ul>
                        {/if}
                        {undef $child_has_children}
                    </li>
                    {/foreach}
                </ul>
                {/if}
                {undef $node_has_children}
            </li>
            {/section}
        </ul>
        {/if}

        {if $has_custom_topics}
        </div>
            <div class="col-md-5">
                <div class="bg-light rounded p-3">
                <p class="font-weight-bold">{$custom_topic_container.name|wash()}</p>
                <ul class="list-unstyled custom_topics">
                    {foreach $custom_topic_container.main_node.children as $node}
                    <li>
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
                    </li>
                    {/foreach}
                </ul>
                </div>
            </div>
        </div>
        {/if}
        {undef $custom_topic_container $has_custom_topics}


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
            {include uri='design:content/datatype/edit/ezobjectrelationlist_create_new.tpl'}
            {include uri='design:content/datatype/edit/ezobjectrelationlist_ajaxuploader.tpl'}

            <div id="browse_and_search_{$attribute.id}" class="mt-3 mb-3"></div>
            <div id="create_new_{$attribute.id}" class="shadow px-3 py-3 mt-3 mb-3 bg-white" style="display: none;"></div>

        </div>



    </div>
{/if}
{/default}
{/let}
