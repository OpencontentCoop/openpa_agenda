<!doctype html>
<html lang="{$site.http_equiv.Content-language|wash}">
<head>

    {if is_set( $extra_cache_key )|not}
        {def $extra_cache_key = ''}
    {/if}

    {if openpacontext().is_homepage}
        {set $extra_cache_key = concat($extra_cache_key, 'homepage')}
    {/if}

    {if openpacontext().is_login_page}
        {set $extra_cache_key = concat($extra_cache_key, 'login')}
    {/if}

    {if openpacontext().is_edit}
        {set $extra_cache_key = concat($extra_cache_key, 'edit')}
    {/if}

    {if openpacontext().is_area_tematica}
        {set $extra_cache_key = concat($extra_cache_key, 'areatematica_', openpacontext().is_area_tematica)}
    {/if}

    {def $has_valuation = '0'}
    {if or(and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation),openpacontext().is_search_page)}
        {set $has_valuation = '1'}
    {/if}

    {def $theme = current_theme()
         $main_content_class = ''
         $has_container = cond(is_set($module_result.content_info.persistent_variable.has_container), true(), false())
         $has_section_menu = cond(is_set($module_result.content_info.persistent_variable.has_section_menu), true(), false())
         $has_sidemenu = cond(and(is_set($module_result.content_info.persistent_variable.has_sidemenu), $module_result.content_info.persistent_variable.has_sidemenu), true(), false())
         $avail_translation = language_switcher( $site.uri.original_uri )}
    {if $has_container|not()}
        {set $main_content_class = 'container px-4 my-4'}
    {/if}

    {debug-accumulator id=page_head name=page_head}
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    {no_index_if_needed()}
    {include uri='design:page_head.tpl' canonical_url=openpacontext().canonical_url}
    {/debug-accumulator}

    {cache-block expiry=86400 ignore_content_expiry keys=array( 'favicon' )}
    {def $pagedata = openpapagedata()}
    {include uri="design:favicon.tpl"}
    {undef $pagedata}
    {/cache-block}

    {debug-accumulator id=page_head_style name=page_head_style}
    {include uri='design:page_head_style.tpl'}
    {/debug-accumulator}

    {debug-accumulator id=page_head_script name=page_head_script}
    {include uri='design:page_head_script.tpl'}
    {include uri='design:page_head_google_tag_manager.tpl'}
    {include uri='design:page_head_google-site-verification.tpl'}
    {/debug-accumulator}

</head>
<body class="{$theme}" style="overflow-x: hidden;"> {* todo style *}
<script type="text/javascript">
//<![CDATA[
var CurrentLanguage = "{ezini( 'RegionalSettings', 'Locale' )}";
var CurrentUserIsLoggedIn = {cond(fetch('user','current_user').is_logged_in, 'true', 'false')};
var UiContext = "{$ui_context}";
var UriPrefix = {'/'|ezurl()};
{if and(openpacontext().is_edit|not(),openpacontext().is_browse|not())}
var PathArray = [{if is_set( openpacontext().path_array[0].node_id )}{foreach openpacontext().path_array|reverse as $path}{$path.node_id}{delimiter},{/delimiter}{/foreach}{/if}];
{/if}
var ModuleResultUri = "{$module_result.uri|wash()}";
var LanguageUrlAliasList = [{foreach $avail_translation as $siteaccess => $lang}{ldelim}locale:"{$lang.locale}",uri:"{$site.uri.original_uri|lang_selector_url($siteaccess)}"{rdelim}{delimiter},{/delimiter}{/foreach}];
$.opendataTools.settings('endpoint',{ldelim}
    'geo': '{'/opendata/api/geo/search/'|ezurl(no)}/',
    'search': '{'/opendata/api/content/search/'|ezurl(no)}/',
    'class': '{'/opendata/api/classes/'|ezurl(no)}/',
    'tags_tree': '{'/opendata/api/tags_tree/'|ezurl(no)}/',
    'fullcalendar': '{'/opendata/api/fullcalendar/search/'|ezurl(no)}/'
{rdelim});
var MomentDateFormat = "{'DD/MM/YYYY'|i18n('openpa/moment_date_format')}";
var MomentDateTimeFormat = "{'DD/MM/YYYY HH:mm'|i18n('openpa/moment_datetime_format')}";
//]]>
</script>

    <div class="skiplinks">
        <a class="sr-only sr-only-focusable" href="#main-content">{'Jump to main content'|i18n('bootstrapitalia')}</a>
        {if $has_section_menu}
            <a class="sr-only sr-only-focusable" href="#section-menu">{'Jump to section menu'|i18n('bootstrapitalia')}</a>
        {/if}
        <a class="sr-only sr-only-focusable" href="#footer">{'Jump to footer'|i18n('bootstrapitalia')}</a>
    </div>

    {debug-accumulator id=page_toolbar name=page_toolbar}
    {include uri='design:page_toolbar.tpl'}
    {/debug-accumulator}

    {if and(openpacontext().is_edit|not(),openpacontext().is_browse|not())}
    {cache-block expiry=86400 ignore_content_expiry keys=array( $access_type.name, $extra_cache_key, openpaini('GeneralSettings','theme', 'default') )}
    {debug-accumulator id=page_header name=page_header}
        {def $pagedata = openpapagedata()}
        {include uri='design:page_notifications.tpl'}
        <header class="it-header-wrapper it-header-sticky">
            {include uri='design:header/service.tpl'}
            <div class="it-nav-wrapper">
                <div class="it-header-center-wrapper{if current_theme_has_variation('light_center')} theme-light{/if}">
                    <div class="container">
                        <div class="row">
                            <div class="col-12">
                                <div class="it-header-center-content-wrapper">
                                    {include uri='design:logo.tpl'}
                                    <div class="it-right-zone">
                                        {include uri='design:header/social.tpl'}
                                        {include uri='design:header/search.tpl'}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
        {undef $pagedata}
    {/debug-accumulator}
    {/cache-block}
    {cache-block expiry=86400 ignore_content_expiry keys=array( $current_user.is_logged_in, $access_type.name, $extra_cache_key, openpaini('GeneralSettings','theme', 'default') )}
    {debug-accumulator id=offcanvas_menu name=offcanvas_menu}
        {def $pagedata = openpapagedata()}
                {include uri='design:header/navbar.tpl'}
            </div>
        </header>
        {undef $pagedata}
    {/debug-accumulator}
    {/cache-block}
    {/if}

    <main id="main-content"{if $main_content_class|ne('')} class="{$main_content_class}"{/if}>

        {if openpacontext().show_breadcrumb}
        {if $has_container}<div class="container">{/if}
        {debug-accumulator id=breadcrumb name=breadcrumb}
            {include uri='design:breadcrumb.tpl' path_array=openpacontext().path_array}
        {/debug-accumulator}
        {if $has_container}</div>{/if}
        {/if}

        {include uri='design:page_mainarea.tpl'}
    </main>

    {if and(openpacontext().is_login_page|not(), openpacontext().is_edit|not())}
    {debug-accumulator id=page_footer name=page_footer}
    {cache-block expiry=86400 ignore_content_expiry keys=array( $access_type.name, $has_valuation )}
        {def $pagedata = openpapagedata()}
        {include uri='design:page_footer.tpl'}
        {include uri='design:page_extra.tpl'}
        {undef $pagedata}
    {/cache-block}
    {/debug-accumulator}
    {/if}

    {include uri='design:page_footer_script.tpl'}

    {include uri='design:parts/load_global_website_toolbar.tpl' current_user=fetch(user, current_user)}

<!--DEBUG_REPORT-->
</body>
</html>
