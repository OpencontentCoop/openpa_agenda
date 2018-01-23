{ezcss_require( array(
    'fullcalendar.min.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.opendataTools.js',
    'fullcalendar/fullcalendar.min.js',
    'fullcalendar/locale/it.js',
    'fullcalendar/locale/de.js',
    'fullcalendar/locale/en.js',
    'openpa_agenda_helpers.js',
    'openpa_agenda_fullcalendar.js',
    'jquery.opendataSearchView.js',
    'jsrender.js'
))}

<div class="container">
    <section class="hgroup">
        <h1>Seleziona eventi o iniziative</h1>
    </section>

    <div class="row">
        <div class="col-md-12">
            <div class="well">
                <form name="browse" action="{$browse.from_page|ezurl(no)}" method="post">

                    {*<input type="checkbox" name="SelectedNodeIDArray[]" value="" />*}

                    {if $browse.persistent_data|count()}
                        {foreach $browse.persistent_data as $key => $data_item}
                            <input type="hidden" name="{$key|wash}" value="{$data_item|wash}" />
                        {/foreach}
                    {/if}


                    <input type="hidden" name="BrowseActionName" value="{$browse.action_name}" />
                    {if $browse.browse_custom_action}
                        <input type="hidden" name="{$browse.browse_custom_action.name}" value="{$browse.browse_custom_action.value}" />
                    {/if}

                    <div class="clearfix">

                    <button class="pull-right btn btn-primary" type="submit" name="SelectButton">{'Select'|i18n('design/ocbootstrap/content/browse')}</button>
                    {if $cancel_action}
                        <input type="hidden" name="BrowseCancelURI" value="{$cancel_action|wash}" />
                    {/if}
                    <button class="pull-right btn btn-large btn-default" type="submit" name="BrowseCancelButton">{'Cancel'|i18n( 'design/ocbootstrap/content/browse' )}</button>

                    </div>


                </form>
            </div>

        </div>
    </div>
    <div class="row">
        <div class="col-md-8">
            <h3>Scegli un evento</h3>
            <div id="calendar"></div>
        </div>
        <div class="col-md-4">
            <h3>Scegli un'iniziativa</h3>
            <div class="list-group" id="iniziativa"></div>
        </div>
    </div>

</div>

<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
        </div>
    </div>
</div>

<script id="tpl-list-empty" type="text/x-jsrender">
<a href="#" class="list-group-item">
    <i class="fa fa-times"></i> {'Nessun contenuto trovato'|i18n('agenda')}
</a>
</script>

<script id="tpl-list-load-other" type="text/x-jsrender">
<a href="#" class="list-group-item btn btn-primary btn-xs">{'Carica altri risultati'|i18n('agenda')}</a>
</script>

{literal}
<script id="tpl-list-event" type="text/x-jsrender">
<a href="#" class="list-group-item" id="selectEvent-{{:metadata.id}}" data-node_id="{{:metadata.mainNodeId}}">
    <h4 class="list-group-item-heading">{{:~i18n(metadata.name)}}</h4>
</a>
</script>
{/literal}

<script type="application/javascript">

    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{ezini('RegionalSettings','Locale')}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}',
        'fullcalendar': '{'/opendata/api/fullcalendar/search/'|ezurl(no,full)}',
    {rdelim});
    var AgendaEventClassIdentifier = "{agenda_event_class_identifier()}";
    {literal}
    var tools = $.opendataTools;

    var calendarLocale = 'it';
    if (tools.settings('language') == 'ger-DE') {
        calendarLocale = 'de';
    } else if (tools.settings('language') == 'eng-GB') {
        calendarLocale = 'en';
    }
    var mainQuery = 'classes ['+AgendaEventClassIdentifier+'] and state = [moderation.accepted, moderation.skipped] sort [published=>desc]';
    var calendar = $('#calendar');

    var i18n = function (data, key, fallbackLanguage) {
        var currentLanguage = tools.settings('language');
        fallbackLanguage = fallbackLanguage || 'ita-IT';
        if (data) {
            if (typeof data[tools.settings('language')] != 'undefined' && data[currentLanguage][key]) {
                return data[currentLanguage][key];
            }
            if (fallbackLanguage && typeof data[fallbackLanguage] != 'undefined' && data[fallbackLanguage][key]){
                return data[fallbackLanguage][key];
            }
            return data[Object.keys(data)[0]][key];
        }
        return null;
    };

    calendar.fullCalendar({
        header: {
            center: "title",
            right: "agendaDay,agendaWeek,month",
            left: "prev,today,next"
        },
        defaultView: 'month',
        locale: calendarLocale,
        axisFormat: 'H(:mm)',
        aspectRatio: 1.35,
        selectable: false,
        editable: false,
        timeFormat: 'H(:mm)',
        eventClick: function(calEvent, jsEvent, view) {
            if (!$('#selectEvent-'+calEvent.content.metadata.id).length) {
                $('form').prepend('<div class="radio" id="selectEvent-' + calEvent.content.metadata.id + '" ><label><input type="radio" checked="checked" name="SelectedNodeIDArray[]" value="' + calEvent.content.metadata.mainNodeId + '" />' + i18n(calEvent.content.data, 'titolo') + '</label></div>');
            }
        },
        events: {
            url: tools.settings().endpoint.fullcalendar,
            data: function () {
                return {q: mainQuery};
            }
        }
    });

    var searchView = $("#iniziativa").opendataSearchView({
        query: 'classes [iniziativa] sort [published=>desc] limit 10',
        onLoadResults: function (response, query, appendResults, view) {
            if (response.totalCount > 0) {
                var template = $.templates("#tpl-list-event");
                $.views.helpers(OpenpaAgendaHelpers);

                var htmlOutput = template.render(response.searchHits);
                if (appendResults) view.container.append(htmlOutput);
                else view.container.html(htmlOutput);

                view.container.find('.list-group-item').on('click', function(){
                    $('form').prepend('<div class="radio" id="' + $(this).attr('id') + '" ><label><input type="radio" checked="checked" name="SelectedNodeIDArray[]" value="' + $(this).data('node_id') + '" />' + $(this).find('h4').html() + '</label></div>');
                });

                if (response.nextPageQuery) {
                    var loadMore = $($.templates("#tpl-list-load-other").render({}));
                    loadMore.bind('click', function (e) {
                        view.doSearch(response.nextPageQuery);
                        loadMore.remove();
                        e.preventDefault();
                    });
                    view.container.append(loadMore)
                }
            } else {
                view.container.html($.templates("#tpl-list-empty").render({}));
            }
        },
        onLoadErrors: function (errorCode, errorMessage, jqXHR, view) {
            view.container.html('<div class="alert alert-danger">' + errorMessage + '</div>')
        }
    }).data('opendataSearchView').init().doSearch();
</script>
{/literal}
