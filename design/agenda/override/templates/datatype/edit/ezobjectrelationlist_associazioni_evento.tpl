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
{let parent_node=cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|eq( 0 )|not ), $class_content.default_placement.node_id, 1 )
     nodesList=fetch( content, tree, hash( parent_node_id, $parent_node, class_filter_type,'include', class_filter_array, $class_content.class_constraint_list, sort_by, array( 'name',true() ), main_node_only, true() ) )}

{def $user=fetch( 'user', 'current_user' )
     $userObject = $user.contentobject}

{section var=node loop=$nodesList}
    <div class="checkbox">
        <label>
            <input type="checkbox" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$node.node_id}]" value="{$node.contentobject_id}"
                    {if ne( count( $attribute.content.relation_list ), 0)}
                        {foreach $attribute.content.relation_list as $item}
                            {if or( eq( $item.contentobject_id, $node.contentobject_id ), eq( $node.contentobject_id, $user.contentobject_id ) ) }
                                checked="checked"
                                {break}
                            {/if}
                        {/foreach}
                    {elseif eq( $node.contentobject_id, $user.contentobject_id )}
                        checked="checked"
                    {/if}
            />
            {$node.name|wash}
        </label>
    </div>
{/section}
{if $userObject.class_identifier|eq('associazione')}
    <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[{$userObject.main_node_id}]" value="{$userObject.id}" />
{/if}


{if eq( count( $nodesList ), 0 )}
    {def $parentnode = fetch( 'content', 'node', hash( 'node_id', $parent_node ) )}
    {if is_set( $parentnode )}
        <p><strong>{'Parent node'|i18n( 'design/standard/content/datatype' )}:</strong> <a href={$parentnode.url_alias|ezurl()}>{$parentnode.name|wash()}</a></p>
    {/if}
    <p><strong>{'Allowed classes'|i18n( 'design/standard/content/datatype' )}:</strong>
        {if ne( count( $class_content.class_constraint_list ), 0 )}
            {foreach $class_content.class_constraint_list as $class}
                {$class}
                {delimiter}, {/delimiter}
            {/foreach}
        {else}
            {'Any'|i18n( 'design/standard/content/datatype' )}
        {/if}
    </p>
    <div class="alert alert-warning"><p>{'There are no objects of allowed classes'|i18n( 'design/standard/content/datatype' )}.</p></div>
{/if}


{/let}
{/default}

{/default}
{/let}
