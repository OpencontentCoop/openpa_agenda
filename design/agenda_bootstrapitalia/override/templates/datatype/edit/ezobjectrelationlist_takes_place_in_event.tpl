{def $class_content=$attribute.class_content
     $parent_node_id = cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|eq( 0 )|not ), $class_content.default_placement.node_id, 1 )}

{def $visibility_states = visibility_states()}
{def $current_language = ezini('RegionalSettings', 'Locale')}

{def $public_places = api_search(concat("classes [place] subtree [",$parent_node_id,"] and state in [", $visibility_states.public.id, "] sort [name=>asc] limit 100"))}

{def $private_places = api_search(concat("classes [place] subtree [",$parent_node_id,"] and state in [", $visibility_states.private.id, "] and owner_id in [", fetch(user,current_user).contentobject_id, "] sort [name=>asc] limit 100"))}

{def $all_used_places_id_list = api_search(concat("classes [event] and owner_id in [", fetch(user,current_user).contentobject_id, "] and facets [takes_place_in.id|count|100] limit 1")).facets[0].data|array_keys}
{def $shared_places = hash('totalCount', 0)}
{if count($all_used_places_id_list)}
    {set $shared_places = api_search(concat("classes [place] subtree [",$parent_node_id,"] and state in [", $visibility_states.private.id, "] and owner_id !in [", fetch(user,current_user).contentobject_id, "] and id in [", $all_used_places_id_list|implode(','), "] sort [name=>asc] limit 100"))}
{/if}

{def $current_selection = array()}
{if ne( count( $attribute.content.relation_list ), 0)}
{foreach $attribute.content.relation_list as $item}
    {set $current_selection = $current_selection|append($item.contentobject_id)}
{/foreach}
{/if}

<input type="hidden" name="single_select_{$attribute.id}" value="1" />
<div data-place_selection_wrapper="{$attribute.id}">
    <select name="ContentObjectAttribute_data_object_relation_list_{$attribute.id}[]" class="form-control" placeholder="{'Select place'|i18n('agenda/place')}">
        <option value="no_relation" {if eq( $attribute.content.relation_list|count, 0 )} selected="selected"{/if}>{'Nowhere'|i18n( 'agenda/place' )}</option>

        {if $public_places.totalCount|gt(0)}
            <optgroup label="{'Editor choice'|i18n('agenda/place')}">
            {foreach $public_places.searchHits as $public_place}
                <option value="{$public_place.metadata.id}" {if $current_selection|contains($public_place.metadata.id )}selected="selected"{/if}>
                    {$public_place.metadata.name[$current_language]|wash}
                </option>
            {/foreach}
            </optgroup>
        {/if}

        {if $shared_places.totalCount|gt(0)}
        <optgroup label="{'Shared'|i18n('agenda/place')}">
            {foreach $shared_places.searchHits as $shared_place}
                <option value="{$shared_place.metadata.id}" {if $current_selection|contains($shared_place.metadata.id )}selected="selected"{/if}>
                    {$shared_place.metadata.name[$current_language]|wash}
                </option>
            {/foreach}
        </optgroup>
        {/if}

        <optgroup data-new_place_select="{$attribute.id}" label="{'Your own'|i18n('agenda/place')}">
            {if $private_places.totalCount|gt(0)}
                {foreach $private_places.searchHits as $private_place}
                    <option value="{$private_place.metadata.id}" {if $current_selection|contains($private_place.metadata.id )}selected="selected"{/if}>
                        {$private_place.metadata.name[$current_language]|wash}
                    </option>
                {/foreach}
            {/if}
        </optgroup>
    </select>
    <a href="#" class="btn btn-link btn-sm pl-0" data-add_custom_place="{$attribute.id}"><i class="fa fa-plus"></i> {'Add your own place'|i18n('agenda/place')}</a>
</div>


<div class="clearfix hide p-5 bg-light position-relative" data-place_gui="{$attribute.id}" data-parent="{$parent_node_id}">
    <button type="button" class="close position-absolute" style="right: 15px; top: 10px" data-dismiss_place_gui aria-hidden="true">×</button>

    <h3 class="show-alert hide">{'A place already exists with similar geolocation'|i18n('agenda/place')}</h3>

    <div id="map-{$attribute.id}" style="width: 100%; height: 300px; margin-top: 2px;"></div>

    <div class="clearfix">
        <button class="float-right btn btn-xs btn-info" name="MyLocation">{'Detect position'|i18n('agenda/place')}</button>
    </div>
    <div class="row">
        <div class="col">
            <input type="hidden"
                   name="place_osm_type_id"
                   value=""/>
            <label class="w-100"><small>{'Name'|i18n('agenda/place')}</small></label>
            <input class="place_name form-control form-control-sm"
                   type="text"
                   name="place_name"
                   value=""/>
        </div>
        <div class="address col">
            <label class="w-100"><small>{'Address'|i18n('agenda/place')}</small></label>
            <input class="place_address form-control form-control-sm"
                   type="text"
                   name="place_address"
                   value=""/>
        </div>
    </div>
    <div class="row">
        <div class="latitude col">
            <label class="w-100"><small>{'Latitude'|i18n('agenda/place')}</small></label>
            <input class="place_latitude form-control form-control-sm"
                   type="text"
                   name="place_latitude"
                   value=""/>
        </div>

        <div class="longitude col">
            <label class="w-100"><small>{'Longitude'|i18n('agenda/place')}</small></label>
            <input class="place_longitude form-control form-control-sm"
                   type="text"
                   name="place_longitude"
                   value=""/>
        </div>
    </div>
    <div class="row mt-2">
        <div class="col">
            <a data-store_place_gui class="btn btn-success btn-sm pull-right" href="#">{'Store place'|i18n('agenda/place')}</a>
            <a data-store_mine_place_gui class="show-alert hide btn btn-dark btn-sm pull-left" href="#">{'Store mine and ignore existent'|i18n('agenda/place')}</a>
            <a data-select_existent_place_gui class="show-alert hide btn btn-danger btn-sm pull-right" href="#">{'Select existent place'|i18n('agenda/place')}</a>
        </div>
    </div>
</div>

{ezcss_require('leaflet/geocoder/Control.Geocoder.css')}
{ezscript_require('leaflet/geocoder/Control.Geocoder.js')}

<script>
$.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
{literal}

(function ($, window, document, undefined) {
    'use strict';
    var pluginName = 'addPlaceGui',
        defaults = {
            'i18n': {
                search: 'Cerca',
                noResults: 'Nessun risultato'

            }
        };
    function Plugin(element, options) {

        this.settings = $.extend({}, defaults, options);
        this.container = $(element);

        this.mapId = 'map-'+this.container.data('place_gui');
        this.myLocationButton = this.container.find("[name='MyLocation']");
        this.geocoder = L.Control.Geocoder.nominatim();
        this.marker = new L.marker(new L.latLng(0, 0), {
            icon: new L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"}),
            draggable: true
        });
        this.storeButton = this.container.find('[data-store_place_gui]');
        this.storeMine = this.container.find('[data-store_mine_place_gui]');
        this.selectExistent = this.container.find('[data-select_existent_place_gui]');
        this.init();
    }
    $.extend(Plugin.prototype, {
        init: function () {
            var plugin = this;

            plugin.container.find('input').val('');
            plugin.map = new L.Map(this.mapId, {loadingControl: true}).setView(new L.latLng(0, 0), 1)
                .on('click', function (e) {
                    var target = e.latlng;
                    plugin.map.loadingControl.addLoader('lc');
                    plugin.geocoder.reverse(target, 60000000, function (data) {
                        plugin.map.loadingControl.removeLoader('lc');
                        if (data.length)
                            plugin.setMarker(target, data[0]);
                        else
                            plugin.setMarker(target);
                    });
                });
            plugin.control = L.Control.geocoder({
                collapsed: false,
                placeholder: plugin.settings.i18n.search,
                errorMessage: plugin.settings.i18n.noResults,
                suggestMinLength: 5,
                defaultMarkGeocode: false
            }).on('markgeocode', function (e) {
                plugin.setMarker(e.geocode.center, e.geocode);
                plugin.map.fitBounds(e.geocode.bbox);
            }).addTo(plugin.map);
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(plugin.map);

            plugin.marker.on('dragend', function (event) {
                plugin.removeAlert();
                var target = event.target.getLatLng();
                plugin.map.loadingControl.addLoader('lc');
                plugin.geocoder.reverse(target, 60000000, function (data) {
                    plugin.map.loadingControl.removeLoader('lc');
                    if (data.length)
                        plugin.setMarker(target, data[0]);
                    else
                        plugin.setMarker(target);
                });
            });

            plugin.container.on('osmaplocation.setMarker', function(event, data){
                plugin.setMarker(data.latLng, data.address);
                map.setView(data.latLng, 18);
            });

            plugin.myLocationButton.on('click', function (e) {
                plugin.map.loadingControl.addLoader('lc');
                plugin.map.locate({setView: true, watch: false})
                    .on('locationfound', function (e) {
                        plugin.map.loadingControl.removeLoader('lc');
                        var target = new L.latLng(e.latitude, e.longitude);
                        plugin.geocoder.reverse(target, 60000000, function (data) {
                            if (data.length)
                                plugin.setMarker(target, data[0]);
                            else
                                plugin.setMarker(target);
                        });
                    })
                    .on('locationerror', function (e) {
                        plugin.map.loadingControl.removeLoader('lc');
                        alert(e.message);
                    });
                e.preventDefault();
            });
            plugin.storeButton.on('click', function (e) {
                var data = plugin.container.find('[name^="place_"]').serializeArray();
                var tokenNode = document.getElementById('ezxform_token_js');
                if ( tokenNode ){
                    data.push({
                        name: 'ezxform_token',
                        value: tokenNode.getAttribute('title')
                    })
                }
                plugin.storeButton.addClass('hide');
                $.ajax({
                    url: $.opendataTools.settings('accessPath') + "/agenda/add_place/" + plugin.container.data('parent'),
                    method: "post",
                    dataType: "json",
                    data: data,
                    success: function(response) {
                        var data = response['data'];
                        if (response.status === 'success'){
                            plugin.selectPlace(data);
                        }else if (response.status === 'error'){
                            alert(data);
                        }else if (response.status === 'wait'){
                            plugin.showAlert(data);
                        }
                    },
                    error: function (response) {
                        console.log(response);
                    }
                });
                e.preventDefault();
            });

            plugin.selectExistent.on('click', function (e) {
                var data = $(this).data('current');
                plugin.selectPlace(data);
                e.preventDefault();
            });

            plugin.storeMine.on('click', function (e) {
                var input = $(this).data('input');
                input.place_osm_type_id = input.place_osm_type_id+'-'+(new Date()).getTime()/1000;
                $.each(input, function (index, value) {
                    plugin.container.find('[name="'+index+'"]').val(value);
                });
                plugin.storeMine.addClass('hide');
                plugin.storeButton.trigger('click');
                e.preventDefault();
            });
        },
        selectPlace: function(data){
            var plugin = this;
            $('[data-new_place_select="'+plugin.container.data('place_gui')+'"]')
                .append('<option value="'+data.id+'" selected="selected">'+data.name+'</option>');
            $('[data-place_selection_wrapper="'+plugin.container.data('place_gui')+'"] select').trigger("chosen:updated");
            $('[data-dismiss_place_gui]').trigger('click');
        },
        showAlert: function(data){
            var plugin = this;
            plugin.selectExistent.data('current', data.current);
            plugin.storeMine.data('input', data.input);
            plugin.container.addClass('alert alert-warning');
            plugin.container.find('.show-alert ').removeClass('hide');
            plugin.storeButton.addClass('hide');
            $.each(data.current, function (index, value) {
                plugin.container.find('[name="'+index+'"]').val(value);
            });
            plugin.map.removeLayer(plugin.marker);
            plugin.marker.setLatLng(new L.latLng(data.current.place_latitude, data.current.place_longitude)).addTo(plugin.map);
        },
        removeAlert: function(){
            this.container.removeClass('alert alert-warning');
            this.container.find('.show-alert ').addClass('hide');
            this.storeButton.removeClass('hide');
            this.selectExistent.removeData('current');
            this.storeMine.removeData('mine');
        },
        refresh: function () {
            this.map.invalidateSize();
            this.container.find('input').val('');
            this.removeAlert();
        },
        setMarker: function (latLng, data) {
            var plugin = this;
            plugin.map.loadingControl.addLoader('lc');
            plugin.parseGeocoderData(data, function (dataParsed) {
                plugin.map.loadingControl.removeLoader('lc');
                plugin.container.find('[name="place_osm_type_id"]').val(dataParsed.id);
                plugin.container.find('[name="place_name"]').val(dataParsed.name);
                plugin.container.find('[name="place_address"]').val(dataParsed.text);
                plugin.container.find('[name="place_latitude"]').val(latLng.lat);
                plugin.container.find('[name="place_longitude"]').val(latLng.lng);
                plugin.map.removeLayer(plugin.marker);
                plugin.marker.setLatLng(latLng).addTo(plugin.map);
            });
        },
        parseGeocoderData: function(data, cb, context){
            var result = {
                'text': '',
                'name': '',
                'id': false
            };

            if (typeof data.properties !== 'undefined'){
                result.id = data.properties.osm_type+'-'+data.properties.osm_id;

                var address = data.properties.address;
                var name = [];
                if (address.hasOwnProperty('road')){
                    name.push(address['road']);
                }else if (address.hasOwnProperty('pedestrian')){
                    name.push(address['pedestrian']);
                }else if (address.hasOwnProperty('suburb')){
                    name.push(address['suburb']);
                }
                if (address.hasOwnProperty('postcode')){
                    name.push(', '+address['postcode']);
                }
                if (address.hasOwnProperty('town')){
                    name.push(address['town']);
                }else if (address.hasOwnProperty('city')){
                    name.push(address['city']);
                }else if (address.hasOwnProperty('village')){
                    name.push(address['village']);
                }
                if (address.hasOwnProperty('country')){
                    name.push(address['country']);
                }
                result.text = name.join(' ').substr(0, 150);

                $.ajax({
                    url: "https://nominatim.openstreetmap.org/details",
                    jsonp: "json_callback",
                    dataType: "jsonp",
                    data: {
                        place_id: data.properties.place_id,
                        format: 'json'
                    },
                    success: function(response) {
                        result.name = response.names.name;
                        if ($.isFunction(cb)) {
                            cb.call(context, result);
                        }
                    },
                    error: function () {
                        if ($.isFunction(cb)) {
                            cb.call(context, result);
                        }
                    }
                });
            }
        }
    });
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' + pluginName, new Plugin(this, options));
            }
            $(this).removeClass('hide').data('plugin_' + pluginName).refresh();
        });
    };
})(jQuery, window, document);

$(document).ready(function () {

    $('[data-place_selection_wrapper="{/literal}{$attribute.id}{literal}"] select').chosen({width:"100%"});

    var trigger = $('[data-add_custom_place]');
    trigger.on('click', function (e) {
        $("[data-place_gui]").addPlaceGui({
            i18n:{
                search: '{/literal}{'Search'|i18n('agenda')}{literal}',
                noResults: '{/literal}{'No contents'|i18n('opendata_forms')}{literal}'
            }
        });
        trigger.addClass('hide');
        e.preventDefault();
    });

    $('[data-dismiss_place_gui]').on('click', function (e) {
        $("[data-place_gui]").addClass('hide');
        trigger.removeClass('hide');
        e.preventDefault();
    });

});
{/literal}
</script>


{undef}
