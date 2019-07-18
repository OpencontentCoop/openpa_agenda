{* todo topics *}
{def $social_pagedata = social_pagedata()
     $topics = false()
     $topic_list = array()
     $selected_topic_list = array()}

<div class="it-header-navbar-wrapper{* theme-light*}">
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
                                               title="{'Got to page:'|i18n('openpa_bootstrapitalia')} {$item.name|wash()}">
                                                <span>{$item.name|wash()}</span>
                                            </a>
                                        </li>
                                    {/foreach}
                                    {undef $items}
                                {/foreach}
                            </ul>

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
                                               title="{'Do you want to register your association?'|i18n('agenda/signupassociazione')}"
                                               href="{'agenda/register_associazione'|ezurl(no)}">
                                                <span>{'Register an association'|i18n('agenda/signupassociazione')}</span>
                                            </a>
                                        </li>
                                    {/if}
                                </ul>
                            {/if}

                            {*if or(count($topic_list)|gt(0), count($selected_topic_list)|gt(0))}
                                <ul class="navbar-nav navbar-secondary">
                                    {if count($selected_topic_list)|gt(0)}
                                        {foreach $selected_topic_list as $selected_topic max 3}
                                            <li class="nav-item">
                                                <a class="nav-link text-truncate"
                                                   href="{$selected_topic.url_alias|ezurl(no)}">
                                                    <span>{$selected_topic.name|wash()}</span>
                                                </a>
                                            </li>
                                        {/foreach}
                                    {else}
                                        {foreach $topic_list.children as $child max 3}
                                            <li class="nav-item">
                                                <a class="nav-link text-truncate" href="{$child.item.url|ezurl(no)}">
                                                    <span>{$child.item.name|wash()}</span>
                                                </a>
                                            </li>
                                        {/foreach}
                                    {/if}
                                    <li class="nav-item">
                                        <a class="nav-link text-truncate"
                                           href="{$topics.main_node.url_alias|ezurl(no)}">
                                            <span
                                                class="font-weight-bold">{'Tutti gli argomenti...'|i18n('openpa_bootstrapitalia')}</span>
                                        </a>
                                    </li>
                                </ul>
                            {/if*}

                        </div>
                    </div>
                </nav>
            </div>
        </div>
    </div>
</div>

{undef $selected_topic_list $topics $topic_list $social_pagedata}
