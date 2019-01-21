{let class_content=$attribute.class_content
     class_list=fetch( class, list, hash( class_filter, $class_content.class_constraint_list ) )
     can_create=true()
     new_object_initial_node_placement=false()
     browse_object_start_node=false()}

{default html_class='full' placeholder=false()}

{if $placeholder}
<label>{$placeholder}</label>
{/if}


  {default attribute_base=ContentObjectAttribute}
  {let parent_node=cond( and( is_set( $class_content.default_placement.node_id ),
                         $class_content.default_placement.node_id|eq( 0 )|not ),
                         $class_content.default_placement.node_id, 1 )         
   nodesList=cond( and( is_set( $class_content.class_constraint_list ), $class_content.class_constraint_list|count|ne( 0 ) ),
                   fetch( content, tree,
                          hash( parent_node_id, $parent_node,
                                class_filter_type,'include',
                                class_filter_array, $class_content.class_constraint_list,
                                sort_by, array( 'name',true() ) ) ),
                   fetch( content, list,
                          hash( parent_node_id, $parent_node,
                                sort_by, array( 'name', true() )
                               ) )
                  )
  }

      <input type="hidden" name="single_select_{$attribute.id}" value="1" />
      {if ne( count( $nodesList ), 0)}
      <select id="luogo-della-cultura" class="{$html_class}" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]">
          {if $attribute.contentclass_attribute.is_required|not}
              <option value="no_relation" {if eq( $attribute.content.relation_list|count, 0 )} selected="selected"{/if}> </option>
          {/if}
          {section var=node loop=$nodesList}
              <option value="{$node.contentobject_id}"
              {if $node.data_map.geo}
                data-latitude="{$node.data_map.geo.content.latitude}"
                data-longitude="{$node.data_map.geo.content.longitude}"
                data-address="{$node.data_map.geo.content.address}"
              {/if}
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
  
  {/let}
  {/default}

{/default}
{/let}
