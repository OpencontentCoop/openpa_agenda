<div class="panel-body" style="background: #fff">
    <section class="section pt-0 pb-4">

    </section>
    <div class="row">
        <div class="col-md-3">
            <h6 class="px-2">{'Status'|i18n('agenda/dashboard')}</h6>
            <ul class="nav nav-pills state-filters">
                {foreach fetch(editorialstuff, post_states, hash('factory_identifier', 'commenti')) as $state}
                    <li role="presentation" class="nav-item w-100">
                        <a class="text-decoration-none nav-link px-2 state-filter"
                           data-state_id="{$state.id|wash()}"
                           data-state_identifier="{$state.identifier|wash()}"
                           data-state_name="{$state.current_translation.name|wash()}"
                           href="#">
                            <div class="d-inline-block mr-1 rounded label-{$state.identifier|wash()}"
                                 style="width: 18px;height: 18px"></div>
                            <small>{$state.current_translation.name|wash()}</small>
                        </a>
                    </li>
                {/foreach}
            </ul>
        </div>
        <div class="col-md-9">
            <section id="comment-list" class="section pt-0 pl-0"></section>
        </div>
    </div>
</div>
{include uri='design:parts/tpl-spinner.tpl'}
{include uri='design:parts/tpl-comment-list.tpl'}
<script>
    var CommentQuery = "classes [comment] subtree [{$post.node.node_id}] sort [published=>desc,name=>desc]";
    {literal}
    $(document).ready(function () {
        $.views.helpers($.opendataTools.helpers);
        var currentPage = 0;
        var queryPerPage = [];
        var limitPagination = 25;
        var stateToggles = $('a.state-filter');

        stateToggles.on('click', function (e) {
            var current = $(this);
            if (current.hasClass('active')) {
                current.removeClass('active');
            } else {
                stateToggles.removeClass('active');
                current.addClass('active');
            }
            renderComments();
            e.preventDefault();
        });

        var buildQuery =  function () {
            var query = CommentQuery;
            if (stateToggles.length > 0){
                var states = [];
                stateToggles.each(function () {
                    if ($(this).hasClass('active')){
                        states.push($(this).data('state_id'));
                    }
                });
                if (states.length > 0){
                    query += ' and state in [' + states.join(',') + ']';
                }
            }
            return query;
        };

        var states = [];
        $('.state-filters a').each(function () {
           states.push($(this).data());
        });

        var renderComments = function () {
            var resultsContainer = $('#comment-list');
            var commentListTemplate = $.templates('#tpl-comment-list');
            var spinnerTpl = $($.templates('#tpl-spinner').render({}));
            var baseQuery = buildQuery();
            var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage * limitPagination;
            resultsContainer.html(spinnerTpl);

            $.opendataTools.find(paginatedQuery, function (response) {
                queryPerPage[currentPage] = paginatedQuery;
                response.currentPage = currentPage;
                response.prevPage = currentPage - 1;
                response.nextPage = currentPage + 1;
                var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount / limitPagination) : 0;
                var pages = [];
                var i;
                for (i = 0; i < pagination; i++) {
                    queryPerPage[i] = baseQuery + ' and limit ' + limitPagination + ' offset ' + (limitPagination * i);
                    pages.push({'query': i, 'page': (i + 1)});
                }
                response.pages = pages;
                response.pageCount = pagination;

                response.prevPageQuery = jQuery.type(queryPerPage[response.prevPage]) === 'undefined' ? null : queryPerPage[response.prevPage];

                $.each(response.searchHits, function () {
                    var self = this;
                    this.baseUrl =  $.opendataTools.settings('accessPath');
                    var moderationStateIdentifier = false;
                    $.each(this.metadata.stateIdentifiers, function () {
                        var parts = this.split('.');
                        if (parts[0] === 'moderation') {
                            moderationStateIdentifier = parts[1];
                        }
                    });
                    this.moderationStateIdentifier = moderationStateIdentifier;
                    this.states = states;
                });
                var renderData = $(commentListTemplate.render(response));
                resultsContainer.html(renderData);
                resultsContainer.find(".moderation-change").on('click', function (e) {
                    var state = $(this).data('moderation');
                    var comment = $(this).data('comment');
                    var url = '/editorialstuff/state_assign/commenti/moderation.'+state+'/'+comment+'/?Ajax=1';
                    $.get($.opendataTools.settings('accessPath')+url,function(response){
                        renderComments();
                    });
                    e.preventDefault();
                });

                resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                    currentPage = $(this).data('page');
                    if (currentPage >= 0){
                        renderComments();
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
        };
        renderComments();
    });
    {/literal}
</script>
