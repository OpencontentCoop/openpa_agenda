{set-block scope=root variable=spinner}
  <div class="text-center">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
  </div>
{/set-block}

{*style="{{if ~mainImageUrl(data)}}background-image: url('{{:~mainImageUrl(data)}}');background-size: contain;background-repeat: no-repeat;background-position: center{{else}}background:#fff{{/if}};margin:0"*}
{set-block scope=root variable=events}
{literal}
  <a class="agenda-widget-event" href="{{:~agendaUrl(metadata.mainNodeId)}}">
    <small>
      {{if ~formatDate(~i18n(data,'to_time'),'yyyy.MM.D') !== ~formatDate(~i18n(data,'from_time'),'yyyy.MM.D')}}
      <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'from_time'),'D MMMM')}} - {{:~formatDate(~i18n(data,'to_time'),'D MMMM')}}
      {{else}}
      <i class="fa fa-calendar"></i> {{:~formatDate(~i18n(data,'from_time'),'D MMMM')}}
      {{/if}}
      {{if ~i18n(data,'orario_svolgimento')}}{{:~i18n(data,'orario_svolgimento')}}{{/if}}
    </small>
    <b>{{:~i18n(data,'titolo')}}</b>
    <small>
      {{if ~i18n(data,'luogo')}}{{for ~i18n(data,'luogo')}}{{>~i18n(name)}}{{/for}}{{else}}{{if ~i18n(data,'luogo_svolgimento')}}{{:~i18n(data,'luogo_svolgimento')}}{{/if}}{{/if}}
    </small>
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
        <span class="logo_title">{$social_pagedata.logo_title}</span>
        <span class="logo_subtitle">{$social_pagedata.logo_subtitle}</span>
      </a>
    {/if}
    {literal}{{if show_title}}<p class="title">{{:title}}</p>{{/if}}{/literal}
  </div>
{/set-block}

{set-block scope=root variable=footer}
  <div class="agenda-widget-footer">
    <a href="{'/'|ezurl(no,full)}"><i class="fa fa-calendar"></i> Vai al calendario {$social_pagedata.logo_title}</a>
  </div>
{/set-block}
