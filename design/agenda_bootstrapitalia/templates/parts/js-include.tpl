{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{ezscript_require(array(
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'fullcalendar/core/main.js',
    concat('fullcalendar/core/locales/', $moment_language, '.js'),
    'fullcalendar/daygrid/main.js',
    'fullcalendar/list/main.js',
    'openpa_agenda_helpers.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'fullcalendar/core/main.css',
    'fullcalendar/daygrid/main.css',
    'fullcalendar/list/main.css'
))}

<script>
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    {if $current_language|ne('eng-GB')}
        $.opendataTools.settings('fallbackLanguage', "eng-GB");
    {/if}
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
    $.opendataTools.settings('base_query', "{$base_query}");
    $.opendataTools.settings('locale', "{$moment_language}");
    $.opendataTools.settings('is_collaboration_enabled', {cond(is_collaboration_enabled(), 'true', 'false')});
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/extrageo/search/'|ezurl(no,full)}/',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}/',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}/',
        'tags_tree': '{'/opendata/api/tags_tree/'|ezurl(no,full)}/',
        'fullcalendar': '{'/opendata/api/calendar/search/'|ezurl(no,full)}/'
    {rdelim});
</script>
