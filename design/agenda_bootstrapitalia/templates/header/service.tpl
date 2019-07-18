{def $header_service = openpaini('GeneralSettings','header_service', 1)
     $header_service_list = array()
     $is_area_tematica = is_area_tematica()}
{if $header_service|eq(1)}
    {if agenda_root()|has_attribute('service_url')}
        {set $header_service_list = $header_service_list|append(hash(
            'url', agenda_root()|attribute('service_url').content|wash(xhtml),
            'name', agenda_root()|attribute('service_url').data_text|wash(xhtml)
        ))}
    {else}
        {set $header_service_list = $header_service_list|append(hash(
            'url', openpaini('InstanceSettings','UrlAmministrazioneAfferente', '#'),
            'name', openpaini('InstanceSettings','NomeAmministrazioneAfferente', 'OpenContent')
        ))}
    {/if}
{/if}
{* todo header_links *}
{def $header_links = array()}

{def $current_language = false()
     $available_languages = array()
     $lang_selector = array()
     $avail_translation = array()}
{if and( is_set( $DesignKeys:used.url_alias ), $DesignKeys:used.url_alias|count|ge( 1 ) )}
    {set $avail_translation = language_switcher( $DesignKeys:used.url_alias )}
{else}
    {set $avail_translation = language_switcher( $site.uri.original_uri )}
{/if}
{if $avail_translation|count|gt( 1 )}
  {foreach $avail_translation as $siteaccess => $lang}
    {if is_set($lang.locale)}
        {if $siteaccess|eq( $access_type.name )}
          {set $current_language = $lang}
        {else}
          {set $available_languages = $available_languages|append($lang)}
        {/if}
    {/if}
  {/foreach}
{/if}

<div class="it-header-slim-wrapper{* theme-light*}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-header-slim-wrapper-content">
                    {if $header_service_list|count()|gt(0)}
                        {foreach $header_service_list as $item}
                            <a class="d-none d-lg-block navbar-brand" href="{$item.url}">{$item.name|wash()}</a>
                        {/foreach}
                        <div class="nav-mobile">
                            <nav>
                                {if $header_links|count()}
                                <a class="d-lg-none navbar-brand"
                                   data-toggle="collapse"
                                   href="#service-menu"
                                   role="button"
                                   aria-expanded="false"
                                   aria-controls="service-menu">
                                    <span>{$header_service_list[0].name|wash()}</span>
                                    {display_icon('it-expand', 'svg', 'icon icon-white')}
                                </a>
                                <div class="link-list-wrapper collapse" id="service-menu">
                                    <ul class="link-list">
                                        {foreach $header_links as $header_link max 3}
                                            <li>{node_view_gui content_node=$header_link view=text_linked}</li>
                                        {/foreach}
                                    </ul>
                                </div>
                                {else}
                                    <a class="d-lg-none navbar-brand" href="{$header_service_list[0].url}"><span>{$header_service_list[0].name|wash()}</span></a>
                                {/if}
                            </nav>
                        </div>
                    {/if}

                    <div class="header-slim-right-zone">
                        {if $available_languages|count()}
                        <div class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle py-0"
                               href="#"
                               data-toggle="dropdown"
                               aria-expanded="false">
                                <span>{$current_language.text|wash|upcase}</span>
                                {display_icon('it-expand', 'svg', 'icon d-none d-lg-block')}
                            </a>
                            <div class="dropdown-menu">
                                <div class="row">
                                    <div class="col-12">
                                        <div class="link-list-wrapper">
                                            <ul class="link-list">
                                                <li>
                                                    <a href="{$current_language.url|ezurl(no)}"
                                                       class="list-item">
                                                        <span lang="{fetch(content, locale, hash(locale_code, $current_language.locale)).http_locale_code|explode('-')[0]}">{$current_language.text|wash|upcase}</span>
                                                    </a>
                                                </li>
                                                {foreach $available_languages as $lang}
                                                    <li>
                                                        <a href="{$lang.url|ezurl(no)}"
                                                           title="{$lang.text|wash|upcase}"
                                                           class="list-item">
                                                            <span lang="{fetch(content, locale, hash(locale_code, $lang.locale)).http_locale_code|explode('-')[0]}">{$lang.text|wash|upcase}</span>
                                                        </a>
                                                    </li>
                                                {/foreach}
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        {/if}
                        <div class="it-access-top-wrapper">
                            <a data-login-top-button class="btn btn-primary btn-icon btn-full" href="{"/user/login"|ezurl(no)}" title="Esegui il login al sito" style="display: none;">
                                 <span class="rounded-icon">
                                     {display_icon('it-user', 'svg', 'icon icon-primary')}
                                </span>
                                <span class="d-none d-lg-block" title="{'Are you already a member?'|i18n('social_user/signin')} {'Log in now!'|i18n('social_user/signin')}">
                                    {'Login'|i18n('design/ocbootstrap/pagelayout')}
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


<script>{literal}
    $(document).ready(function(){
        var trimmedPrefix = UriPrefix.replace(/~+$/g,"");
        if(trimmedPrefix === '/') trimmedPrefix = '';
        var spritePath = "{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}";
        var login = $('[data-login-top-button]');
        login.find('a').attr('href', login.find('a').attr('href') + '?url='+ ModuleResultUri);
        var injectUserInfo = function(data){
            if(data.error_text || !data.content){
                login.show();
            }else{
                var dropdownWrapper = $('<div class="dropdown"></div>');
                var dropdownMenu = $('<div class="dropdown-user dropdown-menu" aria-labelledby="dropdown-user"></div>');
                var dropdownListWrapper = $('<div class="link-list-wrapper"></div>');
                var dropdownList = $('<ul class="link-list"></ul>');
                $('<a href="#" class="btn btn-primary btn-icon btn-full dropdown-toggle" id="dropdown-user" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><span class="rounded-icon"><svg class="icon icon-primary"><use xlink:href="'+spritePath+'#it-user"></use></svg></span><span class="d-none d-lg-block">'+data.content.name+' </span><svg class="icon-expand icon icon-white"><use xlink:href="'+spritePath+'#it-expand"></use></svg></a>')
                    .appendTo(dropdownWrapper);
                $.each(data.content.menu, function () {
                    $('<li><a style="line-height:1" class="my-4 list-item" href="'+trimmedPrefix+'/'+this.url+'" title="'+this.name+'"><span>'+this.name+'</span></a></li>')
                        .appendTo(dropdownList);
                });
                dropdownList.appendTo(dropdownListWrapper);
                dropdownListWrapper.appendTo(dropdownMenu);
                dropdownMenu.appendTo(dropdownWrapper);
                login.after(dropdownWrapper);
                login.remove();
            }
        };
        if(CurrentUserIsLoggedIn){
            $.ez('openpaagendaajax::userInfo', null, function(data){
                injectUserInfo(data);
            });
        }else{
            login.show();
        }
    });
    {/literal}
</script>

</div>
{undef $header_service $header_service_list $is_area_tematica $header_links $current_language $available_languages $lang_selector $avail_translation}
