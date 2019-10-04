{if agenda_root()|has_attribute('layout')}
    {attribute_view_gui attribute=agenda_root()|attribute('layout')}
{/if}

{def $has_latest_program = latest_program()}

<div class="row home-teaser hidden-xs">
{if is_collaboration_enabled()}
    {if $has_latest_program}
        {def $download_url = concat( '/content/download/', $has_latest_program.contentobject_id, '/', $has_latest_program.data_map['file'].id,'/version/', $has_latest_program.data_map['file'].version , '/file/', $has_latest_program.data_map['file'].content.original_filename|urlencode )}
        <div class="col-md-8  col-lg-4">
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
    <div class="col-md-7 col-lg-{if $has_latest_program|not}6{else}4{/if}">
        <div class="card-wrapper card-space pb-2">
            <div class="card card-bg card-big rounded shadow no-after bg-secondary m-0">
                <div class="card-body p-3">
                    <h5 class="card-title mb-0">
                        <a class="stretched-link text-white text-decoration-none" href="{concat('content/view/full/',associazioni_root_node_id())|ezurl(no)}"><b>{'Address Book'|i18n('agenda')}</b> {'Associations'|i18n('agenda')}</a>
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
    <div class="col-md-5 col-lg-{if $has_latest_program|not}6{else}4{/if}">
        <div class="card-wrapper card-space pb-2">
            <div class="card card-bg card-big rounded shadow no-after bg-danger m-0">
                <div class="card-body p-3">
                    <h5 class="card-title mb-0">
                        <a class="stretched-link text-white text-decoration-none" href="{'agenda/info/faq/'|ezurl(no)}">{"Are you an association?"|i18n('agenda')}</a>
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
