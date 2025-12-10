{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'L\'evento %name è stato rifiutato'|i18n('agenda/mail', '', hash('%name', $post.object.name))}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $name = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.id)|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}
{def $openagenda = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.id)|ezurl(no,full), '">', $social_pagedata.logo_title|strip_tags(), '</a>')}

<p>{'Il tuo evento "%name" è stato rifiutato.'|i18n('agenda/mail', '', hash(
    '%name', $name
    ))}</p>

<p>{'Consulta %openagenda per visualizzare l\'evento.'|i18n('agenda/mail', '', hash(
    '%openagenda', $openagenda,
    ))}</p>
