{def $select_name='SelectedObjectIDArray'
     $select_type='checkbox'
     $select_attribute='contentobject_id'}

{if eq( $browse.return_type, 'NodeID' )}
    {set $select_name='SelectedNodeIDArray'}
    {set $select_attribute='node_id'}
{/if}

{if eq( $browse.selection, 'single' )}
    {set $select_type='radio'}
{/if}

<div class="container">
    <section class="hgroup">
        <h1>Libreria immagini</h1>
    </section>

    <div class="row">
        <div class="well clearfix">
            <form name="browse" action="{$browse.from_page|ezurl(no)}" method="post">
                <div class="selection"></div>
                {*<input type="checkbox" name="SelectedNodeIDArray[]" value="" />*}

                {if $browse.persistent_data|count()}
                    {foreach $browse.persistent_data as $key => $data_item}
                        <input type="hidden" name="{$key|wash}" value="{$data_item|wash}" />
                    {/foreach}
                {/if}


                <input type="hidden" name="BrowseActionName" value="{$browse.action_name}" />
                {if $browse.browse_custom_action}
                    <input type="hidden" name="{$browse.browse_custom_action.name}" value="{$browse.browse_custom_action.value}" />
                {/if}

                <div class="clearfix col-xs-12">

                    <button class="pull-right btn btn-primary" type="submit" name="SelectButton">{'Select'|i18n('design/ocbootstrap/content/browse')}</button>
                    {if $cancel_action}
                        <input type="hidden" name="BrowseCancelURI" value="{$cancel_action|wash}" />
                    {/if}
                    <button class="pull-right btn btn-large btn-default" type="submit" name="BrowseCancelButton">{'Cancel'|i18n( 'design/ocbootstrap/content/browse' )}</button>

                </div>


            </form>
        </div>

    </div>


    <form class="form-inline pull-right" id="search-images">
        <div class="form-group">
            <label for="searchImagesByName" class="hide">{'Cerca per nome...'|i18n('agenda')}</label>
            <input type="text" class="form-control" id="searchImagesByName" placeholder="{'Cerca'|i18n('agenda')}">
        </div>
        <button type="submit" class="btn btn-default"><i class="fa fa-search"></i> </button>
        <button type="reset" class="btn btn-default" style="display: none;"><i class="fa fa-times"></i> </button>
    </form>
    <hr />
    <div class="row" id="browse-images"></div>

</div>

<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="overflow: hidden;">
            <div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>
            <div class="modal-body"></div>
        </div>
    </div>
</div>

{ezscript_require(array(
    'ezjsc::jquery',
    'ezjsc::jqueryio',
    'moment.min.js',
    'jquery.opendataTools.js',
    'jquery.opendataSearchView.js',
    'jsrender.js'
))}

<script id="tpl-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
</div>
</script>

<script id="tpl-image-empty" type="text/x-jsrender">
<div class="col-xs-12">
<a href="#">
    <i class="fa fa-times"></i> {'Nessun contenuto trovato'|i18n('agenda')}
</a>
</div>
</script>

<script id="tpl-image-load-other" type="text/x-jsrender">
<div class="col-xs-12 text-center ">
<a href="#" class="btn btn-primary btn-xs">{'Mostra altri elementi'|i18n('agenda')}</a>
</div>
</script>

{literal}
<script id="tpl-image-item" type="text/x-jsrender">
<div class="col-xs-6 col-md-3 selection"
     id="image-{{:metadata.id}}"
     data-contentobject_id="{{:metadata.id}}"
     data-node_id="{{:metadata.mainNodeId}}"
     data-name="{{:~i18n(metadata.name)}}">
    <a class="add-to-selection btn btn-success pull-right" style="margin:3px"><i class="fa fa-plus"></i></a>
    <div class="thumbnail" data-refresh="{{:metadata.id}}">
        <a href="#"
           style="background-image:url({{:~mainImageUrl(data)}});background-position:center center;background-size:contain;background-repeat: no-repeat;display: block;width: 100%;max-width: 100%;min-height:100px"></a>
        <div class="caption" style="height:100px;overflow:hidden">
            <small>
                {{:~i18n(data, 'image').mime_type}}
                {{:~i18n(data, 'image').width}}x{{:~i18n(data, 'image').height}}
                {{if ~i18n(data,'license')}}
                      {{for ~i18n(data,'license')}}
                          <em>{{>~i18n(name)}}</em>
                      {{/for}}
                  {{/if}}
            </small><br />
            <strong>{{:~i18n(metadata.name)}}</strong>
            <a href="#" class="load-preview" data-contentobject_id="{{:metadata.id}}"><i class="fa fa-edit"></i></a>
        </div>
    </div>
</div>
</script>
{/literal}

<script type="application/javascript">

    $.opendataTools.settings('accessPath', "{'/'|ezurl(no,full)}");
    $.opendataTools.settings('language', "{ezini('RegionalSettings','Locale')}");
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']); //@todo
    $.opendataTools.settings('endpoint',{ldelim}
        'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
        'class': '{'/opendata/api/classes/'|ezurl(no,full)}'
    {rdelim});

    var inputName = '{$select_name}';
    var inputAttribute = '{$select_attribute}';
    var inputType = '{$select_type}';

    {literal}

    var preview = $('#preview');
    var searchForm = $('#search-images');
    var spinner = $($.templates("#tpl-spinner").render({}));
    var selectionContainer = $('form[name="browse"]').find('.selection');

    var searchView = $("#browse-images").opendataSearchView({
        debug: true,
        query: 'classes [image] sort [published=>desc] limit 12',
        onBeforeSearch: function (query, view) {
            view.container.html(spinner);
        },
        onLoadResults: function (response, query, appendResults, view) {
            spinner.remove();
            if (response.totalCount > 0) {
                var template = $.templates("#tpl-image-item");
                $.views.helpers($.opendataTools.helpers);
                var htmlOutput = template.render(response.searchHits);
                if (appendResults) view.container.append(htmlOutput);
                else view.container.html(htmlOutput);

                view.container.find('.add-to-selection').on('click', function(){
                    var objId = $(this).parent().data('contentobject_id');
                    if (selectionContainer.find('[data-contentobject_id="'+objId+'"]').length == 0) {
                        var nodeId = $(this).parent().data('node_id');
                        var content = $(this).next().html();
                        var inputValue = $(this).parent().data(inputAttribute);
                        var item = $('<div class="col-xs-6 col-md-3" data-contentobject_id="' + objId + '"><a class="remove-from-selection btn btn-danger pull-right" style="margin:3px"><i class="fa fa-times"></i></a><div class="thumbnail" data-refresh="' + objId + '">' + content + '<input type="hidden" name="' + inputName + '[]" value="' + inputValue + '" /></div></div>');
                        item.find('.remove-from-selection').on('click', function (e) {
                            $(this).parent().remove();
                            e.preventDefault();
                        });
                        if (inputType == 'radio') {
                            selectionContainer.html('');
                        }
                        selectionContainer.prepend(item);
                    }
                });

                if (response.nextPageQuery) {
                    var loadMore = $($.templates("#tpl-image-load-other").render({}));
                    loadMore.bind('click', function (e) {
                        loadMore.remove();
                        view.container.append(spinner);
                        view.appendSearch(response.nextPageQuery);
                        e.preventDefault();
                    });
                    view.container.append(loadMore)
                }
            } else {
                view.container.html($.templates("#tpl-image-empty").render({}));
            }
        },
        onLoadErrors: function (errorCode, errorMessage, jqXHR, view) {
            view.container.html('<div class="alert alert-danger">' + errorMessage + '</div>')
        }
    }).data('opendataSearchView').addFilter({
        name: 'search-by-name',
        current: '',
        init: function (view) {
            self = this;
            searchForm.find('button[type="submit"]').on('click', function (e) {
                var currentValue = searchForm.find('#searchImagesByName').val();
                searchForm.find('button[type="reset"]').show();
                self.setCurrent(currentValue);
                view.doSearch();
                e.preventDefault();
            });
            searchForm.find('button[type="reset"]').on('click', function (e) {
                searchForm.find('button[type="reset"]').hide();
                searchForm.find('#searchImagesByName').val('');
                self.setCurrent('');
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
                return "(raw[meta_name_t] in ['"+currentValue+"*', '*"+currentValue+"', '"+currentValue+"'] or tags in ['"+currentValue+"*', '*"+currentValue+"', '"+currentValue+"'])";
            }
        }
    }).init().doSearch();

    var inlineEdit = function () {
        $('span.inline-form').each(function () {
            $(this).hide();
            $(this).prev().show()
        });
        var editButton = $(this);
        var attributeData = editButton.data();
        var text = editButton.parent();
        var form = text.next();
        text.hide();
        form.show().find('button').bind('click', function () {
            var value = form.find(attributeData.input).val();
            form.hide();
            text.show();
            preview.find('.modal-body').html(spinner);
            $.ez('ocb::attribute_edit', {
                objectId: attributeData.objectid,
                attributeId: attributeData.attributeid,
                version: attributeData.version,
                content: value
            }, function (result) {
                if (result.error_text.length) {
                    alert(result.error_text);
                } else {
                    $('#object-' + attributeData.objectid + ' td.object-name').html(result.content);
                }
                $.ez('ezjsctemplate::preview::' + attributeData.objectid, false, function (data) {
                    if (data.error_text.length) {
                        alert(data.error_text);
                    } else {
                        preview.find('.modal-body').html(data.content);
                    }
                });
                $.opendataTools.find("id in ["+ attributeData.objectid + "]", function(response){
                    var template = $.templates("#tpl-image-item");
                    $.views.helpers($.opendataTools.helpers);
                    var htmlOutput = template.render(response.searchHits);
                    $('[data-refresh="'+attributeData.objectid+'"]').html($(htmlOutput).find('.thumbnail').html());
                });
            });
        });
    };

    var displayImageDetail = function (e) {
        preview.find('.modal-body').html(spinner);
        preview.modal();
        var objectId = $(e.currentTarget).data('contentobject_id');
        $.ez('ezjsctemplate::preview::' + objectId, false, function (data) {
            if (data.error_text.length) {
                alert(data.error_text);
            } else {
                preview.find('.modal-body').html(data.content);
            }
        });
        e.preventDefault();
    };

    if ($.isFunction($(document).on)) {
        $(document).on('click', '.load-preview', displayImageDetail);
        $(document).on('click', '.inline-edit', inlineEdit);
    } else {
        $('.load-preview').live('click', displayImageDetail);
        $('.inline-edit').live('click', inlineEdit);
    }

    {/literal}

</script>
