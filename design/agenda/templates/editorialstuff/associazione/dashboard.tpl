<section class="hgroup">
    <h1>Gestisci associazioni</h1>
</section>


<div class="row">
    <div class="col-sm-12" id="dashboard-filters-container">
        <form class="form-inline" role="form" method="get"
              action={concat('editorialstuff/dashboard/', $factory_identifier )|ezurl()}>

            {if $factory_configuration.CreationRepositoryNode}
                <a href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}" class="btn btn-primary">{$factory_configuration.CreationButtonText|wash()|i18n('agenda/dashboard')}</a>
            {/if}

            <div class="form-group">
                <input type="text" class="form-control" name="query" placeholder="{'Search'|i18n('editorialstuff/dashboard')}"
                       value="{$view_parameters.query|wash()}"/>
            </div>

            {if $states|count()}
            <div class="form-group">
                <select class="form-control" name="state" id="dashboard-state-select">
                    <option value="">{'All'|i18n('editorialstuff/dashboard')}</option>
                    {foreach $states as $state}
                        <option value="{$state.id}" {if $view_parameters.state|eq($state.id)} selected="selected"{/if} >{$state.current_translation.name|wash}</option>
                    {/foreach}
                </select>
            </div>
            {/if}

            {def $intervals = array(
                hash( 'value', '-P1D', 'name', 'Last day'|i18n('editorialstuff/dashboard') ),
                hash( 'value', '-P1W', 'name', 'Last 7 days'|i18n('editorialstuff/dashboard') ),
                hash( 'value', '-P1M', 'name', 'Last 30 days'|i18n('editorialstuff/dashboard') ),
                hash( 'value', '-P2M', 'name', 'Last two months'|i18n('editorialstuff/dashboard') )
            )}

            <div class="form-group">
                <select class="form-control" name="interval" id="dashboard-interval-select">
                    <option value="">{'Period'|i18n('editorialstuff/dashboard')}</option>
                    {foreach $intervals as $interval}
                        <option value="{$interval.value}" {if $view_parameters.interval|eq($interval.value)} selected="selected"{/if}>{$interval.name|wash()}</option>
                    {/foreach}
                </select>
            </div>

            <button type="submit" class="btn btn-info" id="dashboard-search-button">{'Search'|i18n('editorialstuff/dashboard')}</button>
        </form>
    </div>
</div>

<hr />

{if $post_count|gt(0)}

<div class="row editorialstuff">
  <div class="col-sm-12">
    
    {include name=navigator
            uri='design:navigator/google.tpl'
            page_uri=concat('editorialstuff/dashboard/', $factory_identifier )
            item_count=$post_count
            view_parameters=$view_parameters
            item_limit=$view_parameters.limit}
    
    <div class="table-responsive">
    <table class="table table-striped" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <th><small></small></th>
        <th><small>{'Author'|i18n('editorialstuff/dashboard')}</small></th>
        <th><small>{'Date'|i18n('editorialstuff/dashboard')}</small></th>
          {if $states|count()}<th><small>{'State'|i18n('editorialstuff/dashboard')}</small></th>{/if}
        <th><small>{'Title'|i18n('editorialstuff/dashboard')}</small></th>
        <th>{'Translations'|i18n('agenda/dashboard')}</th>
        <th></th>
      </tr>
    {foreach $posts as $post}
      <tr>

          <td class="text-center">            
            {if is_set($post.object.languages[ezini('RegionalSettings','Locale')])}
            <a href="{concat( 'editorialstuff/edit/', $factory_identifier, '/', $post.object.id )|ezurl('no')}" title="Dettaglio" class="btn btn-info">
                {'Detail'|i18n('editorialstuff/dashboard')}
            </a>            
            {/if}
          </td>
          
          <td>
            {if $post.object.owner}{$post.object.owner.name|wash()}{else}?{/if}
          </td>

          {*Data*}
          <td>{$post.object.published|l10n('shortdate')}</td>

          {if $states|count()}
          {*Stato*}
          <td>
            {include uri=concat('design:', $template_directory, '/parts/state.tpl')}
          </td>
          {/if}
          
          <td>
            <a data-toggle="modal" data-load-remote="{concat( 'layout/set/modal/content/view/full/', $post.object.main_node_id )|ezurl('no')}" data-remote-target="#preview .modal-content" href="#{*$post.url*}" data-target="#preview">{$post.object.name}</a>
          </td>

          <td>
            {foreach ezini('RegionalSettings','SiteLanguageList') as $language}
                {if is_set($post.object.languages[$language])}
                    <a href="{concat('/content/edit/', $post.object.id, '/f/', $language)|ezurl(no)}"><img style="max-width:none" src="/share/icons/flags/{$language}.gif" /></a>
                {else}
                    <a href="{concat('/content/edit/', $post.object.id, '/a')|ezurl(no)}"><img style="max-width:none;opacity:0.2" src="/share/icons/flags/{$language}.gif" /></a>
                {/if}
            {/foreach}            
          </td>
          
          <td>
            {include uri='design:parts/toolbar/node_trash.tpl' current_node=$post.node redirect_if_cancel=concat('editorialstuff/dashboard/', $factory_identifier ) redirect_after_remove=concat('editorialstuff/dashboard/', $factory_identifier ) }
          </td>
      
      </tr>
    {/foreach}
    </table>
    </div>
    
    {include name=navigator
            uri='design:navigator/google.tpl'
            page_uri=concat('editorialstuff/dashboard/', $factory_identifier )
            item_count=$post_count
            view_parameters=$view_parameters
            item_limit=$view_parameters.limit}
    
  </div>
</div>

{else}
<div class="alert alert-warning">{'No result found'|i18n('agenda')}</div>
{/if}

<div id="preview" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="previewlLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
        </div>
    </div>
</div>

{ezscript_require( array( 'modernizr.min.js', 'ezjsc::jquery' ) )}

<script>{literal}
    $(document).ready(function() {
        var touch = false;
        if (window.Modernizr) {
            touch = Modernizr.touch;
        }
        if (!touch) {
            $(document).on("mouseenter", ".has-tooltip", function() {
                var el;
                el = $(this);
                if (el.data("tooltip") === undefined) {
                    el.tooltip({
                        placement: el.data("placement") || "top",
                        container: el.data("container") || "body"
                    });
                }
                return el.tooltip("show");
            }).on("mouseleave", ".has-tooltip", function() {
                return $(this).tooltip("hide");
            });
        }
    });
    $('#dashboard-filters-container').find('select').change( function() {
        $('#dashboard-search-button').click();
    });
    $('[data-load-remote]').on('click',function(e) {
        e.preventDefault();
        var $this = $(this);
        $($this.data('remote-target')).html('<em>Loading...</em>');
        var remote = $this.data('load-remote');
        if(remote) {
            $($this.data('remote-target')).load(remote);
        }
    });
{/literal}</script>
