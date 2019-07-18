{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path', false() )}
{ezscript_require(array('jquery.dashboard-search-gui.js'))}

{def $base_query = concat('classes [',agenda_association_class_identifier(),'] and subtree [', associazioni_root_node_id(), '] sort [published=>desc]')}
{if current_user_is_agenda_moderator()|not()}
    {set $base_query = concat($query, " and owner_id = ", fetch(user, current_user).contentobject_id)}
{/if}

<section class="container py-4">
    <div class="row">
        <div class="col">
            <ul class="nav nav-tabs nav-fill overflow-hidden">
                <li role="presentation" class="nav-item">
                    <a class="text-decoration-none nav-link active" style="font-size: 1.8em" data-toggle="tab"
                       href="#events">
                        {'Manage associations'|i18n('agenda/dashboard')}
                    </a>
                </li>
            </ul>
        </div>
    </div>

    {if $factory_configuration.CreationRepositoryNode}
        <div class="pt-4">
            <a class="btn btn-info rounded-0 text-white"
               href="{concat('editorialstuff/add/',$factory_identifier)|ezurl(no)}">
                <i class="fa fa-plus mr-2"></i> {$factory_configuration.CreationButtonText|wash()|i18n('agenda/dashboard')}
            </a>
        </div>
    {/if}

    <div class="tab-pane active" id="events">
        <div class="row py-4">
            <div class="col-md-9 py-2">
                {include uri='design:parts/filters.tpl' use_search_text=true()}
            </div>
            <div class="col-md-3 py-2">
                <div class="btn-group">
                    <a class="py-2 chip chip-lg chip-primary no-minwith text-black dropdown-toggle text-decoration-none" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <span class="chip-label">{'Status'|i18n('agenda/dashboard')}:</span> <span class="chip-label ml-1 current-state-filter" data-text="{'All'|i18n('agenda')}">{'All'|i18n('agenda')}</span>
                        {display_icon('it-expand', 'svg', 'icon-expand icon icon-sm icon-primary filter-remove')}
                    </a>
                    <div class="dropdown-menu" style="min-width:250px; right: 0; left: auto">
                        <div class="link-list-wrapper">
                            <ul class="link-list state-filters">
                                {foreach $states as $state}
                                    <li>
                                        <a class="list-item state-filter text-decoration-none"
                                           data-state_id="{$state.id|wash()}"
                                           data-state_identifier="{$state.identifier|wash()}"
                                           data-state_name="{$state.current_translation.name|wash()}"
                                           href="#">
                                            <div class="d-inline-block mr-1 rounded label-{$state.identifier|wash()}" style="width: 12px;height: 12px"></div>
                                            <small>{$state.current_translation.name|wash()}</small>
                                        </a>
                                    </li>
                                    {if is_set($state_group_identifier)|not()}
                                        {def $state_group_identifier = $state.group.identifier}
                                    {/if}
                                {/foreach}
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col mt-4" style="width: 85px;max-width: 85px">
                {include uri='design:parts/vertical_pills.tpl' views=array('list','geo')}
            </div>
            <div class="col">
                {include uri='design:parts/views.tpl' views=array('list','geo') view_style=''}
            </div>
        </div>
    </div>
</section>

{include uri='design:parts/tpl-spinner.tpl'}
{include uri='design:parts/tpl-empty.tpl'}
{include uri='design:parts/tpl-dashboard-list.tpl'}
{include uri='design:parts/dashboard-search-modal.tpl'}
{include uri='design:parts/preview-modal.tpl'}
{include uri='design:parts/js-include.tpl'}

{literal}
    <script>
        $(document).ready(function () {
            var currentStateFilter = $('span.current-state-filter');
            var stateFilterContainer = currentStateFilter.parent()
            var stateFilters = $("ul.state-filters a.state-filter");
            stateFilters.click(function () {
                var activate = !$(this).hasClass('current');
                stateFilters.removeClass('current');
                stateFilters.find('i.fa-times').remove();
                currentStateFilter.html(currentStateFilter.data('text'));
                stateFilterContainer.removeClass('selected').find('.icon').addClass('icon-primary');
                if (activate) {
                    $(this).addClass('current');
                    console.log($(this).hasClass('current'));
                    currentStateFilter.html($(this).html());
                    stateFilterContainer.addClass('selected').find('.icon').removeClass('icon-primary');
                    $(this).prepend('<i class="fa fa-times"></i>');
                }
            });
            $('#dashboardSearchModal').dashboardSearchGui({
                'spritePath': '{/literal}{'images/svg/sprite.svg'|ezdesign(no)}{literal}',
                'factory': '{/literal}{$factory_identifier}{literal}',
                'stateGroup': '{/literal}{$state_group_identifier}{literal}',
            });
        });
    </script>
    <style>
        .label-private {  background-color: #bbb;  }
        .label-public {  background-color: #5cb85c;  }
    </style>
{/literal}
