{if agenda_root()|has_attribute('layout')}
    {attribute_view_gui attribute=agenda_root()|attribute('layout')}
{elseif agenda_root()|has_attribute('main_events')}
    {def $main_events = array()}
    {foreach agenda_root()|attribute('main_events').content.relation_list as $item}
        {set $main_events = $main_events|append($item.contentobject_id)}
    {/foreach}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', array(
    page_block(
        "",
        "OpendataRemoteContents",
        "default",
        hash(
            "remote_url", "",
            "query", concat("id in [", $main_events|implode(','), "]"),
            "show_grid", "1",
            "show_map", "0",
            "show_search", "0",
            "limit", count($main_events),
            "items_per_row", "3",
            "facets", "",
            "view_api", "banner",
            "color_style", "",
            "fields", "",
            "template", "",
            "simple_geo_api", "0",
            "input_search_placeholder", ""
        )
    )

    )))}
{/if}

{def $has_latest_program = latest_program()}

<div class="row home-teaser hidden-xs" style="justify-content: space-around;">
{if is_collaboration_enabled()}
    {if $has_latest_program}
        {def $download_url = concat( '/content/download/', $has_latest_program.contentobject_id, '/', $has_latest_program.data_map['file'].id,'/version/', $has_latest_program.data_map['file'].version , '/file/', $has_latest_program.data_map['file'].content.original_filename|urlencode )}
        <div class="col" style="max-width:50%">
            <div class="card-wrapper card-space pb-2">
                <div class="card card-bg card-big rounded shadow no-after bg-success m-0">
                    <div class="card-body p-3">
                        <h5 class="card-title mb-0">
                            <a class="stretched-link text-white text-decoration-none" href="{$download_url|ezurl(no)}"><b>{'Programme'|i18n('agenda')}</b></a>
                        </h5>
                        <p class="card-text text-white text-sans-serif pt-0">
                            {if agenda_root()|has_attribute('testo_download_programma')}
                                {agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}
                            {else}
                                {'Download the pdf programme'|i18n('agenda')}
                            {/if}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    {/if}
    <div class="col" style="max-width:50%">
        <div class="card-wrapper card-space pb-2">
            <div class="card card-bg card-big rounded shadow no-after bg-secondary m-0">
                <div class="card-body p-3">
                    <h5 class="card-title mb-0">
                        <a class="stretched-link text-white text-decoration-none" href="{concat('content/view/full/',associazioni_root_node_id())|ezurl(no)}"><b>{'Address Book'|i18n('agenda')}</b> {'Organizations'|i18n('agenda')}</a>
                    </h5>
                    <p class="card-text text-white text-sans-serif pt-0">
                        {if agenda_root()|has_attribute('testo_rubrica_associazioni')}
                            {agenda_root()|attribute('testo_rubrica_associazioni').data_text|wash( xhtml )}
                        {else}
                            {'Official Register of the town'|i18n('agenda')}
                        {/if}
                    </p>
                </div>
            </div>
        </div>
    </div>
    {if is_auto_registration_enabled()}
    <div class="col" style="max-width:50%">
        <div class="card-wrapper card-space pb-2">
            <div class="card card-bg card-big rounded shadow no-after bg-danger m-0">
                <div class="card-body p-3">
                    <h5 class="card-title mb-0">
                        <a class="stretched-link text-white text-decoration-none" href="{'agenda/info/faq/'|ezurl(no)}">{"Are you an organization?"|i18n('agenda')}</a>
                    </h5>
                    <p class="card-text text-white  text-sans-serif pt-0">
                        {if agenda_root()|has_attribute('testo_partecipa_associazioni')}
                            {agenda_root()|attribute('testo_partecipa_associazioni').data_text|wash( xhtml )}
                        {else}
                            {'Find out how to participate!'|i18n('agenda')}
                        {/if}
                    </p>
                </div>
            </div>
        </div>
    </div>
    {/if}


{elseif $has_latest_program}

    <div class="col-md-6 col-lg-4 offset-md-6 offset-lg-8">
        <div class="card-wrapper card-space">
            <div class="card card-bg card-big rounded shadow no-after bg-success">
                <div class="card-body p-3">
                    <h5 class="card-title mb-0">
                        <a class="stretched-link text-white text-decoration-none" href="{'agenda/download/'|ezurl(no)}"><b>{'Programme'|i18n('agenda')}</b></a>
                    </h5>
                    <p class="card-text text-white text-sans-serif pt-0">
                        {if agenda_root()|has_attribute('testo_download_programma')}
                            {agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}
                        {else}
                            {'Download the pdf programme'|i18n('agenda')}
                        {/if}
                    </p>
                </div>
            </div>
        </div>
    </div>

{/if}
</div>
