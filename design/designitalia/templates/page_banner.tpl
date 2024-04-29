{if is_set($social_pagedata)|not()}{def $social_pagedata = social_pagedata()}{/if}
{if is_set( $module_result.content_info.persistent_variable.agenda_home )}
    {if openpaini('OpenpaAgenda', 'ForceBannerUrl', '')|ne('')}
        <div class="full_page_photo hidden-xs" style='background-image: url({openpaini('OpenpaAgenda', 'ForceBannerUrl')});height: 400px;'>
        </div>
    {elseif $social_pagedata.banner_path}
        <div class="full_page_photo hidden-xs" style='background-image: url({$social_pagedata.banner_path|ezroot()});'>
            {if $social_pagedata.banner_title|ne('')}
            <div class="container">
                <section class="call_to_action">
                    <h3 class="animated bounceInDown">{$social_pagedata.banner_title}</h3>
                    <h4 class="animated bounceInUp skincolored">{$social_pagedata.banner_subtitle}</h4>
                </section>
            </div>
            {/if}
        </div>
    {/if}
{/if}
