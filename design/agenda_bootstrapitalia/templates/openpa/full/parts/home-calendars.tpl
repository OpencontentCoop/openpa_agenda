<section class="section pt-0">
    <div class="row mt-4 mb-5">

        {if $title}
            <div class="col-12 my-2 mb-5"><h2>{$title|wash()}</h2></div>
        {/if}

        <div class="col">
            <div data-view="card"
                 data-block_subtree_query="{concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] and organizer.id in [', $organizations|implode(','), ']')}"
                 data-search_type="calendar"
                 data-day_limit="180"
                 data-limit="9"
                 data-items_per_row="3">
                <div class="results">
                    <div class="col-xs-12 spinner text-center">
                        <i class="fa fa-circle-o-notch fa-spin fa-2x fa-fw"></i>
                        <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
                    </div>
                </div>
            </div>
        </div>

    </div>
</section>
{literal}
<script id="tpl-results" type="text/x-jsrender">
    <div class="row mx-lg-n3">
    {{if totalCount > 0}}
        {{for searchHits}}
        <div class="col-md-6 col-lg-4 px-lg-3 pb-lg-3">
            {{include tmpl="#tpl-event"/}}
        </div>
        {{/for}}
    {{else}}
    <div class="col text-center">
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
