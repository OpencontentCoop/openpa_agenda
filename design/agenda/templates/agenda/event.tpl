{include uri="design:parts/opengraph_set_persistent.tpl"}
{ezcss_require( 'star_rating.css' )}
{ezscript_require( array( 'ezjsc::jquery', 'ezjsc::jqueryio', 'ezstarrating_jquery.js' ) )}
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
                <div class="col-md-8">
                    <h1>
                        {$node.data_map.titolo.content|wash()}
                        {if $node.object.can_edit}
                        <a href="{concat('editorialstuff/edit/agenda/',$node.contentobject_id)|ezurl('no')}">
                            <i class="fa fa-edit"></i>
                        </a>
                        {/if}
                    </h1>
                </div>
                <div class="col-md-3">
                    {include uri='design:parts/common/social_control.tpl'}
                    {include uri='design:parts/common/add_to_calendar.tpl'}
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

                    {if or($luogo, $node|has_attribute( 'indirizzo' ), $node|has_attribute( 'luogo_svolgimento' ),$node|has_attribute( 'comune' ))}
					<p> <i class="fa fa-map-marker"></i>
                        <strong>{'Dove'|i18n('agenda/event')}</strong>

                        {if $luogo}
                            {$luogo.name|wash()}                            
                            {if $luogo|has_attribute( 'indirizzo')}{if $luogo.data_map.indirizzo.content|ne($luogo.data_map.title.content)} ,{$luogo|attribute('indirizzo' ).content}{/if}{/if}
                            {if $luogo|has_attribute( 'comune' )} {$luogo|attribute( 'comune' ).content}{/if}
                        {else}

                          {if $node|has_attribute( 'luogo_svolgimento' )}
                              {$node.data_map.luogo_svolgimento.content}
                          {/if}
                          {if $node|has_attribute( 'comune' )}
                              {$node.data_map.comune.content}
                          {/if}

                        {/if}

                    </p>
					{/if}

                    {if $node|has_attribute( 'periodo_svolgimento' )}
                        <p> <i class="fa fa-calendar-o"></i>
                            <strong>{$node.data_map.periodo_svolgimento.contentclass_attribute_name}</strong>
                            {$node.data_map.periodo_svolgimento.content}
                        </p>
                    {else}
                        <p> <i class="fa fa-calendar-o"></i>
                            {include uri='design:atoms/dates.tpl' item=$node show_time=cond($node|has_attribute( 'orario_svolgimento' ),false(),true())}
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

                        {foreach $node|attribute( 'iniziativa' ).content.relation_list as $item}
                            {def $obj = fetch(content,object, hash(object_id, $item['contentobject_id']))}
                            {if $obj.can_read}
                            <div class="well well-sm">
                                <i class="fa fa-link"></i> <strong>parte di </strong> <a href="{concat('agenda/event/',$obj.main_node_id)|ezurl(no)}">{$obj.name|wash()}</a>
                            </div>
							{/if}
                            {undef $obj}
                        {/foreach}

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

				  <div id="event-map-{$geo_attribute.id}" style="width: 100%; height: 300px;"></div>
				  <p class="goto space text-center">
					  <a class="btn btn-lg btn-success" target="_blank" href="https://www.google.com/maps/dir//'{$geo_attribute.content.latitude},{$geo_attribute.content.longitude}'/@{$geo_attribute.content.latitude},{$geo_attribute.content.longitude},15z?hl=it">{'Come arrivare'|i18n('agenda/event')} <i class="fa fa-external-link"></i></a>
				  </p>

			  {run-once}
			  {literal}
				  <script type="text/javascript">
					  var drawMap = function(latlng,id){
						  var map = new L.Map('event-map-'+id);
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
        </div>

        <div class="col-md-4">
            <ul class="list-group">
                {def $associazione_identifier = 'associazione'}
                {if $node|has_attribute( 'organizzazione' )}
                    {set $associazione_identifier = 'organizzazione'}
                {/if}
                {if $node|has_attribute( $associazione_identifier )}
                {foreach $node|attribute( $associazione_identifier ).content.relation_list as $item}
				<li class="list-group-item">
				  <i class="fa fa-group"></i>
				  {def $itemObject = fetch(content, object, hash(object_id, $item.contentobject_id))}
				  {if and($itemObject.class_identifier|eq('associazione'), is_collaboration_enabled())}
					<a href="{concat('content/view/full/',$itemObject.main_node_id)|ezurl(no)}">{$itemObject.name|wash()}</a>
				  {else}
					{$itemObject.name|wash()}
				  {/if}
                  {undef $itemObject}
				</li>
				{/foreach}
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
            <div class="space" id="info">
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
