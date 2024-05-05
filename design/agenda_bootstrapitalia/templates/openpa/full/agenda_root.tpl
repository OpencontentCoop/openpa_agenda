{ezpagedata_set( 'has_container', true() )}

{def $social_pagedata = social_pagedata()}
{if $social_pagedata.banner_path}
<div class="it-hero-wrapper it-overlay it-bottom-overlapping-content it-hero-small-size">
    <div class="img-responsive-wrapper">
        <div class="img-responsive">
            <div class="img-wrapper"><img src="{$social_pagedata.banner_path|ezroot(no)}" {if $social_pagedata.banner_title|ne('')}title="{$social_pagedata.banner_title}"{/if} alt=""></div>
        </div>
    </div>
    {if or($social_pagedata.banner_title|ne(''), $social_pagedata.banner_subtitle|ne(''))}
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-hero-text-wrapper bg-dark pr-4">
                    <h1 class="no_toc">
                        {if $social_pagedata.banner_title|ne('')}
                        <span style="font-size: 1.3em;" class="d-inline-block py-2 px-3 bg-dark font-weight-normal m-0">{$social_pagedata.banner_title|wash()}</span>
                        {/if}
                        {if $social_pagedata.banner_subtitle|ne('')}
                        <span style="font-size: .8em;" class="d-inline-block py-2 px-3 bg-secondary font-weight-normal">{$social_pagedata.banner_subtitle|wash()}</span>
                        {/if}
                    </h1>
                </div>
            </div>
        </div>
    </div>
    {/if}
</div>
{/if}

<section class="container">
    <div class="row">
        <div class="col px-lg-4 py-lg-2" style="min-height: 200px">

            {include uri='design:openpa/full/parts/home-blocks.tpl'}

            {def $hide_tags = cond($node|has_attribute('hide_tags'), $node|attribute('hide_tags').content.tag_ids, array())
                 $hide_iniziative = array()}
            {if $node|has_attribute('hide_tags')}
                {set $hide_tags = $node|attribute('hide_tags').content.tag_ids}
            {/if}
            {if $node|has_attribute('hide_iniziative')}
                {foreach $node|attribute('hide_iniziative').content.relation_list as $item}
                    {set $hide_iniziative = $hide_iniziative|append($item.contentobject_id)}
                {/foreach}
            {/if}

            {def $agenda_query_custom = array()}
            {if count($hide_tags)|gt(0)}
                {foreach $hide_tags as $tag}
                    {set $agenda_query_custom = $agenda_query_custom|append(concat("tipo_evento.tag_ids != '", $tag, "'"))}
                {/foreach}
            {/if}
            {if count($hide_iniziative)|gt(0)}
                {foreach $hide_iniziative as $iniziativa}
                    {set $agenda_query_custom = $agenda_query_custom|append(concat("iniziativa.id != '", $iniziativa, "'"))}
                {/foreach}
            {/if}

            {def $hide_collections = cond($node|has_attribute('main_calendar_hide_collections'), $node|attribute('main_calendar_hide_collections').data_int, false())}
            {if $hide_collections}
                {set $agenda_query_custom = $agenda_query_custom|append('raw[extra_event_collection_i] = 0')}
            {/if}
            {def $view = 'dayGridWeek'
                 $views = array()}
            {if $node|has_attribute('main_calendar_agenda_view')}
                {foreach $node|attribute('main_calendar_agenda_view').class_content.options as $option}
                    {if $node|attribute('main_calendar_agenda_view').content|contains($option.id)}
                        {set $view = $option.name}
                    {/if}
                {/foreach}
            {/if}
            {if $node|has_attribute('main_calendar_views')}
                {foreach $node|attribute('main_calendar_views').class_content.options as $option}
                    {if $node|attribute('main_calendar_views').content|contains($option.id)}
                        {set $views = $views|append($option.name)}
                    {/if}
                {/foreach}
            {/if}
            {if count($views)|eq(0)}
                {set $views = array('grid','geo','agenda')}
            {/if}
            {include
                uri='design:parts/agenda.tpl'
                add_time_buttons=true()
                views=$views
                cal_view=$view
                base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] ', cond($agenda_query_custom|count()|gt(0), ' and ', false()), $agenda_query_custom|implode(' and '))
                style='bg-white rounded-top py-3 px-5'
            }

        </div>
    </div>
</section>


{include uri='design:parts/views.tpl' views=$views}

