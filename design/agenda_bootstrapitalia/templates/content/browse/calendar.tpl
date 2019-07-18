{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
{ezcss_require(array(
    'fullcalendar/core/main.css',
    'fullcalendar/daygrid/main.css',
    'fullcalendar/list/main.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.opendataTools.js',
    'fullcalendar/core/main.js',
    concat('fullcalendar/core/locales/', $moment_language, '.js'),
    'fullcalendar/daygrid/main.js',
    'fullcalendar/list/main.js',
    'openpa_agenda_fullcalendar.js'
))}

<div class="container">
    <section class="hgroup">
        <h1>{'Select'|i18n('agenda/dashboard')}</h1>
    </section>

    <div class="row">
        <div class="col-md-8">
            <div class="block-calendar-default shadow block-calendar block-calendar-big">
                <div id="calendar"></div>
            </div>
        </div>
        <div class="col-md-4">

            <form name="browse" action="{$browse.from_page|ezurl(no)}" method="post" class="well">

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
                <button class="pull-left btn btn-large btn-default" type="submit" name="BrowseCancelButton">{'Cancel'|i18n( 'design/ocbootstrap/content/browse' )}</button>

                </div>


            </form>

        </div>
    </div>

</div>

<script type="application/javascript">

    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{ezini('RegionalSettings','Locale')}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('locale', "{$moment_language}");
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}',
        'fullcalendar': '{'/opendata/api/calendar/search/'|ezurl(no,full)}',
    {rdelim});
    var AgendaEventClassIdentifier = "{agenda_event_class_identifier()}";
    {literal}
    var tools = $.opendataTools;

    var mainQuery = 'classes ['+AgendaEventClassIdentifier+'] and state = [moderation.accepted, moderation.skipped] sort [published=>desc]';

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

    var calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
        plugins: ['dayGrid', 'list'],
        header: {
            left: 'prev,next',
            center: 'title',
            right: 'today'
        },
        defaultView: 'dayGridMonth',
        locale: $.opendataTools.settings('locale'),
        axisFormat: 'H(:mm)',
        aspectRatio: 1.35,
        selectable: false,
        editable: false,
        timeFormat: 'H(:mm)',
        eventClick: function(calEvent, jsEvent, view) {
            if (!$('#selectEvent-'+calEvent.event.extendedProps.content.metadata.id).length) {
                $('form').prepend('<div class="form-check custom-control custom-checkbox" id="selectEvent-' + calEvent.event.extendedProps.content.metadata.id + '" ><input class="custom-control-input" type="checkbox" checked="checked" name="SelectedNodeIDArray[]" value="' + calEvent.event.extendedProps.content.metadata.mainNodeId + '" /><label> ' + i18n(calEvent.event.extendedProps.content.data, 'event_title') + '</label></div>');
            }
        },
        events: {
            url: tools.settings().endpoint.fullcalendar,
            extraParams: function () {
                return {q: mainQuery};
            }
        }
    });
    $(document).ready(function () {
        calendar.refetchEvents();
        calendar.render();
    });

</script>
{/literal}
