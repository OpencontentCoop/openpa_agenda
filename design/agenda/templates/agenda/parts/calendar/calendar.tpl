{ezscript_require( array(
    'ezjsc::jquery',
    'jquery.opendataTools.js',
    'moment-with-locales.min.js',
    'bootstrap-datepicker/bootstrap-datepicker.js',
    'bootstrap-datepicker/locales/bootstrap-datepicker.it.min.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'fullcalendar/fullcalendar.js',
    'fullcalendar/locale/it.js',
    'fullcalendar/locale/de.js',
    'fullcalendar/locale/en.js',
    'openpa_agenda_helpers.js',
    'jquery.opendataSearchView.js',
    'openpa_agenda_filters/base.js',
    'openpa_agenda_filters/type_tree.js',
    'openpa_agenda_filters/type.js',
    'openpa_agenda_filters/date.js',
    'openpa_agenda_filters/target.js',
    'openpa_agenda_filters/iniziativa.js',
    'openpa_agenda_filters/where_tree.js',
    'openpa_agenda_filters/theme_tree.js',
    'openpa_agenda.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'bootstrap-datepicker/bootstrap-datepicker.min.css',
    'fullcalendar.min.css'
))}

{def $filterDefinitions = hash(
    'date','OpenpaAgendaDateFilter',
    'target','OpenpaAgendaTargetFilter',
    'iniziativa','OpenpaAgendaIniziativaFilter'
)}
{def $has_tags_tipo = false()
     $has_tags_luogo = false()
     $has_tags_theme = false()}
{foreach api_class(agenda_event_class_identifier()).fields as $field}
    {if and($field.identifier|eq('tipo_evento'), $field.dataType|eq('eztags'))}
        {set $has_tags_tipo = true()}
    {/if}
    {if and($field.identifier|eq('luogo_evento'), $field.dataType|eq('eztags'))}
        {set $has_tags_luogo = true()}
    {/if}
    {if and($field.identifier|eq('tematica_evento'), $field.dataType|eq('eztags'))}
      {set $has_tags_theme = true()}
    {/if}
{/foreach}
{* Tipo *}
{if $has_tags_tipo}
    {set $filterDefinitions = $filterDefinitions|merge(hash('type', 'OpenpaAgendaTypeTreeFilter'))}
{else}
    {set $filterDefinitions = $filterDefinitions|merge(hash('type', 'OpenpaAgendaTypeFilter'))}
{/if}
{* Luogo *}
{if $has_tags_luogo}
    {set $filterDefinitions = $filterDefinitions|merge(hash('where', 'OpenpaAgendaWhereTreeFilter'))}
{/if}
{* Tematica *}
{if $has_tags_theme}
  {set $filterDefinitions = $filterDefinitions|merge(hash('theme', 'OpenpaAgendaThemeTreeFilter'))}
{/if}

{if is_set($filters)|not()}{def $filters = array()}{/if}
{undef $has_tags_tipo $has_tags_luogo $has_tags_theme}

{def $current_language=ezini('RegionalSettings', 'Locale')}
{def $moment_language = $current_language|explode('-')[1]|downcase()}

<script>
    moment.locale('{$moment_language}');
    $.opendataTools.settings('is_collaboration_enabled', {cond(is_collaboration_enabled(), 'true', 'false')});
    $.opendataTools.settings('onError', function(errorCode,errorMessage,jqXHR){ldelim}
        console.log(errorMessage + ' (error: '+errorCode+')');
        $("#calendar").html('<div class="alert alert-danger">'+errorMessage+'</div>');
        {rdelim});
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}/',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}/',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}/',
        'tags_tree': '{'/opendata/api/tags_tree/'|ezurl(no,full)}/',
        'fullcalendar': '{'/opendata/api/fullcalendar/search/'|ezurl(no,full)}/'
    {rdelim});
    {if is_set($calendar_identifier)}
        $.opendataTools.settings('session_key','agenda-{$calendar_identifier}-{$current_language}');
    {/if}
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('base_query', "{$base_query}");
    $.opendataTools.settings('locale', "{$moment_language}");

    $(document).ready(function () {ldelim}
        $("#calendar").initSearchView().data('opendataSearchView'){foreach $filters as $filter}{if is_set($filterDefinitions[$filter])}.addFilter({$filterDefinitions[$filter]}){/if}{/foreach}.init().doSearch();
    {rdelim});


</script>


{literal}
<style>
    .patronage small span::before {content: "{/literal}{'Patrocinato da'|i18n('agenda')}{literal} ";}
</style>
{/literal}

{include uri='design:agenda/parts/calendar/tpl-spinner.tpl'}
{include uri='design:agenda/parts/calendar/tpl-empty.tpl'}
{include uri='design:agenda/parts/calendar/tpl-load-other.tpl'}
{include uri='design:agenda/parts/calendar/tpl-event.tpl'}

<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
        </div>
    </div>
</div>
