<section class="hgroup">
    <h1>{'Settings'|i18n('agenda/menu')}</h1>
</section>


<div class="row">
    <div class="col-md-12">
        <ul class="list-unstyled">
            <li>{'Modifica impostazioni generali'|i18n('agenda/config')} {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$root redirect_if_discarded='/agenda/config' redirect_after_publish='/agenda/config'}</li>
        </ul>

        <hr />

        <div class="row">

            <div class="col-md-3">
              <ul class="nav nav-pills nav-stacked">
                <li role="presentation" {if $current_part|eq('users')}class="active"{/if}><a href="{'agenda/config/users'|ezurl(no)}">{'Utenti'|i18n('agenda/config')}</a></li>
              <li role="presentation" {if $current_part|eq('moderators')}class="active"{/if}><a href="{'agenda/config/moderators'|ezurl(no)}">{'Moderatori'|i18n('agenda/config')}</a></li>
              </ul>
            </div>

            <div class="col-md-9">

              {if $current_part|eq('moderators')}
              <div class="tab-pane active" id="moderators">
                <form class="form-inline" action="{'agenda/config/moderators'|ezurl(no)}">
                  <div class="form-group">
                    <input type="text" class="form-control" name="s" placeholder="{'Cerca'|i18n('agenda/config')}" value="{$view_parameters.query|wash()}" autofocus>
                  </div>
                  <button type="submit" class="btn btn-success"><i class="fa fa-search"></i></button>
                </form>
                {include name=users_table uri='design:agenda/config/moderators_table.tpl' view_parameters=$view_parameters moderator_parent_node_id=$moderators_parent_node_id}
                <div class="pull-right"><a class="btn btn-danger" href="{concat('add/new/user/?parent=',$moderator_parent_node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Aggiungi moderatore'|i18n('agenda/config')}</a>
                  <form class="form-inline" style="display: inline" action="{'agenda/config/moderators'|ezurl(no)}" method="post">
                    <button class="btn btn-danger" name="AddModeratorLocation" type="submit"><i class="fa fa-plus"></i> {'Aggiungi utente esistente'|i18n('agenda/config')}</button>
                  </form>
              </div>
              </div>
              {/if}

              {if $current_part|eq('users')}
              <div class="tab-pane active" id="users">
                <form class="form-inline" action="{'agenda/config/users'|ezurl(no)}">
                  <div class="form-group">
                    <input type="text" class="form-control" name="s" placeholder="{'Cerca'|i18n('agenda/config')}" value="{$view_parameters.query|wash()}" autofocus>
                  </div>
                  <button type="submit" class="btn btn-success"><i class="fa fa-search"></i></button>
                </form>
                {include name=users_table uri='design:agenda/config/users_table.tpl' view_parameters=$view_parameters user_parent_node=$user_parent_node}
                <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/user/',ezini("UserSettings", "DefaultUserPlacement"))|ezurl(no)}">{'Esporta in CSV'|i18n('agenda/config')}</a></div>
              </div>
              {/if}



          </div>

      </div>
  </div>
</div>
