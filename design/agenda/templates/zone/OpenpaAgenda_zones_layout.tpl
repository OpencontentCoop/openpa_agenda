<div class="row">
    {foreach $zones as $zone}
        <div class="col-md-4">
            {if and( is_set( $zone.blocks ), $zone.blocks|count() )}
                {foreach $zone.blocks as $block}
                    <div id="address-{$block.zone_id}-{$block.id}">
                        {include uri=concat('design:agenda/parts/blocks/',$block.view,'.tpl') block=$block}
                    </div>
                {/foreach}
            {/if}
        </div>
    {/foreach}
</div>
