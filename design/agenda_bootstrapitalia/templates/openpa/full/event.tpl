{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_event_title')}
                <h4 class="py-2">{$node|attribute('short_event_title').content|wash()}</h4>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {if $node.object.can_edit}
            <div class="mb-3">
                <a class="btn btn-warning btn-icon" href="{concat('editorialstuff/edit/agenda/',$node.contentobject_id)|ezurl('no')}">
                    {display_icon('it-pencil', 'svg', 'icon icon-white')}   <span>{'Manage event'|i18n('agenda/dashboard')}</span>
                </a>
            </div>
            {/if}
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}

            <div class="mt-5">
                <a href="{$node.parent.url_alias|ezurl(no)}" class="btn btn-outline-primary btn-icon">
                    {display_icon('it-calendar', 'svg', 'icon icon-primary')}                
                    <span>{'Go to event calendar'|i18n('bootstrapitalia')}</span>
                </a>
            </div>

        </div>
    </div>
</section>


{include uri='design:openpa/full/parts/main_image.tpl'}

<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>

{if is_comment_enabled()}}
    {include uri='design:openpa/full/parts/comments.tpl' node=$node}
{elseif $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}
