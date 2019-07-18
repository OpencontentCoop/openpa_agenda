{literal}
<script id="tpl-dashboard-list" type="text/x-jsrender">
	<div class="row">
	{{if totalCount == 0}}
	    <div class="col text-center">
            <i class="fa fa-times"></i> {/literal}{'No contents'|i18n('opendata_forms')}{literal}
        </div>
	{{else}}
        <div class="col">
        <table class="table table-striped table-sm">
        {/literal}
            <thead>
                  <tr>
                      <th></th>
                      <th>{'Title'|i18n('agenda/dashboard')}</th>
                      <th>{'Author'|i18n('agenda/dashboard')}</th>
                      <th>{'Published'|i18n('agenda/dashboard')}</th>
                      <th>{'Translations'|i18n('agenda/dashboard')}</th>
                  </tr>
            </thead>
        {literal}
            <tbody>
            {{for searchHits}}
                {{include tmpl="#tpl-dashboard-item"/}}
            {{/for}}
            </tbody>
        </table>
        </div>
	{{/if}}
	</div>

	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Pagination">
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

<script id="tpl-dashboard-item" type="text/x-jsrender">
<tr>
    <td>
        <a class="btn btn-link btn-xs label-{{:dashboardStateIdentifier}} text-white" href="{{:baseUrl}}/editorialstuff/edit/{{:factoryIdentifier}}/{{:metadata.id}}">
        {/literal}{'Detail'|i18n('agenda/dashboard')}{literal}
        </a>
    </td>
    <td>{{:~i18n(metadata.name)}}</td>
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
</tr>
</script>
{/literal}
