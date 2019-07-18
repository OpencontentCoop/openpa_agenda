$(document).ready(function () {
    var tools = $.opendataTools;

    var datatableLanguage = "//cdn.datatables.net/plug-ins/1.10.12/i18n/Italian.json";
    var calendarLocale = 'it';
    if (tools.settings('language') == 'ger-DE') {
        datatableLanguage = "//cdn.datatables.net/plug-ins/1.10.12/i18n/German.json";
        calendarLocale = 'de';
    } else if (tools.settings('language') == 'eng-GB') {
        datatableLanguage = "//cdn.datatables.net/plug-ins/1.10.12/i18n/English.json";
        calendarLocale = 'en';
    }

    var facets = [];
    if (LuogoFieldIsEnabled)
        facets.push({field: 'luogo', 'limit': 300, 'sort': 'alpha', name: LuogoFieldIsEnabled});

    var mainQuery = 'null';
    if (CurrentUserIsModerator) {
      mainQuery = 'classes ['+AgendaEventClassIdentifier+'] subtree ['+AgendaSubTree+'] sort [published=>desc]';
    }else{
      mainQuery = "owner_id = '"+CurrentUserId+"' classes ["+AgendaEventClassIdentifier+"] subtree ["+AgendaSubTree+"] sort [published=>desc]";
    }
    if (facets.length > 0) {
        mainQuery += ' facets [' + tools.buildFacetsString(facets) + ']';
    }
    var _currentData = [];
    var stateSelect = $('select#state');
    var calendar = $('#calendar');
    var datatable = $('.content-data').opendataDataTable({
        "builder": {
            "query": mainQuery
        },
        "datatable": {
            "language": {"url": datatableLanguage},
            "ajax": {url: tools.settings('accessPath') + "/opendata/api/datatable/search/"},
            "order": [[3, "desc"]],
            "columns": [
                {"data": "metadata.remoteId", "name": 'remote_id', "title": '', "sortable": false},
                {"data": "data", "name": 'titolo', "title": Translations['Title']},
                {
                    "data": "metadata",
                    "name": 'raw[meta_owner_name_t]',
                    "title": Translations['Author']
                },
                {"data": "metadata.published", "name": 'published', "title": Translations['Published']},
                {"data": "data", "name": 'from_time', "title": Translations['Start date']},
                {"data": "data", "name": 'from_time', "title": Translations['End date']},
                {"data": "metadata.stateIdentifiers", "name": 'state', "title": Translations['Status'], "sortable": false},
                {"data": "metadata.id", "name": 'id', "title": Translations['Translations'], "sortable": false}
            ],
            "columnDefs": [
                {
                    "render": function (data, type, row) {
                        return '<a class="btn btn-info" href="' + tools.settings('accessPath') + '/editorialstuff/edit/agenda/' + row.metadata.id + '">'+Translations['Detail']+'</a>';
                    },
                    "targets": [0]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        if (contentData){
                            var title = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].titolo : contentData[Object.keys(contentData)[0]].titolo;
                            return '<a href="#" class="dt-load-preview" data-object="' + row.metadata.id + '">'+title+'</a>';
                        }
                        return '';
                    },
                    "targets": [1]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.metadata.ownerName;
                        if (contentData){
                            return typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')] : contentData[Object.keys(contentData)[0]];
                        }
                        return '';
                    },
                    "targets": [2]
                },
                {
                    "render": function (data, type, row) {
                        return moment(new Date(data)).format('DD/MM/YYYY');
                    },
                    "targets": [3]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        if (contentData){
                            var date = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].from_time : contentData[Object.keys(contentData)[0]].from_time;
                            return moment(new Date(date)).format('DD/MM/YYYY HH:MM');
                        }
                        return '';
                    },
                    "targets": [4]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        if (contentData){
                            var date = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].to_time : contentData[Object.keys(contentData)[0]].to_time;
                            return moment(new Date(date)).format('DD/MM/YYYY HH:MM');
                        }
                        return '';
                    },
                    "targets": [5]
                },
                {
                    "render": function (data, type, row) {
                        return $.map(data, function (value, key) {
                            var parts = value.split('.');
                            if (parts[0] == 'moderation') {
                                return $.map(stateSelect.find('option'), function (option) {
                                    var $option = $(option);
                                    if ($option.data('state_identifier') == parts[1]) {
                                        return '<span class="label label-info label-'+$option.data('state_identifier')+'">'+$option.text()+'</span>';
                                    }
                                });
                            }
                        });
                    },
                    "targets": [6]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        if (contentData){
                            var keys = $.map(contentData, function (value, key) {
                                return key;
                            });
                            var string = '<div style="white-space:nowrap">';
                            var languages = tools.settings('languages');
                            var length = languages.length;
                            for (var i = 0; i < length; i++) {
                                if ($.inArray(languages[i], keys) >= 0) {
                                  string += '<a href="' + tools.settings('accessPath') + '/content/edit/' + row.metadata.id + '/f/' + languages[i] + '"><img style="max-width:none" src="/share/icons/flags/' + languages[i] + '.gif" /></a> ';
                                } else {
                                  string += '<a href="' + tools.settings('accessPath') + '/content/edit/' + row.metadata.id + '/a"><img style="max-width:none;opacity:0.2" src="/share/icons/flags/' + languages[i] + '.gif" /></a> ';
                                }
                            }
                            string += '</div>';
                            return string;
                        }
                        return '';
                    },
                    "targets": [7]
                }
            ]
        },
        "loadDatatableCallback": function (datatable) {
            calendar.fullCalendar({
                header: {
                    center: "title",
                    right: "agendaDay,agendaWeek,month",
                    left: "prev,today,next"
                },
                defaultView: 'month',
                locale: calendarLocale,
                axisFormat: 'H(:mm)',
                aspectRatio: 1.35,
                selectable: false,
                editable: false,
                timeFormat: 'H(:mm)',
                eventClick: function(calEvent, jsEvent, view) {
                    var remoteTarget = $('#preview .modal-content');
                    $(remoteTarget).html('<em>' + Translations['Loading...'] + '</em>');
                    var template = $.templates("#tpl-event");
                    $.views.helpers(OpenpaAgendaHelpers);
                    remoteTarget.html(template.render(calEvent.content).replace('col-md-6', ''));
                    $('#preview').modal('show');
                },
                eventDataTransform: function(eventData){
                    var content = eventData.content;

                    var color = '#999';
                    $.map(content.metadata.stateIdentifiers, function (value, key) {
                        var parts = value.split('.');
                        if (parts[0] == 'moderation') {
                            return $.map(stateSelect.find('option'), function (option) {
                                var $option = $(option);
                                if ($option.data('state_identifier') == parts[1]) {
                                    var $i = $('<span class="label-'+$option.data('state_identifier')+'">'+$option.text()+'</span>').hide().appendTo("body");
                                    color = $i.css('backgroundColor');
                                    $i.remove();
                                }
                            });
                        }
                    });

                    if (!CurrentUserIsModerator && content.metadata.ownerId != CurrentUserId) {
                        eventData.title = '↪ ' + eventData.title;
                    }

                    eventData.backgroundColor = color;
                    eventData.borderColor = color;

                    return eventData;
                },
                loading: function (isLoading, view) {
                    var calendarSpinnerContainer = $('a[href="#calendar"]');
                    var currentText = calendarSpinnerContainer.html();
                    var calendarSpinner = $('#calendar-tab-spinner');
                    if (isLoading && calendarSpinner.length == 0) {
                        calendarSpinner = $('<span id="calendar-tab-spinner"><i class="fa fa-circle-o-notch fa-spin fa-fw"></i></span>');
                        calendarSpinnerContainer.append(calendarSpinner);
                    } else {
                        calendarSpinner.remove();
                    }

                },
                events: {
                    url: tools.settings().endpoint.fullcalendar,
                    data: function () {
                        return {
                            filters: datatable.settings.builder
                        };
                    }
                }
            });
        }
    }).on('xhr.dt', function (e, settings, json, xhr) {
        if (!calendar.fullCalendar('isFetchNeeded')) {
            calendar.fullCalendar('refetchEvents');
        }
        _currentData = json.data;
    }).on( 'draw.dt', function ( e, settings ) {
        $('a.dt-load-preview').on('click', function (e) {
            var currentId = $(this).data('object');
            var remoteTarget = $('#preview .modal-content');
            $(remoteTarget).html('<em>' + Translations['Loading...'] + '</em>');
            $('#preview').modal('show');
            var template = $.templates("#tpl-event");
            $.views.helpers(OpenpaAgendaHelpers);
            var inMemoryContent;
            $.each(_currentData, function () {
                if (this.metadata.id == currentId){
                    inMemoryContent = this;
                    return;
                }
            });
            if (inMemoryContent){
                remoteTarget.html(template.render(inMemoryContent).replace('col-md-6', ''));
            }else {
                tools.find('id = ' + currentId, function (response) {
                    remoteTarget.html(template.render(response.searchHits[0]).replace('col-md-6', ''));
                });
            }
            e.preventDefault();
        });
    }).data('opendataDataTable')
        .attachFilterInput(stateSelect);

    if (facets.length > 0) {
        tools.find(mainQuery + ' limit 1', function (response) {
            datatable.loadDataTable();
            var form = stateSelect.parents('form');
            $.each(response.facets, function () {
                tools.buildFilterInput(facets, this, datatable, function (selectContainer) {
                    form.append(selectContainer);
                });
            });
        });
    }else{
        datatable.loadDataTable();
    }

    stateSelect.val('').trigger("chosen:updated");;

    $("body").on("shown.bs.tab", function () {
        calendar.fullCalendar('render');
    });

    $(document).on('click','[data-load-remote]',function(e) {
        e.preventDefault();
        var $this = $(this);
        $($this.data('remote-target')).html('<em>Loading...</em>');
        var remote = $this.data('load-remote');
        if(remote) {
            $($this.data('remote-target')).load(remote, null, function(responseTxt, statusTxt, xhr) {
                if (statusTxt == "success") {
                    var links = $($this.data('remote-target')).find('.modal-body').find('a');
                    links.each(function (i, v) {
                        $(v).attr('href', '#').attr('style', 'color:#ccc;');
                    });
                }
            });

        }
    });

});
