<div class="section section-muted section-inset-shadow">
    <div class="section-content">
        <div class="container">
            <div class="row">
                <div class="col">
                    <h3 class="text-center primary-color">{'Comments'|i18n('agenda')}</h3>
                </div>
            </div>
            <div class="mt-2" id="comments"></div>
            <div class="row mt-lg-4">
                <div class="col col-md-6 offset-md-3">
                    {if current_social_user().has_deny_comment_mode|not()}
                        <div id="comment-form" class="text-center"></div>
                    {elseif $node.object.can_create|not()}
                        <p><em>{'In order to leave comments, you need to be logged in'|i18n('agenda')}</em></p>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>

<div id="form-modal" class="modal fade">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body p-5">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                </div>
                <div id="comment-edit-form" class="clearfix"></div>
            </div>
        </div>
    </div>
</div>
{include uri='design:parts/tpl-spinner.tpl'}
{literal}
<style>#form-modal .alpaca-container-label{display:none}</style>
<script id="tpl-comments" type="text/x-jsrender">
	<div class="it-timeline-wrapper">
      <div class="row">
        {{for searchHits}}
            <div class="col-12">
              <div class="timeline-element">
                <div class="it-pin-wrapper it-evidence">
                  <div class="pin-icon">
                    {/literal}{display_icon('it-comment', 'svg', 'icon')}{literal}
                  </div>
                  <div class="pin-text text-sans-serif"><span>{{:~formatDate(metadata.published, 'D/MM/YYYY HH:mm')}}</span></div>
                </div>
                <div class="card-wrapper">
                  <div class="card">
                    <div class="card-body">
                      {{if metadata.published !== metadata.modified}}
                        <p class="card-text text-sans-serif mb-0">
                            <i class="fa fa-pencil"></i> <em>{{:~formatDate(metadata.modified, 'D/MM/YYYY HH:mm')}}</em>
                        </p>
                      {{/if}}
                      <p class="card-text text-sans-serif">
                        {{:~i18n(data, 'message')}}
                      </p>
                      {{if metadata.ownerId == currentUser }}
                        <ul class="list-inline">
                            <li class="list-inline-item"><a class="comment-edit" href="#" data-object="{{:metadata.id}}"><i class="fa fa-edit"></i></a></li>
                            <li class="list-inline-item"><a class="comment-remove" href="#" data-object="{{:metadata.id}}"><i class="fa fa-trash"></i></a></li>
                        </ul>
                      {{/if}}
                    </div>
                    <div class="card-signature" style="font-style:italic;position: absolute;bottom: 24px;right: 24px;"><small>{{:~i18n(metadata.ownerName)}}</small></div>
                  </div>
                </div>
              </div>
            </div>
        {{/for}}
      </div>
    </div>

	{{if pageCount > 1}}
	<div class="row mt-4 pt-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Esempio di navigazione della pagina">
	            <ul class="pagination">

	                <li class="page-item {{if !prevPageQuery}}disabled{{/if}}">
	                    <a class="page-link prevPage" {{if prevPageQuery}}data-page="{{>prevPage}}"{{/if}} href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="sr-only">Pagina precedente</span>
	                    </a>
	                </li>

	                {{for pages ~current=currentPage}}
						<li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
					{{/for}}

	                <li class="page-item {{if !nextPageQuery}}disabled{{/if}}">
	                    <a class="page-link nextPage" {{if nextPageQuery}}data-page="{{>nextPage}}"{{/if}} href="#">
	                        <span class="sr-only">Pagina successiva</span>
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
	                        </svg>
	                    </a>
	                </li>

	            </ul>
	        </nav>
	    </div>
	</div>
	{{/if}}
</script>
{/literal}
{ezscript_require(array(
    'handlebars.min.js',
    'alpaca.js',
    'jquery.opendataform.js',
    'openpa_agenda_helpers.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'alpaca.min.css',
    'alpaca-custom.css'
))}
{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

<script>
$.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
$.opendataTools.settings('language', "{$current_language}");
$.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
var currentUser = {fetch('user','current_user').contentobject_id};
{literal}
$(document).ready(function(){
    $.views.helpers($.opendataTools.helpers);
    var resultsContainer = $('#comments');
    var spinner = $.templates('#tpl-spinner');
    var template = $.templates('#tpl-comments');
    var queryPerPage = [];
    var currentPage = 0;
    var limitPagination = 50;
    var loadComments = function(){
        var baseQuery = 'classes [comment] subtree [{/literal}{$node.node_id}{literal}] sort [published=>asc]';
        var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage*limitPagination;
        resultsContainer.html(spinner);
        $.opendataTools.find(paginatedQuery, function (response) {
            queryPerPage[currentPage] = paginatedQuery;
            response.currentPage = currentPage;
            response.prevPage = currentPage - 1;
            response.nextPage = currentPage + 1;
            var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount/limitPagination) : 0;
            var pages = [];
            var i;
            for (i = 0; i < pagination; i++) {
                queryPerPage[i] = baseQuery + ' and limit ' + limitPagination + ' offset ' + (limitPagination*i);
                pages.push({'query': i, 'page': (i+1)});
            }
            response.pages = pages;
            response.pageCount = pagination;

            response.prevPageQuery = jQuery.type(queryPerPage[response.prevPage]) === "undefined" ? null : queryPerPage[response.prevPage];

            $.each(response.searchHits, function(){
                this.baseUrl = $.opendataTools.settings('accessPath');
                this.currentUser = currentUser;
            });
            var renderData = $(template.render(response));
            resultsContainer.html(renderData);

            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                currentPage = $(this).data('page');
                if (currentPage >= 0) loadComments();
                e.preventDefault();
            });
            resultsContainer.find('.comment-edit').on('click', function (e) {
                $('#comment-edit-form').opendataFormEdit(
                    {object: $(this).data('object')}, {
                    onBeforeCreate: function(){
                        $('#form-modal').modal('show')
                    },
                    onSuccess: function(data){
                        $('#form-modal').modal('hide');
                        loadComments();
                    }
                });
                e.preventDefault();
            });
            resultsContainer.find('.comment-remove').on('click', function (e) {
                $('#comment-edit-form').opendataFormDelete({object: $(this).data('object')},{
                    onBeforeCreate: function(){
                        $('#form-modal').modal('show')
                    },
                    onSuccess: function(data){
                        $('#form-modal').modal('hide');
                        loadComments();
                    }
                });
                e.preventDefault();
            });
            var more = $('<li class="page-item"><span class="page-link">...</span></li');
            var displayPages = resultsContainer.find('.page[data-page_number]');

            var currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
            var length = 7;
            if (displayPages.length > (length+2)){
                if (currentPageNumber <= (length-1)){
                    resultsContainer.find('.page[data-page_number="'+length+'"]').parent().after(more.clone());
                    for (i = length; i < pagination; i++) {
                        resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
                    }
                }else if (currentPageNumber >= length ){
                    resultsContainer.find('.page[data-page_number="1"]').parent().after(more.clone());
                    var itemToRemove = (currentPageNumber+1-length);
                    for (i = 2; i < pagination; i++) {
                        if (itemToRemove > 0){
                            resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
                            itemToRemove--;
                        }
                    }
                    if (currentPageNumber < (pagination-1)){
                        resultsContainer.find('.page[data-current]').parent().after(more.clone());
                    }
                    for (i = (currentPageNumber+1); i < pagination; i++) {
                        resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
                    }
                }
            }
        });
    };
    loadComments();

    $('#comment-form').opendataFormCreate(
        {'class': 'comment', 'parent': {/literal}{$node.node_id}{literal}}, {
        alpaca:{
            'options': {
                'focus': false
            }
        },
        onSuccess: function (data, alpaca) {
            alpaca.form[0].reset();
            loadComments();
        }
    });
});
{/literal}</script>
