<section class="section pt-0">
    {if $title}
        <h2>{$title|wash()}</h2>
    {/if}
    <div class="row mt-4 mb-5">
        <div class="col col-md-3 org-calendars">
            <ul class="nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical" style="overflow:hidden">
                {foreach $organizations as $index => $child}
                    <li class="nav-item" style="display: block">
                        <a class="nav-link pl-0{if $index|eq(0)} active{/if}"
                           style="line-height: 1.5em;"
                           data-bs-toggle="tab"
                           data-toggle="tab"
                           data-bs-target="#org-{$child.contentobject_id}"
                           href="#org-{$child.contentobject_id}">{$child.name|wash()}</a>
                    </li>
                {/foreach}
            </ul>
        </div>
        <div class="col col-md-9 tab-content org-calendars-list">
            {foreach $organizations as $index => $child}
            <div class="position-relative clearfix tab-pane{if $index|eq(0)} active{/if} px-5 mt-2" id="org-{$child.contentobject_id}">
                <h2 class="h4 mt-4 d-block d-md-none">{$child.name|wash()}</h2>
                <div data-view="card"
                     data-block_subtree_query="{concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] and organizer.id in [', $child.contentobject_id, ']')}"
                     data-search_type="calendar"
                     data-day_limit="180"
                     data-limit="9"
                     data-items_per_row="3">
                    <div class="results">
                        <div class="col-xs-12 spinner text-left">
                            <i class="fa fa-circle-o-notch fa-spin fa-2x fa-fw"></i>
                            <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
                        </div>
                    </div>
                </div>
            </div>
            {/foreach}
        </div>
    </div>
</section>
{literal}
<style>
    @media (max-width: 768px) {
        .org-calendars {
            display: none !important;
        }
        .org-calendars-list > .tab-pane {
            display: block !important;
        }
    }
</style>
<script id="tpl-results" type="text/x-jsrender">
    <div class="row mx-lg-n3">
    {{if totalCount > 0}}
        {{for searchHits}}
        <div class="col-md-6 col-lg-4 px-lg-3 pb-lg-3">
            {{:~i18n(extradata, 'view')}}
        </div>
        {{/for}}
    {{else}}
    <div class="col text-left">
        <i class="fa fa-times"></i> {/literal}{'No events found'|i18n('agenda')}{literal}
    </div>
    {{/if}}
    </div>
</script>
{/literal}
{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js',
	'jquery.lista_paginata.js'
))}
