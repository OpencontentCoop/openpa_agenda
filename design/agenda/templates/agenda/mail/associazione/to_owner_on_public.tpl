{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Ti diamo il benevenuto'|i18n('agenda/mail')}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

<h3>{'La tua richiesta di iscrizione è stata approvata.'|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}</h3>

<p>{'Ecco le credenziali per accedere alla piattaforma.'|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}</p>

{def $link = concat('<a href="', $post.object.main_node.url_alias|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}
{def $manage_events_link = concat('<a href="', '/editorialstuff/dashboard/agenda'|ezurl(no,full), '">', $social_pagedata.logo_title, '</a>')}
{def $password_link = concat('<a href="', '/userpaex/forgotpassword'|ezurl(no,full), '">', '/userpaex/forgotpassword'|ezurl(no,full), '</a>')}
{def $username = concat('<strong>', $post.user.login|wash(), '</strong>')}
{def $email = concat('<strong>', $post.user.email|wash(), '</strong>')}

<ul>
    <li>{'Il tuo nome utente è %username'|i18n('agenda/mail', '', hash('%username', $username))}</li>
    <li>{'L\'indirizzo email è %email'|i18n('agenda/mail', '', hash('%email', $email))}</li>
    <li>{'La tua password è sempre recuperabile da qui: %password_link'|i18n('agenda/mail', '', hash('%password_link', $password_link))}</li>
    <li>{'La tua organizzazione è ora pubblica qui: %link'|i18n('agenda/mail', '', hash('%link', $link))}</li>
</ul>

<p>{'Accedi subito alla piattaforma %manage_events_link e inizia a inserire i tuoi eventi'|i18n('agenda/mail', '', hash('%manage_events_link', $manage_events_link))}</p>
