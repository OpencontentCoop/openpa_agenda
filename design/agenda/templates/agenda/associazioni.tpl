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
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'Control.Geocoder.js'
))}

<script type="text/javascript" language="javascript" class="init">
	var baseUri = '{'/'|ezurl(no)}';
    var mainQuery = 'classes [associazione]';
    $.opendataTools.settings('accessPath', "{'/'|ezurl(no)}");
    $.opendataTools.settings('endpoint',{ldelim}
        geo: {'/opendata/api/geo/search/'|ezurl()},
        search: {'/opendata/api/content/search/'|ezurl()},
        class: {'/opendata/api/classes/'|ezurl()}
    {rdelim});
    {literal}

    var facets = [
        {field: 'categoria', 'limit': 300, 'sort': 'alpha', name: 'Categoria'},
        {field: 'argomento.name', 'limit': 300, 'sort': 'alpha', name: 'Argomento'}
    ];

    $(document).ready(function () {
        var tools = $.opendataTools;

        mainQuery += ' facets ['+tools.buildFacetsString(facets)+']';

        var datatable;
        var map = tools.initMap(
                'map',
                function (response) {
                    return L.geoJson(response, {
                        pointToLayer: function (feature, latlng) {
                            iconaSede = "warehouse";
                            coloreSede = '#f00';
                            customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                            return L.marker(latlng, {icon: customIcon});
                        },
                        onEachFeature: function (feature, layer) {
                            var popupDefault = '<h4><a href="' + tools.settings('accessPath') + '/content/view/full/' + feature.properties.mainNodeId + '" target="_blank">';
                            popupDefault += feature.properties.name;
                            popupDefault += '</a></h4>';
                            var popup = new L.Popup({maxHeight: 360});
                            popup.setContent(popupDefault);
                            layer.bindPopup(popup);
                        }
                    });
                }
        );

        /**
         * Inizialiazzaione di OpendataDataTable (wrapper di jquery datatable)
         */
        datatable = $('.content-data').opendataDataTable({
                    "builder":{
                        "query": mainQuery
                    },
                    "datatable":{
                        "language": {
                            "url": "//cdn.datatables.net/plug-ins/1.10.12/i18n/Italian.json"
                        },
                        "ajax": {
                            url: baseUri+"/opendata/api/datatable/search/"
                        },
                        "columns": [
                            {"data": "data."+tools.settings('language')+".titolo", "name": 'titolo', "title": 'Titolo'},
                            {"data": "data."+tools.settings('language')+".localita", "name": 'localita', "title": 'Localita'},
                            {"data": "data."+tools.settings('language')+".contatti", "name": 'contatti', "title": 'Contatti'}
                        ],
                        "columnDefs": [
                            {
                                "render": function ( data, type, row ) {
                                    return '<a href="'+baseUri+'/agenda/associazioni/'+row.metadata.mainNodeId+'">'+data+'</a>';
                                },
                                "targets": [0]
                            }
                        ]
                    },
                    "loadDatatableCallback": function(self){
                        var input = $('.dataTables_filter input');
                        input.unbind().attr('placeholder','Premi invio per cercare');
                        input.bind('keyup', function(e) {
                            if(e.keyCode == 13) {
                                self.datatable.search(this.value).draw();
                            }
                        });
                    }
                })
                .on('xhr.dt', function ( e, settings, json, xhr ) {

                    $.each(json.facets, function(index,val){
                        // aggiorna le select delle faccette in base al risultato (json)
                        var facet = this;
                        tools.refreshFilterInput(facet, function(select){
                            select.trigger("chosen:updated");
                        });

                    });

                    var spinnerContainer = $('a[href="#geo"]');
                    var currentText = spinnerContainer.html();
                    var spinner = $('#tab-spinner');
                    if (spinner.length == 0) {
                        spinner = $('<span id="tab-spinner"></span>');
                        spinnerContainer.append(spinner);
                    }
                    spinner.html('<i class="fa fa-circle-o-notch fa-spin fa-fw"></i>');
                    tools.loadMarkersInMap(datatable.buildQuery(true), function(data){
                        spinner.html(' ('+data.features.length+')');
                    });
                })
                .data('opendataDataTable');


        tools.find(mainQuery + ' limit 1', function(response){
            $('.spinner').hide();
            $('.content-main').show();

            datatable.loadDataTable();

            var form = $('<form class="form-inline">');
            $.each(response.facets, function(){
                tools.buildFilterInput(facets, this, datatable, function(selectContainer){
                    form.append(selectContainer);
                });
            });

            $('.nav-section').append(form).show();
        });

        $("body").on("shown.bs.tab", function() {
            tools.refreshMap();
        });

    });

    {/literal}
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

<div class="content-view-full class-folder">

    <div class="spinner text-center">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">Loading...</span>
    </div>

    <div class="content-main" style="display: none">
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
