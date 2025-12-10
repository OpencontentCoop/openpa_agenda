{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'L\'evento %name è stato approvato'|i18n('agenda/mail', '', hash('%name', $post.object.name))}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $name = concat('<a href="', concat('agenda/event/',$post.object.main_node_id)|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}
{def $openagenda = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.id)|ezurl(no,full), '">', $social_pagedata.logo_title|strip_tags(), '</a>')}

{'Il tuo evento "%name" è stato approvato ed è ora pubblicato all\'interno di %openagenda.'|i18n('agenda/mail', '', hash(
    '%openagenda', $social_pagedata.logo_title|strip_tags(),
    '%name', $name
))}

<p>{'Consulta %openagenda per visualizzare l\'evento.'|i18n('agenda/mail', '', hash(
    '%openagenda', $openagenda,
    ))}</p>
