;(function ($, window, document, undefined) {

    'use strict';

    var pluginName = 'agendaSearchGui',
        defaults = {
            'spritePath': '/',
            'defaultCalendarView': 'dayGridMonth',
            'responsiveCalendar': true,
            'allText': 'Also past events',
            'limitPagination': 21,
            'onInit': function () {}
        };

    function TreeItem(current, container) {
        this.container = container;
        if (current.length > 0) {
            this.id = current.data('id');
            this.label = current.data('label');
            this.path = current.data('tree');
            this.level = current.data('level');
            this.pathArray = this.path.split('#');
            this.parentPath = this.path.replace(this.id + '#', '');
            this.element = current;
        }else{
            this.id = 0;
            this.label = false;
            this.path = 0;
            this.level = -1;
            this.pathArray = [];
            this.parentPath = 0;
            this.element = $();
        }
    }

    $.extend(TreeItem.prototype, {
        tree: function () {
            var self = this;
            var tree = [];
            self.container.find('input[data-tree^="'+self.path+'"]').filter(function () {
                return $(this).data('id') !== self.id;
            }).each(function () {
                tree.push(new TreeItem($(this), self.container));
            });
            return $(tree);
        },

        children: function () {
            var self = this;
            var children = [];
            self.container.find('input[data-tree^="'+self.path+'"][data-level="'+(self.level+1)+'"]').filter(function () {
                return $(this).data('id') !== self.id;
            }).each(function () {
                children.push(new TreeItem($(this), self.container));
            });
            return $(children);
        },

        parent: function(){
            var self = this;
            return new TreeItem(self.container.find('input[data-tree="'+self.parentPath+'"]'), self.container);
        },

        root: function(){
            var self = this;
            return new TreeItem(self.container.find('input[data-id="'+self.pathArray[0]+'"]'), self.container);
        },

        parents: function () {
            var self = this;
            var parents = [];
            self.container.find('input[data-tree]').filter(function () {
                return $.inArray(''+$(this).data('id'), self.pathArray) >= 0 && $(this).data('id') !== self.id;
            }).each(function () {
                parents.push(new TreeItem($(this), self.container));
            });

            return $(parents);
        },

        siblings: function () {
            var self = this;
            var siblings = [];
            self.container.find('input[data-tree^="'+self.parentPath+'"][data-level="'+self.level+'"]').filter(function () {
                return $(this).data('tree') !== self.parentPath && $(this).data('id') !== self.id;
            }).each(function () {
                siblings.push(new TreeItem($(this), self.container));
            });

            return $(siblings);
        },

        isChecked: function(){
            return this.element.is(':checked');
        },

        isIndeterminate: function(){
            return this.element.prop('indeterminate') === true;
        },

        isUnchecked: function(){
            return !this.element.is(':checked') && this.element.prop('indeterminate') === false;
        },

        isSiblingsChecked: function (){
            var self = this;
            return self.siblings().filter(function () {return this.element.is(':checked');}).length === self.siblings().length;
        },

        isSiblingsUnchecked: function (){
            var self = this;
            return self.siblings().filter(function () {return this.element.is(':checked');}).length === 0 && self.siblings().filter(function () {return this.element.prop('indeterminate') === true;}).length === 0;
        },

        isSiblingsMixedChecked: function (){
            var self = this;
            return !self.isSiblingsChecked() && !self.isSiblingsUnchecked();
        },

        isChildrenChecked: function (){
            var self = this;
            return self.tree().filter(function () {return this.element.is(':checked');}).length === self.tree().length;
        },

        isChildrenUnchecked: function (){
            var self = this;
            return self.tree().filter(function () {return this.element.is(':checked');}).length === 0 && self.tree().filter(function () {return this.element.prop('indeterminate') === true;}).length === 0;
        },

        isChildrenMixedChecked: function (){
            var self = this;
            return !self.isChildrenChecked() && !self.isChildrenUnchecked();
        },

        getCheckedIdList: function () {
            var self = this;

            var idList = [];
            self.tree().filter(function () {return this.element.is(':checked');}).each(function () {
                idList.push(this.id);
            });

            return idList;
        },

        getIdList: function () {
            var self = this;

            var idList = [];
            self.tree().each(function () {
                idList.push(this.id);
            });

            return idList;
        },

        getChippableItems: function () {
            var self = this;

            var itemList = [];
            if (self.isChecked()){
                itemList.push(self);
            }else{
                self.children().each(function () {
                    $.merge(itemList, this.getChippableItems());
                });
            }

            return itemList;

        }
    });

    function Plugin(element, options) {
        this.settings = $.extend({}, defaults, options);

        this.modalContainer = $(element);
        this.searchGui = $('.search-gui');
        this.searchGuiForm = this.searchGui.parent();

        this.toggleSearch = $('#toggleSearch');

        this.spritePath = this.settings.spritePath;

        this.fromDateInput = $('#datepicker_start').datepicker({
            inputFormat: ['dd/MM/yyyy'],
            outputFormat: 'dd/MM/yyyy',
        });
        this.toDateInput = $('#datepicker_end').datepicker({
            inputFormat: ['dd/MM/yyyy'],
            outputFormat: 'dd/MM/yyyy',
        });
        this.alsoPastCheck = $('#AlsoPast');

        this.allChipToggle = $('.search-form-filters a[data-all="all"]');

        this.searchQuery = $('.search-query');

        this.needRefresh = {
            'grid': true,
            'geo': true,
            'agenda': true,
        };

        this.baseUrl = $.opendataTools.settings('accessPath');

        $.views.helpers($.extend({}, $.opendataTools.helpers, {
            'agendaUrl': function (id) {
                return $.opendataTools.settings('accessPath') + '/openpa/object/' + id;
            },
            'objectUrl': function (id) {
                return $.opendataTools.settings('accessPath') + '/openpa/object/' + id;
            },
            'agendaMainImageUrl': function (data) {
                var images = $.opendataTools.helpers.i18n(data, 'image');
                if (images.length > 0) {
                    return $.opendataTools.settings('accessPath') + '/agenda/image/' + images[0].id;
                }
                return null;
            },
            'associazioneUrl': function (objectId) {
                return $.opendataTools.settings('accessPath') + '/openpa/object/' + objectId;
            }
        }));

        moment.locale($.opendataTools.settings('locale'));

        this.map = $.opendataTools.initMap(
            'map',
            function (response) {
                return L.geoJson(response, {
                    pointToLayer: function (feature, latlng) {
                        var customIcon = L.MakiMarkers.icon({icon: 'circle', size: 'l'});
                        return L.marker(latlng, {icon: customIcon});
                    },
                    onEachFeature: function (feature, layer) {
                        var popupDefault = '<p class="text-center"><i class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + $.opendataTools.settings('accessPath') + '/agenda/event/' + feature.properties.mainNodeId + '" target="_blank">';
                        popupDefault += feature.properties.name;
                        popupDefault += '</a></p>';
                        var popup = new L.Popup({maxHeight: 360});
                        popup.setContent(popupDefault);
                        layer.on('click', function (e) {

                            $.opendataTools.findOne('id = ' + e.target.feature.properties.id, function (data) {
                                var template = $.templates('#tpl-event');
                                var htmlOutput = template.render([data]);
                                popup.setContent(htmlOutput);
                                popup.update();
                            })
                        });
                        layer.bindPopup(popup);
                    }
                });
            }
        );
        this.map.setView([0, 0], 10).scrollWheelZoom.disable();

        this.preview = $('#preview');
        this.stateToggles = $('a.state-filter');

        var plugin = this;
        this.calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
            plugins: ['dayGrid', 'list'],
            header: {
                left: 'prev,next',
                center: 'title',
                right: 'today'
            },
            height: 'parent',
            locale: $.opendataTools.settings('locale'),
            aspectRatio: 3,
            eventLimit: false,
            columnHeaderFormat: {
                weekday: 'short',
                day: 'numeric',
                omitCommas: true
            },
            defaultView: plugin.settings.defaultCalendarView,
            views: {
                dayGridMonth: {
                    eventLimit: 6
                }
            },
            eventRender: function (info) {
                $(info.el)
                    .find('.fc-content, .fc-list-item-title')
                    .html('<strong>' + info.event.title + '</strong>')
                    .css('cursor', 'pointer');
            },
            windowResize: function (view) {
                if (plugin.settings.responsiveCalendar) {
                    var windowWidth = $(window).width();
                    if (windowWidth < 800) {
                        this.changeView('listWeek');
                    } else {
                        this.changeView('dayGridMonth');
                    }
                }
            },
            eventClick: function (calEvent, jsEvent, view) {
                plugin.preview.find('.modal-content').html('');
                var template = $.templates('#tpl-event');
                var htmlOutput = template.render(calEvent.event.extendedProps.content);
                plugin.preview.find('.modal-content').html(htmlOutput);
                plugin.preview.modal();
            },
            events:{
                url: $.opendataTools.settings('endpoint').fullcalendar,
                extraParams: function (){
                    return {q: plugin.buildQuery()}
                }
            },
            displayEventTime: false
        });

        this.spinnerTpl = $($.templates('#tpl-spinner').render({}));
        this.gridTpl = $.templates('#tpl-grid');
        this.listTpl = $.templates('#tpl-list');
        this.currentPage = 0;
        this.queryPerPage = [];
        this.currentView = $('a.agenda-view-selector.active').attr('href');

        this.resetForm();
        this.addListeners();
        if ($.isFunction(this.settings.onInit)) {
            this.settings.onInit(this);
        }
        this.runSearch();
    }

    $.extend(Plugin.prototype, {

        addListeners: function () {
            var plugin = this;

            plugin.toggleSearch.on('click', function (e) {
                plugin.showSearchGui();
                plugin.modalContainer.modal();
                e.preventDefault();
            });

            plugin.searchGui.find('input[data-tree]').on('change', function (e) {
                var current = $(e.currentTarget);
                plugin.onCheckBoxTreeChange(current);
            });
            plugin.allChipToggle.on('click', function (e) {
                plugin.onAllChipToggleClick();
                e.preventDefault();
            });

            plugin.fromDateInput.on('change', function () {
                plugin.onChangeDatePicker();
            });

            plugin.toDateInput.on('change', function () {
                plugin.onChangeDatePicker();
            });

            plugin.alsoPastCheck.on('change', function (e) {
                plugin.onChangePastCheck(e);
            });

            plugin.searchGuiForm.on('submit', function (e) {
                plugin.hideSearchGui();
                plugin.runSearch();
                e.preventDefault();
            });

            plugin.stateToggles.on('click', function (e) {
                var current = $(this);
                if (current.hasClass('active')) {
                    current.removeClass('active');
                } else {
                    plugin.stateToggles.removeClass('active');
                    current.addClass('active');
                }
                plugin.needRefresh = {
                    'grid': true,
                    'geo': true,
                    'agenda': true,
                };
                plugin.runSearch();
                e.preventDefault();
            });

            $('body').on('shown.bs.tab', function (e) {
                if ($(e.target).hasClass('agenda-view-selector')) {
                    plugin.currentView = $(e.target).attr('href');
                    if (plugin.currentView === '#agenda') {
                        plugin.getFilterChip('daterange').hide();
                        plugin.getFilterChip('alsopast').hide();
                        plugin.refreshAllChipToggle();
                    } else {
                        plugin.getFilterChip('daterange').show();
                        plugin.getFilterChip('alsopast').show();
                        plugin.refreshAllChipToggle();
                    }
                    if (plugin.currentView === '#geo') {
                        $.opendataTools.refreshMap();
                    }
                    plugin.runSearch();
                }
            });

            if (plugin.hasSearchQuery()){
                plugin.searchQuery.find('input').on('keydown', function (e) {
                    var key = e.keyCode || e.which;
                    if (key === 13){
                        plugin.onStartSearchQuery();
                        e.preventDefault();
                    }
                });
                plugin.searchQuery.find('.start-search').on('click', function () {
                    plugin.onStartSearchQuery();
                });
                plugin.searchQuery.find('.reset-search').on('click', function () {
                    plugin.onResetSearchQuery();
                });
            }

            plugin.modalContainer.trigger('search_gui_initialized', this);
        },

        showSearchGui: function () {
            this.modalContainer.trigger('search_gui_show', this);
        },

        hideSearchGui: function () {
            var plugin = this;
            plugin.modalContainer.modal('hide');
        },

        onCheckBoxTreeChange:  function(current){
            var plugin = this;

            var treeItem = new TreeItem(current, plugin.searchGui);

            $.each(treeItem.root().getIdList(), function () {
                plugin.removeFilterChip(this);
            });

            if (treeItem.isChecked()){
                current.prop('indeterminate', false);
                treeItem.tree().each(function () {
                    this.element.prop('checked', true).prop('indeterminate', false);
                });
                treeItem.parents().each(function () {
                    this.element.prop('indeterminate', true).prop('checked', false);
                });
                if (treeItem.isSiblingsChecked()){
                    treeItem.parent().element.prop('indeterminate', false).prop('checked', true);
                }
                if (treeItem.parent().isSiblingsChecked()){
                    treeItem.parent().parent().element.prop('indeterminate', false).prop('checked', true);
                }
            }

            if (treeItem.isUnchecked()){
                treeItem.tree().each(function () {
                    this.element.prop('checked', false);
                });
                if (treeItem.isSiblingsUnchecked()){
                    treeItem.parent().element.prop('indeterminate', false).prop('checked', false);
                }else if (treeItem.isSiblingsChecked() || treeItem.isSiblingsMixedChecked()){
                    treeItem.parent().element.prop('indeterminate', true).prop('checked', false);
                }

                if (treeItem.parent().isSiblingsMixedChecked() || treeItem.parent().isIndeterminate() || treeItem.parent().isUnchecked()){
                    treeItem.parent().parent().element.prop('indeterminate', true).prop('checked', false);
                }
                if (treeItem.parent().isSiblingsUnchecked() && treeItem.parent().isUnchecked()){
                    treeItem.parent().parent().element.prop('indeterminate', false).prop('checked', false);
                }
            }

            $.each(treeItem.root().getChippableItems(),function () {
                plugin.appendFilterChip(this.id, this.label);
            });

        },

        appendFilterChip: function (inputId, name) {
            var plugin = this;
            if ($('a[data-input_id="' + inputId + '"]').length === 0) {
                var chip = $('<a href="#" data-input_id="' + inputId + '" class="chip chip-lg selected"><span class="chip-label">' + name + '</span><svg class="icon filter-remove"><use xlink:href="' + plugin.spritePath + '#it-close"></use></svg><span class="sr-only">Remove</span></a>').on('click', function (e) {
                    var input = plugin.removeFilterChip($(e.currentTarget).data('input_id'));
                    if (input.attr('type') === 'checkbox'){
                        input.prop('checked', false).trigger('change');
                    }else{
                        input.val('');
                    }
                    plugin.searchGuiForm.trigger('submit');
                    e.preventDefault();
                });
                this.toggleSearch.before(chip);
            }
            plugin.refreshAllChipToggle();
            plugin.needRefresh = {
                'grid': true,
                'geo': true,
                'agenda': true,
            };
        },

        removeFilterChip: function (inputId) {
            var plugin = this;
            var chip = $('a[data-input_id="' + inputId + '"]').remove();
            plugin.refreshAllChipToggle();
            plugin.needRefresh = {
                'grid': true,
                'geo': true,
                'agenda': true,
            };
            return $('input[data-id="' + chip.data('input_id') + '"]');
        },

        getFilterChip: function (inputId) {
            return $('a[data-input_id="' + inputId + '"]');
        },

        hasSearchQuery: function(){
            var plugin = this;
            if (plugin.searchQuery.length > 0) {
                plugin.searchQuery.find('.start-search, .reset-search').css('cursor', 'pointer');
                return true;
            }

            return false;
        },

        onStartSearchQuery: function(){
            var plugin = this;
            if (plugin.hasSearchQuery() && plugin.searchQuery.find('input').val() !== '') {
                plugin.setSearchQueryChip();
                plugin.refreshAllChipToggle();
                plugin.runSearch();
            }
        },

        setSearchQueryChip: function(){
            var plugin = this;
            plugin.searchQuery.find('.reset-search').removeClass('hide');
            plugin.searchQuery.find('.start-search').addClass('hide');
            plugin.searchQuery.addClass('selected');
            plugin.needRefresh = {
                'grid': true,
                'geo': true,
                'agenda': true,
            };
        },

        onResetSearchQuery: function(){
            var plugin = this;
            plugin.resetSearchQueryChip();
            plugin.refreshAllChipToggle();
            plugin.runSearch();
        },

        resetSearchQueryChip: function(){
            var plugin = this;
            plugin.searchQuery.find('.start-search').removeClass('hide');
            plugin.searchQuery.find('.reset-search').addClass('hide');
            plugin.searchQuery.find('input').val('');
            plugin.searchQuery.removeClass('selected');
            plugin.needRefresh = {
                'grid': true,
                'geo': true,
                'agenda': true,
            };
        },

        refreshAllChipToggle: function () {
            var plugin = this;
            var chipLength = plugin.hasSearchQuery() ? 3 : 2;
            var hasQueryInput = plugin.hasSearchQuery() && plugin.searchQuery.find('input').val() !== '';
            if ($('.search-form-filters a:visible').length === chipLength && !hasQueryInput) {
                plugin.allChipToggle.addClass('selected');
            } else {
                plugin.allChipToggle.removeClass('selected');
            }
        },

        resetForm: function () {
            this.searchGuiForm[0].reset(); //@todo
            if (this.hasSearchQuery()) {
                this.searchQuery.find('input').val('');
            }
        },

        onChangeDatePicker: function () {
            var plugin = this;
            var start = this.fromDateInput.val();
            var end = this.toDateInput.val();
            var text = '<i class="fa fa-calendar"></i> ';
            if (start.length > 0) {
                text += start + ' ';
            }
            if (end.length > 0) {
                text += '<i class="fa fa-arrow-right"></i> ' + end;
            }
            this.removeFilterChip('daterange');

            if (start.length > 0 || end.length > 0) {
                plugin.appendFilterChip('daterange', text);
            }
        },

        onChangePastCheck: function (e) {
            var plugin = this;
            var current = $(e.currentTarget);
            if (current.is(':checked')) {
                plugin.appendFilterChip('alsopast', plugin.settings.allText);
            }else {
                plugin.removeFilterChip('alsopast');
            }
        },

        onAllChipToggleClick: function () {
            var plugin = this;
            plugin.resetForm();
            $('a[data-input_id]').each(function () {
                plugin.removeFilterChip($(this).data('input_id'));
            });
            $('input[data-tree]').prop('indeterminate', false);
            plugin.resetSearchQueryChip();

            plugin.refreshAllChipToggle();
            plugin.searchGuiForm.trigger('submit');
        },

        buildQuery: function () {
            var plugin = this;

            var types = [];
            var target = [];
            var audience = [];
            var places = [];
            var authors = [];
            var calendar = {'start': moment(), 'end': '*'};
            $.each(plugin.searchGuiForm.serializeArray(), function () {
                if (this.name === 'Type') {
                    types.push(this.value);
                }
                if (this.name === 'Target') {
                    target.push(this.value);
                }
                if (this.name === 'Audience') {
                    audience.push(this.value);
                }
                if (this.name === 'Place') {
                    places.push(this.value);
                }
                if (this.name === 'Author') {
                    authors.push(this.value);
                }
                if (this.name === 'AlsoPast' && this.value.length === 1) {
                    calendar = {'start': '*', 'end': '*'};
                }
                if (this.name === 'From' && this.value.length > 0) {
                    calendar.start = moment(this.value, 'DD/MM/YYYY');
                }
                if (this.name === 'To' && this.value.length > 0) {
                    calendar.end = moment(this.value, 'DD/MM/YYYY');
                }
            });

            var query = plugin.searchGuiForm.data('query');
            if (plugin.hasSearchQuery()){
                var searchText = plugin.searchQuery.find('input').val()
                    .replace(/"/g, '')
                    .replace(/'/g, "")
                    .replace(/\(/g, "")
                    .replace(/\)/g, "")
                    .replace(/\[/g, "")
                    .replace(/\]/g, "");
                if (searchText.length > 0){
                    query += " and q = '\"" + searchText + "\"'";
                }
            }
            if (types.length > 0) {
                query += ' and raw[subattr_has_public_event_typology___tag_ids____si] in [' + types.join(',') + ']';
            }
            if (target.length > 0) {
                query += ' and raw[subattr_typical_age_range___tag_ids____si] in [' + target.join(',') + ']';
            }
            if (audience.length > 0) {
                query += ' and raw[subattr_target_audience___tag_ids____si] in [' + audience.join(',') + ']';
            }
            if (places.length > 0) {
                query += ' and takes_place_in.id in [' + places.join(',') + ']';
            }
            if (authors.length > 0) {
                query += ' and owner_id in [' + authors.join(',') + ']';
            }
            if (plugin.currentView !== '#agenda') {
                var startQuery = calendar.start === '*' ? '*' : calendar.start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm')
                var endQuery = calendar.end === '*' ? '*' : calendar.end.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm')
                query += ' and calendar[time_interval] = [' + startQuery + ',' + endQuery + ']';
            }

            if (plugin.stateToggles.length > 0){
                var states = [];
                plugin.stateToggles.each(function () {
                    if ($(this).hasClass('active')){
                        states.push($(this).data('state_id'));
                    }
                });
                if (states.length > 0){
                    query += ' and state in [' + states.join(',') + ']';
                }
            }

            return query;
        },

        runSearch: function () {
            var plugin = this;
            var query = plugin.buildQuery();
            if (plugin.currentView === '#grid' && plugin.needRefresh.grid) {
                plugin.renderList(plugin.gridTpl);
                plugin.needRefresh.grid = false;
            } else if (plugin.currentView === '#list' && plugin.needRefresh.grid) {
                plugin.renderList(plugin.listTpl);
                plugin.needRefresh.grid = false;
            } else if (plugin.currentView === '#geo' && plugin.needRefresh.geo) {
                plugin.renderGeo(query);
                plugin.needRefresh.geo = false;
            } else if (plugin.currentView === '#agenda' && plugin.needRefresh.agenda) {
                plugin.renderAgenda(query);
                plugin.needRefresh.agenda = false;
            }
        },

        renderList: function (template) {
            var plugin = this;
            var resultsContainer = $('.events ' + plugin.currentView);

            var baseQuery = plugin.buildQuery();
            var paginatedQuery = baseQuery + ' and limit ' + plugin.settings.limitPagination + ' offset ' + plugin.currentPage * plugin.settings.limitPagination;
            resultsContainer.html(plugin.spinnerTpl);

            $.opendataTools.find(paginatedQuery, function (response) {
                plugin.queryPerPage[plugin.currentPage] = paginatedQuery;
                response.currentPage = plugin.currentPage;
                response.prevPage = plugin.currentPage - 1;
                response.nextPage = plugin.currentPage + 1;
                var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount / plugin.settings.limitPagination) : 0;
                var pages = [];
                var i;
                for (i = 0; i < pagination; i++) {
                    plugin.queryPerPage[i] = baseQuery + ' and limit ' + plugin.settings.limitPagination + ' offset ' + (plugin.settings.limitPagination * i);
                    pages.push({'query': i, 'page': (i + 1)});
                }
                response.pages = pages;
                response.pageCount = pagination;

                response.prevPageQuery = jQuery.type(plugin.queryPerPage[response.prevPage]) === 'undefined' ? null : plugin.queryPerPage[response.prevPage];

                $.each(response.searchHits, function () {
                    var self = this;
                    this.baseUrl = plugin.baseUrl;
                    this.languages = $.opendataTools.settings('languages');
                    var currentTranslations = $.map(this.data, function (value, key) {
                        return key;
                    });
                    var translations = [];
                    $.each($.opendataTools.settings('languages'), function () {
                        translations.push({
                            'id': self.metadata.id,
                            'language': this,
                            'active': $.inArray(this, currentTranslations) >= 0
                        });
                    });
                    this.translations = translations;
                    this.currentYear = moment().format('YYYY');
                    var moderationStateIdentifier = false;
                    $.each(this.metadata.stateIdentifiers, function () {
                        var parts = this.split('.');
                        if (parts[0] === 'moderation') {
                            moderationStateIdentifier = parts[1];
                        }
                    });
                    this.moderationStateIdentifier = moderationStateIdentifier;
                });
                var renderData = $(template.render(response));
                resultsContainer.html(renderData);

                resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                    plugin.currentPage = $(this).data('page');
                    if (plugin.currentPage >= 0){
                        plugin.renderList(template);
                    }
                    $('html, body').stop().animate({
                        scrollTop: resultsContainer.offset().top
                    }, 1000);
                    e.preventDefault();
                });
                var more = $('<li class="page-item"><span class="page-link">...</span></li');
                var displayPages = resultsContainer.find('.page[data-page_number]');

                var currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
                var length = 3;
                if (displayPages.length > (length + 2)) {
                    if (currentPageNumber <= (length - 1)) {
                        resultsContainer.find('.page[data-page_number="' + length + '"]').parent().after(more.clone());
                        for (i = length; i < pagination; i++) {
                            resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                        }
                    } else if (currentPageNumber >= length) {
                        resultsContainer.find('.page[data-page_number="1"]').parent().after(more.clone());
                        var itemToRemove = (currentPageNumber + 1 - length);
                        for (i = 2; i < pagination; i++) {
                            if (itemToRemove > 0) {
                                resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                                itemToRemove--;
                            }
                        }
                        if (currentPageNumber < (pagination - 1)) {
                            resultsContainer.find('.page[data-current]').parent().after(more.clone());
                        }
                        for (i = (currentPageNumber + 1); i < pagination; i++) {
                            resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
                        }
                    }
                }
            });
        },

        renderGeo: function () {
            var plugin = this;
            var query = plugin.buildQuery();
            $.opendataTools.loadMarkersInMap(query);
        },

        renderAgenda: function () {
            var plugin = this;
            plugin.calendar.refetchEvents();
            plugin.calendar.render();
            window.dispatchEvent(new Event('resize'));
        },

    });

    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' +
                    pluginName, new Plugin(this, options));
            }
        });
    };

})(jQuery, window, document);

