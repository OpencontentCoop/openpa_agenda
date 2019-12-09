{if agenda_root()|has_attribute('layout')}
    {attribute_view_gui attribute=agenda_root()|attribute('layout')}
{/if}

{def $has_latest_program = latest_program()}

{if is_collaboration_enabled()}
    <div class="row home-teaser hidden-xs">
        {if $has_latest_program}
            <div class="col-md-4">
                <div class="service_teaser vertical">
                    <div class="service_photo">
                        <h2 class="section_header gradient-background">
                            <a href="{'agenda/download/'|ezurl(no)}"><b>{'Programme'|i18n('agenda')}</b></a>
                            {if agenda_root()|has_attribute('testo_download_programma')}
                                <small>{agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}</small>
                            {else}
                                <small>{'Download the pdf programme'|i18n('agenda')}</small>
                            {/if}
                        </h2>
                    </div>
                </div>
            </div>
        {/if}
        <div class="col-sm-6 col-md-{if $has_latest_program}4{else}6{/if}">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background">
                        <a href="{'agenda/associazioni/'|ezurl(no)}"><b>{'Address Book'|i18n('agenda')}</b> {'Organizations'|i18n('agenda')}</a>
                        {if agenda_root()|has_attribute('testo_rubrica_associazioni')}
                            <small>{agenda_root()|attribute('testo_rubrica_associazioni').data_text|wash( xhtml )}</small>
                        {else}
                            <small>{'Official Register of the town'|i18n('agenda')}</small>
                        {/if}
                    </h2>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-md-{if $has_latest_program}4{else}6{/if}">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background">
                        <a href="{'agenda/info/faq/'|ezurl(no)}">{"Are you an organization?"|i18n('agenda')}</a>
                        {if agenda_root()|has_attribute('testo_partecipa_associazioni')}
                            <small>{agenda_root()|attribute('testo_partecipa_associazioni').data_text|wash( xhtml )}</small>
                        {else}
                            <small>{'Find out how to participate!'|i18n('agenda')}</small>
                        {/if}
                    </h2>
                </div>
            </div>
        </div>
    </div>

{elseif $has_latest_program}

    <div class="text-center">
        <a class="btn btn-success btn-lg" href="{'agenda/download/'|ezurl(no)}">
            <strong>{'Programme'|i18n('agenda')}</strong><br />
            {if agenda_root()|has_attribute('testo_download_programma')}
                <small>{agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}</small>
            {else}
                <small>{'Download the pdf programme'|i18n('agenda')}</small>
            {/if}
        </a>
    </div>

    <hr />

{/if}
