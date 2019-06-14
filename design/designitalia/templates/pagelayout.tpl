{def $user_hash  = concat( $current_user.role_id_list|implode( ',' ), ',', $current_user.limited_assignment_value_list|implode( ',' ) )}
{cache-block expiry=86400 keys=array( $current_user.contentobject_id, $module_result.uri, $user_hash )}
{def $social_pagedata = social_pagedata()}
<!doctype html>
<html class="no-js" lang="en">

{include uri='design:page_head.tpl'}
{include uri='design:page_head_google_tag_manager.tpl'}
{include uri='design:page_head_google-site-verification.tpl'}

<body{if and( is_set( $module_result.content_info.persistent_variable.agenda_home ), $social_pagedata.banner_path, $social_pagedata.banner_title|ne('') )} class="collapsing_header"{/if}>
    {include uri='design:page_body_google_tag_manager.tpl'}
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
    {include uri='design:page_footer.tpl'}
  {/cache-block}
</div>



{if is_set($social_pagedata)|not()}{def $social_pagedata = social_pagedata()}{/if}
{if $social_pagedata.google_analytics_id}
    <script type="text/javascript">
      (function(i,s,o,g,r,a,m){ldelim}i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){ldelim}
        (i[r].q=i[r].q||[]).push(arguments){rdelim},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      {rdelim})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
      ga('create', '{$social_pagedata.google_analytics_id}', 'auto');
      ga('set', 'anonymizeIp', true);
      ga('set', 'forceSSL', true);
      ga('send', 'pageview');
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

<script>
  {literal}
  $( document ).ready(function($) {
    $('#show-form-search').click(function() {
      if ($( "#mobile-search" ).hasClass( 'hidden' )) {
        $( "#mobile-search" ).removeClass('hidden');
        $('#show-form-search').find('i').attr('class', 'fa fa-times');
      } else {
        $( "#mobile-search" ).addClass('hidden');
        $('#show-form-search').find('i').attr('class', 'fa fa-search')
      }
    });
  });

  $(document).ready(function($) {

    var $wrap = $(window),
      $header = $("#header"),
      headerHeight = $header.outerHeight(),
      headerTopHeight = $("#header-top").outerHeight(),
      headerInsideHeight = $("#header-inside").outerHeight();

    $wrap.on('scroll', function(e) {
      if ($wrap.scrollTop() > headerTopHeight + headerInsideHeight
        && $wrap.width() > 200
      ) {
        $header.addClass("header-fixed");
      } else {
        $header.removeClass("header-fixed");
      }
    });
  });
  {/literal}
</script>

<!--DEBUG_REPORT-->
</body>
</html>
