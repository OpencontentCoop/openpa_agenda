/*jshint esversion: 6 */
(function ($, window, document, undefined) {
    'use strict';
    let pluginName = 'simplifiedPlaceGui', defaults = {
        'placeClassIdentifier': 'place',
        'placeGeoIdentifier': 'has_address',
        'multiSelect': false,
        'i18n': {
            search: 'search',
            noResults: 'noResults',
            myLocation: 'myLocation',
            store: 'store',
            cancel: 'cancel',
            next: 'next',
            prev: 'prev',
            storeLoading: 'storeLoading',
            cancelDelete: 'cancelDelete',
            confirmDelete: 'confirmDelete'
        }
    };

    function Plugin(element, options) {

        this.settings = $.extend({}, defaults, options);
        this.container = $(element);

        this.mapId = 'map-' + this.container.data('simplified_place_gui');
        this.mapContainer = $('#' + this.mapId);
        this.geocoder = L.Control.Geocoder.nominatim();
        this.geocoderInput = null;
        this.marker = new L.Marker(new L.LatLng(0, 0), {
            icon: L.divIcon({
                html: '<i class="fa fa-map-marker fa-4x text-danger"></i>',
                iconSize: [20, 20],
                className: 'myDivIcon'
            }),
            draggable: true
        }).bindPopup('');
        this.storeButton = this.container.find('[data-store_place_gui]');
        this.selectorWrapper = this.container.find('select[data-place_selection_wrapper]');
        if (this.selectorWrapper.val().length === 0 && !this.selectorWrapper.attr('multiple')) {
            this.selectorWrapper.val('no_relation')
        }
        this.helperTexts = this.container.find('[data-helper-texts]');
        this.editWindow = this.container.find('[data-window]');
        this.selectWindow = this.container.find('[data-selectplace]');

        this.markers = L.featureGroup();
        this.init();

        this.nearestLayer = L.featureGroup().addTo(this.map);
    }

    $.extend(Plugin.prototype, {
        init: function () {
            let plugin = this;

            plugin.container.find('input').val('');

            let startViewPoint = plugin.selectorWrapper.find('[data-lng]').first().data() || new L.LatLng(0, 0);
            let startViewZoom = startViewPoint.lat === 0 ? 5 : 13;
            if (plugin.container.data('lng')){
                startViewPoint = new L.LatLng(plugin.container.data('lat'), plugin.container.data('lng'))
                startViewZoom = plugin.container.data('zoom')
            }

            plugin.map = new L.Map(this.mapId, {
                loadingControl: true, closePopupOnClick: false
            }).setView(startViewPoint, startViewZoom);
            L.Control.geocoder({
                collapsed: false,
                placeholder: plugin.settings.i18n.search,
                errorMessage: plugin.settings.i18n.noResults,
                suggestMinLength: 5,
                defaultMarkGeocode: false
            }).on('markgeocode', function (e) {
                plugin.setMarker(e.geocode.center, e.geocode);
                L.DomEvent.stop(e);
            }).addTo(plugin.map);
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(plugin.map);

            $('[data-toggle="tab"]').on('shown.bs.tab', function (e) {
                plugin.map.invalidateSize(false);
            });
            $('[data-bs-toggle="tab"]').on('shown.bs.tab', function (e) {
                plugin.map.invalidateSize(false);
            });
            plugin.geocoderInput = plugin.container.find('.leaflet-control-geocoder').hide();
            plugin.markers.addTo(plugin.map);
            //plugin.displaySelectedMarkers();
            plugin.selectorWrapper.chosen({width: '100%'}).on('change', function (e, p) {
                plugin.displaySelectedMarkers();
            });

            plugin.container.find('.leaflet-control-geocoder-form input').css('height', 'auto');

            plugin.marker.on('dragend', function (event) {
                // plugin.closeSelectWidow();
                let target = event.target.getLatLng();
                plugin.map.loadingControl.addLoader('lc');
                plugin.geocoder.reverse(target, 60000000, function (data) {
                    plugin.map.loadingControl.removeLoader('lc');
                    if (data.length) {
                        plugin.setMarker(target, data[0]);
                    } else {
                        plugin.setMarker(target);
                    }
                });
            })
        },

        displaySelectedMarkers: function () {
            let plugin = this;
            plugin.map.removeLayer(plugin.marker);
            plugin.markers.clearLayers();
            plugin.closeSelectWidow();
            let selectionValue;
            let doCreate = false;
            plugin.selectorWrapper.find('option:selected').each(function () {
                let selection = $(this);
                selectionValue = selection.val();
                if (selection.data('lat') && selection.data('lng')) {
                    let selectionMarker = new L.Marker(new L.LatLng(selection.data('lat'), selection.data('lng')), {
                        icon: L.divIcon({
                            html: '<i class="fa fa-map-marker fa-4x text-muted" style="cursor: default"></i>',
                            iconSize: [20, 20],
                            className: 'myDivIcon'
                        })
                    });
                    plugin.markers.addLayer(selectionMarker);
                    setTimeout(function () {
                        let popup = plugin.loadPlacePopup(selectionValue);
                        selectionMarker
                            .bindPopup(popup)
                            .openPopup();
                        $.getJSON($.opendataTools.settings('accessPath') + "/openpa/data/map_markers?contentType=marker&view=card_teaser&id=" + selectionValue, function (data) {
                            var content = $(data.content).css({'max-width': '320px'}).addClass('px-0').removeClass('shadow p-4 rounded border');
                            popup.setContent(content.get(0).outerHTML);
                            popup.update();
                        });

                    }, 100)
                }
                if (selection.data('create_new')){
                    doCreate = true;
                }
            });
            if (plugin.markers.getLayers().length > 0 || doCreate) {
                plugin.editWindow.hide();
                if (plugin.markers.getLayers().length > 0) {
                    plugin.map.fitBounds(plugin.markers.getBounds());
                }
                plugin.disableAddMarkerOnClick();
                plugin.showMapContainer();
            } else if (selectionValue === 'no_relation') {
                plugin.editWindow.hide();
                plugin.disableAddMarkerOnClick();
                plugin.hideMapContainer();
            } else {
                plugin.enableAddMarkerOnClick();
                plugin.showMapContainer();
            }
        },

        loadPlacePopup: function (placeId) {
            let plugin = this;
            let popupDefault = '<p class="text-center py-5"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-2x"></i></p>';
            let popup = new L.Popup({maxHeight: 360, minWidth: 300, closeButton: false});
            popup.setContent(popupDefault);
            return popup;
        },

        showMapContainer: function () {
            let plugin = this;
            plugin.mapContainer.parent().show(10, function () {
                plugin.map.invalidateSize(false);
            });
        },

        hideMapContainer: function () {
            let plugin = this;
            plugin.mapContainer.parent().hide();
        },

        enableAddMarkerOnClick: function () {
            let plugin = this;
            plugin.disableAddMarkerOnClick();
            plugin.map.dragging.enable();
            plugin.mapContainer.css('cursor', 'copy')
            plugin.map.on('click', function (event) {
                if (event.latlng !== undefined) {
                    // plugin.closeSelectWidow();
                    plugin.setMarker({
                        lat: event.latlng.lat, lng: event.latlng.lng
                    });
                }
            });
            plugin.geocoderInput.show()
        },

        disableAddMarkerOnClick: function () {
            let plugin = this;
            plugin.map.off('click');
            plugin.map.off('locationerror');
            plugin.map.dragging.disable();
            plugin.geocoderInput.hide()
            plugin.mapContainer.css('cursor', 'inherit')
        },

        addAndSelectPlace: function (data, latLng) {
            let plugin = this;
            if (plugin.settings.multiSelect === false) {
                plugin.selectorWrapper.find('option').removeAttr('selected');
            }
            plugin.selectorWrapper.find('[data-new_place_select]').append('<option data-lng="' + latLng.lng + '" data-lat="' + latLng.lat + '" value="' + data.metadata.id + '" selected="selected">' + data.metadata.name['ita-IT'] + '</option>');
            plugin.selectorWrapper.trigger("chosen:updated").trigger('change');
        },

        selectPlace: function (id, name, latLng) {
            let plugin = this;
            if (plugin.settings.multiSelect === false) {
                plugin.selectorWrapper.find('option').removeAttr('selected');
            }
            let exists = plugin.selectorWrapper.find('option[value="' + id + '"]');
            if (exists.length > 0) {
                exists.prop('selected', true);
            } else {
                plugin.selectorWrapper.find('[data-shared_place_select]').show().append('<option data-lng="' + latLng.lng + '" data-lat="' + latLng.lat + '" value="' + id + '" selected="selected">' + name + '</option>');
            }
            plugin.selectorWrapper.trigger("chosen:updated").trigger('change');
        },

        setMarker: function (latLng, data) {
            let plugin = this;
            // plugin.nearestLayer.clearLayers();
            // plugin.selectWindow.hide();
            plugin.editWindow.hide();
            plugin.markers.clearLayers();
            let helperText = '<p class="lead text-center">' + plugin.helperTexts.find('[data-candrag]').html() + '</p>';
            let confirmButton = '<p class="text-center"><a data-lat="' + latLng.lat + '" data-lng="' + latLng.lng + '" id="add-place-' + plugin.mapId + '" href="#" class="btn btn-secondary btn-xs text-white text-center">' + plugin.helperTexts.find('[data-confirm]').html() + '</a></p>';
            let helpPopup = new L.Popup({
                maxHeight: 360,
                minWidth: 300,
                closeButton: false
            }).setContent('<div>' + helperText + confirmButton + '</div>');
            plugin.map.setView(latLng, 18);
            plugin.marker
                .setLatLng(latLng)
                .addTo(plugin.map)
                .bindPopup(helpPopup)
                .openPopup();
            plugin.mapContainer.find('.leaflet-marker-draggable').css('cursor', 'move')
            $('#add-place-' + plugin.mapId).on('click', function (e) {
                let self = $(this);
                self.html('<i aria-hidden="true" class="fa fa-circle-o-notch fa-spin"></i>');
                let latLng = new L.LatLng(self.data('lat'), self.data('lng'));
                plugin.findNearPlaces(latLng, function (places, latLng) {
                    plugin.marker.closePopup();
                    if (places.features.length === 0) {
                        plugin.openCreateWindow(latLng, data);
                    } else {
                        plugin.openSelectWidow(latLng, data, places);
                    }
                    $('#add-place-' + plugin.mapId).off('click');
                });
                e.preventDefault();
            });

            return false;
        },

        openCreateWindow: function (latLng, data) {
            let plugin = this;
            plugin.nearestLayer.clearLayers();
            plugin.selectWindow.hide();
            plugin.editWindow.html('');
            let container = $('<div></div>').appendTo(plugin.editWindow);
            container.opendataFormCreate({
                class: plugin.settings.class,
                parent: plugin.settings.parent,
                lat: latLng.lat,
                lon: latLng.lng,
                wizard: true
            }, {
                connector: 'add_place', onBeforeCreate: function () {
                    container.parent().show();
                },
                i18n: plugin.settings.i18n,
                alpaca: {
                    'view': {
                        'wizard': {
                            "buttons": {
                                "reset": {
                                    "title": plugin.settings.i18n.cancel,
                                    'styles': 'btn btn-danger btn-xs',
                                    "align": "left",
                                    "click": function(e) {
                                        container.parent().hide();
                                        container.remove();
                                        plugin.displaySelectedMarkers();
                                    }
                                },
                                "previous": {
                                    "title": plugin.settings.i18n.prev,
                                    'style': 'btn btn-outline-primary btn-xs',
                                },
                                "next": {
                                    "title": plugin.settings.i18n.next,
                                    'styles': 'btn btn-outline-primary btn-xs',
                                },
                                "submit": {
                                    "title": plugin.settings.i18n.store,
                                    'styles': 'btn btn-primary btn-xs',
                                    "click": function(e,p) {
                                        $(e.currentTarget).attr('disabled', 'disabled');
                                        let form = this.form
                                        form.refreshValidationState(true);
                                        if (form.isValid(true)) {
                                            var promise = form.ajaxSubmit();
                                            promise.done(function(data) {
                                                if (data.error) {
                                                    alert(data.error);
                                                } else {
                                                    plugin.map.removeLayer(plugin.marker);
                                                    plugin.addAndSelectPlace(data.content, latLng);
                                                    plugin.editWindow.hide();
                                                }
                                            });
                                            promise.fail(function(error) {
                                                alert(data.error);
                                            });
                                        }
                                    },
                                    "id": "mySubmit"
                                }
                            }
                        }
                    },
                    'options': {
                        'form': {
                            'buttons': {
                                'submit': {
                                    'styles': 'd-none'
                                },
                                'reset': {
                                    'styles': 'd-none'
                                }
                            }
                        }
                    }
                }
            });
        },

        closeSelectWidow: function () {
            let plugin = this;
            plugin.selectWindow.hide();
            plugin.mapContainer.css('width', '100%');
            plugin.map.invalidateSize(false);
        },

        openSelectWidow: function (latLng, data, places) {
            let plugin = this;
            plugin.editWindow.hide();
            plugin.selectWindow.html('');
            let list = $('<div class="list-group overflow-auto"></div>');
            let cancelButton = $('<a href="#" style="z-index: 2;right: 5px;position: absolute"><i aria-hidden="true" class="fa fa-times"></i></a>').on('click', function (e) {
                plugin.nearestLayer.clearLayers();
                plugin.selectWindow.hide();
                plugin.displaySelectedMarkers();
                e.preventDefault();
            });
            list.append(cancelButton);
            list.append($('<div class="list-group-item list-group-item-action p-2"><small>' + plugin.helperTexts.find('[data-maybe]').html() + '</small></div>'));

            let searchLayer = L.geoJson(places, {
                pointToLayer: function (feature, center) {
                    let item = $('<a href="#" class="list-group-item list-group-item-action p-2 text-decoration-none" ' + 'data-id="' + feature.id + '" ' + 'data-name="' + feature.properties.name + '" ' + 'data-lat="' + center.lat + '" ' + 'data-lng="' + center.lng + '">' + '<h6 class="mb-0"><span class="badge badge-secondary"><i aria-hidden="true" class="fa fa-map-marker"></i> ' + feature.id + '</span> ' + feature.properties.name + '</h6></a>').on('click', function (e) {
                        plugin.selectPlace($(this).data('id'), $(this).data('name'), new L.LatLng($(this).data('lat'), $(this).data('lng')));
                        plugin.nearestLayer.clearLayers();
                        plugin.selectWindow.hide();
                        e.preventDefault();
                    });
                    list.append(item);
                    return L.marker(center, {
                        icon: L.divIcon({
                            iconSize: null,
                            html: '<div class="map-label">' +
                                '<div class="map-label-content"><i aria-hidden="true" class="fa fa-map-marker"></i> ' + feature.id + '</div>' +
                                '<div class="map-label-arrow"></div>' +
                                '<i class="fa fa-circle" style="display: block;position: absolute;left: -5px;bottom: -10px;color: #5c6f82;"></i>' +
                                '</div>'
                        })
                    });
                }
            });
            plugin.nearestLayer.addLayer(searchLayer);
            let continueButton = $('<a href="#" class="list-group-item list-group-item-action p-2 text-decoration-none"><h6 class="mb-0"><span class="badge badge-danger"><i aria-hidden="true" class="fa fa-map-marker"></i></span> ' + plugin.helperTexts.find('[data-continue]').html() + '</h6></a>').on('click', function (e) {
                plugin.map.removeLayer(plugin.marker);
                plugin.openCreateWindow(latLng, data);
                e.preventDefault();
            });
            list.append(continueButton);
            plugin.selectWindow.append(list).show();
            plugin.mapContainer.css('width', '100%');
            plugin.mapContainer.css('width', plugin.mapContainer.width() - plugin.selectWindow.width());
            plugin.map.fitBounds(plugin.nearestLayer.getBounds());
            plugin.map.invalidateSize(false);
        },

        findNearPlaces: function (latLng, cb, context) {
            let plugin = this;

            let circle = L.circle(latLng, 100);
            let circleBounds = circle.getBounds();
            let rectangle = L.rectangle(circleBounds, {
                color: 'red', weight: 2, fillOpacity: 0
            });

            if (plugin.nearestLayer) {
                //plugin.nearestLayer.addLayer(rectangle);
                plugin.map.fitBounds(rectangle.getBounds());
            }

            let lng, lat, coords = [], polygonWkt;
            let latLngs = rectangle.getLatLngs();
            for (let i = 0; i < latLngs.length; i++) {
                coords.push(latLngs[i].lng + ' ' + latLngs[i].lat);
                if (i === 0) {
                    lng = latLngs[i].lng;
                    lat = latLngs[i].lat;
                }
            }
            polygonWkt = coords.join(',') + ',' + lng + ' ' + lat;
            let query = 'classes [' + plugin.settings.placeClassIdentifier + '] and raw[extra_geo_rpt] = "IsWithin\\(POLYGON\\(\\(' + polygonWkt + '\\)\\)\\) distErrPct=0"';

            $.ajax({
                type: "GET",
                url: $.opendataTools.settings('endpoint').geo,
                data: {q: query},
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.error_message || response.error_code) {
                        console.log(response.error_message);
                        response = {'features': []};
                    }
                    if ($.isFunction(cb)) {
                        cb.call(context, response, latLng);
                    }
                },
                error: function (jqXHR) {
                    let error = {
                        error_code: jqXHR.status, error_message: jqXHR.statusText
                    };
                    console.log(error);
                    if ($.isFunction(cb)) {
                        cb.call(context, {'features': []}, latLng);
                    }
                }
            });
        }
    });
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' + pluginName, new Plugin(this, options));
            }
            $(this).removeClass('hide').data('plugin_' + pluginName);
        });
    };
})(jQuery, window, document);
