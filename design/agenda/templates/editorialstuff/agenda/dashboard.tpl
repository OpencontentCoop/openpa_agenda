{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
<script>
  var CurrentUserIsModerator = {cond(current_user_is_agenda_moderator(), true, false)};
  var CurrentUserId = {fetch(user, current_user).contentobject_id};
  var AgendaEventClassIdentifier = "{agenda_event_class_identifier()}";
  var AgendaSubTree = "{calendar_node_id()}";
  {def $luogo_is_enabled = false()}
  {foreach api_class(agenda_event_class_identifier()).fields as $field}
    {if $field.identifier|eq('luogo')}{set $luogo_is_enabled = $field.name[$current_language]}{break}{/if}
  {/foreach}
  var LuogoFieldIsEnabled = {cond($luogo_is_enabled, concat('"', $luogo_is_enabled, '"'), 'false')};
</script>

{ezcss_require( array(
    'plugins/chosen.css',
    'dataTables.bootstrap.css',
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css',
    'fullcalendar.min.css',
    'plugins/owl-carousel/owl.carousel.css',
    'plugins/owl-carousel/owl.theme.css',
    "plugins/blueimp/blueimp-gallery.css"
))}
{ezscript_require(array(
    'ezjsc::jquery',
    'jsrender.js',
    'plugins/chosen.jquery.js',
    'plugins/owl-carousel/owl.carousel.min.js',
    "plugins/blueimp/jquery.blueimp-gallery.min.js",
    'moment.min.js',
    'jquery.dataTables.js',
    'dataTables.bootstrap.js',
    'jquery.opendataDataTable.js',
    'jquery.opendataTools.js',
    'openpa_agenda_helpers.js',
    'jquery.opendataSearchView.js',
    'fullcalendar/fullcalendar.min.js',
    'fullcalendar/locale/it.js',
    'fullcalendar/locale/de.js',
    'openpa_agenda_fullcalendar.js',
    'openpa_agenda_dashboard.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'jsrender.js'
))}

<div class="row">
  <div class="col-md-12">
      <section class="hgroup">
        <h1>{'Manage events'|i18n('agenda/dashboard')}</h1>
      </section>

        {if $factory_configuration.CreationRepositoryNode}
          <p><a href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}" class="btn btn-lg btn-success">{$factory_configuration.CreationButtonText|wash()|i18n('agenda/dashboard')}</a></p>
        {/if}

        <div class="clearfix row">
            <div class="col-sm-{if $luogo_is_enabled}6{else}8{/if}">
                <ul class="nav nav-pills space">
                    <li class="active"><a data-toggle="tab" href="#table"><i class="fa fa-list" aria-hidden="true"></i> {'List'|i18n('agenda/dashboard')}</a></li>
                    <li><a data-toggle="tab" href="#calendar"><i class="fa fa-calendar" aria-hidden="true"></i> {'Calendar'|i18n('agenda/dashboard')}</a></li>
                </ul>
            </div>
            <div class="col-sm-{if $luogo_is_enabled}6{else}4{/if}">
                <div class="space dashboard-filters">
                    <form class="form">
                        <div class="form-group">
                            <label for="state">{'Status'|i18n('agenda/dashboard')}</label>
                            <select id="state" data-field="state" data-placeholder="{'Select'|i18n('agenda/dashboard')}" name="state" class="form-control">
                                <option value=""></option>
                                {foreach $states as $state}
                                    <option value="{$state.id|wash()}" data-state_identifier="{$state.identifier|wash()}" class="label-{$state.identifier|wash()}">{$state.current_translation.name|wash()}</option>
                                {/foreach}
                            </select>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="tab-content">
            <div id="table" class="tab-pane active"><div class="content-data"></div></div>
            <div id="calendar" class="tab-pane"></div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
      <section class="hgroup">
        <div class="form-inline pull-right" id="search-iniziativa">
          <div class="form-group">
            <label for="searchIniziativaByName" class="hide">{'Search by name ...'|i18n('agenda')}</label>
            <input type="text" class="form-control" id="searchIniziativaByName" placeholder="{'Cerca'|i18n('agenda')}">
          </div>
          <button type="submit" class="btn btn-default"><i class="fa fa-search"></i> </button>
          <button type="reset" class="btn btn-default" style="display: none;"><i class="fa fa-times"></i> </button>
        </div>
        <h1>{'Manage initiatives'|i18n('agenda/dashboard')}</h1>
      </section>
    </div>
    <div class="col-md-12">
        <table class="table table-striped table-bordered">
            <thead>
            <tr>
                <th>{'Title'|i18n('agenda/dashboard')}</th>
                <th>{'Author'|i18n('agenda/dashboard')}</th>
                <th>{'Published'|i18n('agenda/dashboard')}</th>
                <th>{'Changed'|i18n('agenda/dashboard')}</th>
                <th>{'Translations'|i18n('agenda/dashboard')}</th>
                <th></th>
            </tr>
            </thead>
            <tbody id="dashboard-iniziative"></tbody>
        </table>
    </div>
</div>

<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
        </div>
    </div>
</div>

<script id="tpl-list-empty" type="text/x-jsrender">
<tr><td colspan="6"><a href="#">
    <i class="fa fa-times"></i> {'No result found'|i18n('agenda')}
</a></td></tr>
</script>

<script id="tpl-list-load-other" type="text/x-jsrender">
<tr><td colspan="6"><a href="#" class="btn btn-primary btn-xs">{'Show less recent'|i18n('agenda')}</a></td></tr>
</script>

{include uri='design:agenda/parts/calendar/tpl-event.tpl'}

{literal}
<script id="tpl-list-iniziativa" type="text/x-jsrender">
<tr data-contentobject_id="{{:metadata.id}}" data-node_id="{{:metadata.mainNodeId}}">
    <td>
        <a href="{{:~agendaUrl(metadata.mainNodeId)}}"><strong class="list-group-item-heading">{{:~i18n(metadata.name)}}</strong></a>
        {{if ~i18n(data,'abstract')}}
        <small>{{:~i18n(data,'abstract')}}</small>
        {{/if}}
    </td>
    <td style="white-space: nowrap;width:100px;">{{:~i18n(metadata.ownerName)}}</td>
    <td style="white-space: nowrap;width:100px;">{{:~formatDate(metadata.published,'D MMMM YYYY')}}</td>
    <td style="white-space: nowrap;width:100px;">{{:~formatDate(metadata.modified,'D MMMM YYYY')}}</td>
    <td style="white-space: nowrap;width:100px;">{{:~editLink(metadata)}}</td>
    <td style="white-space: nowrap;width:20px;">{{:~removeLink(metadata, 'editorialstuff/dashboard/agenda')}}</td>
</tr>
</script>

</script>
{/literal}
<script type="text/javascript" language="javascript" class="init">
    moment.locale('{$moment_language}');
    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('locale', "{$moment_language}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('endpoint',{ldelim}
        'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}',
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}',
        'fullcalendar': '{'/agenda/calendar/'|ezurl(no,full)}',
    {rdelim});

    var Translations = {ldelim}
        'Title':'{'Title'|i18n('agenda/dashboard')}',
        'Published':'{'Published'|i18n('agenda/dashboard')}',
        'Start date': '{'Start date'|i18n('agenda/dashboard')}',
        'End date': '{'End date'|i18n('agenda/dashboard')}',
        'Status': '{'Status'|i18n('agenda/dashboard')}',
        'Translations': '{'Translations'|i18n('agenda/dashboard')}',
        'Author': '{'Author'|i18n('agenda/dashboard')}',
        'Detail': '{'Detail'|i18n('agenda/dashboard')}',
        'Loading...': '{'Loading...'|i18n('agenda/dashboard')}'
    {rdelim};

{literal}
    var searchIniziativaSelector = '#dashboard-iniziative';
    var renderIniziativa = function(content){
        var template = $.templates("#tpl-list-iniziativa");
        $.views.helpers(OpenpaAgendaHelpers);
        return template.render(content);
    };
    var searchForm = $('#search-iniziativa');

    var iniziativeQuery = 'null';
    if (CurrentUserIsModerator) {
      iniziativeQuery = 'classes [iniziativa] sort [modified=>desc] limit 5';
    }else{
      iniziativeQuery = 'classes [iniziativa] and owner_id = '+CurrentUserId+' sort [modified=>desc] limit 5';
    }

    var searchViewIniziativa = $(searchIniziativaSelector).opendataSearchView({
        query: iniziativeQuery,
        onBeforeSearch: function(){
            $('#searchIniziativaSpinner').show();
        },
        onAfterSearch: function(){
            $('#searchIniziativaSpinner').hide();
        },
        onLoadResults: function (response, query, appendResults, view) {
            if (response.totalCount > 0) {
                if(appendResults) {
                    view.container.append(renderIniziativa(response.searchHits));
                }else {
                    view.container.html(renderIniziativa(response.searchHits));
                }

                view.container.find('.list-group-item').on('click', function(e){
                    selectIniziativa($(e.currentTarget).data('contentobject_id'));
                    e.preventDefault();
                });

                if (response.nextPageQuery) {
                    var loadMore = $($.templates("#tpl-list-load-other").render({}));
                    loadMore.bind('click', function (e) {
                        view.appendSearch(response.nextPageQuery);
                        loadMore.remove();
                        e.preventDefault();
                    });
                    view.container.append(loadMore)
                }
            } else {
                view.container.html($.templates("#tpl-list-empty").render({}));
            }
        },
        onLoadErrors: function (errorCode, errorMessage, jqXHR, view) {
            view.container.html('<div class="alert alert-danger">' + errorMessage + '</div>')
        }
    }).data('opendataSearchView');
    searchViewIniziativa.addFilter({
        name: 'search-by-name',
        current: '',
        init: function (view, filter) {
            searchForm.find('button[type="submit"]').on('click', function (e) {
                var currentValue = searchForm.find('#searchIniziativaByName').val();
                searchForm.find('button[type="reset"]').show();
                filter.setCurrent(currentValue);
                view.doSearch();
                e.preventDefault();
            });
            searchForm.find('button[type="reset"]').on('click', function (e) {
                searchForm.find('button[type="reset"]').hide();
                searchForm.find('#searchIniziativaByName').val('');
                filter.setCurrent('');
                view.doSearch();
                e.preventDefault();
            });
        },
        setCurrent: function (value) {
            this.current = value;
        },

        getCurrent: function () {
            return this.current;
        },
        buildQuery: function () {
            var currentValue = this.getCurrent();
            if (currentValue.length > 0) {
                return "raw[meta_name_t] in ['"+currentValue+"*', '*"+currentValue+"', '"+currentValue+"']";
            }
        }
    }).init().doSearch();

</script>

<style>
    .chosen-search input, .chosen-container-multi input{height: auto !important}
    .label-draft {  background-color: #ccc;  }
    .label-skipped {  background-color: #999;  }
    .label-waiting {  background-color: #f0ad4e;  }
    .label-accepted {  background-color: #5cb85c;  }
    .label-refused {  background-color: #d9534f;  }
    .dashboard-filters .form-group {{/literal}{if $luogo_is_enabled}width: 49%;float: left;margin-left: 1%{else}width: 100%{/if}{literal}};
</style>
{/literal}
