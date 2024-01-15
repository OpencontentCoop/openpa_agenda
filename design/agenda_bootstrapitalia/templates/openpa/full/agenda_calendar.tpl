{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
<div class="it-hero-wrapper it-wrapped-container">
    {if $node|has_attribute('image')}
        <div class="img-responsive-wrapper">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {attribute_view_gui attribute=$node|attribute('image') image_class=reference}
                </div>
            </div>
        </div>
    {/if}

    <div class="container">
        <div class="row">
            <div class="col-12 px-lg-5">
                <div class="it-hero-card it-hero-bottom-overlapping px-2 px-lg-5 py-2 py-lg-5 rounded shadow">
                    <div class="container">
                        <div class="row">
                            <div class="col">
                                <nav class="breadcrumb-container" aria-label="breadcrumb">
                                    <ol class="breadcrumb">
                                        <li class="breadcrumb-item">
                                            <a href="{'/'|ezurl(no)}">{agenda_root().name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item">
                                            <a href="{$node.parent.url_alias|ezurl(no)}">{$node.parent.name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item active" aria-current="page">
                                            {$node.name|wash()}
                                        </li>
                                    </ol>
                                </nav>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <h1>{$node.name|wash()}</h1>
                                <p>{attribute_view_gui attribute=$node|attribute('abstract')}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{def $tag_filter = ''}
{if $node|has_attribute('calendar_types')}
    {set $tag_filter = concat( "raw[ezf_df_tag_ids] in [", $node|attribute('calendar_types').content.tag_ids|implode(","), "]")}
{/if}


<div class="section section-muted section-inset-shadow p-0">
    <div class="section-content">
        {include
            uri='design:parts/agenda.tpl'
            exclude=array('what')
            views=array('grid','geo','agenda')
            base_query=concat("classes [",agenda_event_class_identifier(),"] and ", $tag_filter, " and subtree [", calendar_node_id(), "] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc]")
            style='section'}
        {include uri='design:parts/views.tpl' views=array('grid','geo','agenda')}
    </div>
</div>
