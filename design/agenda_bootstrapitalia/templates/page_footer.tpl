<footer class="it-footer">
    <div class="it-footer-main">
        <div class="container">
            <section>
                <div class="row clearfix">
                    <div class="col-sm-12">
                        {if $pagedata.homepage|has_attribute('footer_logo')}
                            <div class="it-brand-wrapper">
                                <a href="{'/'|ezurl(no)}"
                                   title="{ezini('SiteSettings','SiteName')}">
                                    <img class="icon" style="width: auto !important;"
                                         alt="{ezini('SiteSettings','SiteName')}"
                                         src="{$pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no,full)}" />
                                </a>
                            </div>
                        {else}
                            {include uri='design:logo.tpl'}
                        {/if}
                    </div>
                </div>
            </section>

            {def $social_pagedata = social_pagedata()
                 $social_links = social_links()}
            {def $has_social = cond(or(
                        is_set($social_links.facebook),
                        is_set($social_links.twitter),
                        is_set($social_links.linkedin),
                        is_set($social_links.instagram),
                        is_set($social_links.youtube)
                    ), true(), false())}

            <section class="pb-4">
                <div class="row">

                    <div class="col pb-2">
                        <h4><span>{'Informations'|i18n('openpa/footer')}</span></h4>
                        <p>{attribute_view_gui attribute=$social_pagedata.attribute_footer}</p>
                    </div>

                    <div class="col pb-2">
                        <h4><span>{'Contacts'|i18n('openpa/footer')}</span></h4>
                        <p>{attribute_view_gui attribute=$social_pagedata.attribute_contacts}</p>
                    </div>

                    {if $has_social}
                    <div class="col pb-2">
                        <h4><span>{'Follow us'|i18n('openpa/footer')}</span></h4>
                        {include uri='design:footer/social.tpl'}
                    </div>
                    {/if}

                    {if and(ezmodule('newsletter','subscribe'), has_newsletter())}
                        <div class="col pb-2">
                            <h4><span>Newsletter</span></h4>
                            {include uri='design:footer/newsletter_subscribe.tpl'}
                        </div>
                    {/if}
                </div>
            </section>

        </div>
    </div>
    <div class="it-footer-small-prints clearfix">
        <div class="container">
            <ul class="it-footer-small-prints-list list-inline mb-0 d-flex flex-column flex-md-row">
                <li class="list-inline-item">
                    <a href="{'agenda/info/faq'|ezurl(no)}"
                       title="{'FAQ'|i18n('agenda/menu')}">
                        {'FAQ'|i18n('agenda/menu')}
                    </a>
                </li>
                <li class="list-inline-item">
                    <a href="{'agenda/info/privacy'|ezurl(no)}"
                       title="{'Privacy'|i18n('agenda/menu')}">
                        {'Privacy'|i18n('agenda/menu')}
                    </a>
                </li>
                <li class="list-inline-item">
                    <a href="{'agenda/info/terms'|ezurl(no)}"
                       title="{'Terms of use'|i18n('agenda/menu')}">
                        {'Terms of use'|i18n('agenda/menu')}
                    </a>
                </li>
                {*<li class="list-inline-item">
                    <a href="{'agenda/stat'|ezurl(no)}"
                       title="{'Statistics'|i18n('agenda/stat')}">
                        {'Statistics'|i18n('agenda/stat')}
                    </a>
                </li>*}
                {def $needCookieConsent = cond(or(
                    and( openpaini('Seo', 'GoogleAnalyticsAccountID'), openpaini('Seo', 'GoogleCookieless')|eq('disabled') ),
                    and( openpaini('Seo', 'webAnalyticsItaliaID'), openpaini('Seo', 'WebAnalyticsItaliaCookieless')|eq('disabled') ),
                    openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled')
                    ), true(), false())}
                {if and(openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced'), $needCookieConsent)}
                    <li class="list-inline-item">
                        <a href="{'openpa/cookie'|ezurl(no)}" title="{'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}">{'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}</a>
                    </li>
                {undef $needCookieConsent}
            </ul>
        </div>
    </div>
    <div class="container">
        <div class="container text-secondary x-small mt-1 mb-1 text-right">
            &copy; {currentdate()|datetime( 'custom', '%Y' )} {$social_pagedata.site_title|wash()}
            powered by
            <a href="{openpaini('CreditsSettings', 'Url', 'http://www.opencontent.it/openpa')}" title="{openpaini('CreditsSettings', 'Title', 'OpenPA - Strumenti di comunicazione per la pubblica amministrazione')}">
                {openpaini('CreditsSettings', 'Name', 'OpenCity')} {if openpaini('CreditsSettings', 'CodeVersion', false())}<a href="{openpaini('CreditsSettings', 'CodeUrl', false())}">{openpaini('CreditsSettings', 'CodeVersion', false())}</a>{/if}
            </a>
            &#8212; concept & design based on <a class="text-decoration-none" href="https://designers.italia.it/kit/comuni/">{display_icon('it-designers-italia', 'svg', 'icon icon-xs icon-primary')} Designers Italia</a>
        </div>
    </div>
</footer>


<a href="#" aria-hidden="true" data-attribute="back-to-top" class="back-to-top shadow">
    {display_icon('it-arrow-up', 'svg', 'icon icon-light')}
</a>

{undef $social_pagedata $has_social}
