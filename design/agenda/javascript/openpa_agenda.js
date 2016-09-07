$(document).ready(function () {

    var tools = $.opendataTools;

    var map = tools.initMap(
        'map',
        function (response) {
            return L.geoJson(response, {
                pointToLayer: function (feature, latlng) {
                    customIcon = L.MakiMarkers.icon({icon: "circle", size: "l"});
                    return L.marker(latlng, {icon: customIcon});
                },
                onEachFeature: function (feature, layer) {
                    var popupDefault = '<p class="text-center"><i class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + tools.settings('accessPath') + '/agenda/event/' + feature.properties.mainNodeId + '" target="_blank">';
                    popupDefault += feature.properties.name;
                    popupDefault += '</a></p>';
                    var popup = new L.Popup({maxHeight: 360});
                    popup.setContent(popupDefault);
                    layer.on('click', function(e) {

                        tools.findOne('id = '+ e.target.feature.properties.id, function(data){
                            var template = $.templates("#tpl-event");
                            $.views.helpers({
                                'formatDate': function (date, format) {
                                    return moment(new Date(date)).format(format);
                                },
                                'agendaUrl': function (id) {
                                    return tools.settings('accessPath') + '/agenda/event/' + id;
                                },
                                'filterUrl': function (fullUrl) {
                                    if ($.isFunction(tools.settings('filterUrl'))) {
                                        fullUrl = tools.settings('filterUrl')(fullUrl);
                                    }
                                    return fullUrl;
                                },
                                'settings': function (setting) {
                                    return tools.settings(setting);
                                },
                                'language': tools.settings('language')
                            });
                            var htmlOutput = template.render([data]).replace('col-md-4','');
                            popup.setContent(htmlOutput);popup.update();
                        })
                    });
                    layer.bindPopup(popup);
                }
            });
        }
    );
    map.scrollWheelZoom.disable();

    $("body").on("shown.bs.tab", function() {
        tools.refreshMap();
    });

    var spinner = $.templates("#tpl-spinner").render({});

    var resultContainer = $(".service_teasers");
    var filters = [];
    var typeList = $('.widget[data-filter="type"] ul');
    var dateList = $('.widget[data-filter="date"] ul');
    var targetList = $('.widget[data-filter="target"] ul');
    var searchInput = $('.widget[data-filter="q"] input');

    var datepicker = $("#datepicker");
    datepicker.datepicker({
        startDate: "today",
        language: "it",
        todayHighlight: true
    }).on('changeDate', function (e) {
        resetSelectType();
        resetSelectTarget();
        clearSelectDate();
        var now = new Date();
        if (now.toDateString() == e.date.toDateString()) {
            $('li a[data-value="today"]', dateList).parent().addClass('active');
        }
        doFind();
        e.preventDefault();
    });

    $('.widget[data-filter="q"]').find('button').on('click', function (e) {
        var current = $(e.currentTarget);
        var currentWidget = current.parents('.widget');
        var currentInput = currentWidget.find('input');
        var icon = current.find('i');
        searchButtonIcon(icon, currentInput, function () {
            doFind();
        });
        e.preventDefault();
    });

    var searchButtonIcon = function (icon, input, cb, context) {
        var searchClass = 'glyphicon glyphicon-search';
        var clearClass = 'glyphicon glyphicon-remove-circle';
        if (icon.hasClass(searchClass) && input.val() != '') {
            icon.removeClass(searchClass).addClass(clearClass);
            if ($.isFunction(cb)) {
                cb.call(context);
            }
        } else if (icon.hasClass(clearClass)) {
            icon.removeClass(clearClass).addClass(searchClass);
            input.val('');
            if ($.isFunction(cb)) {
                cb.call(context);
            }
        }
    };

    $(document).on('click', 'aside.widget a', function (e) {
        var current = $(e.currentTarget);
        var currentWidget = current.parents('.widget');
        var currentValue = current.data('value');
        var currentFilter = currentWidget.data('filter');
        if (currentFilter == 'type') {
            clearSelectType();
        } else if (currentFilter == 'target') {
            clearSelectTarget();
        } else {
            clearSelectDate();
            datepicker.datepicker('update', '');
            if (currentValue == 'today') {
                var now = new Date();
                datepicker.datepicker('update', new Date(now.toDateString()));
            }
        }
        current.parents('li').addClass('active');
        doFind();
        e.preventDefault();
    });

    var clearSelectType = function () {
        $('li', typeList).removeClass('active').hide();
    };

    var clearSelectDate = function () {
        $('li', dateList).removeClass('active');
    };

    var clearSelectTarget = function () {
        $('li', targetList).removeClass('active').hide();
    };

    var resetSelectType = function () {
        clearSelectType();
        $('li a[data-value="all"]', typeList).parent().addClass('active');
    };

    var resetDateType = function () {
        clearSelectDate();
        $('li a[data-value="next 30 days"]', dateList).parent().addClass('active');
    };

    var resetSelectTarget = function () {
        clearSelectTarget();
        $('li a[data-value="all"]', targetList).parent().addClass('active');
    };

    var readFilters = function () {
        var filters = [];
        $('aside.widget li.active a').each(function () {
            filters.push({
                name: $(this).parents('.widget').data('filter'),
                value: $(this).data('value')
            });
        });
        filters.push({
            name: 'q',
            value: searchInput.val()
        });
        var currentDatepicker = datepicker.datepicker('getDate');
        if (currentDatepicker) {
            filters.push({
                name: 'datepicker',
                value: currentDatepicker.toDateString()
            });
        }
        //console.log(filters);
        return filters;
    };

    var buildQuery = function () {
        filters = readFilters();
        var query = '';

        var search = getFilter('q');
        if (search){
            query += "q = '"+search+"' and ";
        }
        var currentDatepicker = getFilter('datepicker');
        var currentDate = getFilter('date');
        if (currentDatepicker) {
            var currentMoment = moment(new Date(currentDatepicker));
            query += ' calendar[] = [' + currentMoment.set('hour', 0).set('minute', 0).format('YYYY-MM-DD') + ',' + currentMoment.set('hour', 23).set('minute', 59).format('YYYY-MM-DD') + '] and ';
        } else if (currentDate) {
            var start;
            var end;
            switch (currentDate) {
                case 'today':
                    start = moment();
                    end = moment();
                    break;
                case 'weekend':
                    start = moment().day(6);
                    end = moment().day(7);
                    break;
                case 'next 7 days':
                    start = moment();
                    end = moment().add(7, 'days');
                    break;
                case 'next 30 days':
                    start = moment();
                    end = moment().add(30, 'days');
                    break;
                case 'all':
                    start = moment();
                    end = '*';
                    break;
            }

            if (end == '*') {
                query += 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD') + ',*] and ';
            } else {
                query += 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD') + ',' + end.set('hour', 23).set('minute', 59).format('YYYY-MM-DD') + '] and ';
            }
        }
        // Tipo di evento
        var currentType = getFilter('type');
        if (currentType && currentType != 'all') {
            query += 'tipo_evento.name in [' + currentType + '] and ';
        }
        // Target dell'evento
        var currentTarget = getFilter('target');
        if (currentTarget && currentTarget != 'all') {
            query += 'target in [' + currentTarget + '] and ';
        }

        query += ' classes [event] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc] facets [tipo_evento|alpha|100, target|alpha|10]';
        console.log(query);
        return query;
    };

    var doFind = function () {
        find(buildQuery());
    };

    var find = function (query) {
        resultContainer.html(spinner);
        tools.find(query, function (response) {
            parseFacets(response);
            parseSearchHits(response);
            tools.loadMarkersInMap(query);
        });
    };

    var parseFacets = function (response) {
        clearSelectType();
        clearSelectTarget();
        var currentType = getFilter('type'),
            currentTarget = getFilter('target');
        //console.log(currentTarget);
        $('li a[data-value="all"]').parent().show();
        $.each(response.facets, function(){
           if (this.name == 'tipo_evento'){
               $.each(this.data, function(value,count){
                   $('li a[data-value="'+value+'"]', typeList).html(value +' ('+count+')').parent().show();
               });
               $('li a[data-value="'+currentType+'"]', typeList).parent().addClass('active');
           } else if (this.name == 'target') {
               $.each(this.data, function(value,count){
                   if (value != '') {
                       if ($('li a[data-value="'+value+'"]', targetList).length) {
                           $('li a[data-value="'+value+'"]', targetList).html(value +' ('+count+')').parent().show();
                       } else {
                           var li = $('<li><a href="#" data-value="'+value+'">'+value+' ('+count+')'+'</a></li>');
                           targetList.append(li);
                       }
                   }
               });
               $('li a[data-value="'+currentTarget+'"]', targetList).parent().addClass('active');
           }
        });

    };

    var parseSearchHits = function (response, append) {
        if (response.totalCount > 0) {
            sessionStorage.setItem(tools.settings('session_key'), JSON.stringify(filters));
            var template = $.templates("#tpl-event");
            $.views.helpers({
                'formatDate': function (date, format) {
                    return moment(new Date(date)).format(format);
                },
                'agendaUrl': function (nodeId) {
                    return tools.settings('accessPath') + '/agenda/event/' + nodeId;
                },
                'associazioneUrl': function (objectId) {
                    return tools.settings('accessPath') + '/agenda/associazioni/' + objectId;
                },
                'filterUrl': function (fullUrl) {
                    if ($.isFunction(tools.settings('filterUrl'))) {
                        fullUrl = tools.settings('filterUrl')(fullUrl);
                    }
                    return fullUrl;
                },
                'settings': function (setting) {
                    return tools.settings(setting);
                },
                'language': tools.settings('language')
            });

            console.log(response.searchHits);

            var htmlOutput = template.render(response.searchHits);
            if (append) {
                resultContainer.append(htmlOutput);
            } else {
                resultContainer.html(htmlOutput);
            }
            if (response.nextPageQuery) {
                var loadMore = $('<a href="#" class="btn btn-primary btn-lg">Carica altri eventi</a>');
                loadMore.bind('click',function(e){
                    tools.find(response.nextPageQuery, function (response) {
                        parseSearchHits(response, true);
                        loadMore.remove();
                    });
                    e.preventDefault();
                });
                resultContainer.append(loadMore)
            }
        }else {
            resultContainer.html('<em>Nessun evento trovato...</em>');
        }
    };

    var getFilter = function (name) {
        var filter = null;
        $.each(filters, function () {
            if (this.name == name) {
                filter = this.value;
            }
        });
        return filter;
    };

    var init = function () {

        resultContainer.html(spinner);

        resetSelectType();
        resetDateType();
        resetSelectTarget();


        if (sessionStorage.getItem(tools.settings('session_key'))) {
            filters = JSON.parse(sessionStorage.getItem(tools.settings('session_key')));
            var currentDatepicker = getFilter('datepicker');
            if (currentDatepicker) {
                clearSelectDate();
                datepicker.datepicker('update', new Date(currentDatepicker));
            }
            var currentDate = getFilter('date');
            if (currentDate) {
                clearSelectDate();
                datepicker.datepicker('update', '');
                $('li a[data-value="' + currentDate + '"]', dateList).parent().addClass('active');
            }
            searchInput.val(getFilter('q'));
        }

        searchButtonIcon($('.widget[data-filter="q"] i'), searchInput);

        doFind();
    };

    tools.cacheAll('classes [tipo_evento] and raw[meta_depth_si] = 4 sort [name=>asc]', function (response) {
        $.each(response,function(){
            var li = $('<li><a href="#" data-value="'+this.metadata.name[tools.settings('language')]+'">'+this.metadata.name[tools.settings('language')]+'</a></li>');
            li.hide();
            typeList.append(li);
        });
        init();
    });

});