<section class="hgroup">
    <h1>{'Gestisci eventi'|i18n('agenda/dashboard')}</h1>
</section>

{ezcss_require( array(
    'plugins/chosen.css',
    'dataTables.bootstrap.css',
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css',
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
    'fullcalendar/fullcalendar.min.js',
    'fullcalendar/locale/it.js',
    'fullcalendar/locale/de.js',
    'fullcalendar/locale/en.js',
    'openpa_agenda_fullcalendar.js',
    'openpa_agenda_dashboard.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'Control.Geocoder.js'
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
        'Titolo':'{'Titolo'|i18n('agenda/dashboard')}',
        'Pubblicato':'{'Pubblicato'|i18n('agenda/dashboard')}',
        'Inizio': '{'Inizio'|i18n('agenda/dashboard')}',
        'Fine': '{'Fine'|i18n('agenda/dashboard')}',
        'Stato': '{'Stato'|i18n('agenda/dashboard')}',
        'Traduzioni': '{'Traduzioni'|i18n('agenda/dashboard')}',
        'Dettaglio': '{'Dettaglio'|i18n('agenda/dashboard')}',
        'Loading...': '{'Loading...'|i18n('agenda/dashboard')}'
    {rdelim};

</script>
{literal}
<style>
    .chosen-search input, .chosen-container-multi input{height: auto !important}
    .label-skipped {  background-color: #999;  }
    .label-waiting {  background-color: #f0ad4e;  }
    .label-accepted {  background-color: #5cb85c;  }
    .label-refused {  background-color: #d9534f;  }
</style>
{/literal}


<div class="content-view-full class-folder">
    <div class="content-main">
      
        {if $factory_configuration.CreationRepositoryNode}
          <p><a href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}" class="btn btn-lg btn-success">{$factory_configuration.CreationButtonText|wash()|i18n('agenda/dashboard')}</a></p>
        {/if}

        {*$states|attribute(show))*}


        <div class="clearfix">
            <ul class="nav nav-pills space pull-left">
                <li class="active"><a data-toggle="tab" href="#table"><i class="fa fa-list" aria-hidden="true"></i> {'Lista'|i18n('agenda/dashboard')}</a></li>
                <li><a data-toggle="tab" href="#calendar"><i class="fa fa-calendar" aria-hidden="true"></i> {'Calendario'|i18n('agenda/dashboard')}</a></li>
            </ul>
            <div class="nav-section space pull-right">
                <form class="form-inline">
                    <div class="form-group" style="margin-bottom: 10px">
                        <label for="state">{'Filtra per stato'|i18n('agenda/dashboard')}</label>
                        <select id="state" data-field="state" data-placeholder="{'Seleziona'|i18n('agenda/dashboard')}" name="state">
                            <option value=""></option>
                            {foreach $states as $state}
                                <option value="{$state.id|wash()}" data-state_identifier="{$state.identifier|wash()}">{$state.current_translation.name|wash()}</option>
                            {/foreach}
                        </select>
                    </div>
                </form>
            </div>
        </div>

        <div class="tab-content">
            <div id="table" class="tab-pane active"><div class="content-data"></div></div>
            <div id="calendar" class="tab-pane"></div>
        </div>
    </div>


</div>


<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
        </div>
    </div>
</div>
