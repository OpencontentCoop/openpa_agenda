{if is_set( $attribute_base )|not}
    {def $attribute_base = 'ContentObjectAttribute'}
{/if}
{def $latitude  = $attribute.content.latitude|explode(',')|implode('.')
     $longitude = $attribute.content.longitude|explode(',')|implode('.')}
{def $viewport = openagenda_default_geolocation()}
<div class="clearfix" data-osmap-attribute="{$attribute.id}" {if $viewport}data-lat="{$viewport.latitude}" data-lng="{$viewport.longitude}" data-zoom="15"{/if}>

    <div id="map-{$attribute.id}" style="width: 100%; height: 300px; margin-top: 2px;"></div>
    <div class="row mt-1">
        <div class="address col-md-8">
            <input class="ezgml_new_address"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_address_{$attribute.id}"
                   value="{$attribute.content.address}"/>
            <input class="ezgml_hidden_address"
                   type="hidden"
                   name="ezgml_hidden_address"
                   value="{$attribute.content.address}"
                   disabled="disabled"/>
        </div>
        <div class="col-md-4 text-right">
            <button class="btn btn-xs btn-danger ml-3 ms-3" name="Reset" style="display: none">Annulla modifiche</button>
            <button class="btn btn-xs btn-outline-secondary" name="MyLocation">Rileva posizione</button>
        </div>
    </div>
    <div class="row d-none">
        <div class="latitude col-md-6">
            <label><small>Latitudine</small></label>
            <input class="ezgml_new_latitude box form-control form-control-sm"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_latitude_{$attribute.id}"
                   value="{$latitude}"/>
            <input class="ezgml_hidden_latitude"
                   type="hidden"
                   name="ezgml_hidden_latitude"
                   value="{$latitude}"
                   disabled="disabled"/>
        </div>

        <div class="longitude col-md-6">
            <label><small>Longitudine</small></label>
            <input class="ezgml_new_longitude box form-control form-control-sm"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_longitude_{$attribute.id}"
                   value="{$longitude}"/>
            <input class="ezgml_hidden_longitude"
                   type="hidden"
                   name="ezgml_hidden_longitude"
                   value="{$longitude}"
                   disabled="disabled"/>
        </div>
    </div>

</div>

{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css',
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css'
))}
{ezscript_require(array(
    'leaflet/leaflet.0.7.2.js',
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/geocoder/Control.Geocoder.js'
))}

{literal}
<script>
    $(document).ready(function () {
        $("[data-osmap-attribute]").each(function () {
            var
                $container = $(this),

                attributeId = $container.data('osmap-attribute'),

                originalLat = $container.find('.ezgml_hidden_latitude').val(),
                originalLng = $container.find('.ezgml_hidden_longitude').val(),
                originalText = $container.find('.ezgml_hidden_address').val(),

                inputLat = $container.find('.ezgml_new_latitude'),
                inputLng = $container.find('.ezgml_new_longitude'),
                inputText = $container.find('.ezgml_new_address'),

                resetButton = $container.find("[name='Reset']").on('click', function (e) {
                    reset();
                    e.preventDefault();
                }),

                myLocationButton = $container.find("[name='MyLocation']"),

                map = new L.Map('map-' + attributeId, {loadingControl: true})
                    .setView(new L.latLng($container.data('lat') || 0, $container.data('lng') || 0), $container.data('zoom') || 0),

                simplifyAddressName = function(properties){
                    var name = [];
                    if (properties.hasOwnProperty('road')){
                        name.push(properties['road']);
                    }else if (properties.hasOwnProperty('pedestrian')){
                        name.push(properties['pedestrian']);
                    }else if (properties.hasOwnProperty('suburb')){
                        name.push(properties['suburb']);
                    }
                    if (properties.hasOwnProperty('house_number')){
                        name.push(properties['house_number']);
                    }
                    if (properties.hasOwnProperty('postcode')){
                        name.push(properties['postcode']);
                    }
                    if (properties.hasOwnProperty('town')){
                        name.push(properties['town']);
                    }else if (properties.hasOwnProperty('city')){
                        name.push(properties['city']);
                    }else if (properties.hasOwnProperty('village')){
                        name.push(properties['village']);
                    }
                    //if (properties.hasOwnProperty('country')){
                    //    name.push(properties['country']);
                    //}

                    return name.join(' ').substr(0, 150);
                },

                //geocoder = L.Control.Geocoder.mapzen('search-DopSHJw'),
                geocoder = L.Control.Geocoder.nominatim(),
                control = L.Control.geocoder({
                    //geocoder: geocoder,
                    collapsed: false,
                    placeholder: 'Cerca...',
                    errorMessage: 'Nessun risultato.',
                    suggestMinLength: 5,
                    defaultMarkGeocode: false
                }).on('markgeocode', function (e) {
                    console.log(e)
                    setMarker(e.geocode.center, simplifyAddressName(e.geocode.properties.address));
                    map.fitBounds(e.geocode.bbox);
                    if (originalLat.length) {
                        resetButton.show();
                    }
                }).addTo(map),

                marker = new L.marker(new L.latLng(0, 0), {
                    icon: new L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"}),
                    draggable: true
                }).on('dragend', function (event) {
                    var target = event.target.getLatLng();
                    map.loadingControl.addLoader('lc');
                    geocoder.reverse(target, 1, function (data) {
                        map.loadingControl.removeLoader('lc');
                        if (data.length)
                            setMarker(target, data[0].name);
                        else
                            setMarker(target);
                    });
                    if (originalLat.length) {
                        resetButton.show();
                    }
                }),

                setMarker = function (latLng, text) {
                    inputText.val(text);
                    inputLat.val(latLng.lat);
                    inputLng.val(latLng.lng);
                    map.removeLayer(marker);
                    marker.setLatLng(latLng).addTo(map);
                },

                reset = function () {
                    if (originalLat.length) {
                        var latLng = new L.latLng(originalLat, originalLng);
                        setMarker(latLng, originalText);
                        map.setView(latLng, 18);
                        resetButton.hide();
                    }
                };

            reset();

            $container.bind('osmaplocation.setMarker', function(event, data){
                setMarker(data.latLng, data.address);
                map.setView(data.latLng, 18);
            });

            myLocationButton.bind('click', function (e) {
                map.loadingControl.addLoader('lc');
                map.locate({setView: true, watch: false})
                    .on('locationfound', function (e) {
                        map.loadingControl.removeLoader('lc');
                        var target = new L.latLng(e.latitude, e.longitude);
                        geocoder.reverse(target, 1, function (data) {
                            if (data.length)
                                setMarker(target, data[0].name);
                            else
                                setMarker(target);
                        });
                    })
                    .on('locationerror', function (e) {
                        map.loadingControl.removeLoader('lc');
                        alert(e.message);
                    });
                e.preventDefault();
            });

            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
        });
    });

</script>
{/literal}
