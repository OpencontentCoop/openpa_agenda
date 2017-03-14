$(document).ready(function () {

    var tools = $.opendataTools;

    var formatDate = function (date, format) {
        return moment(new Date(date)).format(format);
    };
    var agendaUrl = function (id) {
        return tools.settings('accessPath') + '/agenda/event/' + id;
    };
    var filterUrl = function (fullUrl) {
        if ($.isFunction(tools.settings('filterUrl'))) {
            fullUrl = tools.settings('filterUrl')(fullUrl);
        }
        return fullUrl;
    };
    var mainImageUrl = function (data) {
        var images = i18n(data,'images');
        if (images.length > 0){
            return tools.settings('accessPath') + '/agenda/image/' + images[0].id;
        }
        var image = i18n(data,'image');
        if (image) {
            return filterUrl(image.url);
        }
        return null;
    };
    var i18n = function (data, key, fallbackLanguage) {
        var currentLanguage = tools.settings('language');        
        fallbackLanguage = fallbackLanguage || 'ita-IT';
        var returnData = false;
        if (data && key) {
            if (typeof data[currentLanguage] != 'undefined' && data[currentLanguage][key]) {
                returnData = data[currentLanguage][key];
            }
            else if (fallbackLanguage && typeof data[fallbackLanguage] != 'undefined' && data[fallbackLanguage][key]){
                returnData = data[fallbackLanguage][key];
            }            
        }else if (data) {
            if (typeof data[currentLanguage] != 'undefined' && data[currentLanguage]) {
                returnData = data[currentLanguage];
            }
            else if (fallbackLanguage && typeof data[fallbackLanguage] != 'undefined' && data[fallbackLanguage]){
                returnData = data[fallbackLanguage];
            }          
        }        
        return returnData != 0 ? returnData : false;
    };

    var helpers = {
        'formatDate': function (date, format) {
            return formatDate(date, format);
        },
        'agendaUrl': function (id) {
            return agendaUrl(id);
        },
        'filterUrl': function (fullUrl) {
            return filterUrl(fullUrl);
        },
        'mainImageUrl': function (data) {
            return mainImageUrl(data);
        },
        'settings': function (setting) {
            return tools.settings(setting);
        },
        'language': tools.settings('language'),
        'i18n': function (data, key, fallbackLanguage) {
          return i18n(data, key, fallbackLanguage);
        },
        'associazioneUrl': function (objectId) {
          return tools.settings('accessPath') + '/openpa/object/' + objectId;
        }
    };

    if (document.getElementById('map')) {
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
                        layer.on('click', function (e) {

                            tools.findOne('id = ' + e.target.feature.properties.id, function (data) {
                                var template = $.templates("#tpl-event");
                                $.views.helpers(helpers);
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
    }
    $("body").on("shown.bs.tab", function() {
        tools.refreshMap();
    });

    var spinner = $.templates("#tpl-spinner").render({});
    var empty = $.templates("#tpl-empty").render({});

    var resultContainer = $("#calendar");
    var filters = [];
    var typeList = $('.widget[data-filter="type"] ul');
    var dateList = $('.widget[data-filter="date"] ul');
    var targetList = $('.widget[data-filter="target"] ul');
    var iniziativaList = $('.widget[data-filter="iniziativa"] ul');
    var searchInput = $('.widget[data-filter="q"] input');

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
        } else if (currentFilter == 'iniziativa') {
            clearSelectIniziativa();
        } else {
            clearSelectDate();
        }
        current.parent().addClass('active');
        current.parents('aside').find('h4').append('<span class="loading"> <i class="fa fa-circle-o-notch fa-spin"></i></span>');
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

    var clearSelectIniziativa = function () {
        $('li', iniziativaList).removeClass('active').hide();
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

    var resetSelectIniziativa = function () {
        clearSelectIniziativa();
        $('li a[data-value="all"]', iniziativaList).parent().addClass('active');
    };

    var readFilters = function () {
        var filters = [];
        $('aside.widget li.active>a').each(function () {
            filters.push({
                name: $(this).parents('.widget').data('filter'),
                value: $(this).data('value')
            });
        });
        filters.push({
            name: 'q',
            value: searchInput.val()
        });
        //console.log(filters);
        return filters;
    };

    var buildQuery = function () {
        filters = readFilters();
        var query = '';

        var searchList = getFilter('q');
        var search = searchList.length > 0 ? searchList[0] : null;
        if (search){
            query += "q = '"+search+"' and ";
        }
        var currentDateList = getFilter('date');
        var currentDate = currentDateList.length > 0 ? currentDateList[0] : null;
        if (currentDate) {
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
                    start = '*';
                    end = '*';
                    break;
            }

            if (start != '*'){
                if (end == '*') {
                    query += 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',*] and ';
                } else {
                    query += 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',' + end.set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + '] and ';
                }
            }
        }
        // Tipo di evento
        var currentType = getFilter('type');
        if (currentType.length && currentType[0] != 'all') {
            query += 'tipo_evento.tag_ids in [\'' + currentType.join("','") + '\'] and ';
        }
        // Target dell'evento
        var currentTargetList = getFilter('target');
        var currentTarget = currentTargetList.length > 0 ? currentTargetList[0] : null;
        if (currentTarget && currentTarget != 'all') {
            query += 'target in [\'' + currentTarget + '\'] and ';
        }
        // Iniziativa dell'evento
        var currentIniziativaList = getFilter('iniziativa');
        var currentIniziativa = currentIniziativaList.length > 0 ? currentIniziativaList[0] : null;
        if (currentIniziativa && currentIniziativa != 'all') {
            query += 'iniziativa in [\'' + currentIniziativa + '\'] and ';
        }
        var baseQuery = tools.settings('base_query');
        query += ' '+baseQuery;
        //console.log(query);
        return query;
    };

    var doFind = function () {
        find(buildQuery());
    };

    var find = function (query) {
        resultContainer.html(spinner);
        tools.find(query, function (response) {
            if (response.totalCount > 0 && tools.settings('session_key')) {
                sessionStorage.setItem(tools.settings('session_key'), JSON.stringify(filters));
            }
            $('aside.widget h4 span.loading').remove();
            parseFacets(response);
            parseSearchHits(response);
            tools.loadMarkersInMap(query);
        });
    };

    var parseFacets = function (response) {
        clearSelectType();
        clearSelectTarget();
        clearSelectIniziativa();
        var currentTypeList = getFilter('type'),
            currentTargetList = getFilter('target'),
            currentIniziativaList = getFilter('iniziativa');

        var currentTarget = currentTargetList.length > 0 ? currentTargetList[0] : null,
            currentIniziativa = currentIniziativaList.length > 0 ? currentIniziativaList[0] : null;

        $('li a[data-value="all"]').parent().show();
        $.each(response.facets, function(){
            var name = this.name;
            if (this.name == 'tipo_evento.tag_ids'){
                parseTagFacets(this.data, currentTypeList, typeList)
            } else if (this.name == 'target') {
                $.each(this.data, function(value,count){
                    if (value != '') {
                        var quotedValue = value;
                        if ($('li a[data-value="'+quotedValue+'"]', targetList).length) {
                            $('li a[data-value="'+quotedValue+'"]', targetList).html(value +' ('+count+')').parent().show();
                        } else {
                            var li = $('<li><a href="#" data-value="'+quotedValue+'">'+value+' ('+count+')'+'</a></li>');
                            targetList.append(li);
                        }
                        $('[data-filter="'+name+'"]').show();
                    }
                });
                $('li a[data-value="'+currentTarget+'"]', targetList).parent().addClass('active');
            } else if (this.name == 'iniziativa') {
                $.each(this.data, function(value,count){
                    if (value != '') {
                        var quotedValue = value;
                        if ($('li a[data-value="'+quotedValue+'"]', iniziativaList).length) {
                            $('li a[data-value="'+quotedValue+'"]', iniziativaList).html(value +' ('+count+')').parent().show();
                        } else {
                            var li = $('<li><a href="#" data-value="'+quotedValue+'">'+value+' ('+count+')'+'</a></li>');
                            iniziativaList.append(li);
                        }
                        $('[data-filter="'+name+'"]').show();

                    }
                });
                $('li a[data-value="'+currentIniziativa+'"]', iniziativaList).parent().addClass('active');
            }
        });

    };

    var parseTagFacets = function(data, currentList, container){
        $('li a', container).each(function () {
            var name = $(this).data('name');
            $(this).html(name);
        });
        $.each(data, function(value,count){
            var item = $('li a[data-value="'+value+'"]', container);
            var name = item.data('name');
            item.html(name +' ('+count+')').parent().show();
        });
        $.each(currentList, function(){
            $('a[data-value="'+this+'"]', container).parent().addClass('active');
        });
    };

    var parseSearchHits = function (response, append) {
        if (response.totalCount > 0) {
            var template = $.templates("#tpl-event");
            $.views.helpers(helpers);

            var htmlOutput = template.render(response.searchHits);
            if (append) {
                resultContainer.append(htmlOutput);
            } else {
                resultContainer.html(htmlOutput);
            }
            if (response.nextPageQuery) {
                var loadMore = $($.templates("#tpl-load-other").render({}));
                loadMore.find('a').bind('click',function(e){
                    tools.find(response.nextPageQuery, function (response) {
                        parseSearchHits(response, true);
                        loadMore.remove();
                    });
                    e.preventDefault();
                });
                resultContainer.append(loadMore)
            }
        }else {
            resultContainer.html(empty);
        }
    };

    var getFilter = function (name) {
        var filter = [];
        $.each(filters, function () {
            if (this.name == name && (typeof this.value == 'string' || typeof this.value == 'number')) {
                filter.push(typeof this.value == 'string' ? this.value.replace('\'', '\\\'') : this.value);
            }
        });
        //console.log(name, filter);
        return filter;
    };

    var init = function () {

        resultContainer.html(spinner);

        resetSelectType();
        resetDateType();
        resetSelectTarget();
        resetSelectIniziativa();


        if (tools.settings('session_key') && sessionStorage.getItem(tools.settings('session_key'))) {
            filters = JSON.parse(sessionStorage.getItem(tools.settings('session_key')));
            var currentDateList = getFilter('date');
            var currentDate = currentDateList.length > 0 ? currentDateList[0] : null;
            if (currentDate) {
                clearSelectDate();
                $('li a[data-value="' + currentDate + '"]', dateList).parent().addClass('active');
            }
            searchInput.val(getFilter('q'));
        }

        searchButtonIcon($('.widget[data-filter="q"] i'), searchInput);

        doFind();
    };

    var renderTagTree = function(tag, container){
        var li = $('<li><a href="#" data-value="' + tag.id + '" data-name="' + tag.keyword + '">' + tag.keyword + '</a></li>');
        if (tag.hasChildren){
            var childContainer = $('<ul/>');
            $.each(tag.children, function(){
                renderTagTree(this, childContainer);
            });
            li.hide();
            li.append(childContainer)
        }
        container.append(li);
    };

    if (typeList.length > 0) {
        tools.tagsTree('Tipologia di evento', function (response) {
            $.each(response.children, function () {
                renderTagTree(this, typeList);
            });
            init();
        });
    }
});
