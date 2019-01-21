{def $user_hash  = concat( $current_user.role_id_list|implode( ',' ), ',', $current_user.limited_assignment_value_list|implode( ',' ) )}
{cache-block expiry=86400 keys=array( $current_user.contentobject_id, $module_result.uri, $user_hash )}
{def $social_pagedata = social_pagedata()}
<!doctype html>
<html class="no-js" lang="en">

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
    {include uri='design:page_footer.tpl'}
  {/cache-block}
</div>



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
