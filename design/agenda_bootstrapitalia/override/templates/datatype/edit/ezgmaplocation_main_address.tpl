{if is_set( $attribute_base )|not}
    {def $attribute_base = 'ContentObjectAttribute'}
{/if}
{def $latitude  = $attribute.content.latitude|explode(',')|implode('.')
     $longitude = $attribute.content.longitude|explode(',')|implode('.')}

<div class="clearfix" data-osmap="{$attribute.id}">
    <div style="position:relative">
        <input class="ezgml_new_address box form-control form-control-sm"
               type="text"
               name="{$attribute_base}_data_gmaplocation_address_{$attribute.id}"
               value="{$attribute.content.address}"/>
        <button class="btn p-0 btn-link" tabindex="100" name="ShowMap" title="Rileva posizione"
                style="cursor: pointer;position: absolute;top: 5px;right: 30px;{if $attribute.version|gt(1)}display: none{/if}"><i class="fa fa-map"></i></button>
        <button class="btn p-0 btn-link" tabindex="100" name="MyLocation" title="Rileva posizione"
                style="cursor: pointer;position: absolute;top: 5px;right: 10px;"><i class="fa fa-map-marker"></i></button>
        <button class="btn p-0 btn-link" tabindex="100" name="Reset" title="Annulla modifiche"
                style="cursor: pointer;position: absolute;top: 5px;right: 0;display: none"><i class="fa fa-close"></i>
        </button>
    </div>
    <input class="ezgml_hidden_address"
           type="hidden"
           name="ezgml_hidden_address"
           value="{$attribute.content.address}"
           disabled="disabled"/>
    <div id="map-{$attribute.id}" style="width: 100%; height: 300px; margin-top: 0;{if $attribute.version|eq(1)}display: none{/if}"></div>
    <input class="ezgml_new_latitude"
           type="hidden"
           name="{$attribute_base}_data_gmaplocation_latitude_{$attribute.id}"
           value="{$latitude}"/>
    <input class="ezgml_hidden_latitude"
           type="hidden"
           name="ezgml_hidden_latitude"
           value="{$latitude}"
           disabled="disabled"/>
    <input class="ezgml_new_longitude"
           type="hidden"
           name="{$attribute_base}_data_gmaplocation_longitude_{$attribute.id}"
           value="{$longitude}"/>
    <input class="ezgml_hidden_longitude"
           type="hidden"
           name="ezgml_hidden_longitude"
           value="{$longitude}"
           disabled="disabled"/>
</div>

{ezcss_require(array('leaflet/leaflet.0.7.2.css','leaflet/geocoder/Control.Geocoder.css','leaflet/Control.Loading.css'))}
{ezscript_require(array('leaflet/leaflet.0.7.2.js','ezjsc::jquery','leaflet/Control.Loading.js','leaflet/Leaflet.MakiMarkers.js','leaflet/geocoder/Control.Geocoder.js'))}
{literal}
    <script>
        $(document).ready(function () {
            $("[data-osmap]").each(function () {
                var
                    $container = $(this),
                    attributeId = $container.data('osmap'),
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
                    showMapButton = $container.find("[name='ShowMap']"),
                    map = new L.Map('map-' + attributeId, {loadingControl: true})
                        .setView(new L.latLng(0, 0), 1)
                        .on('click', function (event) {
                            // if (event.latlng !== undefined) {
                            //     var target = {
                            //         lat: event.latlng.lat,
                            //         lng: event.latlng.lng
                            //     };
                            //     geocoder.reverse(target, 1, function (data) {
                            //         map.loadingControl.removeLoader('lc');
                            //         if (data.length)
                            //             setMarker(target, data[0].name);
                            //         else
                            //             setMarker(target);
                            //     });
                            // }
                        }),
                    geocoder = L.Control.Geocoder.nominatim(),
                    control = L.Control.geocoder({
                        collapsed: false,
                        placeholder: 'Cerca...',
                        errorMessage: 'Nessun risultato.',
                        suggestMinLength: 5,
                        defaultMarkGeocode: false
                    }).on('markgeocode', function (e) {
                        setMarker(e.geocode.center, e.geocode.name);
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
                            if (data.length) {
                                setMarker(target, data[0].name);
                            }else {
                                setMarker(target);
                            }
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
                inputText.on('change', function (e){
                    let value = $(this).val();
                    geocoder.geocode(value, function (response) {
                        let data = response[0] || false;
                        if (data){
                            setMarker(data.center, value)
                        }
                        if (response.length > 1) {
                            $('.leaflet-control-geocoder-form input').val(value);
                            $('.leaflet-control-geocoder-icon').trigger('click');
                            $('#map-' + attributeId).show(function () {
                                map.setView(marker.getLatLng(), 18);
                                map.invalidateSize();
                            });
                        }else if (response.length === 0) {
                            setMarker(new L.latLng(0, 0), value);
                        }
                    })
                })
                $container.bind('osmaplocation.setMarker', function (event, data) {
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
                showMapButton.bind('click', function (e) {
                    $('#map-' + attributeId).toggle(function (){
                        map.setView(marker.getLatLng(), 18);
                        map.invalidateSize();
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
