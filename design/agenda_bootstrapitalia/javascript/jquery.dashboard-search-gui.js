;(function ($, window, document, undefined) {

    'use strict';

    var pluginName = 'dashboardSearchGui',
        defaults = {
            'spritePath': '/',
            'limitPagination': 21,
            'factory': 'factoryidentifier',
            'stateGroup': 'ezlock'
        };

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

        this.allChipToggle = $('.search-form-filters a:first');

        this.searchQuery = $('.search-query');

        this.needRefresh = {
            'grid': true,
            'geo': true
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

        if ($('#map').length > 0) {
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
        }

        this.preview = $('#preview');
        this.stateToggles = $('a.state-filter');

        this.spinnerTpl = $($.templates('#tpl-spinner').render({}));
        this.gridTpl = $.templates('#tpl-dashboard-grid');
        this.listTpl = $.templates('#tpl-dashboard-list');
        this.currentPage = 0;
        this.queryPerPage = [];
        this.currentView = $('a.agenda-view-selector.active').attr('href');

        this.addListeners();
        this.resetForm();
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

            plugin.searchGui.find('input[data-group]').on('change', function (e) {
                plugin.onInputGroupChange(e);
            });

            plugin.searchGui.find('input[data-in_group]').on('change', function (e) {
                plugin.onInputInGroupChange(e);
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
                    'geo': true
                };
                plugin.runSearch();
                e.preventDefault();
            });

            $('body').on('shown.bs.tab', function (e) {
                if ($(e.target).hasClass('agenda-view-selector')) {
                    plugin.currentView = $(e.target).attr('href');
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

        onInputGroupChange: function (e) {
            var plugin = this;

            var current = $(e.currentTarget);
            if (current.is(':checked')) {
                current.parents('[data-input_group]').find('input[data-in_group]').prop('checked', true).each(function () {
                    plugin.removeFilterChip($(this).data('id'));
                });
                plugin.appendFilterChip(current.data('id'), current.parent().find('span').text());
            } else {
                current.parents('[data-input_group]').find('input[data-in_group]').prop('checked', false).each(function () {
                    plugin.removeFilterChip($(this).data('id'));
                });
                plugin.removeFilterChip(current.data('id'));
            }
        },

        onInputInGroupChange: function (e) {
            var plugin = this;

            var current = $(e.currentTarget);
            var parentGroup = current.parents('[data-input_group]').find('input[data-group]');
            var parentGroupText = parentGroup.parent().find('span').text();
            var allChecked = current.parents('[data-input_group]').find('input[data-in_group]:checked').length === current.parents('[data-input_group]').find('input[data-in_group]').length;
            var allUnchecked = current.parents('[data-input_group]').find('input[data-in_group]:checked').length === 0;

            if (allChecked) {
                parentGroup.prop('indeterminate', false).prop('checked', true);
                current.parents('[data-input_group]').find('input[data-in_group]:checked').each(function () {
                    plugin.removeFilterChip($(this).data('id'));
                });
                plugin.appendFilterChip(parentGroup.data('id'), parentGroupText);
            } else if (allUnchecked) {
                parentGroup.prop('indeterminate', false).prop('checked', false);
                plugin.removeFilterChip(parentGroup.data('id'));
            } else {
                parentGroup.prop('checked', false).prop('indeterminate', true);
                if (current.is(':checked')) {
                    plugin.removeFilterChip(parentGroup.data('id'));
                    plugin.appendFilterChip(current.data('id'), parentGroupText + ': ' + current.parent().find('span').text());
                } else {
                    plugin.removeFilterChip(parentGroup.data('id'));
                    plugin.removeFilterChip(current.data('id'));
                    current.parents('[data-input_group]').find('input[data-in_group]:checked').each(function () {
                        plugin.appendFilterChip($(this).data('id'), parentGroupText + ': ' + $(this).parent().find('span').text());
                    });
                }
            }
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
                'geo': true
            };
        },

        removeFilterChip: function (inputId) {
            var plugin = this;
            var chip = $('a[data-input_id="' + inputId + '"]').remove();
            plugin.refreshAllChipToggle();
            plugin.needRefresh = {
                'grid': true,
                'geo': true
            };
            return $('input[data-id="' + chip.data('input_id') + '"]');
        },

        getFilterChip: function (inputId) {
            return $('a[data-input_id="' + inputId + '"]');
        },

        refreshAllChipToggle: function () {
            var plugin = this;
            if ($('.search-form-filters a:visible').length === 2) {
                plugin.allChipToggle.addClass('selected');
            } else {
                plugin.allChipToggle.removeClass('selected');
            }
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

        onAllChipToggleClick: function () {
            var plugin = this;
            plugin.resetForm();
            $('a[data-input_id]').each(function () {
                plugin.removeFilterChip($(this).data('input_id'));
            });
            $('input[data-group]').prop('indeterminate', false);
            plugin.resetSearchQueryChip();

            plugin.refreshAllChipToggle();
            plugin.searchGuiForm.trigger('submit');
        },

        buildQuery: function () {
            var plugin = this;

            var places = [];
            var authors = [];
            var calendar = {'start': '*', 'end': '*'};
            $.each(plugin.searchGuiForm.serializeArray(), function () {
                if (this.name === 'Place') {
                    places.push(this.value);
                }
                if (this.name === 'Author') {
                    authors.push(this.value);
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
            if (places.length > 0) {
                query += ' and takes_place_in.id in [' + places.join(',') + ']';
            }
            if (authors.length > 0) {
                query += ' and owner_id in [' + authors.join(',') + ']';
            }
            if (plugin.currentView !== '#agenda') {
                var startQuery = calendar.start === '*' ? '*' : calendar.start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm');
                var endQuery = calendar.end === '*' ? '*' : calendar.end.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm');
                query += ' and published range [' + startQuery + ',' + endQuery + ']';
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
                    var dashboardStateIdentifier = false;
                    $.each(this.metadata.stateIdentifiers, function () {
                        var parts = this.split('.');
                        if (parts[0] === plugin.settings.stateGroup) {
                            dashboardStateIdentifier = parts[1];
                        }
                    });
                    this.dashboardStateIdentifier = dashboardStateIdentifier;
                    this.factoryIdentifier = plugin.settings.factory;
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
        }

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

