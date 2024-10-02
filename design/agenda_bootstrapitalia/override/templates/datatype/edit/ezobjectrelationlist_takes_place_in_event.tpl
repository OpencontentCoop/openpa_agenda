{def $class_content=$attribute.class_content
     $parent_node_id = cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|eq( 0 )|not ), $class_content.default_placement.node_id, 1 )
     $viewport = openagenda_default_geolocation()}
{if $class_content.selection_type|eq(0)}

    {include uri='design:content/datatype/edit/ezobjectrelationlist.tpl'}

{else}

    {def $privacy_states = privacy_states()}
    {def $languages = ezini('RegionalSettings', 'SiteLanguageList')}
    {def $owner_list = array(fetch(user,current_user).contentobject_id)}
    {foreach $attribute.object.author_array as $author}
        {if $owner_list|contains($author.contentobject_id)|not()}
            {set $owner_list = $owner_list|append($author.contentobject_id)}
        {/if}
    {/foreach}

    {def $public_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.public'].id, "] sort [name=>asc] limit 300")}
    {debug-log msg='public_places_query' var=$public_places_query}
    {def $public_places = api_search($public_places_query, 'content', true())}
    {debug-log msg='public_places_count' var=$public_places.totalCount}

    {def $private_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.private'].id, "] and owner_id in [", $owner_list|implode(','), "] sort [name=>asc] limit 300")}
    {debug-log msg='private_places_query' var=$private_places_query}
    {def $private_places = api_search($private_places_query, 'content', true())}
    {debug-log msg='private_places_count' var=$private_places.totalCount}

    {def $all_used_places_id_list_query = concat("owner_id in [", $owner_list|implode(','), "] and facets [takes_place_in.id|count|1000] limit 1")}
    {debug-log msg='all_used_places_id_list_query' var=$all_used_places_id_list_query}
    {def $all_used_places_id_list = api_search($all_used_places_id_list_query).facets[0].data|array_keys}

    {def $shared_places = hash('totalCount', 0)}
    {if count($all_used_places_id_list)}
        {def $shared_places_query = concat("classes [place] subtree [",$parent_node_id,"] and state in [", $privacy_states['privacy.private'].id, "] and owner_id !in [", $owner_list|implode(','), "] and id in [", $all_used_places_id_list|implode(','), "] sort [name=>asc] limit 300")}
        {debug-log msg='shared_places_query' var=$shared_places_query}
        {set $shared_places = api_search($shared_places_query, 'content', true())}
        {debug-log msg='shared_places_count' var=$shared_places.totalCount}
    {/if}

    {def $current_selection = array()}
    {if ne( count( $attribute.content.relation_list ), 0)}
    {foreach $attribute.content.relation_list as $item}
        {set $current_selection = $current_selection|append($item.contentobject_id)}
    {/foreach}
    {/if}

    <div data-simplified_place_gui="{$attribute.id}"{if $viewport} data-lat="{$viewport.latitude}" data-lng="{$viewport.longitude}" data-zoom="15"{/if}>
        <select data-place_selection_wrapper name="ContentObjectAttribute_data_object_relation_list_{$attribute.id}[]"
                {if and($class_content.selection_type|ne(1),$class_content.selection_type|ne(2))}multiple{/if}
                class="form-control"
                data-placeholder="{'Select place'|i18n('add_place_gui')}">
            {if or($class_content.selection_type|eq(1),$class_content.selection_type|eq(2))}
                <option value="no_relation" {if eq( $attribute.content.relation_list|count, 0 )} selected="selected"{/if}>{'Nowhere'|i18n( 'add_place_gui' )}</option>
            {/if}

            <optgroup data-new_place_select label="{'Your own'|i18n('add_place_gui')}">
                <option value="no_relation" data-create_new="1" style="font-weight:bold">+ {'Create new'|i18n('opendata_forms')}</option>
                {if $private_places.totalCount|gt(0)}
                    {foreach $private_places.searchHits as $private_place}
                        {foreach $languages as $language}
                            {if is_set($private_place.metadata.name[$language])}
                                <option data-lng="{$private_place.data[$language].has_address.longitude}"
                                        data-lat="{$private_place.data[$language].has_address.latitude}"
                                        value="{$private_place.metadata.id}" {if $current_selection|contains($private_place.metadata.id )}selected="selected"{/if}>
                                    {$private_place.metadata.name[$language]|wash}
                                </option>
                                {break}
                            {/if}
                        {/foreach}
                    {/foreach}
                {/if}
            </optgroup>

            {if $public_places.totalCount|gt(0)}
                <optgroup label="{'Editor choice'|i18n('add_place_gui')}">
                {foreach $public_places.searchHits as $public_place}
                    {foreach $languages as $language}
                        {if is_set($public_place.metadata.name[$language])}
                            <option data-lng="{$public_place.data[$language].has_address.longitude}"
                                    data-lat="{$public_place.data[$language].has_address.latitude}"
                                    value="{$public_place.metadata.id}" {if $current_selection|contains($public_place.metadata.id )}selected="selected"{/if}>
                                {$public_place.metadata.name[$language]|wash}
                            </option>
                            {break}
                        {/if}
                    {/foreach}
                {/foreach}
                </optgroup>
            {/if}

            <optgroup data-shared_place_select label="{'Shared with other editors'|i18n('add_place_gui')}" {if $shared_places.totalCount|eq(0)}class="hide"{/if}>
                {if $shared_places.totalCount|gt(0)}
                {foreach $shared_places.searchHits as $shared_place}
                    {foreach $languages as $language}
                        {if is_set($shared_place.metadata.name[$language])}
                            <option data-lng="{$shared_place.data[$language].has_address.longitude}"
                                    data-lat="{$shared_place.data[$language].has_address.latitude}"
                                    value="{$shared_place.metadata.id}" {if $current_selection|contains($shared_place.metadata.id )}selected="selected"{/if}>
                                {$shared_place.metadata.name[$language]|wash}
                            </option>
                            {break}
                        {/if}
                    {/foreach}
                {/foreach}
                {/if}
            </optgroup>

        </select>

        {if or($class_content.selection_type|eq(1),$class_content.selection_type|eq(2))}
            <input type="hidden" name="single_select_{$attribute.id}" value="1" />
        {/if}


        <div class="position-relative" style="display:none">
            <div id="map-{$attribute.id}" style="width: 100%; height: 500px!important; margin: 10px 0;"></div>

            <div data-helper-texts style="display: none;">
                <div data-candrag>{'You can drag the marker on the map to select the location more precisely.'|i18n('add_place_gui')}</div>
                <div data-confirm>{'Add this location to your places'|i18n('add_place_gui')}</div>
                <div data-maybe>{'There are places near the selected location registered in the system. Do you want to use one of these?'|i18n('add_place_gui')}</div>
                <div data-continue>{'Continue with my location'|i18n('add_place_gui')}</div>
                <div data-cancel>{'Cancel'|i18n('add_place_gui')}</div>
            </div>

            <div data-window class="bg-white position-absolute h-100 w-100 overflow-auto card-teaser no-after rounded shadow p-3" style="top: 0;z-index: 1000;display: none"></div>
            <div data-selectplace class="bg-white position-absolute h-100 overflow-auto" style="top: 0;z-index: 1000; display: none; right: 0;width: 300px;" ></div>
        </div>

    </div>

    {ezcss_require('leaflet/geocoder/Control.Geocoder.css')}
    {ezscript_require(array('leaflet/geocoder/Control.Geocoder.js', 'jquery.simplifiedPlaceGui.js'))}
    {def $color = primary_color()}
    <style>
        .alpaca-wizard-buttons{ldelim}
            position: absolute;
            width: 94%;
            bottom: 26px;
        {rdelim}
        .alpaca-wizard-buttons [data-alpaca-wizard-button-key="next"],
        .alpaca-wizard-buttons [data-alpaca-wizard-button-key="previous"]{ldelim}
            color: {$color};
            background-color: transparent;
            background-image: none;
            box-shadow: inset 0 0 0 1px {$color};
            border-radius: 4px;
            padding: 8px 8px;
            font-size: .82496rem;
            line-height: 1.45;
        {rdelim}
        .alpaca-wizard-buttons [data-alpaca-wizard-button-key="submit"]{ldelim}
            border-radius: 4px;
            padding: 8px 8px;
            font-size: .82496rem;
            line-height: 1.45;
        {rdelim}
        .alpaca-wizard-buttons [data-alpaca-wizard-button-key="reset"]{ldelim}
            color: #fff;
            background-color: #d9364f;
            background-image: none;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.15),0 1px 1px rgba(0,0,0,0.075);
            border-radius: 4px;
            padding: 8px 8px;
            font-size: .82496rem;
            line-height: 1.45;
        {rdelim}
    </style>
    <script>
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
{literal}
    $(document).ready(function () {
        $('[data-simplified_place_gui="{/literal}{$attribute.id}{literal}"]').simplifiedPlaceGui({
            class: 'place',
            parent: {/literal}{$attribute.class_content.default_placement.node_id|int()}{literal},
            multiSelect: {/literal}{cond(and($class_content.selection_type|ne(1),$class_content.selection_type|ne(2)), 'true', 'false')}{literal},
            i18n:{{/literal}
                'search': '{'Search'|i18n('opendata_forms')}',
                'noResults': '{'No contents'|i18n('opendata_forms')}',
                'myLocation': '{'Detect position'|i18n('add_place_gui')}',
                'store': "{'Store'|i18n('opendata_forms')}",
                'cancel': "{'Cancel'|i18n('opendata_forms')}",
                'next': "{"Next"|i18n("design/admin/navigator")}",
                'prev': "{"Previous"|i18n("design/admin/navigator")}",
                'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
                'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
                'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
            {literal}}
        });
    });
    </script>
{/literal}

{/if}
{undef}
