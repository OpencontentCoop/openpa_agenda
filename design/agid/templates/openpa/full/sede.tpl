<div class="agenda-view-full">
  <div class="row">
    <div class="col-md-12 calendar_teaser">

      <div class="row">
        <div class="col-md-12">
          <h1>
            {$node.name|wash()}
            {if $node.object.can_edit}
              <a href="{concat('editorialstuff/edit/associazione/',$node.contentobject_id)|ezurl('no')}">
                <i class="fa fa-edit"></i>
              </a>
            {/if}
          </h1>
        </div>
      </div>
      <div class="row">
        <div class="col-md-8">
          <div class="text space">
            {if $node|has_attribute('intro')}
              {attribute_view_gui attribute=$node|attribute('intro')}
            {/if}
          </div>
        </div>
        <div class="col-md-4">
          {if is_set( $openpa.content_main.parts.image )}
            <div class="text-center">
              {include uri='design:atoms/image.tpl' item=$node image_class=imagefull alignment="center" image_css_class="img-responsive"}
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-md-8">
      {if $node|has_attribute( 'geo' )}
        {def $attribute = $node|attribute( 'geo' )}
        {if and( $attribute.content.latitude, $attribute.content.longitude )}

          {ezscript_require( array( 'ezjsc::jquery', 'leaflet/leaflet.0.7.2.js', 'leaflet/Leaflet.MakiMarkers.js', 'leaflet/leaflet.markercluster.js') )}
          {ezcss_require( array( 'leaflet/leaflet.css', 'leaflet/map.css', 'leaflet/MarkerCluster.css', 'leaflet/MarkerCluster.Default.css' ) )}
          <div id="map-{$attribute.id}" style="width: 100%; height: 300px;"></div>
          <p class="goto space text-center">
            <a class="btn btn-lg btn-success" target="_blank"
               href="https://www.google.com/maps/dir//'{$attribute.content.latitude},{$attribute.content.longitude}'/@{$attribute.content.latitude},{$attribute.content.longitude},15z?hl=it">Come
              arrivare <i class="fa fa-external-link"></i></a>
          </p>
        {run-once}
        {literal}
          <script type="text/javascript">
            var drawMap = function (latlng, id) {
              var map = new L.Map('map-' + id);
              map.scrollWheelZoom.disable();
              var customIcon = L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"});
              var postMarker = new L.marker(latlng, {icon: customIcon});
              postMarker.addTo(map);
              map.setView(latlng, 15);
              L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
              }).addTo(map);
            }
          </script>
        {/literal}
        {/run-once}
          <script type="text/javascript">
            drawMap([{$attribute.content.latitude},{$attribute.content.longitude}],{$attribute.id});
          </script>
        {/if}
        {undef $attribute}
      {/if}
      <div class="text space">
        {if $node|has_attribute('description')}
          {attribute_view_gui attribute=$node|attribute('description')}
        {/if}
      </div>
    </div>
    <div class="col-md-4">
      {if $node.data_map.has_contact_point.has_content}
        {foreach $node.data_map.has_contact_point.content.relation_list as $cp_rel}
          {def $contact_point = fetch( 'content', 'object', hash( 'object_id', $cp_rel.contentobject_id ) )}
          <ul class="list-group">

            {if $contact_point|has_attribute( 'indirizzo' )}
              <li class="list-group-item"><i class="fa fa-map-marker"></i>
                {attribute_view_gui attribute=$contact_point.data_map.indirizzo}
              </li>
            {/if}

            {if or( $contact_point|has_attribute( 'telefono_principale' ), $contact_point|has_attribute( 'telefono_secondario' ))}
              <li class="list-group-item"><i class="fa fa-phone"></i>
                {attribute_view_gui attribute=$contact_point.data_map.telefono_principale}
                {attribute_view_gui attribute=$contact_point.data_map.telefono_secondario}
              </li>
            {/if}

            {if $contact_point|has_attribute( 'cellulare' )}
              <li class="list-group-item">
                <i class="fa fa-mobile"></i> {attribute_view_gui attribute=$contact_point.data_map.cellulare}
              </li>
            {/if}

            {if $contact_point|has_attribute( 'fax' )}
              <li class="list-group-item">
                <i class="fa fa-fax"></i> {attribute_view_gui attribute=$contact_point.data_map.fax}
              </li>
            {/if}

            {if $contact_point|has_attribute( 'e_mail' )}
              <li class="list-group-item">
                <i class="fa fa-envelope"></i> {attribute_view_gui attribute=$contact_point.data_map.e_mail}
              </li>
            {/if}

            {if $contact_point|has_attribute( 'pec' )}
              <li class="list-group-item">
                <i class="fa fa-envelope"></i> {attribute_view_gui attribute=$contact_point.data_map.pec}
              </li>
            {/if}

            {if $contact_point|has_attribute( 'sito_web' )}
              <li class="list-group-item">
                <i class="fa fa-globe"></i> {attribute_view_gui attribute=$contact_point.data_map.sito_web}</li>
            {/if}
          </ul>
          {undef $contact_point}
        {/foreach}
      {/if}

      {if $openpa.content_reverse_related.has_data}
        {*OGGETTI INVERSAMENTE CORRELATI*}
        {include name = reverse_related_objects
        node = $node
        title = false()
        uri = 'design:parts/reverse_related_objects.tpl'}
      {/if}

    </div>
  </div>
</div>

{if $node|has_attribute('json_ld')}
{attribute_view_gui attribute=$node|attribute('json_ld')}
{/if}