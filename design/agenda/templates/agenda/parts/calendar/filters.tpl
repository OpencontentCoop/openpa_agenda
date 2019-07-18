<div id="openFilters">
  <a class="btn btn-info btn-block collapsed" data-toggle="collapse" href="#collapseFilters" aria-expanded="false" aria-controls="collapseFilters"><i class="fa fa-filter" aria-hidden="true"></i> </a>
</div>


<div class="collapse" id="collapseFilters">
  <aside class="widget agenda-filters" data-filter="q" style="display: none">
    <div class="input-group">
      <input type="text" class="form-control" placeholder="Cerca nel titolo o nel testo" name="srch-term"
             id="srch-term">
      <div class="input-group-btn">
        <button class="btn btn-default" type="submit"><i class="glyphicon glyphicon-search"></i>
        </button>
      </div>
    </div>
  </aside>

  <aside class="widget agenda-filters" data-filter="date">
    <h4>{'When?'|i18n('agenda')}</h4>
    <div class="datepicker" id="datepicker" style="display: none"></div>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="today">{'Today'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="weekend">{'This weekend'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="next 7 days">{'Next 7 days'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="next 30 days">{'Next 30 days'|i18n('agenda')}</a></li>
      <li {if and(is_set($hide_all_filter), $hide_all_filter|eq(true()))}class="hidden"{elseif and(is_set($view_all), $view_all|eq(true()))}class="active"{/if}><a href="#" data-value="all">{'All'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="theme" style="display: none">
    <h4>{'Topics'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'All event collections'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="type" style="display: none">
    <h4>{'What?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'All'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="target" style="display: none">
    <h4>{'Who are you?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'All'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="where" style="display: none">
    <h4>{'Where?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
        <li><a href="#" data-value="all">{'All'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="iniziativa" style="display: none">
    <h4>{'Event collection '|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'All event collections'|i18n('agenda')}</a></li>
    </ul>
  </aside>
</div>
