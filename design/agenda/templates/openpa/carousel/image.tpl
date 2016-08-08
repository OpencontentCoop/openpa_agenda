<div class="relative">
    {if $node.data_map.image.content[$image_class]}
        {def $image = $node.data_map.image.content[$image_class]}
        <img src={$image.url|ezroot} width="{$image.width}" height="{$image.height}" alt="{$node.name|wash}" class="img-responsive center-block mw_mxs_none mw_xs_none"/>
        {undef $image}
    {else}
        <img src={'placeholder.png'|ezimage} width="1200" height="800" alt="{$node.name|wash}" class="img-responsive center-block mw_mxs_none mw_xs_none"/>
    {/if}
</div>
