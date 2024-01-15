{def $social_pagedata = social_pagedata('agenda')}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Nuova associazione'|i18n('agenda/mail')} {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}
{def $link = concat('<a href="', $post.editorial_url|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}

<p>{"L'associazione %name si è registrata sulla piattaforma."|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}</p>
<p>{'Verifica le informazioni inserite a questo link: %link e approva la richista utilizzando il pulsante "Cambia lo stato in..."'|i18n('agenda/mail', '', hash('%link', $link))}</p>
