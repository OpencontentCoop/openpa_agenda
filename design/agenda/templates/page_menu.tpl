<div class="collapse navbar-collapse">

  <ul class="nav pull-right navbar-nav">
    {def $avail_translation = language_switcher( $site.uri.original_uri)}
    {if $avail_translation|count()|gt(1)}
      {foreach $avail_translation as $siteaccess => $lang}
        <li>
          <a href={$lang.url|ezurl}>
            {if $siteaccess|eq($access_type.name)}
              <span class="label label-default" style="font-size: 100%">{$lang.text|wash}</span>
            {else}
              {$lang.text|wash}
            {/if}
          </a>
        </li>
      {/foreach}
    {/if}

    {foreach $social_pagedata.menu as $item}
        {if $item.has_children}
            <li class="dropdown">
                <a data-toggle="dropdown" class="dropdown-toggle"
                   href="{$item.url|ezurl(no)}">{$item.name|wash()}
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    {foreach $item.children as $child}
                        <li><a href="{$child.url|ezurl(no)}">{$child.name|wash()}</a></li>
                    {/foreach}
                </ul>
            </li>
        {else}
            <li>
                <a href="{$item.url|ezurl(no)}">
                    {if $item.highlight}<span class="label label-primary" style="font-size: 100%">{/if}
                        {$item.name|wash()}
                    {if $item.highlight}</span>{/if}
                </a>
            </li>
        {/if}
    {/foreach}



    {if $current_user.is_logged_in|not()}

      <li>
          {if is_login_enabled()}
            <a href="#login">
              <span class="label label-primary" style="font-size: 100%">
                  {'Login'|i18n('design/standard/user')}
              </span>
            </a>
          {else}
            <a href="{'user/login'|ezurl(no)}">
              <span class="label label-primary" style="font-size: 100%">
                  {'Login'|i18n('design/standard/user')}
              </span>
            </a>
          {/if}
      </li>

    {else}

      <li class="dropdown">
        <a data-toggle="dropdown" class="dropdown-toggle" href="#">
          {include uri='design:parts/user_image.tpl' object=$current_user.contentobject height=25 width=25}
          <span class="caret"></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-right">
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
