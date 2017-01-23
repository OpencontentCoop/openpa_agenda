<section class="hgroup noborder home-agenda">

{if is_collaboration_enabled()}
    <div class="row home-teaser hidden-xs">
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/download/'|ezurl(no)}"><b>{'Programma'|i18n('agenda')}</b></a> <small>{'Scarica il programma in pdf'|i18n('agenda')}</small></h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/associazioni/'|ezurl(no)}"><b>{'Rubrica'|i18n('agenda')}</b> {'associazioni'|i18n('agenda')}</a> <small>{'Registro ufficiale del comune'|i18n('agenda')}</small></h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/info/faq/'|ezurl(no)}"">{"Sei un'<b>associazione</b>?"|i18n('agenda')}</a> <small>{'Scopri come partecipare!'|i18n('agenda')}</small></h2>
                </div>
            </div>
        </div>
    </div>

{else}

    <div class="text-center">
        <a class="btn btn-success btn-lg" href="{'agenda/download/'|ezurl(no)}">
            <strong>{'Programma'|i18n('agenda')}</strong><br />
            <small>{'Scarica il programma in pdf'|i18n('agenda')}</small>
        </a>
    </div>

{/if}
    <hr />

    <div class="row">
        <div class="col-sm-9">


            <div class="tab-content" style="margin-bottom: 40px;">
                <div id="list" class="tab-pane active">
                    <section id="calendar" class="service_teasers row"></section>
                </div>
                <div id="geo" class="tab-pane">
                    <div id="map" style="width: 100%; height: 700px"></div>
                </div>
            </div>

        </div>

        <div class="col-sm-3">

            <aside>
            <ul class="nav nav-pills">
                <li class="active"><a data-toggle="tab" href="#list"><i class="fa fa-calendar" aria-hidden="true"></i> {'Calendario'|i18n('agenda')}</a></li>
                <li><a data-toggle="tab" href="#geo"><i class="fa fa-map-marker" aria-hidden="true"></i> {'Sulla mappa'|i18n('agenda')}</a></li>
            </ul>
            </aside>

            <aside class="widget" data-filter="q" style="display: none">
                <div class="input-group">
                    <input type="text" class="form-control" placeholder="Cerca nel titolo o nel testo" name="srch-term" id="srch-term">
                    <div class="input-group-btn">
                        <button class="btn btn-default" type="submit"><i class="glyphicon glyphicon-search"></i></button>
                    </div>
                </div>
            </aside>

            <aside class="widget" data-filter="date">
                <h4>{'Quando?'|i18n('agenda')}</h4>
                <div class="datepicker" id="datepicker" style="display: none"></div>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="today">{'Oggi'|i18n('agenda')}</a></li>
                    <li><a href="#" data-value="weekend">{'Questo fine settimana'|i18n('agenda')}</a></li>
                    <li><a href="#" data-value="next 7 days">{'I prossimi 7 giorni'|i18n('agenda')}</a></li>
                    <li><a href="#" data-value="next 30 days">{'I prossimi 30 giorni'|i18n('agenda')}</a></li>
                    <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="type">
                <h4>{'Cosa?'|i18n('agenda')}</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="target" style="display: none">
                <h4>{'Chi sei?'|i18n('agenda')}</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
                </ul>
            </aside>

            <aside class="widget" data-filter="iniziativa" style="display: none">
                <h4>{'Manifestazione'|i18n('agenda')}</h4>
                <ul class="nav nav-pills nav-stacked">
                    <li><a href="#" data-value="all">{'Tutte'|i18n('agenda')}</a></li>
                </ul>
            </aside>

        </div>

    </div>
</section>

<script>
    $.opendataTools.settings('is_collaboration_enabled', {cond(is_collaboration_enabled(), 'true', 'false')});
</script>
{literal}

<style>
    .type-499{display: none;}
</style>

<script id="tpl-spinner" type="text/x-jsrender">
<div class="spinner text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{/literal}{'Loading...'|i18n('agenda')}{literal}</span>
</div>
</script>

<script id="tpl-empty" type="text/x-jsrender">
<div class="text-center">
    <i class="fa fa-times"></i> {/literal}{'Nessun evento trovato'|i18n('agenda')}{literal}
</div>
</script>

<script id="tpl-event" type="text/x-jsrender">
<div class="col-md-6">
    <div class="service_teaser calendar_teaser vertical">
      {{if ~i18n(data,'image')}}
      <div class="service_photo">
          <figure style="background-image:url({{:~mainImageUrl(data)}})"></figure>
      </div>
      {{/if}}
      <div class="service_details">
        
          <div class="media">

              {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.dd') == ~formatDate(~i18n(data,'from_time'),'yyyy.MM.dd')}}
                  <div class="media-left">
                      <div class="calendar-date">
                        <span class="month">{{:~formatDate(~i18n(data,'from_time'),'MMM')}}</span>
                        <span class="day">{{:~formatDate(~i18n(data,'from_time'),'D')}}</span>
                      </div>
                  </div>
             {{/if}}

              <div class="media-body">
                  {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.dd') !== ~formatDate(~i18n(data,'from_time'),'yyyy.MM.dd')}}
                    <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'from_time'),'D MMMM')}} - {{:~formatDate(~i18n(data,'to_time'),'D MMMM')}}
                  {{/if}}
                   <h2 class="section_header skincolored">
                      <a href="{{:~agendaUrl(metadata.mainNodeId)}}">
                          <b>{{:~i18n(data,'titolo')}}</b>
                          <small>{{:~i18n(data,'luogo_svolgimento')}} {{:~i18n(data,'orario_svolgimento')}}</small>
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
          
          {{for ~i18n(data,'patrocinio')}}
            <div class="patronage">            
               <small><i class="fa fa-flag"></i> {{>~i18n(name)}}</small>
            </div>
          {{/for}}

          <div class="tipo_evento">
              <small>
              {{for ~i18n(data,'tipo_evento')}}
                  <span class="type-{{>id}}" style="white-space:nowrap">
                      <i class="fa fa-tag"></i> {{>~i18n(name)}}
                  </span>
              {{/for}}
              </small>
          </div>
          {{if ~settings('is_collaboration_enabled')}}
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

      </div>
    </div>
</div>
</script>
{/literal}

{include
    uri='design:agenda/parts/calendar.tpl'
    site_identifier=$site_identifier
    current_language=$current_language
    base_query=concat('classes [event] and subtree [', $calendar_node_id, '] and state in [moderation.skipped,moderation.accepted] sort [from_time=>asc] facets [tipo_evento|alpha|100,target|alpha|10,iniziativa|count|10]')
}
