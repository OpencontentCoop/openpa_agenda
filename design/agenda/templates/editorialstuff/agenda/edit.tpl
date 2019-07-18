{ezscript_require( array( 'jquery.opendataTools.js', 'moment.js' ) )}
<section class="hgroup">
    <h1>{$post.object.name|wash()}</h1>
    {include uri=concat('design:', $template_directory, '/parts/workflow.tpl') post=$post}
</section>

<div class="row">
    <div class="col-md-{if is_set( $post.object.data_map.internal_comments )}9{else}12{/if}">

        <div role="tabpanel">

            <ul class="nav nav-tabs" role="tablist">
                {foreach $post.tabs as $index=> $tab}
                    <li role="presentation"{if $index|eq(0)} class="active"{/if}>
                        <a href="#{$tab.identifier}" aria-controls="{$tab.identifier}"
                           role="tab" data-toggle="tab">{$tab.name|i18n('agenda/dashboard')}</a>
                    </li>
                {/foreach}
            </ul>

            <div class="tab-content">
                {foreach $post.tabs as $index=> $tab}
                <div role="tabpanel" class="tab-pane{if $index|eq(0)} active{/if}" id="{$tab.identifier}">
                    {include uri=$tab.template_uri post=$post}
                </div>
                {/foreach}
            </div>

        </div>

    </div>

    {if is_set( $post.object.data_map.internal_comments )}
        <div class="col-md-3">
            {include uri=concat('design:', $template_directory, '/parts/comments.tpl') post=$post}
        </div>
    {/if}

</div>


<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
        </div>
    </div>
</div>

{include uri='design:agenda/parts/calendar/tpl-event.tpl'}
{ezscript_require( array(
    'modernizr.min.js',
    'ezjsc::jquery',
    'bootstrap/tooltip.js',
    'jquery.editorialstuff_default.js',
    'jquery.opendataTools.js',
    'openpa_agenda_helpers.js',
    'jsrender.js'
) )}
<script>
var Translations = {ldelim}
    'Title':'{'Title'|i18n('agenda/dashboard')}',
    'Published':'{'Published'|i18n('agenda/dashboard')}',
    'Start date': '{'Start date'|i18n('agenda/dashboard')}',
    'End date': '{'End date'|i18n('agenda/dashboard')}',
    'Status': '{'Status'|i18n('agenda/dashboard')}',
    'Translations': '{'Translations'|i18n('agenda/dashboard')}',
    'Detail': '{'Detail'|i18n('agenda/dashboard')}',
    'Loading...': '{'Loading...'|i18n('agenda/dashboard')}'
{rdelim};
{literal}
$(document).ready(function () {
    $('.load-preview').on('click', function (e) {
        var tools = $.opendataTools;
        var currentId = $(this).data('object');
        var remoteTarget = $('#preview .modal-content');
        $(remoteTarget).html('<em>' + Translations['Loading...'] + '</em>');
        $('#preview').modal('show');
        var template = $.templates("#tpl-event");
        $.views.helpers(OpenpaAgendaHelpers);
        tools.find('id = ' + currentId, function (response) {
            remoteTarget.html(template.render(response.searchHits[0]).replace('col-md-6', ''));
        });
        e.preventDefault();
    })
});
{/literal}
</script>
