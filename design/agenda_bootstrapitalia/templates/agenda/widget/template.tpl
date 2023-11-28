{set-block scope=root variable=spinner}
  <div class="text-center" style="margin-top:30px">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
  </div>
{/set-block}

{*
style="{{if ~mainImageUrl(data)}}background-image: url('{{:~mainImageUrl(data)}}');background-size: contain;background-repeat: no-repeat;background-position: center{{else}}background:#fff{{/if}};margin:0"
*}
{set-block scope=root variable=events}
{literal}
  <a class="agenda-widget-event" href="{{:~agendaUrl(metadata.mainNodeId)}}">
    {{if ~mainImageUrl(data)}}
    <div class="agenda-widget-image-wrapper">
        <img src="{{:~mainImageUrl(data)}}" />
        <div class="agenda-widget-calendar">
          <span class="agenda-widget-calendar-day">{{if ~i18n(data,'time_interval').default_value.count > 1}}<small>{/literal}{'from'|i18n('openpa/search')}{literal}</small>{{/if}}{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'DD')}}</span>
          <span class="agenda-widget-calendar-month">{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'MMMM')}}</span>
        </div>
    </div>
    {{else}}
    <div class="agenda-widget-calendar">
        <span class="agenda-widget-calendar-day">{{if ~i18n(data,'time_interval').default_value.count > 1}}<small>{/literal}{'from'|i18n('openpa/search')}{literal}</small>{{/if}}{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'DD')}}</span>
        <span class="agenda-widget-calendar-month">{{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'MMMM')}}</span>
    </div>
    {{/if}}
    <div class="agenda-widget-content">
      <h3>{{:~i18n(metadata.name)}}</h3>
      {{if ~i18n(data,'event_abstract')}}
        {{:~i18n(data,'event_abstract')}}
      {{/if}}
        <small>
            {{if ~i18n(data,'time_interval').default_value && (~formatDate(~i18n(data,'time_interval').default_value.from_time,'yyyy.MM.D') !== ~formatDate(~i18n(data,'time_interval').default_value.to_time,'yyyy.MM.D')) && ~i18n(data,'time_interval').default_value.count == 1}}
            <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'D/MM/YY · H:mm')}}
            {{else ~i18n(data,'time_interval').default_value.count == 1}}
            <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'H:mm')}}
            {{else ~i18n(data,'time_interval').default_value && ~i18n(data,'time_interval').default_value.count > 1}}
            <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'D/MM/YY · H:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'H:mm')}} {{:~i18n(data,'time_interval').text}}
            {{/if}}
        </small>
  </div>
  </a>
{/literal}
{/set-block}

{def $social_pagedata= social_pagedata()}

{set-block scope=root variable=header}
  <div class="agenda-widget-header">
    {if is_header_only_logo_enabled()}
      <a href="{'/'|ezurl(no,full)}">
        <img src="{$social_pagedata.logo_path|ezroot(no,full)}" alt="{$social_pagedata.site_title}" style="max-height: 90px" />
        <span class="hide" style="display: none">{$social_pagedata.logo_title} - {$social_pagedata.logo_subtitle}</span>
      </a>
    {else}
      <a class="agenda-widget-brand" href="{'/'|ezurl(no,full)}">
        <img src="{$social_pagedata.logo_path|ezroot(no,full)}" alt="{$social_pagedata.site_title}" height="90" width="90">
        <div>
          <span class="logo_title">{$social_pagedata.logo_title}</span>
          <span class="logo_subtitle">{$social_pagedata.logo_subtitle}</span>
        </div>
      </a>
    {/if}
    {literal}{{if show_title}}<h2 class="agenda-widget-header-title">{{:title}}</h2>{{/if}}{/literal}
  </div>
{/set-block}

{set-block scope=root variable=footer}
  <div class="agenda-widget-footer">
    <a href="{'/'|ezurl(no,full)}"><i class="fa fa-calendar"></i> {'Go to event calendar'|i18n('bootstrapitalia')} {$social_pagedata.logo_title}</a>
  </div>
{/set-block}
