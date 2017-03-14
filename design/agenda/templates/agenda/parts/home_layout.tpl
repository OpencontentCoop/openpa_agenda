{if agenda_root()|has_attribute('layout')}
    {attribute_view_gui attribute=agenda_root()|attribute('layout')}
{/if}

{if is_collaboration_enabled()}
    <div class="row home-teaser hidden-xs">
        {if latest_program()}
            <div class="col-sm-4">
                <div class="service_teaser vertical">
                    <div class="service_photo">
                        <h2 class="section_header gradient-background"><a href="{'agenda/download/'|ezurl(no)}"><b>{'Programma'|i18n('agenda')}</b></a> <small>{'Scarica il programma in pdf'|i18n('agenda')}</small></h2>
                    </div>
                </div>
            </div>
        {/if}
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/associazioni/'|ezurl(no)}"><b>{'Rubrica'|i18n('agenda')}</b> {'associazioni'|i18n('agenda')}</a> <small>{'Registro ufficiale del comune'|i18n('agenda')}</small></h2>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="service_teaser vertical">
                <div class="service_photo">
                    <h2 class="section_header gradient-background"><a href="{'agenda/info/faq/'|ezurl(no)}"">{"Sei un'<b>associazione</b>?"|i18n('agenda')}</a> <small>{'Scopri come partecipare!'|i18n('agenda')}</small></h2>
                </div>
            </div>
        </div>
    </div>

{elseif latest_program()}

    <div class="text-center">
        <a class="btn btn-success btn-lg" href="{'agenda/download/'|ezurl(no)}">
            <strong>{'Programma'|i18n('agenda')}</strong><br />
            <small>{'Scarica il programma in pdf'|i18n('agenda')}</small>
        </a>
    </div>

    <hr />

{/if}
