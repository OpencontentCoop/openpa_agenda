{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <div class="d-flex justify-content-start align-items-center">
                {if $node|has_attribute('has_logo')}
                    <div class="mr-3">
                        {attribute_view_gui attribute=$node|attribute('has_logo') image_class=medium}
                    </div>
                {/if}
                <div>
                    <h1>{$node.name|wash()}</h1>
                    {if $node|has_attribute('short_title')}
                        <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
                    {/if}
                </div>
        </div>
            {if $node|has_attribute('business_objective')}
                <div class="lead">{attribute_view_gui attribute=$node|attribute('business_objective')}</div>
            {/if}

            {*<div class="row">
                {foreach array('tax_code', 'vat_code', 'rea_number') as $attribute}
                    {if $node|has_attribute($attribute)}
                    <div class="col">
                        <p class="info-date my-3">
                            <span class="d-block text-nowrap">{$node|attribute($attribute).contentclass_attribute_name|wash()}:</span>
                            <strong class="text-nowrap">{$node|attribute($attribute).content|wash()}</strong>
                        </p>
                    </div>
                    {/if}
                {/foreach}
            </div>*}
        </div>
        <div class="col-lg-3 offset-lg-1">
            {if $node.object.can_edit}
                <div class="mb-3">
                    <a class="btn btn-warning btn-icon" href="{concat('content/edit/',$node.contentobject_id, '/f')|ezurl('no')}">
                        {display_icon('it-pencil', 'svg', 'icon icon-white')}   <span>{'Edit'|i18n('agenda/dashboard')}</span>
                    </a>
                </div>
            {/if}
            {include uri='design:openpa/full/parts/actions.tpl'}
            {def $current_topics = array()}
            {if $node|has_attribute('topics')}
            {foreach $node|attribute('topics').content.relation_list as $item}
                {def $object = fetch(content, object, hash(object_id, $item.contentobject_id))}
                {if and($object.can_read, $object.class_identifier|eq('topic'))}
                    {set $current_topics = $current_topics|append($object)}
                {/if}
                {undef $object}
            {/foreach}
            {/if}
            {if or(
                $current_topics|count(),
                $node|has_attribute('has_private_org_activity_type'),
                $node|has_attribute('private_organization_category'),
                $node|has_attribute('legal_status_code')
            )}
            <div class="mt-4 mb-4">
                {if $current_topics|count()}
                    <h6 class="mb-0"><small>{'Topics'|i18n('bootstrapitalia')}</small></h6>
                    {foreach $current_topics as $object}
                        <a class="text-decoration-none text-nowrap d-inline-block " href="{$object.main_node.url_alias|ezurl(no)}"><div class="chip chip-simple chip-{if $object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$object.name|wash()}</span></div></a>
                    {/foreach}
                {/if}
                {if $node|has_attribute('has_public_event_typology')}
                    <h6 class="mb-0{if $current_topics|count()} mt-1{/if}"><small>{$node|attribute('has_private_org_activity_type').contentclass_attribute_name}</small></h6>
                    {attribute_view_gui attribute=$node|attribute('has_private_org_activity_type')}
                {/if}
                {if $node|has_attribute('private_organization_category')}
                    <h6 class="mb-0{if $current_topics|count()} mt-1{/if}"><small>{$node|attribute('private_organization_category').contentclass_attribute_name}</small></h6>
                    {attribute_view_gui attribute=$node|attribute('private_organization_category')}
                {/if}
                {if $node|has_attribute('legal_status_code')}
                    <h6 class="mb-0{if $current_topics|count()} mt-1{/if}"><small>{$node|attribute('legal_status_code').contentclass_attribute_name}</small></h6>
                    {attribute_view_gui attribute=$node|attribute('legal_status_code')}
                {/if}
            </div>
            {/if}

            {undef $current_topics}
        </div>
    </div>
</section>


{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}

{def $static_structure = hash(
    'description', array('description', 'image'),
    'has_spatial_coverage', array('has_spatial_coverage-main_address'),
    'has_online_contact_point', array('has_online_contact_point'),
    'more_information', array('more_information', 'foundation_date', 'attachments', 'has_private_org_activity_type', 'private_organization_category', 'legal_status_code')
)}

{def $static_structure_has_content = array()}
{def $static_structure_has_content_count = 0}
{foreach $static_structure as $identifier => $attributes}
    {def $has_content = false()}
    {foreach $attributes as $attribute}
        {if $node|has_attribute($attribute)}
            {set $has_content = true()}
            {break}
        {else}
            {def $attrs = $attribute|explode('-')}
            {foreach $attrs as $attr}
                {if $node|has_attribute($attr)}
                    {set $has_content = true()}
                    {break}
                {/if}
            {/foreach}
            {undef $attrs}
        {/if}
    {/foreach}
    {set $static_structure_has_content = $static_structure_has_content|merge(hash($identifier, $has_content))}
    {if $has_content}
        {set $static_structure_has_content_count = $static_structure_has_content_count|inc()}
    {/if}
    {undef $has_content}
{/foreach}

{if $static_structure_has_content_count|gt(0)}
<section class="container">
    <div class="row{if $static_structure_has_content_count|gt(1)} border-top row-column-border row-column-menu-left{/if} attribute-list">
        {if $static_structure_has_content_count|gt(1)}
            <aside class="col-lg-4">
                <div class="sticky-wrapper navbar-wrapper">
                    <nav class="navbar it-navscroll-wrapper it-top-navscroll navbar-expand-lg">
                        <button class="custom-navbar-toggler" type="button" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation" title="Toggle navigation" data-target="#navbarNav">
                            <span class="it-list"></span> {$summary_text|wash()}
                        </button>
                        <div class="navbar-collapsable" id="navbarNav">
                            <div class="overlay"></div>
                            <div class="close-div sr-only">
                                <button class="btn close-menu" type="button" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">
                                    <span class="it-close"></span> {$close_text|wash()}
                                </button>
                            </div>
                            <a class="it-back-button" href="#">
                                {display_icon('it-chevron-left', 'svg', 'icon icon-sm icon-primary align-top')}
                                <span>{$close_text|wash()}</span>
                            </a>
                            <div class="menu-wrapper">
                                <div class="link-list-wrapper menu-link-list">
                                    <h3 class="no_toc">{$summary_text|wash()}</h3>
                                    <ul class="link-list">
                                        {foreach $static_structure as $identifier => $attributes}
                                            {if $static_structure_has_content[$identifier]}
                                            <li class="nav-item{if $identifier|eq('description')} active{/if}">
                                                <a class="nav-link{if $identifier|eq('description')} active{/if}" href="#{$identifier|wash()}">
                                                    <span>{$node.data_map[$identifier].contentclass_attribute_name|wash()}</span>
                                                </a>
                                            </li>
                                            {/if}
                                        {/foreach}
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </nav>
                </div>
            </aside>
        {/if}
        <section class="{if $static_structure_has_content_count|le(1)}col w-100 px-lg-4 pb-lg-4{else}col-lg-8{/if}">
            {foreach $static_structure as $identifier => $attributes}
                <article id="{$identifier|wash()}" class="it-page-section mb-4 {if $static_structure_has_content_count|gt(1)}anchor-offset {/if}clearfix">
                    {if $static_structure_has_content[$identifier]}

                        {if $static_structure_has_content_count|gt(1)}
                            <h2 class="h4">{$node.data_map[$identifier].contentclass_attribute_name|wash()}</h2>
                        {/if}
                        <div>
                            {foreach $attributes as $attribute}
                                {if $node|has_attribute($attribute)}
                                    {if $attribute|ne($identifier)}
                                        <h3 class="h5 no_toc">{$node.data_map[$attribute].contentclass_attribute_name|wash()}</h3>
                                    {/if}
                                    {if $identifier|eq('description')}
                                        <div class="text-serif">
                                    {/if}
                                    {attribute_view_gui attribute=$node.data_map[$attribute]
                                                        view_context=full_attributes
                                                        image_class=medium
                                                        context_class=$node.class_identifier
                                                        relation_view='banner'
                                                        relation_has_wrapper=false()
                                                        show_link=true()
                                                        hide_title=true()
                                                        tag_view="chip-lg mr-2 me-2"}
                                    {if $identifier|eq('description')}
                                        </div>
                                    {/if}
                                {elseif $attribute|eq('image')}
                                    {def $images = array()}
                                    {if $node|has_attribute('image')}
                                    {foreach $node.data_map['image'].content.relation_list as $index => $item}
                                        {def $image_object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
                                        {if $image_object.can_read}
                                            {set $images = $images|append($image_object)}
                                        {/if}
                                        {undef $image_object}
                                    {/foreach}
                                    {/if}
                                    {include uri='design:atoms/gallery.tpl' items=$images}
                                    {undef $images}
                                {elseif $attribute|eq('has_spatial_coverage-main_address')}
                                    {def $node_list = array() $markers = array()}

                                    {if $node|has_attribute('main_address')}
                                        {set $markers = $markers|append($node|attribute('main_address').content)}
                                    {/if}

                                    {if $node|has_attribute('has_spatial_coverage')}
                                        {foreach $node|attribute('has_spatial_coverage').content.relation_list as $relation_item}
                                            {if $relation_item.in_trash|not()}
                                                {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
                                                {if $content_object.can_read}
                                                    {set $node_list = $node_list|append($content_object.main_node)}
                                                    {if $content_object|has_attribute('has_address')}
                                                        {set $markers = $markers|append($content_object|attribute('has_address').content)}
                                                    {/if}
                                                {/if}
                                                {undef $content_object}
                                            {/if}
                                        {/foreach}
                                    {/if}

                                    {if count($markers)|gt(0)}
                                    <div class="card-wrapper card-teaser-wrapper">
                                        {if $node|has_attribute('main_address')}
                                            <div class="card card-teaser shadow  p-4 rounded">
                                                {display_icon('it-pin', 'svg', 'icon')}
                                                <div class="card-body">
                                                    <div class="card-text">
                                                        <a href="https://www.google.com/maps/dir//'{$node|attribute('main_address').content.latitude},{$node|attribute('main_address').content.longitude}'/@{$node|attribute('main_address').content.latitude},{$node|attribute('main_address').content.longitude},15z?hl=it" rel="noopener noreferrer" target="_blank">
                                                            {$node|attribute('main_address').content.address}
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        {/if}
                                        {foreach $node_list as $child }
                                            {node_view_gui content_node=$child view=card_teaser show_icon=true() image_class=widemedium}
                                        {/foreach}
                                    </div>
                                    {/if}
                                    <div class="map-wrapper map-column mt-4 mb-5">
                                        <div id="relations-map-{$node.contentobject_id}" style="width: 100%; height: 400px;"></div>
                                    </div>
                                    <script type="text/javascript">
                                        {run-once}
                                        {literal}
                                        function drowRelationMap(id, latLngList) {
                                            var map = new L.Map('relations-map-'+id);
                                            map.scrollWheelZoom.disable();
                                            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                                            }).addTo(map);
                                            var markers = L.markerClusterGroup().addTo(map);
                                            $.each(latLngList, function () {
                                                var postMarker = new L.marker(this,{
                                                    icon: L.divIcon({
                                                        html: '<i class="fa fa-map-marker fa-4x text-danger"></i>',
                                                        iconSize: [20, 20],
                                                        className: 'myDivIcon'
                                                    }),
                                                });
                                                postMarker.addTo(markers)
                                            });
                                            if (markers.getLayers().length > 0) {
                                                map.fitBounds(markers.getBounds(), {padding: [50, 50]});
                                            }
                                        }
                                        {/literal}
                                        {/run-once}
                                        drowRelationMap({$node.contentobject_id},[{foreach $markers as $marker}[{$marker.latitude},{$marker.longitude}]{delimiter},{/delimiter}{/foreach}]);
                                    </script>
                                    {undef $node_list $markers}

                                {elseif $attribute|eq('has_online_contact_point-main_phone-main_person')}
                                    <div class="card-wrapper card-teaser-wrapper">

                                        {if $node|has_attribute('main_phone')}
                                            <div class="card card-teaser shadow  rounded ">
                                                {display_icon('it-telephone', 'svg', 'icon')}
                                                <div class="card-body">
                                                    <h5 class="card-title mb-1">{$node|attribute('main_phone').contentclass_attribute_name|wash()}</h5>
                                                    <div class="card-text">
                                                        <div class="mt-1">
                                                            <p class="mb-1">
                                                                {if $node|has_attribute('main_person')}{$node|attribute('main_person').content|wash()}<br />{/if}
                                                                {$node|attribute('main_phone').content|wash()}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        {/if}

                                        {*if $node|has_attribute('user_account')}
                                            <div class="card card-teaser shadow  rounded ">
                                                {display_icon('it-telephone', 'svg', 'icon')}
                                                <div class="card-body">
                                                    <h5 class="card-title mb-1">Email</h5>
                                                    <div class="card-text">
                                                        <div class="mt-1">
                                                            <p class="mb-1">
                                                                {$node|attribute('user_account').content.email|wash()}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        {/if*}

                                        {if $node|has_attribute('has_online_contact_point')}
                                            {attribute_view_gui attribute=$node.data_map['has_online_contact_point']
                                                                view_context=full_attributes
                                                                image_class=medium
                                                                context_class=$node.class_identifier
                                                                relation_view='banner'
                                                                relation_has_wrapper=true()
                                                                show_link=true()
                                                                tag_view="chip-lg mr-2 me-2"}
                                        {/if}
                                    </div>
                                {/if}
                            {/foreach}

                        </div>
                    {/if}
                </article>
            {/foreach}
        </section>
    </div>
    <script>{literal}$(document).ready(function () {
        $('.menu-wrapper a.nav-link').on('click', function () {
            $(this).addClass('active')
                .parent().addClass('active')
                .parents('.menu-wrapper').find('.active').not(this).removeClass('active')
        })
    }){/literal}</script>
</section>
{/if}
{if $node.children_count}
<div class="section section-muted section-inset-shadow p-4">
    {node_view_gui content_node=$node view=children view_parameters=$view_parameters}
</div>
{/if}

{def $related_event_classe_attributes = hash(
    'topic', array('topics'),
    'private_organization', array('organizer'),
    'place', array('takes_place_in'),
    'online_contact_point', array('has_online_contact_point'),
    'offer', array('has_offer')
)}
{def $related_event_classes = array(
    'topic',
    'private_organization',
    'place',
    'online_contact_point',
    'offer'
)}

{if $related_event_classes|contains($node.class_identifier)}

    {def $agenda_query_custom = ' ('}
    {foreach $related_event_classe_attributes[$node.class_identifier] as $identifier}
        {set $agenda_query_custom = concat($agenda_query_custom, $identifier, '.id in [', $node.contentobject_id, ']')}
        {delimiter}{set $agenda_query_custom = concat($agenda_query_custom, ' or ')}{/delimiter}
    {/foreach}
    {set $agenda_query_custom = concat($agenda_query_custom, ')')}

    <div class="section section-muted section-inset-shadow p-0">
        <div class="section-content">
        {include
            uri='design:parts/agenda.tpl'
            views=array('grid','geo','agenda')
            base_query=concat('classes [',agenda_event_class_identifier(),'] and subtree [', calendar_node_id(), '] and state in [moderation.skipped,moderation.accepted] sort [time_interval=>asc] and ', $agenda_query_custom)
            style='section'
        }
        {include uri='design:parts/views.tpl' views=array('grid','geo','agenda')}
        </div>
    </div>

{elseif $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}
