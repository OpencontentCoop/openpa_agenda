$(document).ready(function () {
    var mainQuery = 'classes [private_organization]';
    var map = $.opendataTools.initMap(
        'map',
        function (response) {
            return L.geoJson(response, {
                pointToLayer: function (feature, latlng) {
                    iconaSede = "warehouse";
                    coloreSede = '#f00';
                    customIcon = L.MakiMarkers.icon({icon: iconaSede, color: coloreSede, size: "l"});
                    return L.marker(latlng, {icon: customIcon});
                },
                onEachFeature: function (feature, layer) {
                    var popupDefault = '<p class="text-center"><i class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + $.opendataTools.settings('accessPath') + '/content/view/full/' + feature.properties.mainNodeId + '" target="_blank">';
                    popupDefault += feature.properties.name;
                    popupDefault += '</a></p>';
                    var popup = new L.Popup({maxHeight: 450, maxWidth: 500, minWidth: 350});
                    popup.setContent(popupDefault);
                    layer.on('click', function (e) {
                        $.getJSON($.opendataTools.settings('accessPath') + "/openpa/data/map_markers?contentType=marker&view=card_teaser&id="+e.target.feature.properties.id, function(data) {
                            var content = $(data.content).css({'max-width': '320px'}).removeClass('shadow p-4 rounded border');
                            popup.setContent(content.get(0).outerHTML);
                            popup.update();
                        });
                    });
                    layer.bindPopup(popup);
                }
            });
        }
    );
    map.setView([0, 0], 10).scrollWheelZoom.disable();
    $.opendataTools.loadMarkersInMap(mainQuery, function (response) {
        $('#map').removeClass('hide');
        $.opendataTools.refreshMap();
    });
    $("body").on("shown.bs.tab", function () {
        $.opendataTools.refreshMap();
    });

});
