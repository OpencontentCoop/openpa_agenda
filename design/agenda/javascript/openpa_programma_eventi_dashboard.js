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

    var mainQuery = 'classes [programma_eventi]';
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
                {"data": "data", "name": 'title', "title": Translations['Titolo']},
                {
                    "data": "metadata",
                    "name": 'raw[meta_owner_name_t]',
                    "title": 'Autore'
                },
                {"data": "metadata.published", "name": 'published', "title": Translations['Pubblicato']},
                {"data": "data", "name": 'from_time', "title": Translations['Inizio']},
                {"data": "data", "name": 'to_time', "title": Translations['Fine']},
                {"data": "metadata.stateIdentifiers", "name": 'state', "title": Translations['Stato'], "sortable": false},
                {"data": "metadata.id", "name": 'id', "title": Translations['Traduzioni'], "sortable": false},
                {"data": "metadata.id", "name": 'id', "title": '', "sortable": false}
            ],
            "columnDefs": [
                {
                    "render": function (data, type, row) {
                        return '<a class="btn btn-info" href="' + tools.settings('accessPath') + '/editorialstuff/edit/programma_eventi/' + row.metadata.id + '">'+Translations['Dettaglio']+'</a>';
                    },
                    "targets": [0]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        var title = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].title : contentData[Object.keys(contentData)[0]].title;
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
                        return moment(new Date(date)).format('DD/MM/YYYY');
                    },
                    "targets": [4]
                },
                {
                    "render": function (data, type, row) {
                        var contentData = row.data;
                        var date = typeof contentData[tools.settings('language')] != 'undefined' ? contentData[tools.settings('language')].to_time : contentData[Object.keys(contentData)[0]].to_time;
                        return moment(new Date(date)).format('DD/MM/YYYY');
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
    }).data('opendataDataTable')
    .attachFilterInput(stateSelect)
    .loadDataTable();

    $(document).on('click','[data-load-remote]',function(e) {
        e.preventDefault();
        var $this = $(this);
        $($this.data('remote-target')).html('<em>Loading...</em>');
        var remote = $this.data('load-remote');
        if(remote) {
            $($this.data('remote-target')).load(remote);
        }
    });

});
