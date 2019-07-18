{let class_content=$attribute.class_content
     class_list=fetch( class, list, hash( class_filter, $class_content.class_constraint_list ) )
     can_create=true()
     new_object_initial_node_placement=false()
     browse_object_start_node=false()}

{default html_class='full' placeholder=false() attribute_base=ContentObjectAttribute}



{if $placeholder}
    <label>{$placeholder}</label>
{/if}

    {def $current = false()}
    {foreach $attribute.content.relation_list as $item}
        {set $current = $item.contentobject_id}
        {break}
    {/foreach}

    <label>Aggiungi iniziativa</label>
    <div class="form-inline" id="add-new-iniziativa">
        <div class="form-group">
            <label for="new-iniziativa-titolo" class="hide">Titolo</label>
            <input type="text" class="form-control" name="new-iniziativa-titolo" id="new-iniziativa-titolo" placeholder="Titolo">
        </div>
        <div class="form-group">
            <label for="new-iniziativa-abstract" class="hide">Breve descrizione</label>
            <input type="text" class="form-control" name="new-iniziativa-abstract" id="new-iniziativa-abstract" placeholder="Breve descrizione">
        </div>
        <button class="btn btn-info" type="button"><i class="fa fa-plus"></i> </button>
    </div>

    <hr />

    <label>Seleziona iniziativa <i id="searchIniziativaSpinner" class="fa fa-circle-o-notch fa-spin" style="display: none"></i></label>
    <div class="space">
        <div class="form-inline pull-right" id="search-iniziativa">
            <div class="form-group">
                <label for="searchIniziativaByName" class="hide">{'Search by name ...'|i18n('agenda')}</label>
                <input type="text" class="form-control" id="searchIniziativaByName" placeholder="{'Cerca'|i18n('agenda')}">
            </div>
            <button type="submit" class="btn btn-default"><i class="fa fa-search"></i> </button>
            <button type="reset" class="btn btn-default" style="display: none;"><i class="fa fa-times"></i> </button>
        </div>
        <span class="label label-default label-success searchIniziativaByUser" data-user_id="{fetch(user, current_user).contentobject_id}">Create da {fetch(user, current_user).contentobject.name|wash()}</span>
        <span class="label label-default searchIniziativaByUser">Tutte</span>
    </div>
    <hr />
    <div class="row">
        <div class="col-md-12">
            <div class="list-group" id="current-{$attribute.id}"></div>
        </div>
    </div>    
    <div class="row">
        <div class="col-md-12">
            <div class="list-group" id="relations-{$attribute.id}"></div>
        </div>
    </div>

    <input type="hidden" name="{$attribute_base}_data_object_relation_list_{$attribute.id}[]" value="{$current}" id="select-iniziativa"/>
    <input type="hidden" name="single_select_{$attribute.id}" value="1" />
    <input type="hidden" name="{$attribute_base}_priority[{$attribute.id}][]" value="0" />


{/default}
{/let}

{ezscript_require(array(
    'ezjsc::jquery',
    'moment.min.js',
    'jquery.opendataTools.js',
    'jquery.opendataSearchView.js',
    'jsrender.js'
))}


<script id="tpl-list-empty" type="text/x-jsrender">
<a href="#" class="list-group-item">
    <i class="fa fa-times"></i> {'No result found'|i18n('agenda')}
</a>
</script>

<script id="tpl-list-load-other" type="text/x-jsrender">
<a href="#" class="list-group-item btn btn-primary btn-xs">{'Show less recent'|i18n('agenda')}</a>
</script>

{literal}
<script id="tpl-list-iniziativa" type="text/x-jsrender">
<a href="#" class="list-group-item" data-contentobject_id="{{:metadata.id}}" data-node_id="{{:metadata.mainNodeId}}">
    <strong class="list-group-item-heading">{{:~i18n(metadata.name)}}</strong>
    {{if ~i18n(data,'abstract')}}
    <br /><small>{{:~i18n(data,'abstract')}}</small>
    {{/if}}
</a>
</script>
{/literal}

<script type="application/javascript">

    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{ezini('RegionalSettings','Locale')}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('endpoint',{ldelim}
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
    {rdelim});

    var searchIniziativaSelector = '#relations-{$attribute.id}';
    var currentIniziativaSelector = '#current-{$attribute.id}';
    var addNewIniziativaSelector = '#add-new-iniziativa';
    var addNewIniziativaEndPoint = "{'agenda/add/iniziativa'|ezurl(no)}";
    var selectIniziativaSelector = "#select-iniziativa";

    {literal}

    var currentIniziativa = $(selectIniziativaSelector).val();
    
    var selectIniziativa = function(id){
        $(selectIniziativaSelector).val(id);        
        currentIniziativa = id;
        refreshCurrentIniziativa();
    };

    var renderIniziativa = function(content){
        var template = $.templates("#tpl-list-iniziativa");
        $.views.helpers($.opendataTools.helpers);
        return template.render(content);
    };

    var clearCurrentIniziativa = function(){
        currentIniziativa = null;
        $(selectIniziativaSelector).val(0);
        $(currentIniziativaSelector).html('');
    }
    
    var refreshCurrentIniziativa = function(){        
        if (currentIniziativa){
            $('#searchIniziativaSpinner').show();
            $.opendataTools.findOne('id in ['+currentIniziativa+']', function(response){
                var clearButton = $('<a class="pull-right btn btn-info" href="#" style="display:block;position:relative;z-index:10;margin:20px"><i class="fa fa-close"></i></a>');                
                clearButton.on('click', function(e){
                    clearCurrentIniziativa();
                    e.preventDefault();
                });
                var renderedInizitiva = $(currentIniziativaSelector).html(renderIniziativa(response));
                renderedInizitiva.find('a').addClass('active').css('cursor', 'none');                
                $(currentIniziativaSelector).prepend(clearButton);
                $('#searchIniziativaSpinner').hide();
            });
        }
    };
    
    var searchForm = $('#search-iniziativa');
    var searchViewIniziativa = $(searchIniziativaSelector).opendataSearchView({
        query: 'classes [iniziativa] sort [published=>desc] limit 5',        
        onBuildQuery: function(){
            if (currentIniziativa){
                return "id != '"+currentIniziativa+"'";
            }
        },
        onInit: function(){
          refreshCurrentIniziativa();
        },
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
    }).addFilter({
        name: 'search-by-owner',
        current: null,
        init: function (view, filter) {
            var user = $('.searchIniziativaByUser.label-success').data('user_id');
            filter.setCurrent(user);
            $('.searchIniziativaByUser').css('cursor', 'pointer').on('click', function(e){
                $('.searchIniziativaByUser').toggleClass('label-success');
                var user = $(e.currentTarget).data('user_id');
                filter.setCurrent(user);
                view.doSearch();
            })
        },
        setCurrent: function (value) {
            this.current = value;
        },

        getCurrent: function () {
            return this.current;
        },
        buildQuery: function () {
            var currentValue = this.getCurrent();
            if (currentValue) {
                return "owner_id = "+currentValue;
            }
        }
    }).init().doSearch();

    $(addNewIniziativaSelector).find('button').on('click', function(e){
        var name = $('input[name="new-iniziativa-titolo"]').val();
        var abstract = $('input[name="new-iniziativa-abstract"]').val();
        if (name != '' && abstract != '') {
            $(addNewIniziativaSelector).find('button>i').addClass('fa-circle-o-notch fa-spin');
            $.post(addNewIniziativaEndPoint, {titolo: name, abstract: abstract}, function(data){
                $(addNewIniziativaSelector).find('button>i').removeClass('fa-circle-o-notch fa-spin');
                searchViewIniziativa.container.prepend(renderIniziativa(data.content));
                selectIniziativa(data.content.metadata.id);
                $(addNewIniziativaSelector).find('input').val('');
            }).fail(function(jqXHR, textStatus, errorThrown) {
                var response = JSON.parse(jqXHR.responseText);
                if (response.error){
                    searchViewIniziativa.loadErrors(0, response.error, jqXHR);
                }
            });
        }
        e.preventDefault();
    });

</script>
{/literal}
