<div class="agenda-view-full">
    <div class="row">
        <div class="col-md-12 calendar_teaser">

            <div class="row">
                <div class="col-md-10">
                    <h1>
                        {$node.data_map.titolo.content|wash()}
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
                                    <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating" style="width:{$rating.rounded_average|div(1)|mul(100)}%;">{'Currently %current_rating out of 5 Stars.'|i18n('extension/ezstarrating/datatype', '', hash( '%current_rating', concat('<span>', $rating.rounded_average|wash, '</span>') ))}</li>
                                    {for 1 to 1 as $num}
                                        <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
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
                                    <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating" style="width:{$rating.rounded_average|div(4)|mul(100)}%;">Attualmente <span>{$rating.rounded_average|wash}</span> su 4</li>
                                    {for 1 to 4 as $num}
                                        <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}" title="{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
                                    {/for}
                                </ul>

                                {if eq($attribute.contentclass_attribute_identifier, 'star_rating')}
                                    <span class="ezsr-star-rating-label">Molto chiara</span>
                                {elseif eq($attribute.contentclass_attribute_identifier, 'usefull_rating')}
                                    <span class="ezsr-star-rating-label">Molto utile</span>
                                {else}
                                    <span class="ezsr-star-rating-label">Molto</span>
                                {/if}


                                <span class="hide">Media votazione <span id="ezsr_average_{$attribute.id}" class="average ezsr-average-rating">{$rating.rounded_average|wash}</span> su 4 ( voti <span id="ezsr_total_{$attribute.id}" class="votes">{$rating.rating_count|wash}</span>)</span>
                                <p id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">Grazie!</p>
                                <p id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">Puoi esprimere il tuo parere una volta sola</p>
                                <p id="ezsr_changed_rating_{$attribute.id}" class="ezsr-changed-rating hide">Grazie per aver aggiornato il tuo parere</p>
                            </div>
                        {/if}
                    {/if}

                    {undef $rating}
                    {undef $attribute}
                </div>
            </div>
            <div class="text space">
                {if $node|has_attribute('abstract')}
                    {attribute_view_gui attribute=$node|attribute('abstract')}
                {/if}
            </div>

        </div>
    </div>

    <div class="row">
        <div class="col-md-4">
            {if is_set( $openpa.content_main.parts.image )}
                <div class="text-center">
                    {include uri='design:atoms/image.tpl' item=$node image_class=imagefull alignment="center" image_css_class="img-responsive"}
                </div>
            {/if}
        </div>

        <div class="col-md-4">
            {if $node|has_attribute( 'geo' )}
                {def $attribute = $node|attribute( 'geo' )}
                {if and( $attribute.content.latitude, $attribute.content.longitude )}

                    {ezscript_require( array( 'ezjsc::jquery', 'leaflet/leaflet.0.7.2.js', 'leaflet/Leaflet.MakiMarkers.js', 'leaflet/leaflet.markercluster.js') )}
                    {ezcss_require( array( 'leaflet/leaflet.css', 'leaflet/map.css', 'leaflet/MarkerCluster.css', 'leaflet/MarkerCluster.Default.css' ) )}

                    <div id="map-{$attribute.id}" style="width: 100%; height: 300px;"></div>
                    <p class="goto space text-center">
                        <a class="btn btn-lg btn-success" target="_blank" href="https://www.google.com/maps/dir//'{$attribute.content.latitude},{$attribute.content.longitude}'/@{$attribute.content.latitude},{$attribute.content.longitude},15z?hl=it">Come arrivare <i class="fa fa-external-link"></i></a>
                    </p>

                {run-once}
                {literal}
                    <script type="text/javascript">
                        var drawMap = function(latlng,id){
                            var map = new L.Map('map-'+id);
                            map.scrollWheelZoom.disable();
                            var customIcon = L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"});
                            var postMarker = new L.marker(latlng,{icon:customIcon});
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
            <ul class="list-group">

                <li class="list-group-item"><i class="fa fa-map-marker"></i>
                    {attribute_view_gui attribute=$node.data_map.indirizzo}
                    {attribute_view_gui attribute=$node.data_map.cap}
                    {attribute_view_gui attribute=$node.data_map.localita}
                    {if $node|has_attribute( 'presso' )}presso {attribute_view_gui attribute=$node.data_map.presso}{/if}
                </li>

                <li class="list-group-item"><i class="fa fa-phone"></i>
                    {attribute_view_gui attribute=$node.data_map.telefono}
                    {attribute_view_gui attribute=$node.data_map.numero_telefono1}
                </li>

                {if $node|has_attribute( 'fax' )}
                    <li class="list-group-item"><i class="fa fa-fax"></i> {attribute_view_gui attribute=$node.data_map.fax}</li>
                {/if}

                {if $node|has_attribute( 'casella_postale' )}
                    <li class="list-group-item"><i class="fa fa-inbox"></i> {attribute_view_gui attribute=$node.data_map.casella_postale}</li>
                {/if}

                {if $node|has_attribute( 'email' )}
                    <li class="list-group-item"><i class="fa fa-envelope"></i> {attribute_view_gui attribute=$node.data_map.email}</li>
                {/if}
                {if $node|has_attribute( 'url' )}
                    <li class="list-group-item"><i class="fa fa-globe"></i> {attribute_view_gui attribute=$node.data_map.url}</li>
                {/if}
            </ul>
        </div>

    </div>


    <div class="row space">
        <div class="col-md-12">

            <div class="text">
                {if $node|has_attribute('scheda')}
                    {attribute_view_gui attribute=$node|attribute('scheda')}
                {/if}
            </div>

            {if $node|has_attribute('contatti')}
                <button class="btn btn-info btn-lg center-block space" type="button" data-toggle="collapse" data-target="#info" aria-expanded="false" aria-controls="info">
                    <i class="fa fa-info-circle"></i> Maggiori informazioni
                </button>
                <div class="collapse space" id="info">
                    <div class="well">
                        {attribute_view_gui attribute=$node|attribute('contatti')}
                    </div>
                </div>
            {/if}

        </div>
    </div>

    <hr />

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

