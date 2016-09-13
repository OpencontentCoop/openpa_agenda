<section class="hgroup noborder home-agenda">

    <div class="row home-teaser hidden-xs">
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/download/'|ezurl(no)}"><b>Programma</b></a> <small>Scarica il programma mensile in pdf</small></h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/associazioni/'|ezurl(no)}"><b>Rubrica</b> associazioni</a> <small>Registro ufficiale del comune</small></h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/info/terms/'|ezurl(no)}"">Sei un'<b>associazione</b>?</a> <small>Scopri come partecipare!</small></h2>
                </div>
            </div>
        </div>
    </div>

    <hr />

    <div class="row">
        <div class="col-sm-9">

            <div class="tab-content">
                <div id="list" class="tab-pane active">
                    <section class="service_teasers row"></section>
                </div>
                <div id="geo" class="tab-pane">
                    <div id="map" style="width: 100%; height: 700px"></div>
                </div>
            </div>

        </div>

        <div class="col-sm-3">

            <aside>
            <ul class="nav nav-pills">
                <li class="active"><a data-toggle="tab" href="#list"><i class="fa fa-calendar" aria-hidden="true"></i> Calendario</a></li>
                <li><a data-toggle="tab" href="#geo"><i class="fa fa-map-marker" aria-hidden="true"></i> Sulla mappa</a></li>
            </ul>
            </aside>

            <aside class="widget" data-filter="q" style="display: none">
                <div class="input-group">
                    <input type="text" class="form-control" placeholder="Cerca nel titolo o nel testo" name="srch-term" id="srch-term">
                    <div class="input-group-btn">
                        <button class="btn btn-default" type="submit"><i class="glyphicon glyphicon-search"></i></button>
                    </div>
                </div>
            </aside>

            <aside class="widget" data-filter="date">
                <h4>Quando?</h4>
                <div class="datepicker" id="datepicker" style="display: none"></div>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="today">Oggi</a></li>
                    <li><a href="#" data-value="weekend">Questo fine settimana</a></li>
                    <li><a href="#" data-value="next 7 days">I prossimi 7 giorni</a></li>
                    <li><a href="#" data-value="next 30 days">I prossimi 30 giorni</a></li>
                    <li><a href="#" data-value="all">Tutti</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="type">
                <h4>Cosa?</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">Tutti</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="target" style="display: none">
                <h4>Chi sei?</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">Tutti</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="iniziativa" style="display: none">
                <h4>Manifestazione</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">Tutte</a></li>
                </ul>
            </aside>

        </div>

    </div>
</section>

{ezscript_require( array(
    'ezjsc::jquery',
    'jquery.opendataTools.js',
    'moment-with-locales.min.js',
    'bootstrap-datepicker/bootstrap-datepicker.js',
    'bootstrap-datepicker/locales/bootstrap-datepicker.it.min.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'openpa_agenda.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'bootstrap-datepicker/bootstrap-datepicker.min.css'
))}


<script>
    moment.locale('it');
    $.opendataTools.settings('onError', function(errorCode,errorMessage,jqXHR){ldelim}
        console.log(errorMessage + ' (error: '+errorCode+')');
    {rdelim});
    $.opendataTools.settings('calendar_node_id', "{$calendar_node_id}");
    $.opendataTools.settings('endpoint',{ldelim}
        geo: {'/opendata/api/geo/search/'|ezurl()},
        search: {'/opendata/api/content/search/'|ezurl()},
        class: {'/opendata/api/classes/'|ezurl()}
    {rdelim});
    $.opendataTools.settings('session_key','agenda-{$site_identifier}');
    $.opendataTools.settings('event-listitem-exclude-types', ["Evento singolo4"]);
    $.opendataTools.settings('accessPath', "{$access_path}");
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('filterUrl', function(url){ldelim} return url{rdelim} );
</script>

{literal}
<style>
    .type-499{
        display: none;
    }
</style>

<script id="tpl-spinner" type="text/x-jsrender">
<div class="spinner text-center col-md-12">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">Loading...</span>
</div>
</script>
<script id="tpl-event" type="text/x-jsrender">
<div class="col-md-4">
    <div class="service_teaser calendar_teaser vertical">

        {{if data[~language].image}}
        <div class="service_photo">
            <figure style="background-image:url({{:~filterUrl(data[~language].image.url)}})"></figure>
        </div>
        {{/if}}
        <div class="service_details">

            <div class="media">
                <div class="media-left">
                    <div class="calendar-date">
                      <span class="month">{{:~formatDate(data[~language].from_time,'MMM')}}</span>
                      <span class="day">{{:~formatDate(data[~language].from_time,'D')}}</span>
                    </div>
                </div>
                <div class="media-body">
                     <h2 class="section_header skincolored">
                        <a href="{{:~agendaUrl(metadata.mainNodeId)}}">
                            <b>{{:data[~language].titolo}}</b>
                            <small>{{:data[~language].luogo_svolgimento}} {{:data[~language].orario_svolgimento}}</small>
                        </a>
                    </h2>
                </div>
            </div>

            <p>
                <small class="periodo_svolgimento">
                    {{:data[~language].periodo_svolgimento}}
                </small>
                {{:data[~language].abstract}}
            </p>

            <p class="pull-left">
                <small class="tipo_evento">
                {{for data[~language].tipo_evento}}
                    <span class="type-{{>id}}">
                        {{>name[~language]}}
                    </span>
                {{/for}}
                </small>
            </p>
            <p class="pull-right">
                <small>
                {{for data[~language].associazione}}
                    <a class="brn btn-success btn-xs type-{{>id}}" href="{{:~associazioneUrl(id)}}">
                        {{>name[~language]}}
                    </a>
                {{/for}}
                </small>
            </p>

        </div>
    </div>
</div>
</script>


{/literal}
