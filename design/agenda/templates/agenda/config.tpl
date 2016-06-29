<section class="hgroup">
    <h1>{'Settings'|i18n('agenda/menu')}</h1>
</section>


<div class="row">
    <div class="col-md-12">
        <ul class="list-unstyled">
            <li>{'Modifica impostazioni generali'|i18n('agenda/config')} {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$root redirect_if_discarded='/agenda/config' redirect_after_publish='/agenda/config'}</li>
        </ul>
    </div>
</div>