;(function ($, window, document, undefined) {

    "use strict";

    var pluginName = "initSearchView",
        defaults = {};

    function InitSearchView(element, options) {
        this.element = element;
        this.settings = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.init();
    }

    // Avoid Plugin.prototype conflicts
    $.extend(InitSearchView.prototype, {
        init: function () {
            var tools = $.opendataTools;

            var spinner = $($.templates("#tpl-spinner").render({}));

            var empty = $.templates("#tpl-empty").render({});

            var viewCalendar = $('#agenda');

            var preview = $('#preview');

            var isChangeView = false;

            var initMap = function () {
                if (document.getElementById('map')) {
                    var map = tools.initMap(
                        'map',
                        function (response) {
                            return L.geoJson(response, {
                                pointToLayer: function (feature, latlng) {
                                    var customIcon = L.MakiMarkers.icon({icon: "circle", size: "l"});
                                    return L.marker(latlng, {icon: customIcon});
                                },
                                onEachFeature: function (feature, layer) {
                                    var popupDefault = '<p class="text-center"><i class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + tools.settings('accessPath') + '/agenda/event/' + feature.properties.mainNodeId + '" target="_blank">';
                                    popupDefault += feature.properties.name;
                                    popupDefault += '</a></p>';
                                    var popup = new L.Popup({maxHeight: 360});
                                    popup.setContent(popupDefault);
                                    layer.on('click', function (e) {

                                        tools.findOne('id = ' + e.target.feature.properties.id, function (data) {
                                            var template = $.templates("#tpl-event");
                                            $.views.helpers(OpenpaAgendaHelpers);
                                            var htmlOutput = template.render([data]).replace('col-md-6', '');
                                            popup.setContent(htmlOutput);
                                            popup.update();
                                        })
                                    });
                                    layer.bindPopup(popup);
                                }
                            });
                        }
                    );
                    map.scrollWheelZoom.disable();

                    $("body").on("shown.bs.tab", function () {
                        tools.refreshMap();
                    });
                }
            };

            var loadMapResults = function (response, query, appendResults, view) {
                if (response.totalCount > 0) {
                    tools.loadMarkersInMap(query);
                }
            };

            var initCalendar = function (view) {
                $("body").on("shown.bs.tab", function (e) {
                    if ($(e.target).attr('href') == '#agenda') {
                        view.setFilterValue('date', 'all');
                        view.doSearch();
                        refreshCalendar(view);
                        $('.widget[data-filter="date"]').addClass('hide');
                        isChangeView = true;
                    } else {
                        $('.widget[data-filter="date"]').removeClass('hide');
                    }
                });
            };

            var refreshCalendar = function (view, response) {
                if ($.isFunction($.fn.fullCalendar)) {
                    var defaultDate = moment();
                    //if (response){
                    //    if (response.totalCount > 0) {
                    //        defaultDate = moment(response.searchHits[0].data[tools.settings('language')].from_time, moment.ISO_8601);;
                    //    }
                    //}
                    if (viewCalendar.data('fullCalendar')) {
                        viewCalendar.fullCalendar('destroy');
                    }
                    viewCalendar.fullCalendar({
                        header: {
                            center: "title",
                            right: "agendaDay,agendaWeek,month",
                            left: "prev,today,next"
                        },
                        defaultView: 'agendaWeek',
                        locale: tools.settings('locale'),
                        axisFormat: 'H(:mm)',
                        aspectRatio: 1.35,
                        selectable: false,
                        defaultDate: defaultDate,
                        editable: false,
                        timeFormat: 'H(:mm)',
                        eventClick: function (calEvent, jsEvent, view) {
                            preview.find('.modal-content').html('');
                            var template = $.templates("#tpl-event");
                            $.views.helpers(OpenpaAgendaHelpers);
                            var htmlOutput = template.render(calEvent.content);
                            preview.find('.modal-content').html(htmlOutput);
                            preview.find('.col-md-6').removeClass('col-md-6');
                            preview.modal();
                        },
                        events: {
                            url: tools.settings().endpoint.fullcalendar,
                            data: function () {
                                return {q: view.getQuery()};
                            }
                        }
                    });
                }
            };

            var loadCalendarResults = function (response, query, appendResults, view) {
                if (!isChangeView) {
                    refreshCalendar(view, response);
                } else {
                    isChangeView = false;
                }

            };

            var loadListResults = function (response, query, appendResults, view) {
                spinner.remove();
                if (response.totalCount > 0) {
                    var template = $.templates("#tpl-event");
                    $.views.helpers(OpenpaAgendaHelpers);

                    var htmlOutput = template.render(response.searchHits);
                    if (appendResults) view.container.append(htmlOutput);
                    else view.container.html(htmlOutput);

                    if (response.nextPageQuery) {
                        var loadMore = $($.templates("#tpl-load-other").render({}));
                        loadMore.find('a').bind('click', function (e) {
                            view.appendSearch(response.nextPageQuery);
                            loadMore.remove();
                            view.container.append(spinner);
                            e.preventDefault();
                        });
                        view.container.append(loadMore)
                    }
                } else {
                    view.container.html(empty);
                }
            };

            var data = $(this.element).data('opendataSearchView');
            if (!data) {
                $(this.element).opendataSearchView({
                    query: $.opendataTools.settings('base_query'),
                    onInit: function (view) {
                        initMap();
                        initCalendar(view);
                    },
                    onBeforeSearch: function (query, view) {
                        view.container.html(spinner);
                    },
                    onLoadResults: function (response, query, appendResults, view) {
                        loadListResults(response, query, appendResults, view);
                        loadMapResults(response, query, appendResults, view);
                        loadCalendarResults(response, query, appendResults, view);
                    },
                    onLoadErrors: function (errorCode, errorMessage, jqXHR, view) {
                        view.container.html('<div class="alert alert-danger">' + errorMessage + '</div>')
                    }
                });
            }
        }
    });
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" +
                    pluginName, new InitSearchView(this, options));
            }
        });
    };

})(jQuery, window, document);
$(document).ready(function () {


});
