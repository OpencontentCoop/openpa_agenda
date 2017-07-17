{def $user_hash  = concat( $current_user.role_id_list|implode( ',' ), ',', $current_user.limited_assignment_value_list|implode( ',' ) )}
{cache-block expiry=86400 keys=array( $current_user.contentobject_id, $module_result.uri, $user_hash )}
{def $social_pagedata = social_pagedata()}
<!doctype html>
<html class="no-js" lang="en">

{ezcss_require(array(
    'leaflet.css',
    'MarkerCluster.css',
    'MarkerCluster.Default.css',
    'openpa_agenda.css',
    'addtocalendar.css'
))}

{include uri='design:page_head.tpl'}

<body{if and( is_set( $module_result.content_info.persistent_variable.agenda_home ), $social_pagedata.banner_path, $social_pagedata.banner_title|ne('') )} class="collapsing_header"{/if}>
    {include uri='design:page_alert_cookie.tpl'}

    {include uri='design:page_header.tpl'}

    {include uri='design:page_banner.tpl'}

{/cache-block}

<div class="main">
    <div class="container">
        {$module_result.content}

        {if and($current_user.is_logged_in|not(), $ui_context|ne('edit'))}
            {include uri='design:page_login.tpl'}
        {/if}

    </div>

{cache-block expiry=86400 keys=array( $user_hash )}

    {if is_set( $social_pagedata )|not()}{def $social_pagedata = social_pagedata()}{/if}
    <footer>
        <section id="footer_teasers_wrapper">
            <div class="container">
                <div class="row">
                    <div class="footer_teaser col-sm-6 col-md-6">
                        <h3>{'Contatti'|i18n('ocsocialdesign')}</h3>
                        <p>{attribute_view_gui attribute=$social_pagedata.attribute_contacts}</p>
                    </div>
                    <div class="footer_teaser col-sm-6 col-md-6">
                        <p>{attribute_view_gui attribute=$social_pagedata.attribute_footer}</p>
                    </div>
                </div>
            </div>
        </section>
        <section class="copyright">
            <div class="container">
                <div class="row">
                    <div class="col-sm-12 col-md-12">
                        &copy; {currentdate()|datetime('custom', '%Y')} {$social_pagedata.text_credits|wash()}
                    </div>
                </div>
            </div>
        </section>
    </footer>

</div>
{/cache-block}

{if is_set($social_pagedata)|not()}{def $social_pagedata = social_pagedata()}{/if}
{if $social_pagedata.google_analytics_id}
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '{$social_pagedata.google_analytics_id}']);
        _gaq.push(['_setAllowLinker', true]);
        _gaq.push(['_trackPageview']);
        (function() {ldelim}
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            {rdelim})();
    </script>
{/if}

<script>
    {literal}
    $(document).ready(function(){
        $.get({/literal}{'social_user/alert'|ezurl()}{literal}, function(data){
            $('header').prepend(data)
        });
    });
    {/literal}
</script>

<!--DEBUG_REPORT-->
</body>
</html>
