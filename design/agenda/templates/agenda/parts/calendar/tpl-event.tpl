{literal}
<script id="tpl-event" type="text/x-jsrender">
<div class="col-md-6">
    <div class="service_teaser calendar_teaser vertical">
      {{if ~mainImageUrl(data)}}
      <div class="service_photo">
          <figure style="background-image:url({{:~mainImageUrl(data)}})"></figure>
      </div>
      {{/if}}
      <div class="service_details">
        
          <div class="media">

              {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.D') == ~formatDate(~i18n(data,'from_time'),'yyyy.MM.D')}}
                  <div class="media-left">
                      <div class="calendar-date">
                        <span class="month">{{:~formatDate(~i18n(data,'from_time'),'MMM')}}</span>
                        <span class="day">{{:~formatDate(~i18n(data,'from_time'),'D')}}</span>
                      </div>
                  </div>
			  {{/if}}

              <div class="media-body">
                  {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.D') !== ~formatDate(~i18n(data,'from_time'),'yyyy.MM.D')}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'from_time'),'D MMMM')}} - {{:~formatDate(~i18n(data,'to_time'),'D MMMM')}}
                  {{/if}}
                   <h2 class="section_header skincolored">
                      <a href="{{:~agendaUrl(metadata.mainNodeId)}}">
                          <b>{{:~i18n(data,'titolo')}}</b>
                          <small>
							{{if ~i18n(data,'luogo')}}
							  {{for ~i18n(data,'luogo')}}{{>~i18n(name)}}{{/for}}
							{{else}}
							  {{if ~i18n(data,'luogo_svolgimento')}}
								{{:~i18n(data,'luogo_svolgimento')}}
							  {{/if}}
							{{/if}}
							{{if ~i18n(data,'orario_svolgimento')}}
							  {{:~i18n(data,'orario_svolgimento')}}
							{{/if}}
						  </small>
                      </a>
                  </h2>
              </div>
          </div>

          {{if ~i18n(data,'periodo_svolgimento')}}
              <small class="periodo_svolgimento">
                  {{:~i18n(data,'periodo_svolgimento')}}
              </small>
          {{/if}}
          {{if ~i18n(data,'abstract')}}
              {{:~i18n(data,'abstract')}}
          {{/if}}
          
          {{if ~i18n(data,'patrocinio')}}
			{{for ~i18n(data,'patrocinio')}}
			  <div class="patronage">            
				 <small><i class="fa fa-flag"></i> <span>{{>~i18n(name)}}</span></small>
			  </div>
			{{/for}}
		  {{/if}}

          {{if ~i18n(data,'tipo_evento')}}
		  <div class="tipo_evento">
              <small>
              {{for ~i18n(data,'tipo_evento')}}
                  <span class="type-{{>id}}" style="white-space:nowrap">
                      <i class="fa fa-tag"></i> {{if ~i18n(name)}} {{>~i18n(name)}} {{else}} {{>#data}} {{/if}}
                  </span>
              {{/for}}
              </small>
          </div>
		  {{/if}}
		  
          {{if ~settings('is_collaboration_enabled')}}
          {{if ~i18n(data,'organizzazione')}}
		  <div class="organizzazione">
              <small>
              {{for ~i18n(data,'organizzazione')}}
                  <a class="btn btn-success btn-xs type-{{>id}}" href="{{:~associazioneUrl(id)}}">
                      {{>~i18n(name)}}
                  </a>
              {{/for}}
              </small>
          </div>          
          {{/if}}
		  {{/if}}

      </div>
    </div>
</div>
</script>
{/literal}
