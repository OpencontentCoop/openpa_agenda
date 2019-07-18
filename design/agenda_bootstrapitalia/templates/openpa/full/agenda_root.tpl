{ezpagedata_set( 'has_container', true() )}

{def $social_pagedata = social_pagedata()}
{if and($social_pagedata.banner_path, $social_pagedata.banner_title|ne(''))}
<div class="it-hero-wrapper it-overlay it-bottom-overlapping-content it-hero-small-size">
    <div class="img-responsive-wrapper">
        <div class="img-responsive">
            <div class="img-wrapper"><img src="{$social_pagedata.banner_path|ezroot(no)}" title="{$social_pagedata.banner_title}" alt=""></div>
        </div>
    </div>
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-hero-text-wrapper bg-dark pr-4">
                    <h1 class="no_toc">
                        <span style="font-size: 1.3em;" class="d-inline-block py-2 px-3 bg-dark font-weight-normal m-0">{$social_pagedata.banner_title|wash()}</span>
                        <span style="font-size: .8em;" class="d-inline-block py-2 px-3 bg-secondary font-weight-normal">{$social_pagedata.banner_subtitle|wash()}</span>
                    </h1>
                </div>
            </div>
        </div>
    </div>
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

            {include
                uri='design:parts/agenda.tpl'
                views=array('grid','geo','agenda')
                base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] ', cond($agenda_query_custom|count()|gt(0), ' and ', false()), $agenda_query_custom|implode(' and '))
                style='bg-white rounded-top py-3 px-5'
            }

        </div>
    </div>
</section>


{include uri='design:parts/views.tpl' views=array('grid','geo','agenda')}

