<div class="agenda-view-full">
  <div class="row">
    <div class="col-md-12 calendar_teaser">

      <div class="row">
        <div class="col-md-10">
          <h1>
            {$node.data_map.nome.content|wash()}
            {if $node.object.can_edit}
              <a href="{concat('editorialstuff/edit/associazione/',$node.contentobject_id)|ezurl('no')}">
                <i class="fa fa-edit"></i>
              </a>
            {/if}
          </h1>
        </div>
        <div class="col-md-2">
          {def $attribute = $node.data_map.rating}
          {def $rating = $attribute.content}

          {if eq($attribute.contentclass_attribute_identifier, 'rating')}
            {if $attribute.data_int|not()}
              <div class="hreview-aggregate like_rating  center-block">
                <ul id="ezsr_rating_{$attribute.id}" class="ezsr-star-rating">
                  <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating"
                      style="width:{$rating.rounded_average|div(1)|mul(100)}%;">{'Currently %current_rating out of 5 Stars.'|i18n('extension/ezstarrating/datatype', '', hash( '%current_rating', concat('<span>', $rating.rounded_average|wash, '</span>') ))}</li>
                  {for 1 to 1 as $num}
                    <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}"
                           class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
                  {/for}
                </ul>
                <span id="ezsr_total_{$attribute.id}">{$rating.rating_count|wash}</span>
                {*<p id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">{'Thank you for rating!'|i18n('extension/ezstarrating/datatype', 'When rating')}</p>
                <p id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">Hai già votato!</p>*}
              </div>
            {/if}
          {else}
            {if $attribute.data_int|not()}
              <div class="hreview-aggregate">

                {if eq($attribute.contentclass_attribute_identifier, 'star_rating')}
                  <span class="ezsr-star-rating-label">Poco chiara</span>
                {elseif eq($attribute.contentclass_attribute_identifier, 'usefull_rating')}
                  <span class="ezsr-star-rating-label">Poco utile</span>
                {else}
                  <span class="ezsr-star-rating-label">Poco</span>
                {/if}

                <ul id="ezsr_rating_{$attribute.id}" class="ezsr-star-rating">
                  <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating"
                      style="width:{$rating.rounded_average|div(4)|mul(100)}%;">Attualmente
                    <span>{$rating.rounded_average|wash}</span> su 4
                  </li>
                  {for 1 to 4 as $num}
                    <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}"
                           title="{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a>
                    </li>
                  {/for}
                </ul>

                {if eq($attribute.contentclass_attribute_identifier, 'star_rating')}
                  <span class="ezsr-star-rating-label">Molto chiara</span>
                {elseif eq($attribute.contentclass_attribute_identifier, 'usefull_rating')}
                  <span class="ezsr-star-rating-label">Molto utile</span>
                {else}
                  <span class="ezsr-star-rating-label">Molto</span>
                {/if}


                <span class="hide">Media votazione <span id="ezsr_average_{$attribute.id}"
                                                         class="average ezsr-average-rating">{$rating.rounded_average|wash}</span> su 4 ( voti <span
                    id="ezsr_total_{$attribute.id}" class="votes">{$rating.rating_count|wash}</span>)</span>
                <p id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">Grazie!</p>
                <p id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">Puoi esprimere il tuo parere una
                  volta sola</p>
                <p id="ezsr_changed_rating_{$attribute.id}" class="ezsr-changed-rating hide">Grazie per aver aggiornato
                  il tuo parere</p>
              </div>
            {/if}
          {/if}

          {undef $rating}
          {undef $attribute}
        </div>
      </div>
      <div class="row">
        <div class="col-md-8">
          <div class="text space">
            {if $node|has_attribute('abstract')}
              {attribute_view_gui attribute=$node|attribute('abstract')}
            {/if}
            {if or( $node|has_attribute('forma_giuridica'), $node|has_attribute('albo'), $node|has_attribute('numero_iscritti') )}
              <table cellpadding="4">
                {if $node|has_attribute('codice_fiscale')}
                  <tr>
                    <td><strong>{$node|attribute('codice_fiscale').contentclass_attribute.name}:</strong></td>
                    <td>
                        <small><span class="label label-primary">{attribute_view_gui attribute=$node|attribute('codice_fiscale')}</span></small>
                    </td>
                  </tr>
                {/if}
              {if $node|has_attribute('forma_giuridica')}
                <tr>
                  <td><strong>{$node|attribute('forma_giuridica').contentclass_attribute.name}:</strong></td>
                  <td>
                    {foreach $node|attribute('forma_giuridica').content.tags as $tag}
                      <small><span class="label label-primary">{$tag.keyword|wash}</span></small>
                      {delimiter} {/delimiter}
                    {/foreach}
                  </td>
                </tr>
              {/if}
              {if $node|has_attribute('albo')}
                <tr>
                  <td><strong>{$node|attribute('albo').contentclass_attribute.name}:</strong></td>
                  <td>
                    {foreach $node|attribute('albo').content.tags as $tag}
                      <small><span class="label label-primary">{$tag.keyword|wash}</span></small>
                      {delimiter} {/delimiter}
                    {/foreach}
                  </td>
                </tr>
              {/if}
                {if $node|has_attribute('numero_iscritti')}
                  <tr>
                    <td><strong>{$node|attribute('numero_iscritti').contentclass_attribute.name}:</strong></td>
                    <td>
                      {foreach $node|attribute('numero_iscritti').content.tags as $tag}
                        <small><span class="label label-primary">{$tag.keyword|wash}</span></small>
                        {delimiter} {/delimiter}
                      {/foreach}
                    </td>
                  </tr>
                {/if}
              </table>
            {/if}
          </div>
        </div>
        <div class="col-md-4">
          {if $node|has_attribute('logo')}
            <div class="text-center">
              {attribute_view_gui attribute=$node|attribute('logo') alignment='center'}
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>

  {if $node.data_map.has_site.has_content}
    {foreach $node.data_map.has_site.content.relation_list as $rel}
      {def $sede = fetch( 'content', 'object', hash( 'object_id', $rel.contentobject_id ) )}
      <div class="row">
        <div class="col-md-12"><h3>{$sede.name}</h3></div>
        <div class="col-md-8">
          {if $sede|has_attribute( 'geo' )}
            {def $attribute = $sede|attribute( 'geo' )}
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
        </div>
        <div class="col-md-4">
          {if $sede.data_map.has_contact_point.has_content}
            {foreach $sede.data_map.has_contact_point.content.relation_list as $cp_rel}
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
                {if and($node|has_attribute('json_ld'), openpaini('OpenpaAgendaSettings', 'ShowJsonLDLink', 'enabled')|eq('enabled'))}
                    <li class="list-group-item">
                        <a href="{concat('easyvocs/object/', $node.contentobject_id, '?ContentType=json')|ezurl(no)}" target="_blank">
                            <img style="border:0px;" width="24" src="https://json-ld.org/images/json-ld-data-24.png" alt="JSON-LD-logo-24"/> JSON-LD
                        </a>
                    </li>
                {/if}
              </ul>
              {undef $contact_point}
            {/foreach}
          {/if}

        </div>
      </div>
      {undef $sede}
    {/foreach}
  {/if}


  <div class="row space">
    <div class="col-md-8">

      <div class="text">
        {if $node|has_attribute('descrizione_completa')}
          {attribute_view_gui attribute=$node|attribute('descrizione_completa')}
        {/if}
      </div>

      <div class="text">
        {if $node|has_attribute('funzione_principale')}
          {attribute_view_gui attribute=$node|attribute('funzione_principale')}
        {/if}
      </div>

      {if $node|has_attribute('referenti')}
        <h5><i class="fa fa-users"></i> Referenti</h5>
        <table class="table">
          <thead>
            <tr>
              <th>Ruolo</th>
              <th>Nome</th>
              <th>Email</th>
            </tr>
          </thead>
          {foreach $node|attribute('referenti').content.relation_list as $r}
            {def $ref = fetch( 'content', 'node', hash( 'node_id', $r.node_id ) )}
            <tr>
              {if $ref|has_attribute('ruolo')}
              <td>{attribute_view_gui attribute=$ref|attribute('ruolo')}</td>
              {/if}
              {if $ref|has_attribute('nome')}
              <td>{attribute_view_gui attribute=$ref|attribute('nome')}</td>
              {/if}
              {if $ref|has_attribute('email')}
              <td>{attribute_view_gui attribute=$ref|attribute('email')}</td>
              {/if}
            </tr>
          {/foreach}
        </table>
      {/if}

      {if $node|has_attribute('contatti')}
        <button class="btn btn-info btn-lg center-block space" type="button" data-toggle="collapse" data-target="#info"
                aria-expanded="false" aria-controls="info">
          <i class="fa fa-info-circle"></i> {'More information'|i18n('agenda')}
        </button>
        <div class="collapse space" id="info">
          <div class="well">
            {attribute_view_gui attribute=$node|attribute('contatti')}
          </div>
        </div>
      {/if}

    </div>
  </div>

  <hr/>

  <div class="panel">
    <div class="panel-body">
      {include uri='design:agenda/parts/calendar/views.tpl' views=array('list','geo','agenda')}

      {include
      uri='design:agenda/parts/calendar/calendar.tpl'
      name=iniziativa_calendar
      calendar_identifier=$node.contentobject_id
      filters=array('date', 'target')
      base_query=concat('classes [',agenda_event_class_identifier(),'] and associazione.id in [', $node.contentobject_id, '] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc]')
      }
    </div>
  </div>

</div>


{if $node|has_attribute('json_ld')}
{attribute_view_gui attribute=$node|attribute('json_ld')}
{/if}
