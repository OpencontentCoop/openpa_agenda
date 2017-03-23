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

    var mainQuery = 'null';
    if (CurrentUserIsModerator) {
      mainQuery = 'classes [event] sort [published=>desc]';
    }else{
      mainQuery = "owner_id = '"+CurrentUserId+"' classes [event] sort [published=>desc]";
    }
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
                {"data": "data", "name": 'titolo', "title": Translations['Titolo']},
                {
                    "data": "metadata",
                    "name": 'raw[meta_owner_name_t]',
                    "title": 'Autore'
                },
                {"data": "metadata.published", "name": 'published', "title": Translations['Pubblicato']},
                {"data": "data", "name": 'from_time', "title": Translations['Inizio']},
                {"data": "data", "name": 'from_time', "title": Translations['Fine']},
                {"data": "metadata.stateIdentifiers", "name": 'state', "title": Translations['Stato'], "sortable": false},
                {"data": "metadata.id", "name": 'id', "title": Translations['Traduzioni'], "sortable": false},
                {"data": "metadata.id", "name": 'id', "title": '', "sortable": false}
            ],
            "columnDefs": [
                {
                    "render": function (data, type, row) {
                        return '<a class="btn btn-info" href="' + tools.settings('accessPath') + '/editorialstuff/edit/agenda/' + row.metadata.id + '">'+Translations['Dettaglio']+'</a>';
                    },
                    "targets": [0]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        var title = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].titolo : contentData[Object.keys(contentData)[0]].titolo;
                        return '<a href="#" data-toggle="modal" data-remote-target="#preview .modal-content" data-target="#preview" data-load-remote="' + tools.settings('accessPath') + '/layout/set/modal/content/view/full/' + row.metadata.mainNodeId + '">'+title+'</a>';
                    },
                    "targets": [1]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.metadata.ownerName;
                        return typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')] : contentData[Object.keys(contentData)[0]];
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
                        var date = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].from_time : contentData[Object.keys(contentData)[0]].from_time;
                        return moment(new Date(date)).format('DD/MM/YYYY HH:MM');
                    },
                    "targets": [4]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        var date = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].to_time : contentData[Object.keys(contentData)[0]].to_time;
                        return moment(new Date(date)).format('DD/MM/YYYY HH:MM');
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
                        var keys = $.map(contentData, function (value, key) {
                            return key;
                        });
                        var string = '';
                        var languages = tools.settings('languages');
                        var length = languages.length;
                        for (var i = 0; i < length; i++) {
                            if ($.inArray(languages[i], keys) >= 0) {
                                string += '<img src="/share/icons/flags/' + languages[i] + '.gif" /> ';
                            } else {
                                string += '<a href="' + tools.settings('accessPath') + '/content/edit/' + row.metadata.id + '/a"><img style="opacity:0.2" src="/share/icons/flags/' + languages[i] + '.gif" /></a> ';
                            }
                        }
                        return string;
                    },
                    "targets": [7]
                },
                {
                    "render": function (data, type, row) {
                        return ' <form method="post" action="' + tools.settings('accessPath') + '/content/action" style="display: inline;"><button class="btn btn-link btn-xs" type="submit" name="ActionRemove"><i class="fa fa-trash" style="font-size: 12px;"></i></button><input name="ContentObjectID" value="' + row.metadata.id + '" type="hidden"><input name="NodeID" value="' + row.metadata.mainNodeId + '" type="hidden"><input name="ContentNodeID" value="' + row.metadata.mainNodeId + '" type="hidden"><input name="RedirectIfCancel" value="editorialstuff/dashboard/agenda" type="hidden"><input name="RedirectURIAfterRemove" value="editorialstuff/dashboard/agenda" type="hidden"></form> ';
                    },
                    "targets": [8]
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
                    $(remoteTarget).html('<em>'+Translations['Loading...']+'</em>');
                    var remote = tools.settings('accessPath') + '/layout/set/modal/agenda/event/' + calEvent.content.metadata.mainNodeId;
                    if(remote) {
                        remoteTarget.load(remote, null, function(responseTxt, statusTxt, xhr) {
                            if (statusTxt == "success") {
                                var links = $(remoteTarget).find('.modal-body').find('a');
                                links.each(function (i, v) {
                                    $(v).attr('href', '#').attr('style', 'color:#ccc;');
                                });
                            }
                        });
                        $('#preview').modal('show');
                    }
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
                        var q = datatable.buildQuery(true);
                        return {q: q};
                    }
                }
            });
        }
    }).on('xhr.dt', function (e, settings, json, xhr) {
        if (!calendar.fullCalendar('isFetchNeeded')) {
            calendar.fullCalendar('refetchEvents');
        }
    }).data('opendataDataTable')
        .attachFilterInput(stateSelect)
        .loadDataTable();

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
