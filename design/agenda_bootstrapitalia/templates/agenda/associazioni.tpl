{ezpagedata_set( 'has_container', true() )}

{ezcss_require( array(
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.opendataTools.js',
    'openpa_agenda_associazioni.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js'
))}

<script type="text/javascript" language="javascript" class="init">
  $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
  $.opendataTools.settings('endpoint',{ldelim}
      geo: '{'/opendata/api/extrageo/search/'|ezurl(no,full)}',
      search: '{'/opendata/api/content/search/'|ezurl(no,full)}',
      class: '{'/opendata/api/classes/'|ezurl(no,full)}'
  {rdelim});
</script>
{literal}
    <style>
        .chosen-search input, .chosen-container-multi input{height: auto !important}
    </style>
{/literal}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>
            {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
            {include uri='design:openpa/full/parts/main_attributes.tpl'}
        </div>
    </div>
</section>

<div id="map" style="width: 100%; height: 500px" class="hide"></div>

<div class="section section-muted section-inset-shadow p-4">
    {*def $blocks = array(
        page_block(
            "",
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "6",
                "elementi_per_riga", "auto",
                "includi_classi", "private_organization",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", '',
                "color_style", "",
                "container_style", "",
                "node_id", $node.node_id
            )
        )
    )}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))*}

    {node_view_gui content_node=$node view=children view_parameters=$view_parameters}

</div>

