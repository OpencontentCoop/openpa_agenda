{cache-block keys=array( $module_result.content_info.persistent_variable.agenda_home )}
{if is_set($social_pagedata)|not()}{def $social_pagedata = social_pagedata()}{/if}
{if and( is_set( $module_result.content_info.persistent_variable.agenda_home ), $social_pagedata.banner_path, $social_pagedata.banner_title|ne('') )}
    <div class="full_page_photo hidden-xs" style='background-image: url({$social_pagedata.banner_path|ezroot()});'>
        <div class="container">
            <section class="call_to_action">
                <h3 class="animated bounceInDown">{$social_pagedata.banner_title}</h3>
                <h4 class="animated bounceInUp skincolored">{$social_pagedata.banner_subtitle}</h4>
            </section>
        </div>
    </div>
{/if}
{/cache-block}