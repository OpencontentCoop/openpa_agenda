<div class="row align-items-end{if and(is_set($hide_filters), $hide_filters|eq(true))} d-none{/if}">
    <div class="col-lg-{if count($views)|eq(1)}12{else}9{/if} mt-4">
        {include uri='design:parts/filters.tpl'}
    </div>
    <div class="col-lg-3 mt-4{if count($views)|eq(1)} hide{/if}">
        {include uri='design:parts/pills.tpl'}
    </div>
</div>
