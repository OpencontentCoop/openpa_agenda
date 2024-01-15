{set_defaults(hash('grid_view', false()))}
{literal}
<script id="tpl-grid" type="text/x-jsrender">
	<div class="row mx-lg-n3">
	{{if totalCount == 0}}
	    {{include tmpl="#tpl-empty"/}}
	{{else}}
	{{for searchHits}}
		<div class="col-md-6 col-lg-4 px-lg-3 pb-lg-3">
		    {{include tmpl="#tpl-event"/}}
		</div>
	{{/for}}
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

<script id="tpl-event" type="text/x-jsrender">
<div class="card-wrapper card-space">
    <div class="card {{if ~agendaMainImageUrl(data)}}card-img{/literal}{if $grid_view|ne('mini')}{literal}{{else}}card-big{/literal}{/if}{literal}{{/if}} card-bg rounded shadow no-after">
        {{if ~agendaMainImageUrl(data)}}
        <div class="img-responsive-wrapper">
            <div class="img-responsive img-responsive-panoramic">
                <div class="img-wrapper">
                    <img src="{{:~agendaMainImageUrl(data)}}" class="img-fluid" />
                </div>
                <div class="card-calendar d-flex flex-column justify-content-center">
                    <span class="card-date">{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'DD')}}</span>
                    <span class="card-day">{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'MMMM')}}</span>
                </div>
            </div>
        </div>
        {{/if}}
        <div class="card-body">
            {/literal}{if $grid_view|ne('mini')}{literal}
            <div class="category-top">
                {{if ~i18n(data,'time_interval').default_value && (~formatDate(~i18n(data,'time_interval').default_value.from_time,'yyyy.MM.D') !== ~formatDate(~i18n(data,'time_interval').default_value.to_time,'yyyy.MM.D')) && ~i18n(data,'time_interval').default_value.count == 1}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'D/MM/YY · H:mm')}}
                {{else ~i18n(data,'time_interval').default_value.count == 1}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'H:mm')}}
                {{else ~i18n(data,'time_interval').default_value && ~i18n(data,'time_interval').default_value.count > 1}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'H:mm')}}<br />{{:~i18n(data,'time_interval').text}}
                {{/if}}
            </div>
            {/literal}{/if}{literal}
            <h5 class="card-title{{if !~agendaMainImageUrl(data)}} big-heading{{/if}}">
                <a class="stretched-link text-primary text-decoration-none" href="{{:~objectUrl(metadata.id)}}">{{:~i18n(metadata.name)}}</a>
            </h5>
            {/literal}{if $grid_view|ne('mini')}{literal}
            {{if ~i18n(data,'event_abstract')}}
              {{:~i18n(data,'event_abstract')}}
            {{/if}}
            {/literal}{/if}{literal}

            <ul class="list-inline m-0" style="font-size:.8em">
                {{if ~i18n(data,'has_public_event_typology')}}
                    {{for ~i18n(data,'has_public_event_typology')}}
                        <li class="list-inline-item"><i class="fa fa-tag"></i> {{>#data}}</li>
                    {{/for}}
                {{/if}}
                {{if ~settings('is_collaboration_enabled')}}
                  {{if ~i18n(data,'organizer')}}
                    {{for ~i18n(data,'organizer')}}
                    <li class="list-inline-item"><i class="fa fa-user"></i> {{>~i18n(name)}}</li>
                    {{/for}}
                  {{/if}}
                {{/if}}
            </p>
        </div>
    </div>
</div>
</script>
{/literal}
{unset_defaults(array('show_abstract'))}
