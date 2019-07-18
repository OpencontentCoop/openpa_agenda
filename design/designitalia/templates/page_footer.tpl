{if is_set( $social_pagedata )|not()}{def $social_pagedata = social_pagedata()}{/if}

{*<section id="survey" class="clearfix container-fluid">
  <div class="row">
    <div class="col-md-12 text-center">
      <a href="#">
        <i class="fa fa-pencil-square-o" aria-hidden="true"></i> <strong>Valuta questo sito</strong>
      </a>
    </div>
  </div>
</section>*}


<section id="pre-footer" class="clearfix container-fluid">
  <div class="row">
    <div class="col-xs-2">
      <div id="logo-footer">
        <a href="{'/'|ezurl(no)}" title="{$social_pagedata.site_title}" rel="{$social_pagedata.site_title}">
          <img class="img-responsive" src="{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}" style="max-height: 75px">
        </a>
      </div>
    </div>
    <div class="col-xs-10">
      <div id="site-name-footer">
        <a href="{'/'|ezurl(no)}" title="{$social_pagedata.logo_title}"><h2>{$social_pagedata.logo_title}</h2></a>
      </div>
    </div>
  </div>
</section>
<!-- #footer -->
<footer id="footer" class="clearfix">
  <div class="container-fluid footer-container">
    <div class="row">
      <div class="col-md-4 col-sm-6">
        <h3>{'Contacts'|i18n('ocsocialdesign')}</h3>
        <p>{attribute_view_gui attribute=$social_pagedata.attribute_contacts}</p>
      </div>

      <div class="col-md-4 col-sm-6">
        <h3>&nbsp;</h3>
        <p>{attribute_view_gui attribute=$social_pagedata.attribute_footer}</p>
      </div>

      {*<div class="col-md-3 col-sm-6">
        <h3>Siti tematici</h3>
        <ul class="list-unstyled">
          <li><a href="#">Lorem ipsum dolor</a></li>
          <li><a href="#">Lorem ipsum dolor</a></li>
          <li><a href="#">Lorem ipsum dolor</a></li>
          <li><a href="#">Lorem ipsum dolor</a></li>
          <li><a href="#">Lorem ipsum dolor</a></li>
        </ul>
      </div>

      <div class="col-md-4 col-sm-6">
        <h3>Seguici su</h3>
        <p class="nav_social clearfix">
          <a href="#" title="Seguici su Twitter">
                        <span class="fa-stack fa-lg">
                          <span class="fa fa-circle fa-stack-2x"></span>
                          <span class="fa fa-twitter fa-stack-1x fa-inverse"></span>
                        </span><span class="sr-only">Twitter</span>
          </a>
          <a href="#" title="Seguici su Facebook">
                        <span class="fa-stack fa-lg">
                          <span class="fa fa-circle fa-stack-2x"></span>
                          <span class="fa fa-facebook fa-stack-1x fa-inverse"></span>
                        </span><span class="sr-only">Facebook</span>
          </a>
          <a href="#" title="Seguici su Youtube">
                        <span class="fa-stack fa-lg">
                          <span class="fa fa-circle fa-stack-2x"></span>
                          <span class="fa fa-youtube-play fa-stack-1x fa-inverse"></span>
                        </span><span class="sr-only">Youtube</span>
          </a>
        </p>
      </div>*}
    </div>
  </div>
</footer>
<!-- EOF #footer -->

<section id="subfooter" class="clearfix">
  <div class="container-fluid">
    <div class="row">
      <div class="col-md-12">
        <div class="content">
          <small>&copy; {currentdate()|datetime('custom', '%Y')} {$social_pagedata.text_credits|wash()}</small>
          {*<ul class="list-inline list-unstyled">
            <li><a href="#">Note legali</a></li>
            <li><a href="#">Privacy policy e cookie</a></li>
            <li><a href="#">Valutazione dei servizi</a></li>
            <li><a href="#">Statistiche di accesso</a></li>
            <li><a href="#">Feed RSS</a></li>
          </ul>*}
        </div>
      </div>
    </div>
  </div>
</section>
