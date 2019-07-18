{ezcss_require( array(
    'dataTables.bootstrap.css'
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap.js',
    'jquery.opendataDataTable.js',
    'jquery.opendataTools.js'
))}

<script type="text/javascript" language="javascript" class="init">
	var baseUri = '{'/'|ezurl(no,full)}';
    var mainQuery = 'classes [comment] subtree [{$post.node.node_id}]';
    {literal}

    $(document).ready(function () {

        var tools = $.opendataTools;

        var states = [
          {
            label: 'Non necessita di moderazione',
            identifier: 'skipped',
            cssClass: 'primary'
          },
          {
            label: 'In attesa di moderazione',
            identifier: 'waiting',
            cssClass: 'warning'
          },
          {
            label: 'Accettato',
            identifier: 'accepted',
            cssClass: 'success'
          },
          {
            label: 'Rifiutato',
            identifier: 'refused',
            cssClass: 'danger'
          }
        ]
        
        var defStatus = function(statusIdentifier){
            var state = {
                label: 'Sconosciuto',
                cssClass: 'default',
                identifier: 'sconosciuto'
            };

            switch (statusIdentifier){
                case 'skipped':
                    state.label = 'Non necessita di moderazione';
                    state.identifier = statusIdentifier;
                    break;
                case 'waiting':
                    state.label = 'In attesa di moderazione';
                    state.cssClass = 'warning';
                    state.identifier = statusIdentifier;
                    break;
                case 'accepted':
                    state.label = 'Accettato';
                    state.cssClass = 'success';
                    state.identifier = statusIdentifier;
                    break;
                case 'refused':
                    state.label = 'Rifiutato';
                    state.cssClass = 'danger';
                    state.identifier = statusIdentifier;
                    break;
            }

            return state;
        };

        var datatable;
        datatable = $('.content-data').opendataDataTable({
                    "builder":{
                        "query": mainQuery
                    },
                    "datatable":{
                        "language": {
                            "url": "//cdn.datatables.net/plug-ins/1.10.12/i18n/Italian.json"
                        },
                        "ajax": {
                            url: baseUri+"/opendata/api/datatable/search/"
                        },
                        "order": [ 0, 'desc' ],
                        "columns": [
                            {"data": "metadata.published", "name": 'published', "title": 'Data di pubblicazione'},
                            {"data": "data."+tools.settings('language')+".message", "name": 'message', "title": 'Messaggio'},
                            {"data": "metadata.id", "name": 'id', "title": 'File', "orderable": false},
                            {"data": "metadata.id", "name": 'id', "title": 'Moderazione', "orderable": false}
                        ],
                        "columnDefs": [
                            {
                                "render": function (data, type, row, meta) {                                    
                                    var validDate = moment(data, moment.ISO_8601);
                                    if (validDate.isValid()) {
                                        return '<span style="white-space:nowrap">' + validDate.format("D MMMM YYYY, hh:mm") + '</span>';
                                    } else {
                                        return data;
                                    }
                                },
                                "targets": [0]
                            },
                            {
                                "render": function (data, type, row, meta) {
                                    if (row.data[tools.settings('language')].file)
                                        return '<a href="'+row.data[tools.settings('language')].file.url+'">'+row.data[tools.settings('language')].file.filename+'</a>';
                                    return '';
                                },
                                "targets": [2]
                            },
                            {
                                "render": function (data, type, row, meta) {
                                    var stateIdentifiers = row.metadata.stateIdentifiers;
                                    var currentStateIdentifier;
                                    $.each(stateIdentifiers, function(key,value){
                                        var parts = value.split('.');
                                        if (parts[0] == 'moderation'){
                                            currentStateIdentifier = parts[1];
                                        }
                                    });
                                    return currentStateIdentifier;
                                },
                                "targets": [3],
                                "createdCell": function (td, cellData, rowData, row, col) {
                                    var stateIdentifiers = rowData.metadata.stateIdentifiers;
                                    var currentStateIdentifier;
                                    $.each(stateIdentifiers, function(key,value){
                                        var parts = value.split('.');
                                        if (parts[0] == 'moderation'){
                                            currentStateIdentifier = parts[1];
                                        }
                                    });
                                    var container = $('<div />')
                                    var state, cssClass;
                                    $.each(states, function(){
                                      cssClass = this.identifier == currentStateIdentifier ? this.cssClass : 'default';                                      
                                      state = $('<span class="moderate '+this.identifier+'" data-commentid="'+rowData.metadata.id+'" data-moderation="'+this.identifier+'">')
                                            .addClass('label label-'+cssClass )
                                            .text(this.label);
                                      container.append(state);
                                    });                                    
                                    var $td = $(td).html(container);
                                    var span = $(td).find('span.moderate').css('cursor','pointer');                                    
                                    span.bind('click', function(){                                      
                                        var newStateIdentifier = $(this).data('moderation');
                                        $.get(baseUri+'/editorialstuff/state_assign/commenti/moderation.'+newStateIdentifier+'/'+rowData.metadata.id+'/?Ajax=1',function(response){                                                                                        
                                            $.each(states, function(){
                                              cssClass = response.result == 'success' && this.identifier == newStateIdentifier ? this.cssClass : 'default';                                      
                                              $(td)
                                                .find('span.'+this.identifier)                                                
                                                .removeClass('label-'+this.cssClass)
                                                .addClass('label-'+cssClass);
                                            });
                                        });
                                    });                                            
                                }
                            }
                        ]
                    },
                    "loadDatatableCallback": function(self){
                        var input = $('.dataTables_filter input');
                        input.unbind().attr('placeholder','Premi invio per cercare');
                        input.bind('keyup', function(e) {
                            if(e.keyCode == 13) {
                                self.datatable.search(this.value).draw();
                            }
                        });
                    }
                })
                .data('opendataDataTable');


        datatable.loadDataTable();

    });

    {/literal}
</script>
{literal}
    <style>
        .chosen-search input, .chosen-container-multi input{height: auto !important}
        span.moderate{margin-left:10px;}
    </style>
{/literal}

<div style="background: #fff" class="panel-body">
    <div id="table" class="tab-pane active"><div class="content-data"></div></div>
</div>
