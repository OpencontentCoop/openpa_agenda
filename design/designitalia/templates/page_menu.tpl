{*<ul class="nav nav-pills">
  <li><a href="#"><i class="fa fa-tachometer" aria-hidden="true"></i> Dashboard</a></li>
  <li><a href="#"><i class="fa fa-user" aria-hidden="true"></i> Profilo</a></li>
  <li><a href="#"><i class="fa fa-files-o" aria-hidden="true"></i> Pratiche</a></li>
</ul>*}

<ul class="nav nav-pills">
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
