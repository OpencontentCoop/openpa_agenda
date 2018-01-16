{ezcss_require( array(
    'plugins/chosen.css',
    'dataTables.bootstrap.css',
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'plugins/chosen.jquery.js',
    'moment.min.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap.js',
    'jquery.opendataDataTable.js',
    'jquery.opendataTools.js',
    'openpa_agenda_associazioni.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'Control.Geocoder.js'
))}

<script type="text/javascript" language="javascript" class="init">
  $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
  $.opendataTools.settings('endpoint',{ldelim}
      geo: '{'/opendata/api/geo/search/'|ezurl(no,full)}',
      search: '{'/opendata/api/content/search/'|ezurl(no,full)}',
      class: '{'/opendata/api/classes/'|ezurl(no,full)}'
  {rdelim});
</script>
{literal}
    <style>
        .chosen-search input, .chosen-container-multi input{height: auto !important}
    </style>
{/literal}

<section class="hgroup">
    <h1>
        Associazioni
    </h1>
</section>

<div class="content-view-full class-folder clearfix">

    <div class="spinner text-center">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">Loading...</span>
    </div>

    <div class="content-main wide" style="display: none">
        <div class="clearfix">
            <ul class="nav nav-pills space pull-left">
                <li class="active"><a data-toggle="tab" href="#table"><i class="fa fa-list" aria-hidden="true"></i> Lista</a></li>
                <li><a data-toggle="tab" href="#geo"><i class="fa fa-map-marker" aria-hidden="true"></i> Mappa</a></li>
            </ul>
            <div class="nav-section space pull-right" style="display: none"></div>
        </div>
        <div class="tab-content">
            <div id="table" class="tab-pane active"><div class="content-data"></div></div>
            <div id="geo" class="tab-pane">
                <div id="map" style="width: 100%; height: 700px"></div>
            </div>
        </div>
    </div>


</div>
