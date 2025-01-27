{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}
{if is_set($show_all_attributes)|not()}
    {def $show_all_attributes = false()}
{/if}
{def $summary_items = array()}
{def $attribute_groups = class_extra_parameters($object.class_identifier, 'attribute_group')}
{def $hide_index = $attribute_groups.hide_index}
{if $show_all_attributes}
    {foreach $object.data_map as $attribute_identifier => $attribute}
        {*if and(fetch('user', 'has_access_to', hash('module', 'agenda', 'function', 'config' ))|not(), $attribute.contentclass_attribute.category|eq('hidden'))}{skip}{/if}
        {if array('ocrecaptcha','ezpaex')|contains($attribute.data_type_string)}{skip}{/if*}
        {if $attribute.contentclass_attribute.category|eq('hidden')}{skip}{/if}
        {if or($attribute.has_content, $attribute.data_type_string|eq('ezuser'))}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
{elseif $attribute_groups.enabled}
    {foreach $attribute_groups.group_list as $slug => $name}
        {if count($attribute_groups[$slug])|gt(0)}
            {def $openpa_attributes = array()
                 $wrapped = true()}
            {foreach $attribute_groups[$slug] as $attribute_identifier}
                {if and( is_set($openpa[$attribute_identifier]), $openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}

                    {*workaround per ezboolean*}
                    {if and(
                        is_set($openpa[$attribute_identifier].contentobject_attribute),
                        $openpa[$attribute_identifier].contentobject_attribute.data_type_string|eq('ezboolean'),
                        $openpa[$attribute_identifier].contentobject_attribute.data_int|ne(1)
                    )}
                        {skip}
                    {/if}

                    {*evita di duplicare l'immagine principale nella galleria*}
                    {if and(
                        class_extra_parameters($object.class_identifier, 'table_view').main_image|contains($attribute_identifier),
                        class_extra_parameters($object.class_identifier, 'table_view').show_link|contains($attribute_identifier)|not(),
                        is_set($openpa[$attribute_identifier].contentobject_attribute)
                    )}
                        {if and($openpa[$attribute_identifier].contentobject_attribute.data_type_string|eq('ezobjectrelationlist'), count($openpa[$attribute_identifier].contentobject_attribute.content.relation_list)|le(1))}
                            {skip}
                        {/if}
                    {/if}

                    {set $openpa_attributes = $openpa_attributes|append($openpa[$attribute_identifier])}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_link|not())}{set $wrapped = false()}{/if}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_label)}{set $wrapped = false()}{/if}
                {/if}
            {/foreach}
            {if count($openpa_attributes)|gt(0)}
                {set $summary_items = $summary_items|append(
                    hash( 'slug', $slug, 'title', $attribute_groups.current_translation[$slug], 'attributes', $openpa_attributes, 'is_grouped', true(), 'wrap', cond($wrapped, count($openpa_attributes)|gt(1),true(),false()) )
                )}
            {/if}
            {undef $openpa_attributes $wrapped}
        {/if}
    {/foreach}
{else}
    {def $table_view = class_extra_parameters($object.class_identifier, 'table_view')}
    {foreach $table_view.show as $attribute_identifier}
        {if and($openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
    {undef $table_view}
{/if}

{if count($summary_items)|gt(0)}
    <div class="row{if and(count($summary_items)|gt(1), $hide_index|not())} border-top row-column-border row-column-menu-left{/if} attribute-list">
        {if and(count($summary_items)|gt(1), $hide_index|not())}
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
                                    {foreach $summary_items as $index => $item}
                                        <li class="nav-item{if $index|eq(0)} active{/if}">
                                            <a class="nav-link{if $index|eq(0)} active{/if}" href="#{$item.slug|wash()}"><span>{$item.title|wash()}</span></a>
                                        </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>
            </div>
        </aside>
        {/if}
        <section class="{if or(count($summary_items)|eq(1), $hide_index)}col w-100 px-lg-4 pb-lg-4{else}col-lg-8{/if}">
            {foreach $summary_items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section mb-4 clearfix" {*if and(count($summary_items)|gt(1), $hide_index|not())}anchor-offset {/if*} {*if $index|eq(0)} class="anchor-offset"{/if*}>
                    {if and(count($summary_items)|gt(1), $attribute_groups.hidden_list|contains($item.slug)|not())}
                    <h4>{$item.title|wash()}</h4>
                    {/if}

                    {if $item.wrap}
                    <div class="card-wrapper card-teaser-wrapper">
                    {/if}

                    {foreach $item.attributes as $openpa_attribute}

                        {if $openpa_attribute.full.highlight}
                        <div class="callout important">
                            {if and($openpa_attribute.full.show_label, $openpa_attribute.full.collapse_label|not(), $item.is_grouped)}
                                <div class="callout-title">
                                    {display_icon('it-info-circle', 'svg', 'icon')}
                                    {$openpa_attribute.label|wash()}
                                </div>
                            {/if}
                            <div class="text-serif small neutral-1-color-a7">
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped)}
                            {if $openpa_attribute.full.collapse_label|not()}
                                <h5 class="no_toc">{$openpa_attribute.label|wash()}</h5>
                            {else}
                                <h6 class="d-inline mr-2 me-2 font-weight-bold">{$openpa_attribute.label|wash()}:</h6>
                            {/if}
                        {/if}

                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                view_context=full_attributes
                                                image_class=medium
                                                context_class=$node.class_identifier
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')
                                                relation_has_wrapper=$item.wrap
                                                show_link=$openpa_attribute.full.show_link
                                                tag_view="chip-lg mr-2 me-2"}
                        {elseif and(is_set($openpa_attribute.template), $openpa_attribute.template)}
                            {include uri=$openpa_attribute.template}
                        {/if}

                        {if $openpa_attribute.full.highlight}
                            </div>
                        </div>
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped,$openpa_attribute.full.collapse_label)}
                            <br />
                        {/if}
                    {/foreach}

                    {if $item.wrap}
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
{/if}
