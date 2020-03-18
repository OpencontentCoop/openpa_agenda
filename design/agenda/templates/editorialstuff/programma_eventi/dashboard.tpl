<section class="hgroup">
    <h1>{'Manage PDF Programme'|i18n('agenda/menu')}</h1>
</section>

{ezcss_require( array(
    'plugins/chosen.css',
    'dataTables.bootstrap.css',
    'bootstrap-datepicker/bootstrap-datepicker.min.css',
    'fullcalendar.min.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'plugins/chosen.jquery.js',
    'moment.min.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap.js',
    'jquery.opendataDataTable.js',
    'jquery.opendataTools.js',
    'openpa_programma_eventi_dashboard.js',
    'leaflet.js',
    'moment-with-locales.min.js',
    'bootstrap-datepicker/bootstrap-datepicker.js',
    'bootstrap-datepicker/locales/bootstrap-datepicker.it.min.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'fullcalendar/fullcalendar.js',
    concat('fullcalendar/locale/', fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') )).http_locale_code|explode('-')[0]|downcase()|extract_left( 2 ), '.js'),
    'openpa_agenda_helpers.js',
    'jquery.opendataSearchView.js',
    'openpa_agenda_filters/base.js',
    'openpa_agenda_filters/type_tree.js',
    'openpa_agenda_filters/type.js',
    'openpa_agenda_filters/date.js',
    'openpa_agenda_filters/target.js',
    'openpa_agenda_filters/iniziativa.js',
    'openpa_agenda.js',
    'jsrender.js'
))}

<script type="text/javascript" language="javascript" class="init">
    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{ezini('RegionalSettings','Locale')}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}',
        'fullcalendar': '{'/opendata/api/fullcalendar/search/'|ezurl(no,full)}',
        {rdelim});

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

</script>
{literal}
    <style>
        .chosen-search input, .chosen-container-multi input{height: auto !important}
        .label-public {  background-color: #5cb85c;  }
        .label-private {  background-color: #d9534f;  }
    </style>
{/literal}

<div class="row">
    <div class="col-sm-12" id="dashboard-filters-container">
        <form class="form-inline" role="form" method="get"
              action={concat('editorialstuff/dashboard/', $factory_identifier )|ezurl()}>
            {if $states|count()}
                <div class="hide">
                    <select id="state" data-field="state" data-placeholder="{'Select'|i18n('agenda/dashboard')}" name="state" class="form-control">
                        <option value=""></option>
                        {foreach $states as $state}
                            <option value="{$state.id|wash()}" data-state_identifier="{$state.identifier|wash()}" class="label-{$state.identifier|wash()}">{$state.current_translation.name|wash()}</option>
                        {/foreach}
                    </select>
                </div>
            {/if}
            {if $factory_configuration.CreationRepositoryNode}
                <a href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}"  class="btn btn-lg btn-success">{$factory_configuration.CreationButtonText|wash()}</a>
            {/if}
        </form>
    </div>
</div>

<hr />

<div class="row editorialstuff">
  <div class="col-sm-12">
      <div class="content-data"></div>
  </div>
</div>


<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
        </div>
    </div>
</div>
