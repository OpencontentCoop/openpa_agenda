{*
<header>
    <div class="container">
        <div class="navbar navbar-default" role="navigation" style="position: relative; z-index: 10;">
            <div class="navbar-header">
                {if is_header_only_logo_enabled()}
                    <a href="{'/'|ezurl(no)}">
                        <img src="{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}" style="max-height: 90px" />
                        <span class="hide" style="display: none">{$social_pagedata.logo_title} - {$social_pagedata.logo_subtitle}</span>
                    </a>
                {else}
                    <a class="navbar-brand" href="{'/'|ezurl(no)}">
                        <img src="{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}" height="90" width="90">
                        <span class="logo_title">{$social_pagedata.logo_title}</span>
                        <span class="logo_subtitle">{$social_pagedata.logo_subtitle}</span>
                    </a>
                {/if}
                <a class="btn btn-navbar btn-default navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="nb_left pull-left">
                        <span class="fa fa-reorder"></span>
                    </span>
                    <span class="nb_right pull-right">Menu</span>
                </a>
            </div>
            {include uri='design:page_menu.tpl'}
        </div>
    </div>
</header>
*}
<div class="navmenu navmenu-default navmenu-fixed-left offcanvas">
  <ul class="nav navmenu-nav">
    {foreach $social_pagedata.menu as $item}
      {if $item.has_children}
        <li class="dropdown">
          <a data-toggle="dropdown" class="dropdown-toggle" data-toggle="dropdown" href="{$item.url|ezurl(no)}">
            {$item.name|wash()}
            <b class="caret"></b>
          </a>
          <ul class="dropdown-menu  navmenu-nav">
            {foreach $item.children as $child}
              <li><a href="{$child.url|ezurl(no)}">{$child.name|wash()}</a></li>
            {/foreach}
          </ul>
        </li>
      {else}
        <li>
          <a href="{$item.url|ezurl(no)}">
            {if $item.highlight}{/if}
            {$item.name|wash()}
            {if $item.highlight}{/if}
          </a>
        </li>
      {/if}
    {/foreach}
    {if $current_user.is_logged_in|not()}

      <li>
        <a href="#login">
          {'Accedi'|i18n('ocsocialdesign/menu')}
        </a>
      </li>

    {else}

      <li class="dropdown">
        <a data-toggle="dropdown" class="dropdown-toggle" href="#">
          {include uri='design:parts/user_image.tpl' object=$current_user.contentobject height=25 width=25}
          <span class="caret"></span>
        </a>
        <ul class="dropdown-menu navmenu-nav">
          <li>
          <span style="text-transform: none;padding: 3px 20px;display: block;background: #eee;"><small>{$current_user.contentobject.name|wash()}
              <br/>{$current_user.email|shorten(40)|wash()}</small></span>
          </li>
          {foreach $social_pagedata.user_menu as $item}
            <li><a href="{$item.url|ezurl(no)}">{$item.name|wash()}</a></li>
          {/foreach}
        </ul>
      </li>

    {/if}
  </ul>
</div>
<header id="header">
  <div id="header-top">
    <div class="container-fluid">
      <div class="row">
          <div id="header-top-left" class="col-md-7 col-md-offset-2 col-xs-7 col-xs-offset-2">
            <span>&nbsp;</span>
          </div>
          <div id="header-top-right" class="col-md-3 col-xs-3">
            {def $avail_translation = language_switcher( $site.uri.original_uri)}
            {if $avail_translation|count()|gt(1)}
              <ul class="nav navbar-nav pull-right">
                {foreach $avail_translation as $siteaccess => $lang}
                  <li {if $siteaccess|eq($access_type.name)}class="active"{/if}>
                    <a href={$lang.url|ezurl}>
                      {$lang.text|wash}
                    </a>
                  </li>
                {/foreach}
              </ul>
            {/if}
          </div>
        </div>
      </div>
    </div>
  </div>


  <div id="header-inside" class="clearfix">
    <div class="container-fluid">
      <div class="row">
        <div class="col-xs-2">
          <h2 class="sr-only">Menu principale</h2>
          <div class="burger-wrapper">
            <div class="burger-container">
              <!--<button id="showLeftPush">Show/Hide Left Push Menu</button>-->
              <a class="toggle-menu" data-toggle="offcanvas" data-target=".navmenu" data-canvas="body">
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
              </a>
            </div>
          </div>
        </div>
        <div class="col-xs-7">
          <div id="logo" class="clearfix">
            <a href="{'/'|ezurl(no)}" title="{$social_pagedata.site_title}" rel="{$social_pagedata.site_title}">
              <img class="img-responsive" src="{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}" style="max-height: 75px" height="75">
            </a>
          </div>
          <div id="site-name" class="clearfix">
            <a href="{'/'|ezurl(no)}" title="{$social_pagedata.logo_title}"><h1>{$social_pagedata.logo_title}</h1></a>
            <span class="logo_subtitle">{$social_pagedata.logo_subtitle}</span>
          </div>
        </div>

        <div class="col-xs-3">
          {*<h2 class="sr-only title">Motore di ricerca</h2>
          <form action="#" method="post" accept-charset="UTF-8">
            <div class="input-group hidden-xs hidden-sm">
              <input type="text" class="form-control" placeholder="Cerca">
              <span class="input-group-btn">
                                <button class="btn btn-secondary btn-search" type="submit"><i class="fa fa-search" aria-hidden="true"></i></button>
                            </span>
            </div>
            <button id="show-form-search" class="btn btn-secondary hidden-md hidden-lg pull-right" type="button"><i class="fa fa-search" aria-hidden="true"></i></button>
          </form>*}
        </div>
        <div id="mobile-search" class="col-xs-12 hidden-md hidden-lg hidden">
          <form action="#" method="post" accept-charset="UTF-8">
            <div class="input-group">
              <input type="text" class="form-control" placeholder="Cerca">
              <span class="input-group-btn">
                  <button class="btn btn-secondary btn-search" type="submit"><i class="fa fa-search" aria-hidden="true"></i></button>
              </span>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <div id="nav-aree" class="container-fluid clearfix">
    <div class="row">
      <div class="no-pad-b">
        <h2 class="sr-only">Sezioni principali</h2>
        {include uri='design:page_menu.tpl'}
      </div>
      <!--<div class="col-xs-6 no-pad-b">
          <h2 class="sr-only">Accesso ai servizi</h2>
          <ul class="nav nav-pills pull-right">
              <li><a href="#"><i class="fa fa-user" aria-hidden="true"></i> Accesso ai servizi</a></li>
          </ul>
      </div>-->
    </div>
  </div>
</header>
