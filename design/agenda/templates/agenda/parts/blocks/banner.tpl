{def $banner = $block.valid_nodes[0]
     $image = false()
     $link = '#'
     $target = '_self'}

{if $banner|has_attribute( 'image' )}
  {set $image = $banner|attribute('image').content}
{/if}

{if $banner|has_attribute( 'location' )}
  {set $link = $banner|attribute('location').content
       $target = '_blank'}
{elseif $banner|has_attribute( 'internal_location' )}
  {def $location = fetch(content,object,hash(object_id, $banner|attribute('internal_location').content.relation_list[0].contentobject_id))}
  {set $link = $location.main_node.url_alias|ezurl(no)}
  {undef $location}
{/if}

<div class="service_teaser vertical agenda-block"
     style="{if $image}background-image: url('{$image['large'].url|ezroot(no)}');background-size: cover;background-repeat: no-repeat;background-position: center{else}background:#fff{/if}">
  <div class="service_details">
    <h2 class="section_header skincolored" style="">
      <a href="{$link}" target="{$target}"><b>{$banner.name|wash()}</b></a>
      {if $banner|has_attribute( 'abstract' )}
        <small>{$banner|abstract()|oc_shorten(100)}</small>
      {/if}
    </h2>
  </div>
</div>
{undef $banner $image $link $target}
