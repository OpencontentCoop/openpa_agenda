{def $facets = api_search(concat($base_query, ' facets [owner_id|count|60] limit 1'))}
{def $owner_ids = array_keys($facets.facets[0].data)}
{def $owner_id_name_list = array()}
{if count($owner_ids)}
    {set $owner_id_name_list = api_search(concat('select-fields [metadata.id=>metadata.name] classes [user,private_organization] and subtree [1] and id in [', $owner_ids|implode(','), ']'))}
{/if}
<div class="modal modal-fullscreen modal-search" tabindex="-1" role="dialog" id="dashboardSearchModal">
    <div class="modal-dialog" role="search">
        <div class="modal-content">
            <div class="modal-body mt-5">
                <form action="{'content/search'|ezurl(no)}" method="get" data-query="{$base_query|wash(javascript)}">
                    <div class="search-gui container position-relative">
                        <div class="row">
                            <div class="col-12">
                                <ul class="nav nav-tabs nav-justified flex-wrap" role="tablist">
                                    <li class="nav-item">
                                        <a role="tab" data-toggle="tab" class="nav-link active"
                                           href="#filter-by-when">
                                            {'When?'|i18n('agenda')}
                                        </a>
                                    </li>
                                    {if count($owner_id_name_list)}
                                        <li class="nav-item">
                                            <a role="tab" data-toggle="tab" class="nav-link"
                                               href="#filter-by-owner">
                                                {'Author'|i18n('agenda/dashboard')}
                                            </a>
                                        </li>
                                    {/if}
                                </ul>
                            </div>
                        </div>
                        <div style="position: fixed;top: 15px;z-index: 100;left:0;width: 100%">
                            <div class="container text-right">
                                <button class="do-search btn btn-outline-primary btn-icon btn-sm mt-3 bg-white" type="submit">{'Confirm'|i18n('agenda')}</button>
                            </div>
                        </div>
                        <div class="tab-content mt-5">
                            <div class="tab-pane active" id="filter-by-when">
                                <div class="row">
                                    <div class="offset-lg-1 col-lg-10 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                            <div class="col-md-6 col-sm-12 mb-4">
                                                <div class="it-datepicker-wrapper">
                                                    <div class="form-group">
                                                        <label for="datepicker_start">{'Start date'|i18n('agenda/dashboard')}</label>
                                                        <input class="form-control it-date-datepicker" data-id="daterange" id="datepicker_start" type="text" name="From" value="">
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6 col-sm-12 mb-4">
                                                <div class="it-datepicker-wrapper">
                                                    <div class="form-group">
                                                        <label for="datepicker_end">{'End date'|i18n('agenda/dashboard')}</label>
                                                        <input class="form-control it-date-datepicker" data-id="daterange" id="datepicker_end" type="text" name="To" value="">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {if count($owner_id_name_list)}
                                <div class="tab-pane" id="filter-by-owner">
                                    <div class="row">
                                        <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                            <div class="row">
                                                {foreach $owner_id_name_list as $id => $name max count($owner_id_name_list)|div(2)|ceil()}
                                                    <div class="col-md-6 mb-5">
                                                        <div class="form-check custom-control custom-checkbox">
                                                            <input id="place-filter-{$id}"
                                                                   type="checkbox"
                                                                   name="Author"
                                                                   value="{$id}"
                                                                   class="custom-control-input"
                                                                   data-group="{$id}"
                                                                   data-id="{$id}">
                                                            <label for="place-filter-{$id}" class="custom-control-label">
                                                                <span>{$name|wash()}</span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                {/foreach}
                                                {if count($owner_id_name_list)|gt(1)}
                                                    {foreach $owner_id_name_list as $id => $name offset count($owner_id_name_list)|div(2)|ceil()}
                                                        <div class="col-md-6 mb-5">
                                                            <div class="form-check custom-control custom-checkbox">
                                                                <input id="place-filter-{$id}"
                                                                       type="checkbox"
                                                                       name="Author"
                                                                       value="{$id}"
                                                                       class="custom-control-input"
                                                                       data-group="{$id}"
                                                                       data-id="{$id}">
                                                                <label for="place-filter-{$id}" class="custom-control-label">
                                                                    <strong class="text-primary"><span>{$name|wash()}</span></strong>
                                                                </label>
                                                            </div>
                                                        </div>
                                                    {/foreach}
                                                {/if}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {/if}
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
