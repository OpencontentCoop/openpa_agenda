{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Evento %name in lavorazione'|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $name = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.main_node_id)|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}
{def $openagenda = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.id)|ezurl(no,full), '">', $social_pagedata.logo_title|strip_tags(), '</a>')}

<p>{'Il tuo evento "%name" è stato riportato in lavorazione.'|i18n('agenda/mail', '', hash(
    '%openagenda', $social_pagedata.logo_title|strip_tags(),
    '%name', $name
))}</p>

<p>{'Consulta %openagenda per modificare l\'evento.'|i18n('agenda/mail', '', hash(
    '%openagenda', $openagenda,
))}</p>
