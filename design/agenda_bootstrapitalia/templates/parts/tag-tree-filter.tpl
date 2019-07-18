<div class="mb-5">
    <div class="form-check custom-control custom-checkbox">
        <input id="{$key}-filter-{$tag.id}"
               type="checkbox"
               name="{$key}"
               value="{$tag.id}"
               class="custom-control-input"
               data-tree="{$tag.id}#"
               data-id="{$tag.id}"
               data-level="1"
               data-label="{$tag.keyword|wash()}">
        <label for="{$key}-filter-{$tag.id}" class="custom-control-label">
            <strong class="text-primary"><span>{$tag.keyword|wash()}</span></strong>
        </label>
    </div>
    {if $tag.hasChildren}
        {foreach $tag.children as $child}
            <div class="form-check custom-control custom-checkbox">
                <input id="{$key}-filter-{$child.id}"
                       type="checkbox"
                       name="{$key}"
                       value="{$child.id}"
                       class="custom-control-input"
                       data-tree="{$tag.id}#{$child.id}#"
                       data-id="{$child.id}"
                       data-level="2"
                       data-label="{$child.keyword|wash()}">
                <label for="{$key}-filter-{$child.id}" class="custom-control-label">
                    <span>{$child.keyword|wash()}</span>
                </label>
                {if $child.hasChildren}
                <a class="ml-2 large left-icon collapsed" href="#more-filters-{$child.id}" data-toggle="collapse" aria-expanded="false" aria-controls="more-filters">
                    {display_icon('it-more-items', 'svg', 'icon icon-primary right')}
                </a>
                {/if}
            </div>
            {if $child.hasChildren}
                <div id="more-filters-{$child.id}" class="collapse ml-4">
                {foreach $child.children as $subchild}
                    <div class="form-check">
                        <input id="{$key}-filter-{$subchild.id}"
                               type="checkbox"
                               name="{$key}"
                               value="{$subchild.id}"
                               class="form-check-input"
                               data-tree="{$tag.id}#{$child.id}#{$subchild.id}#"
                               data-id="{$subchild.id}"
                               data-level="3"
                               data-label="{$subchild.keyword|wash()}">
                        <label for="{$key}-filter-{$subchild.id}" class="form-check-label">
                            <span>{$subchild.keyword|wash()}</span>
                        </label>
                    </div>
                {/foreach}
                </div>
            {/if}
        {/foreach}
    {/if}
</div>
