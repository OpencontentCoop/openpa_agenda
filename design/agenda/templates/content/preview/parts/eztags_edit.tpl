{def $root = $attribute.contentclass_attribute.data_int1}
{def $tree = api_tagtree($root)}
<select>
  <option></option>
  {foreach $tree.children as $item}
    <option value="{concat($item.id,'|#',$item.keyword|wash(),'|#',$item.parentId,'|#',ezini('RegionalSettings','Locale'))}">{$item.keyword|wash()}</option>
  {/foreach}
</select>
{undef $root $tree}