{ezcss_require( array(
    'fullcalendar.min.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.opendataTools.js',
    'fullcalendar/fullcalendar.min.js',
    concat('fullcalendar/locale/', fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') )).http_locale_code|explode('-')[0]|downcase()|extract_left( 2 ), '.js'),
    'openpa_agenda_fullcalendar.js'
))}

<div class="container">
    <section class="hgroup">
        <h1>{'Select'|i18n('agenda/dashboard')}</h1>
    </section>

    <div class="row">
        <div class="col-md-8">
            <div id="calendar"></div>
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
                $('form').prepend('<div class="checkbox" id="selectEvent-' + calEvent.content.metadata.id + '" ><label><input type="checkbox" checked="checked" name="SelectedNodeIDArray[]" value="' + calEvent.content.metadata.mainNodeId + '" />' + i18n(calEvent.content.data, 'titolo') + '</label></div>');
            }
        },
        events: {
            url: tools.settings().endpoint.fullcalendar,
            data: function () {
                return {q: mainQuery};
            }
        }
    });
</script>
{/literal}
