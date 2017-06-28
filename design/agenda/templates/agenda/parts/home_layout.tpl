{if agenda_root()|has_attribute('layout')}
    {attribute_view_gui attribute=agenda_root()|attribute('layout')}
{/if}

{if is_collaboration_enabled()}
    <div class="row home-teaser hidden-xs">
        {if latest_program()}
            <div class="col-sm-4">
                <div class="service_teaser vertical">
                    <div class="service_photo">
                        <h2 class="section_header gradient-background">
                            <a href="{'agenda/download/'|ezurl(no)}"><b>{'Programma'|i18n('agenda')}</b></a>
                            {if agenda_root()|has_attribute('testo_download_programma')}
                                <small>{agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}</small>
                            {else}
                                <small>{'Scarica il programma in pdf'|i18n('agenda')}</small>
                            {/if}
                        </h2>
                    </div>
                </div>
            </div>
        {/if}
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background">
                        <a href="{'agenda/associazioni/'|ezurl(no)}"><b>{'Rubrica'|i18n('agenda')}</b> {'associazioni'|i18n('agenda')}</a>
                        {if agenda_root()|has_attribute('testo_rubrica_associazioni')}
                            <small>{agenda_root()|attribute('testo_rubrica_associazioni').data_text|wash( xhtml )}</small>
                        {else}
                            <small>{'Registro ufficiale del comune'|i18n('agenda')}</small>
                        {/if}
                    </h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background">
                        <a href="{'agenda/info/faq/'|ezurl(no)}">{"Sei un'<b>associazione</b>?"|i18n('agenda')}</a>
                        {if agenda_root()|has_attribute('testo_partecipa_associazioni')}
                            <small>{agenda_root()|attribute('testo_partecipa_associazioni').data_text|wash( xhtml )}</small>
                        {else}
                            <small>{'Registro ufficiale del comune'|i18n('agenda')}</small>
                        {/if}
                    </h2>
                </div>
            </div>
        </div>
    </div>

{elseif latest_program()}

    <div class="text-center">
        <a class="btn btn-success btn-lg" href="{'agenda/download/'|ezurl(no)}">
            <strong>{'Programma'|i18n('agenda')}</strong><br />
            {if agenda_root()|has_attribute('testo_download_programma')}
                <small>{agenda_root()|attribute('testo_download_programma').data_text|wash( xhtml )}</small>
            {else}
                <small>{'Scarica il programma in pdf'|i18n('agenda')}</small>
            {/if}
        </a>
    </div>

    <hr />

{/if}
