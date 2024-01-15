{def $social_pagedata = social_pagedata('agenda')}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Evento in attesa di moderazione'|i18n('agenda/mail')}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}
{def $name = concat('<a href="', $post.editorial_url|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}
{def $openagenda = concat('<a href="', concat('editorialstuff/edit/agenda/',$post.object.id)|ezurl(no,full), '">', $social_pagedata.logo_title|strip_tags(), '</a>')}
<p>{'L\'evento "%name" è in attesa di moderazione.'|i18n('agenda/mail', '', hash('%name', $name))}</p>
<p>{'Approva o rifiuta l\'evento utilizzando il pulsante "Cambia stato in..." nella pagina dedicata di %openagenda'|i18n('agenda/mail', '', hash(
    '%openagenda', $openagenda,
    ))}</p>

