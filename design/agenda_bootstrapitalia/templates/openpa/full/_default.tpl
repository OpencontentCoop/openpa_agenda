{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
    </div>
</section>


{include uri='design:openpa/full/parts/main_image.tpl'}

<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>

{if $node.children_count}
<div class="section section-muted section-inset-shadow p-4">
    {node_view_gui content_node=$node view=children view_parameters=$view_parameters}
</div>
{/if}

{def $related_event_classe_attributes = hash(
    'topic', array('topics'),
    'private_organization', array('organizer', 'attendee', 'composer', 'performer', 'sponsor', 'translator', 'funder'),
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
