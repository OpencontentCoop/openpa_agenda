<section class="hgroup">
    <h1>Gestisci programma in pdf</h1>
</section>

{ezcss_require( array(
'plugins/chosen.css',
'dataTables.bootstrap.css'
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
'leaflet.js'
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

<div class="row">
    <div class="col-sm-12" id="dashboard-filters-container">
        <form class="form-inline" role="form" method="get"
              action={concat('editorialstuff/dashboard/', $factory_identifier )|ezurl()}>

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
