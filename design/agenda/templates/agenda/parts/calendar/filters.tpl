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
    <h4>{'Quando?'|i18n('agenda')}</h4>
    <div class="datepicker" id="datepicker" style="display: none"></div>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="today">{'Oggi'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="weekend">{'Questo fine settimana'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="next 7 days">{'I prossimi 7 giorni'|i18n('agenda')}</a></li>
      <li><a href="#" data-value="next 30 days">{'I prossimi 30 giorni'|i18n('agenda')}</a></li>
      <li {if and(is_set($view_all), $view_all|eq(true()))}class="active"{/if}><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="theme" style="display: none">
    <h4>{'Tematica'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'Tutte'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="type" style="display: none">
    <h4>{'Cosa?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="target" style="display: none">
    <h4>{'Chi sei?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="where" style="display: none">
    <h4>{'Dove?'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
        <li><a href="#" data-value="all">{'Tutti'|i18n('agenda')}</a></li>
    </ul>
  </aside>

  <aside class="widget agenda-filters" data-filter="iniziativa" style="display: none">
    <h4>{'Manifestazione'|i18n('agenda')}</h4>
    <ul class="nav nav-pills nav-stacked">
      <li><a href="#" data-value="all">{'Tutte'|i18n('agenda')}</a></li>
    </ul>
  </aside>
</div>
