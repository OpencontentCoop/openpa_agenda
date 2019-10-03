{def $locales = fetch( 'content', 'translation_list' )}
{def $class_identifiers = array()}
{def $parent_node_id = false()}
{def $extra_buttons = array()}
{def $request_url = false()}
{def $is_user = false()}
{def $state_toggle = false()}
<section class="hgroup">
    <h1>{'Settings'|i18n('agenda/menu')}</h1>
</section>

<div class="row">
    <div class="col-md-12">
        <ul class="list-unstyled">
            {if $root.can_edit}
                <li>
                    <a class="btn btn-primary btn-xs" href="{concat('/content/edit/', $root.contentobject_id, '/f/', ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini'))|ezurl(no)}">
                        <i class="fa fa-pencil mr-1"></i> {'Change general settings'|i18n('agenda/config')}
                    </a>
                </li>
            {/if}
            {if is_moderation_enabled()}
                <li><strong>{'Moderation is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_registration_enabled()}
                <li><strong>{'User registration is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_auto_registration_enabled()}
                <li><strong>{'Associations registration is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_comment_enabled()}
                <li><strong>{'Comments enabled'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_login_enabled()}
                <li><strong>{'Login is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if $root|has_attribute('hide_tags')}
                <li><strong>{'Topics to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_tags')}</li>
            {/if}
            {if $root|has_attribute('hide_iniziative')}
                <li><strong>{'Event collections to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_iniziative')}</li>
            {/if}
        </ul>

        <div class="row mt-5">

            <div class="col-md-3">
                <ul class="nav nav-pills">
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $current_part|eq('users')} active{/if}"
                            href="{'agenda/config/users'|ezurl(no)}">{'Users'|i18n('agenda/config')}</a></li>
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $current_part|eq('moderators')} active{/if}"
                            href="{'agenda/config/moderators'|ezurl(no)}">{'Moderators'|i18n('agenda/config')}</a></li>
                    <li role="presentation" class="nav-item w-100"><a
                            class="text-decoration-none nav-link{if $current_part|eq('external_users')} active{/if}"
                            href="{'agenda/config/external_users'|ezurl(no)}">{'External Users'|i18n('agenda/config')}</a></li>
                    {if $data|count()|gt(0)}
                        {foreach $data as $item}
                            <li role="presentation" class="nav-item w-100"><a
                                    class="text-decoration-none nav-link{if $current_part|eq(concat('data-',$item.contentobject_id))} active{/if}"
                                    href="{concat('agenda/config/data-',$item.contentobject_id)|ezurl(no)}">{$item.name|wash()}</a></li>
                        {/foreach}
                    {/if}
                </ul>
            </div>

            <div class="col-md-9">
                <div class="tab-pane active" id="{$current_part}">
                    {if $current_part|eq('moderators')}
                        {set $parent_node_id = $moderators_parent_node_id}
                        {set $class_identifiers = array('user')}
                        {set $extra_buttons = array(
                            hash('name', 'AddModeratorLocation', 'value', 'Add Existing User'|i18n('agenda/config')),
                            hash('href', concat('exportas/csv/user/',$moderators_parent_node_id), 'value', 'Export to CSV'|i18n('agenda/config'))
                        )}
                        {set $request_url = '/agenda/config/moderators'}
                        {set $is_user = true()}

                    {elseif $current_part|eq('external_users')}
                        {set $parent_node_id = $external_users_parent_node_id}
                        {set $class_identifiers = array('user')}
                        {set $extra_buttons = array(
                            hash('name', 'AddExternalUsersLocation', 'value', 'Add Existing User'|i18n('agenda/config')),
                            hash('href', concat('exportas/csv/user/',$external_users_parent_node_id), 'value', 'Export to CSV'|i18n('agenda/config'))
                        )}
                        {set $request_url = '/agenda/config/external_users'}
                        {set $is_user = true()}

                    {elseif $current_part|eq('users')}
                        {set $parent_node_id = $user_parent_node.node_id}
                        {set $class_identifiers = array('user')}
                        {set $extra_buttons = array(hash('href', concat('exportas/csv/user/',$user_parent_node.node_id), 'value', 'Export to CSV'|i18n('agenda/config')))}
                        {set $request_url = '/agenda/config/users'}
                        {set $is_user = true()}

                    {elseif $data|count()|gt(0)}
                        {foreach $data as $item}
                            {if $current_part|eq(concat('data-',$item.contentobject_id))}
                                {set $parent_node_id = $item.node_id}
                                {if $item|has_attribute('tags')}
                                    {foreach $item|attribute('tags').content.keyword_string|explode(', ') as $class_identifier}
                                        {set $extra_buttons = $extra_buttons|append(hash('href', concat('exportas/csv/',$class_identifier,'/',$parent_node_id), 'value', 'Export to CSV'|i18n('agenda/config')))}
                                        {set $class_identifiers = $class_identifiers|append($class_identifier)}
                                        {if $class_identifier|eq('place')}
                                            {set $state_toggle = true()}
                                        {/if}
                                    {/foreach}
                                {/if}
                                {set $request_url = concat('/agenda/config/data-',$item.contentobject_id)}
                            {/if}
                        {/foreach}
                    {/if}


                    <form class="row form px-3 mb-2">
                        <div class="col-md-6">
                            <input type="text" class="form-control" data-search="q" placeholder="{'Search'|i18n('agenda')}">
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-link">
                                {display_icon('it-search', 'svg', 'icon startSearch')}
                            </button>
                            <button type="reset" class="btn btn-link hide">
                                {display_icon('it-close-big', 'svg', 'icon resetSearch')}
                            </button>
                        </div>
                        {if $state_toggle}
                        <div class="col-md-3">
                            <div class="bootstrap-select-wrapper">
                            <select data-search="visibility" title="{'Visibility'|i18n('design/admin/contentstructuremenu')}">
                                <option selected="selected">{'Visibility'|i18n('design/admin/contentstructuremenu')}: {'All'|i18n('agenda')}</option>
                                {foreach visibility_states() as $state}
                                    <option value="{$state.id}">{'Visibility'|i18n('design/admin/contentstructuremenu')}: {$state.current_translation.name|wash()}</option>
                                {/foreach}
                            </select>
                            </div>
                        </div>
                        {/if}
                    </form>
                    {if $parent_node_id}
                        <div class="px-3"
                             data-parent="{$parent_node_id}"
                             data-classes="{$class_identifiers|implode(',')}"
                             data-limit="20"
                             data-redirect="{$request_url}"
                             data-is_user="{$is_user|int()}"
                             data-state_toggle="{$state_toggle|int()}"></div>

                        {if count($class_identifiers)}
                            {def $parent_node = fetch(content, node, hash(node_id, $parent_node_id))}
                            {def $can_instantiate_class_list = fetch(content, can_instantiate_class_list, hash(parent_node, $parent_node))
                                 $can_instantiate_classes = array()}
                            {foreach $can_instantiate_class_list as $class}
                                {set $can_instantiate_classes = $can_instantiate_classes|append($class.identifier)}
                            {/foreach}
                            {def $classes = fetch(class, list, hash(class_filter, $class_identifiers))}

                            <form class="text-right" method="post" action="{$request_url|ezurl(no)}">
                                {foreach $classes as $class}
                                    {if $can_instantiate_classes|contains($class.identifier)}
                                        <a class="btn btn-primary mr-2" href="{concat('add/new/',$class.identifier,'/?parent=',$parent_node.node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {$class.name|wash()}</a>
                                    {/if}
                                {/foreach}
                                {foreach $extra_buttons as $button}
                                    {if is_set($button.href)}
                                        <a class="btn btn-secondary mr-2" href="{$button.href|ezurl(no)}">{$button.value|wash()}</a>
                                    {else}
                                        <button class="btn btn-secondary mr-2" name="{$button.name|wash()}" type="submit">{$button.value|wash()}</button>
                                    {/if}
                                {/foreach}
                            </form>
                        {/if}
                    {/if}

                </div>
            </div>

        </div>
    </div>
</div>

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{ezscript_require(array('jsrender.js'))}

{literal}
<script id="tpl-data-spinner" type="text/x-jsrender">
<div class="col spinner my-3 text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{/literal}{'Loading...'|i18n('agenda')}{literal}</span>
</div>
</script>
<script id="tpl-data-results" type="text/x-jsrender">
<div class="row mb-3 pt-3">
    {{if totalCount == 0}}
        <div class="col text-center">
            <i class="fa fa-times"></i> {/literal}{'No results found'|i18n('agenda')}{literal}
        </div>
    {{else}}
    <div class="col">
        <table class="table table-striped table-sm">
            <thead>
                  <tr>
                      <th>{/literal}{'Title'|i18n('agenda/dashboard')}{literal}</th>
                      {{if showType}}
                        <th>{/literal}{'Content type'|i18n('agenda')}{literal}</th>
                      {{/if}}
                      <th>{/literal}{'Author'|i18n('agenda/dashboard')}{literal}</th>
                      <th>{/literal}{'Published'|i18n('agenda/dashboard')}{literal}</th>
                      <th>{/literal}{'Translations'|i18n('agenda/dashboard')}{literal}</th>
                      {{if stateToggle}}
                        <th>{/literal}{'Visibility'|i18n('design/admin/contentstructuremenu')}{literal}</th>
                      {{/if}}
                      <th></th>
                  </tr>
            </thead>
            <tbody>
            {{for searchHits}}
                <tr>
                    <td><a href="{{:baseUrl}}/openpa/object/{{:metadata.id}}">{{:~i18n(metadata.name)}}</a>{{if placeOsmDetailUrl}}<br /><a target="_blank" href="{{:placeOsmDetailUrl}}"><small style="font-size:.7em">Nominatim detail</small></a>{{/if}}</td>
                    {{if showType}}
                        <td>{{:~i18n(metadata.classDefinition.name)}}</td>
                    {{/if}}
                    <td>{{:~i18n(metadata.ownerName)}}</td>
                    <td>{{:~formatDate(metadata.published,'DD/MM/YYYY HH:MM')}}</td>
                    <td class="text-nowrap">
                        {{for translations}}
                            {{if active}}
                                <a href="{{:baseUrl}}/content/edit/{{:id}}/f/{{:language}}"><img style="max-width:none" src="/share/icons/flags/{{:language}}.gif" /></a>
                            {{else}}
                                <a href="{{:baseUrl}}/content/edit/{{:id}}/a"><img style="max-width:none;opacity:0.2" src="/share/icons/flags/{{:language}}.gif" /></a>
                            {{/if}}
                        {{/for}}
                    </td>
                    {{if stateToggle}}
                    <td>
                        <div class="toggles">
                            <label for="Visibility-{{:metadata.id}}" style="line-height: 1px;">
                                <input type="checkbox" data-object="{{:metadata.id}}" id="Visibility-{{:metadata.id}}" name="Visibility" value="1" {{if visibility == 'public'}}checked = "checked"{{/if}} />
                                <span class="lever" style="margin-top: 0;"></span>
                            </label>
                        </div>
                    </td>
                    {{/if}}
                    <td class="text-nowrap">
                        {{if isUser}}
                            <a class="btn btn-link btn-xs text-black" href="{{:baseUrl}}/social_user/setting/{{:metadata.id}}"><i class="fa fa-user"></i></a>
                        {{/if}}
                        {{if metadata.userAccess.canEdit}}
                            <form method="post" action="{{:baseUrl}}/content/action" style="display: inline;">
                                <button class="btn btn-link btn-xs text-black" type="submit" name="EditButton"><i class="fa fa-pencil"></i></button>
                                <input type="hidden" name="ContentObjectID" value="{{:metadata.id}}" />
                                <input type="hidden" name="NodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="ContentNodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="RedirectIfDiscarded" value="{{:redirect}}" />
                                <input type="hidden" name="ContentObjectLanguageCode" value="{{:locale}}" />
                                <input type="hidden" name="RedirectURIAfterPublish" value="{{:redirect}}" />
                                <input type="hidden" name="HasMainAssignment" value="1" />
                            </form>
                        {{/if}}
                        {{if metadata.userAccess.canTranslate}}
                            <form method="post" action="{{:baseUrl}}/content/action" style="display: inline;">
                                <button class="btn btn-link btn-xs text-black" type="submit" name="EditButton"><i class="fa fa-language"></i></button>
                                <input type="hidden" name="ContentObjectID" value="{{:metadata.id}}" />
                                <input type="hidden" name="NodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="ContentNodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="RedirectIfDiscarded" value="{{:redirect}}" />
                                <input type="hidden" name="RedirectURIAfterPublish" value="{{:redirect}}" />
                                <input type="hidden" name="HasMainAssignment" value="1" />
                            </form>
                        {{/if}}
                        {{if metadata.userAccess.canRemove}}
                            <form method="post" action="{{:baseUrl}}/content/action" style="display: inline;">
                                <button class="btn btn-link btn-xs  text-black" type="submit" name="ActionRemove"><i class="fa fa-trash"></i></button>
                                <input type="hidden" name="ContentObjectID" value="{{:metadata.id}}" />
                                <input type="hidden" name="NodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="ContentNodeID" value="{{:metadata.mainNodeId}}" />
                                <input type="hidden" name="RedirectIfCancel" value="{{:redirect}}" />
                                <input type="hidden" name="RedirectURIAfterRemove" value="{{:redirect}}" />
                            </form>
                        {{/if}}
                    </td>
                </tr>
            {{/for}}
            </tbody>
        </table>
    </div>
    {{/if}}
</div>

{{if pageCount > 1}}
<div class="row mt-lg-4">
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
<script>
{/literal}
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    {if $current_language|ne('eng-GB')}$.opendataTools.settings('fallbackLanguage', "eng-GB");{/if}
    $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
    $.opendataTools.settings('locale', "{$moment_language}");
    $.opendataTools.settings('endpoint',{ldelim}'search': '{'/opendata/api/useraware/search/'|ezurl(no,full)}/'{rdelim});
{literal}
    $.views.helpers($.opendataTools.helpers);
    $(document).ready(function () {
        $('[data-parent]').each(function(){
            var resultsContainer = $(this);
            var form = resultsContainer.prev();
            var limitPagination = resultsContainer.data('limit');
            var subtree = resultsContainer.data('parent');
            var classes = resultsContainer.data('classes');
            var redirect = resultsContainer.data('redirect');
            var isUser = resultsContainer.data('is_user');
            var stateToggle = parseInt(resultsContainer.data('state_toggle')) === 1;
            var currentPage = 0;
            var queryPerPage = [];
            var template = $.templates('#tpl-data-results');
            var spinner = $($.templates("#tpl-data-spinner").render({}));

            if (stateToggle){
                $('[data-search="visibility"]').on('change', function () {
                    currentPage = 0;
                    loadContents();
                })
            }
            var buildQuery = function(){
                var classQuery = '';
                if (classes.length){
                    classQuery = 'classes ['+classes+']';
                }
                var query = classQuery + ' subtree [' + subtree + '] and raw[meta_main_node_id_si] !in [' + subtree + ']';
                var searchText = form.find('[data-search="q"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
                if (searchText.length > 0){
                    query += " and q = '\"" + searchText + "\"'";
                }
                if (stateToggle){
                    var state = $('[data-search="visibility"]').val();
                    if (parseInt(state) > 0){
                        query += " and state in [" + state + "]";
                    }
                }
                query += ' sort [name=>asc]';

                return query;
            };

            var loadContents = function(){
                var baseQuery = buildQuery();
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
                    response.stateToggle = stateToggle;
                    response.showType = classes.split(',').length > 1;
                    $.each(response.searchHits, function(){
                        if (this.metadata.classIdentifier === 'place') {
                            var osmParts = this.metadata.remoteId.split('-');
                            if (osmParts.length === 2){
                                this.placeOsmDetailUrl = 'https://nominatim.openstreetmap.org/details?osmtype='+osmParts[0].toUpperCase().charAt(0)+'&osmid='+osmParts[1];
                            }
                        }
                        this.showType = classes.split(',').length > 1;
                        this.baseUrl = $.opendataTools.settings('accessPath');
                        var self = this;
                        this.languages = $.opendataTools.settings('languages');
                        var currentTranslations = $(this.languages).filter($.map(this.data, function (value, key) {
                            return key;
                        }));
                        var translations = [];
                        $.each($.opendataTools.settings('languages'), function () {
                            translations.push({
                                'id': self.metadata.id,
                                'language': ''+this,
                                'active': $.inArray(''+this, currentTranslations) >= 0
                            });
                        });
                        this.translations = translations;
                        this.redirect = redirect;
                        this.locale = $.opendataTools.settings('language');
                        this.isUser = isUser;
                        this.stateToggle = stateToggle;
                        var stateIdentifier = false;
                        $.each(this.metadata.stateIdentifiers, function () {
                            var parts = this.split('.');
                            if (parts[0] === 'privacy') {
                                stateIdentifier = parts[1];
                            }
                        });
                        this.visibility = stateIdentifier;
                    });
                    var renderData = $(template.render(response));
                    resultsContainer.html(renderData);

                    resultsContainer.find('[name="Visibility"]').on('change', function () {
                        var object = $(this).data('object');
                        var state = $(this).is(':checked') ? 'public' : 'private';
                        $.get($.opendataTools.settings('accessPath')+'/agenda/visibility/'+object+'/'+state, function (response) {
                            if (response !== 'success'){
                                console.log(response);
                            }
                        });
                    });

                    resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
                        currentPage = $(this).data('page');
                        if (currentPage >= 0) loadContents();
                        $('html, body').stop().animate({
                            scrollTop: form.offset().top
                        }, 1000);
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

            form[0].reset();
            loadContents();

            form.find('button[type="submit"]').on('click', function(e){
                form.find('button[type="reset"]').removeClass('hide');
                currentPage = 0;
                loadContents();
                e.preventDefault();
            });
            form.find('button[type="reset"]').on('click', function(e){
                form[0].reset();
                form.find('button[type="reset"]').addClass('hide');
                currentPage = 0;
                loadContents();
                e.preventDefault();
            });
        });
    });
</script>
{/literal}
