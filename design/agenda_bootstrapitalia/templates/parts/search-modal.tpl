{set_defaults(hash('show_private_place', false()))}
{def $event_class = fetch(content, class, hash('class_id', 'event'))}
{def $type_tags = api_tagtree($event_class.data_map['has_public_event_typology'].data_int1).children}
{def $target_tag_root = fetch('tags', 'tag', hash('tag_id', $event_class.data_map['target_audience'].data_int1)).parent_id}
{def $target_tags = api_tagtree($target_tag_root).children}
{def $place_facets = api_search(concat($base_query, ' facets [takes_place_in.id|count|600,owner_id|count|600] limit 1'))}
{def $place_ids = array_keys($place_facets.facets[0].data)}
{def $place_id_name_list = array()}
{if count($place_ids)}
    {set $place_id_name_list = api_search(concat('select-fields [metadata.id=>metadata.name] classes [place] and subtree [1] and id in [', $place_ids|implode(','), '] and state in [', visibility_states().public.id, ']' ))}
{/if}
{def $private_place_id_name_list = array()}
{def $has_place = false()}
{if count($place_ids)}
    {set $place_id_name_list = api_search(concat('select-fields [metadata.id=>metadata.name] classes [place] and subtree [1] and id in [', $place_ids|implode(','), '] and state in [', visibility_states().public.id, ']' ))}
    {if count($place_id_name_list)|gt(0)}
        {set $has_place = true()}
    {/if}
    {if $show_private_place}
        {set $private_place_id_name_list = api_search(concat('select-fields [metadata.id=>metadata.name] classes [place] and subtree [1] and id in [', $place_ids|implode(','), '] and state in [', visibility_states().private.id, ']' ))}
        {if count($private_place_id_name_list)|gt(0)}
            {set $has_place = true()}
        {/if}
    {/if}
{/if}
{def $owner_ids = array_keys($place_facets.facets[1].data)}
{def $owner_id_name_list = array()}
{if count($owner_ids)}
    {set $owner_id_name_list = api_search(concat('select-fields [metadata.id=>metadata.name] classes [user,private_organization] and subtree [1] and id in [', $owner_ids|implode(','), ']'))}
{/if}

{if is_set($exclude)|not()}
    {def $exclude = array()}
{/if}

<div class="modal modal-fullscreen modal-search" tabindex="-1" role="dialog" id="searchModal">
    <div class="modal-dialog" role="search">
        <div class="modal-content">
            <div class="modal-body mt-5">
                <form action="{'content/search'|ezurl(no)}" method="get" data-query="{$base_query|wash(javascript)}">
                    <div class="search-gui container position-relative">
                        <div class="row">
                            <div class="col-12">
                                <ul class="nav nav-tabs nav-justified flex-wrap" role="tablist">
                                    {def $active = false()}
                                    {if $exclude|contains('what')|not()}
                                    <li class="nav-item">
                                        <a role="tab" data-toggle="tab" class="nav-link{if $active|not()} active{set $active = true()}{/if}"
                                           href="#filter-by-what">
                                            {'What?'|i18n('agenda')}
                                        </a>
                                    </li>
                                    {/if}
                                    {if $exclude|contains('when')|not()}
                                    <li class="nav-item">
                                        <a role="tab" data-toggle="tab" class="nav-link{if $active|not()} active{set $active = true()}{/if}"
                                           href="#filter-by-when">
                                            {'When?'|i18n('agenda')}
                                        </a>
                                    </li>
                                    {/if}
                                    {if and($exclude|contains('where')|not(),$has_place)}
                                    <li class="nav-item">
                                        <a role="tab" data-toggle="tab" class="nav-link{if $active|not()} active{set $active = true()}{/if}"
                                           href="#filter-by-where">
                                            {'Where?'|i18n('agenda')}
                                        </a>
                                    </li>
                                    {/if}
                                    {if $exclude|contains('who')|not()}
                                    <li class="nav-item">
                                        <a role="tab" data-toggle="tab" class="nav-link{if $active|not()} active{set $active = true()}{/if}"
                                           href="#filter-by-who">
                                            {'Who are you?'|i18n('agenda')}
                                        </a>
                                    </li>
                                    {/if}
                                    {if and($exclude|contains('who')|not(), count($owner_id_name_list))}
                                        <li class="nav-item">
                                            <a role="tab" data-toggle="tab" class="nav-link{if $active|not()} active{set $active = true()}{/if}"
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
                        {set $active = false()}
                        <div class="tab-content mt-5">
                            {if $exclude|contains('what')|not()}
                            <div class="tab-pane{if $active|not()} active{set $active = true()}{/if}" id="filter-by-what">
                                <div class="row">
                                    <div class="offset-lg-1 col-lg-10 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                            <div class="col-md-6 mb-5">
                                                {foreach $type_tags as $tag max 3}
                                                    {include uri='design:parts/tag-tree-filter.tpl' tag=$tag key=Type}
                                                {/foreach}
                                            </div>
                                            <div class="col-md-6 mb-5">
                                                {foreach $type_tags as $tag offset 3}
                                                    {include uri='design:parts/tag-tree-filter.tpl' tag=$tag key=Type}
                                                {/foreach}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {/if}
                            {if $exclude|contains('when')|not()}
                            <div class="tab-pane{if $active|not()} active{set $active = true()}{/if}" id="filter-by-when">
                                <div class="row">
                                    <div class="offset-lg-1 col-lg-10 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                            <div class="col-md-12 col-sm-12 mb-4">
                                                <div class="form-check form-check-group">
                                                    <div class="toggles">
                                                        <label for="AlsoPast">
                                                            {'Also shows past events'|i18n('agenda')}
                                                            <input type="checkbox" data-id="alsopast" id="AlsoPast" name="AlsoPast" value="1">
                                                            <span class="lever"></span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
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
                            {/if}
                            {if and($exclude|contains('where')|not(),$has_place)}
                            <div class="tab-pane{if $active|not()} active{set $active = true()}{/if}" id="filter-by-where">
                                <div class="row">
                                    <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                        {if count($place_id_name_list)|gt(0)}
                                        <div class="row">
                                            {foreach $place_id_name_list as $id => $name max count($place_id_name_list)|div(2)|ceil()}
                                                <div class="col-md-6">
                                                    <div class="form-check custom-control custom-checkbox">
                                                        <input id="place-filter-{$id}"
                                                               type="checkbox"
                                                               name="Place"
                                                               value="{$id}"
                                                               class="custom-control-input"
                                                               data-group="{$id}"
                                                               data-tree="{$id}#"
                                                               data-level="1"
                                                               data-label="{$name|wash()}"
                                                               data-id="{$id}">
                                                        <label for="place-filter-{$id}" class="custom-control-label">
                                                            <span>{$name|wash()}</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            {/foreach}
                                            {if count($place_id_name_list)|gt(1)}
                                            {foreach $place_id_name_list as $id => $name offset count($place_id_name_list)|div(2)|ceil()}
                                                <div class="col-md-6">
                                                    <div class="form-check custom-control custom-checkbox">
                                                        <input id="place-filter-{$id}"
                                                               type="checkbox"
                                                               name="Place"
                                                               value="{$id}"
                                                               class="custom-control-input"
                                                               data-group="{$id}"
                                                               data-tree="{$id}#"
                                                               data-level="1"
                                                               data-label="{$name|wash()}"
                                                               data-id="{$id}">
                                                        <label for="place-filter-{$id}" class="custom-control-label">
                                                            <span>{$name|wash()}</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            {/foreach}
                                            {/if}
                                        </div>
                                        {/if}

                                        {if count($private_place_id_name_list)|gt(0)}
                                        <div class="row mt-4">
                                            {foreach $private_place_id_name_list as $id => $name max count($private_place_id_name_list)|div(2)|ceil()}
                                                <div class="col-md-6">
                                                    <div class="form-check custom-control custom-checkbox">
                                                        <input id="place-filter-{$id}"
                                                               type="checkbox"
                                                               name="Place"
                                                               value="{$id}"
                                                               class="custom-control-input"
                                                               data-group="{$id}"
                                                               data-tree="{$id}#"
                                                               data-level="1"
                                                               data-label="{$name|wash()}"
                                                               data-id="{$id}">
                                                        <label for="place-filter-{$id}" class="custom-control-label">
                                                            <span>{$name|wash()}</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            {/foreach}
                                            {if count($private_place_id_name_list)|gt(1)}
                                                {foreach $private_place_id_name_list as $id => $name offset count($private_place_id_name_list)|div(2)|ceil()}
                                                    <div class="col-md-6">
                                                        <div class="form-check custom-control custom-checkbox">
                                                            <input id="place-filter-{$id}"
                                                                   type="checkbox"
                                                                   name="Place"
                                                                   value="{$id}"
                                                                   class="custom-control-input"
                                                                   data-group="{$id}"
                                                                   data-tree="{$id}#"
                                                                   data-level="1"
                                                                   data-label="{$name|wash()}"
                                                                   data-id="{$id}">
                                                            <label for="place-filter-{$id}" class="custom-control-label">
                                                                <span>{$name|wash()}</span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                {/foreach}
                                            {/if}
                                        </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                            {/if}
                            {if $exclude|contains('who')|not()}
                            <div class="tab-pane{if $active|not()} active{set $active = true()}{/if}" id="filter-by-who">
                                <div class="row">
                                    <div class="offset-lg-2 col-lg-8 offset-md-1 col-md-10 col-sm-12">
                                        <div class="row">
                                            {foreach $target_tags as $index => $tag}
                                                <div class="col-md-6 mb-5">
                                                    {include uri='design:parts/tag-tree-filter.tpl' tag=$tag key=cond($index|eq(0), 'Target', 'Audience')}
                                                </div>
                                            {/foreach}
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {/if}
                            {if and($exclude|contains('who')|not(), count($owner_id_name_list))}
                                <div class="tab-pane{if $active|not()} active{set $active = true()}{/if}" id="filter-by-owner">
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
                                                                   data-tree="{$id}#"
                                                                   data-level="1"
                                                                   data-label="{$name|wash()}"
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
                                                                       data-tree="{$id}#"
                                                                       data-level="1"
                                                                       data-label="{$name|wash()}"
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
{unset_defaults(array('show_private_place'))}
