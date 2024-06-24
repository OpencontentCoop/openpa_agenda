{* todo topics *}
{def $social_pagedata = social_pagedata()
     $topics = false()
     $topic_list = array()
     $selected_topic_list = array()}

<div class="it-header-navbar-wrapper{if current_theme_has_variation('light_navbar')} theme-light theme-light-desk border-bottom"{/if}">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <nav class="navbar navbar-expand-lg has-megamenu">
                    <button class="custom-navbar-toggler"
                            type="button"
                            aria-controls="main-menu"
                            aria-expanded="false"
                            aria-label="Toggle navigation"
                            data-target="#main-menu">
                        {display_icon('it-burger', 'svg', 'icon')}
                    </button>
                    <div class="navbar-collapsable" id="main-menu">
                        <div class="overlay"></div>
                        <div class="menu-wrapper">
                            <div class="close-div">
                                <button class="btn close-menu" type="button">
                                    {display_icon('it-close-circle', 'svg', 'icon')}
                                </button>
                            </div>
                            <ul class="navbar-nav">
                                {foreach $social_pagedata.menu as $item}
                                    {def $items = array($item)}
                                    {if and(is_set($item.has_children), $item.has_children)}
                                        {set $items = $item.children}
                                    {/if}
                                    {foreach $items as $item}
                                        <li class="nav-item">
                                            <a class="main-nav-link nav-link text-truncate"
                                               href="{$item.url|ezurl(no)}"
                                               title="{$item.name|wash()}">
                                                <span>{$item.name|wash()}</span>
                                            </a>
                                        </li>
                                    {/foreach}
                                    {undef $items}
                                {/foreach}
                            </ul>

                            {if fetch(user, current_user).is_logged_in}
                                <ul class="navbar-nav navbar-secondary">
                                    <li class="nav-item">
                                        <a class="nav-link text-truncate btn btn-success rounded-0 text-white"
                                           href="{'editorialstuff/add/agenda'|ezurl(no)}">
                                            <span><i class="fa fa-plus mr-2"></i> {ezini( 'agenda', 'CreationButtonText', 'editorialstuff.ini' )|i18n('agenda/dashboard')}</span>
                                        </a>
                                    </li>
                                </ul>
                            {else}
                                {if or(is_registration_enabled(), is_auto_registration_enabled())}
                                    <ul class="navbar-nav navbar-secondary">
                                        {if is_registration_enabled()}
                                        <li class="nav-item">
                                            <a class="nav-link text-truncate btn btn-dark rounded-0 text-white"
                                               title="{'Are you not registered yet?'|i18n('social_user/signup')}"
                                               href="{'user/register'|ezurl(no)}">
                                                <span>{'Subscribe'|i18n('agenda/signup')}</span>
                                            </a>
                                        </li>
                                        {/if}
                                        {if is_auto_registration_enabled()}
                                            <li class="nav-item">
                                                <a class="nav-link text-truncate btn btn-danger rounded-0 text-white"
                                                   title="{'Do you want to register your organization?'|i18n('agenda/signupassociazione')}"
                                                   href="{'agenda/register_associazione'|ezurl(no)}">
                                                    <span>{'Register an organization'|i18n('agenda/signupassociazione')}</span>
                                                </a>
                                            </li>
                                        {/if}
                                    </ul>
                                {/if}
                            {/if}

                        </div>
                    </div>
                </nav>
            </div>
        </div>
    </div>
</div>

{undef $selected_topic_list $topics $topic_list $social_pagedata}
