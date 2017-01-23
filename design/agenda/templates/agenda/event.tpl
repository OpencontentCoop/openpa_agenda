{ezcss_require( 'star_rating.css' )}
{ezscript_require( array( 'ezjsc::jquery', 'ezjsc::jqueryio', 'ezstarrating_jquery.js', 'readmore.min.js' ) )}
{def $reply_limit=20
     $reply_tree_count = fetch('content','tree_count', hash( parent_node_id, $node.node_id ) )
     $reply_count=fetch('content','list_count', hash( parent_node_id, $node.node_id ) )}


<div class="agenda-view-full">
    <div class="row">
        <div class="col-md-12 calendar_teaser">

            <div class="row">
                <div class="col-md-1 space">
                    <div class="calendar-date center-block">
                        <span class="month">{$node.data_map.from_time.content.timestamp|datetime( 'custom', '%M' )}</span>
                        <span class="day">{$node.data_map.from_time.content.timestamp|datetime( 'custom', '%j' )}</span>
                    </div>
                </div>
                <div class="col-md-9">
                    <h1>
                        {$node.data_map.titolo.content|wash()}
                        {if $node.object.can_edit}
                        <a href="{concat('editorialstuff/edit/agenda/',$node.contentobject_id)|ezurl('no')}">
                            <i class="fa fa-edit"></i>
                        </a>
                        {/if}
                    </h1>
                </div>
                <div class="col-md-2">
                    {def $attribute = $node.data_map.rating}
                    {def $rating = $attribute.content}

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
        <div class="col-md-12">
            <div class="text-center">
            {if $node|has_attribute( 'images' )}
                {include uri='design:atoms/image.tpl' item=fetch(content,object,hash(object_id, $node|attribute('images').content.relation_list[0].contentobject_id)) image_class=imagefull alignment="center" image_css_class="img-responsive"}
            {elseif $node|has_attribute( 'image' )}
                {include uri='design:atoms/image.tpl' item=$node image_class=imagefull alignment="center" image_css_class="img-responsive"}
            {/if}
            </div>
        </div>
    </div>

    {def $luogo = false()}                      
    {if $node|has_attribute( 'luogo' )}                          
      {set $luogo = fetch('content','node',hash('node_id', $node.data_map.luogo.content.relation_list[0].node_id))}                        
    {/if}

    <div class="service_teasers row space">

        <div class="col-md-4">
            <div class="service_teaser vertical notitle">
                <div class="service_details">

                    <p> <i class="fa fa-map-marker"></i>
                        <strong>Dove</strong>

                        {if $luogo}
                            {$luogo.name|wash()}                            
                            {if $luogo|has_attribute( 'indirizzo')}
                              {$luogo|attribute( 'indirizzo' ).content}
                            {/if}
                            
                            {if $luogo|has_attribute( 'comune' )}                                
                              {$luogo|attribute( 'comune' ).content}
                            {/if}
                            
                        {else}

                          {if $node|has_attribute( 'indirizzo' )}
                              {$node.data_map.indirizzo.content}
                          {/if}
                          {if $node|has_attribute( 'luogo_svolgimento' )}
                              {$node.data_map.luogo_svolgimento.content}
                          {/if}
                          {if $node|has_attribute( 'comune' )}
                              {*if $node|has_attribute( 'cap' )}
                                {$node.data_map.cap}
                              {/if*}
                              {$node.data_map.comune.content}
                          {/if}

                        {/if}

                    </p>

                    {if $node|has_attribute( 'periodo_svolgimento' )}
                        <p> <i class="fa fa-calendar-o"></i>
                            <strong>{$node.data_map.periodo_svolgimento.contentclass_attribute_name}</strong>
                            {$node.data_map.periodo_svolgimento.content}
                        </p>
                    {else}
                        <p> <i class="fa fa-calendar-o"></i>
                            {include uri='design:atoms/dates.tpl' item=$node}
                        </p>
                    {/if}

                    {if $node|has_attribute( 'orario_svolgimento' )}
                        <p> <i class="fa fa-clock-o"></i>
                            <strong>{$node.data_map.orario_svolgimento.contentclass_attribute_name}</strong>
                            {$node.data_map.orario_svolgimento.content}
                        </p>
                    {/if}

                    {if $node|has_attribute( 'durata' )}
                        <p> <i class="fa fa-clock-o"></i>
                            <strong>{$node.data_map.durata.contentclass_attribute_name}</strong>
                            {$node.data_map.durata.content}
                        </p>
                    {/if}

                    {if $node|has_attribute( 'iniziativa' )}
                        <div class="well well-sm">
                            <p> <i class="fa fa-link"></i>
                            <strong>parte di </strong> {attribute_view_gui attribute=$node|attribute( 'iniziativa' ) show_link=true()}
                        </div>
                    {/if}

                    {if $node|has_attribute( 'costi' )}
                        <p>
                            <i class="fa fa-money"></i>
                            <strong>{$node.data_map.costi.contentclass_attribute_name}</strong>
                            {$node.data_map.costi.content}
                        </p>
                    {/if}

                    {if $node|has_attribute( 'file' )}
                        <p>
                            <i class="fa fa-file"></i>
                            <strong>{$node.data_map.file.contentclass_attribute_name}</strong><br />
                            {attribute_view_gui attribute=$node.data_map.file}
                        </p>
                    {/if}

                </div>
            </div>
        </div>

        <div class="col-md-4">


            {if or($node|has_attribute( 'indirizzo' ),
                   $node|has_attribute( 'luogo_svolgimento' ),
                   $node|has_attribute( 'comune' ),
                   $node|has_attribute( 'geo' ))}

                {def $geo_attribute = false()}
                {if and( $luogo, $luogo|has_attribute( 'geo' ) )}
                  {set $geo_attribute = $luogo|attribute( 'geo' )}
                {elseif $node|has_attribute( 'geo' )}
                  {set $geo_attribute = $node|attribute( 'geo' )}
                {/if}
                
                {if $geo_attribute}
                    {if and( $geo_attribute.content.latitude, $geo_attribute.content.longitude )}

                        {ezscript_require( array( 'ezjsc::jquery', 'leaflet/leaflet.0.7.2.js', 'leaflet/Leaflet.MakiMarkers.js', 'leaflet/leaflet.markercluster.js') )}
                        {ezcss_require( array( 'leaflet/leaflet.css', 'leaflet/map.css', 'leaflet/MarkerCluster.css', 'leaflet/MarkerCluster.Default.css' ) )}

                        <div id="map-{$geo_attribute.id}" style="width: 100%; height: 300px;"></div>
                        <p class="goto space text-center">
                            <a class="btn btn-lg btn-success" target="_blank" href="https://www.google.com/maps/dir//'{$geo_attribute.content.latitude},{$geo_attribute.content.longitude}'/@{$geo_attribute.content.latitude},{$geo_attribute.content.longitude},15z?hl=it">Come arrivare <i class="fa fa-external-link"></i></a>
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
                            drawMap([{$geo_attribute.content.latitude},{$geo_attribute.content.longitude}],{$geo_attribute.id});
                        </script>

                    {/if}
                    {undef $geo_attribute}
                {/if}

            {/if}
        </div>

        <div class="col-md-4">
            <ul class="list-group">
                {if $node|has_attribute( 'organizzazione' )}
                {def $itemObject = false()}
                <li class="list-group-item"><i class="fa fa-group"></i> {foreach $node.data_map.organizzazione.content.relation_list as $item}{set $itemObject = fetch(content, object, hash(object_id, $item.contentobject_id))}<a href="{concat('content/view/full/',$itemObject.main_node_id)|ezurl(no)}">{$itemObject.name|wash()}</a>{delimiter}, {/delimiter}{/foreach}</li>
                {undef $itemObject}
                {/if}
                {if $node|has_attribute( 'telefono' )}
                    <li class="list-group-item"><i class="fa fa-phone"></i> {attribute_view_gui attribute=$node.data_map.telefono}</li>
                {/if}
                {if $node|has_attribute( 'fax' )}
                    <li class="list-group-item"><i class="fa fa-fax"></i> {attribute_view_gui attribute=$node.data_map.fax}</li>
                {/if}
                {if $node|has_attribute( 'email' )}
                    <li class="list-group-item"><i class="fa fa-envelope"></i> {attribute_view_gui attribute=$node.data_map.email}</li>
                {/if}
                {if $node|has_attribute( 'url' )}
                    <li class="list-group-item"><i class="fa fa-globe"></i> {attribute_view_gui attribute=$node.data_map.url}</li>
                {/if}
                {if $node|has_attribute( 'iniziativa' )}
                    {foreach $node|attribute( 'iniziativa' ).content.relation_list as $item}
                            {def $obj = fetch(content,object, hash(object_id, $item['contentobject_id']))}
                            {if $obj.can_read}
                                <li class="list-group-item"><i class="fa fa-star"></i> <a href="{concat('agenda/event/',$obj.main_node_id)|ezurl(no)}">{$obj.name|wash()}</a></li>{/if}
                            {undef $obj}
                    {/foreach}
                {/if}
            </ul>
        </div>


    </div>


    <div class="row space">
        <div class="col-md-12">

            <div class="text">
                {if $node|has_attribute('text')}
                    {attribute_view_gui attribute=$node|attribute('text')}
                {/if}
            </div>

            {if $node|has_attribute('informazioni')}
            <button class="btn btn-info btn-lg center-block space" type="button" data-toggle="collapse" data-target="#info" aria-expanded="false" aria-controls="info">
                <i class="fa fa-info-circle"></i> Maggiori informazioni
            </button>
            <div class="collapse space" id="info">
                <div class="well">
                    {attribute_view_gui attribute=$node|attribute('informazioni')}
                </div>
            </div>
            {/if}

        </div>
    </div>

    <div class="row space">
        <div class="col-md-12">
            {if $node|has_attribute('images')}
                {def $images = array()}
                {foreach $node|attribute('images').content.relation_list as $index => $item}
                    {if $index|eq(0)}{skip}{/if}
                    {set $images = $images|append(fetch(content,node, hash(node_id, $item.node_id)))}
                {/foreach}
                <div class="widget">
                    <div class="widget_content">
                        {include uri='design:atoms/carousel.tpl' root_node=$node items=$images title=false() items_per_row=3 auto_height=true() image_class=widemedium}
                    </div>
                </div>
            {/if}
        </div>
    </div>


    <div class="row space">
        <div class="col-md-12">
            <section id="calendar" class="service_teasers row"></section>
        </div>
    </div>

    {if is_comment_enabled()}
    <div class="service_teaser">
        <div class="service_details comments clearfix">
            <h2><i class="fa fa-comments"></i> {'Commenti'|i18n('agenda')}</h2>
        {if $reply_count}
            {include uri='design:agenda/comments/comments.tpl'}
        {/if}

        {if and( $comment_form, current_social_user().has_deny_comment_mode|not(), $current_reply|is_object|not() )}
            {$comment_form}
        {elseif and( $node.object.can_create, current_social_user().has_deny_comment_mode|not() )}
            {def $offset = $view_parameters.offset}
            {if is_numeric( $view_parameters.offset )|not()}
                {set $offset = 0}
            {/if}
            <div class="pull-right">
                <a class="btn btn-lg btn-primary comment-reply" href={concat("agenda/comment/", $node.node_id, "/(offset)/", $offset )|ezurl()}>{'Inserisci commento'|i18n( 'design/ocbootstrap/full/forum_topic' )}</a>
            </div>

            <form method="post" action={"content/action/"|ezurl}>
                <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
                <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
                <input type="hidden" name="NodeID" value="{$node.node_id}" />
                <input type="hidden" name="ClassIdentifier" value="comment" />
                <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
            </form>
        {else}
            <p><em>{'Per poter commentare devi essere autenticato'|i18n('agenda')}</em></p>
        {/if}

        </div>
    </div>
    {/if}


</div>


<script>
    $.opendataTools.settings('is_collaboration_enabled', {cond(is_collaboration_enabled(), 'true', 'false')});
</script>
{literal}
<script id="tpl-spinner" type="text/x-jsrender"></script>

<script id="tpl-empty" type="text/x-jsrender"></script>

<script id="tpl-load-other" type="text/x-jsrender">
<div class="col-sm-12 text-center">
  <a href="#" class="btn btn-primary btn-lg">{/literal}{'Carica altri eventi'|i18n('agenda')}{literal}</a>
</div>
</script>

<script id="tpl-event" type="text/x-jsrender">
<div class="col-md-6 space">
    <div class="service_teaser calendar_teaser vertical">
      {{if ~i18n(data,'image')}}
      <div class="service_photo">
          <figure style="background-image:url({{:~mainImageUrl(data)}})"></figure>
      </div>
      {{/if}}
      <div class="service_details">
          <div class="media">

              {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.dd') == ~formatDate(~i18n(data,'from_time'),'yyyy.MM.dd')}}
                  <div class="media-left">
                      <div class="calendar-date">
                        <span class="month">{{:~formatDate(~i18n(data,'from_time'),'MMM')}}</span>
                        <span class="day">{{:~formatDate(~i18n(data,'from_time'),'D')}}</span>
                      </div>
                  </div>
             {{/if}}

              <div class="media-body">
                  {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.dd') !== ~formatDate(~i18n(data,'from_time'),'yyyy.MM.dd')}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'from_time'),'D MMMM')}} - {{:~formatDate(~i18n(data,'to_time'),'D MMMM')}}
                  {{/if}}
                   <h2 class="section_header skincolored">
                      <a href="{{:~agendaUrl(metadata.mainNodeId)}}">
                          <b>{{:~i18n(data,'titolo')}}</b>
                          <small>{{:~i18n(data,'luogo_svolgimento')}} {{:~i18n(data,'orario_svolgimento')}}</small>
                      </a>
                  </h2>
              </div>
          </div>

          {{if ~i18n(data,'periodo_svolgimento')}}
              <small class="periodo_svolgimento">
                  {{:~i18n(data,'periodo_svolgimento')}}
              </small>
          {{/if}}
          {{if ~i18n(data,'abstract')}}
              {{:~i18n(data,'abstract')}}
          {{/if}}

          <p class="pull-left">
              <small class="tipo_evento">
              {{for ~i18n(data,'tipo_evento')}}
                  <span class="type-{{>id}}">
                      {{>~i18n(name)}}
                  </span>
              {{/for}}
              </small>
          </p>
          {{if ~settings('is_collaboration_enabled')}}
          <p class="pull-right">
              <small>
              {{for ~i18n(data,'organizzazione')}}
                  <a class="btn btn-success btn-xs type-{{>id}}" href="{{:~associazioneUrl(id)}}">
                      {{>~i18n(name)}}
                  </a>
              {{/for}}
              </small>
          </p>
          {{/if}}

      </div>
    </div>
</div>
</script>
{/literal}

{include
    uri='design:agenda/parts/calendar.tpl'
    current_language=$node.object.current_language
    base_query=concat('classes [event] and subtree [', $calendar_node_id, '] and iniziativa.id in [', $node.contentobject_id, '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc] facets [tipo_evento|alpha|100,target|alpha|10,iniziativa|count|10]')
}
