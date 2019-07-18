<div class="it-brand-wrapper">
{def $only_logo = is_header_only_logo_enabled()
     $social_pagedata = social_pagedata()}
<a href={"/"|ezurl} title="{ezini('SiteSettings','SiteName')}">
    <img class="icon"
         src="{$social_pagedata.logo_path|ezroot(no)}" alt="{$social_pagedata.site_title}"
         {if $only_logo}style="width: auto !important;"{/if}/>
    {if $only_logo|not()}
    <div class="it-brand-text">
        <h2 class="no_toc">{$social_pagedata.logo_title}</h2>
        <h3 class="no_toc d-none d-md-block">
          {$social_pagedata.logo_subtitle}
        </h3>
    </div>
    {/if}
</a>
{undef $only_logo $social_pagedata}
</div>
