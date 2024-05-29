{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] Richiesta registrazione in validazione{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

<p>Grazie per aver inviato la tua richiesta di registrazione alla piattaforma.</p>
<p>Stiamo validando la tua iscrizione, riceverai una mail di conferma a questo indirizzo email quando la richiesta verrà approvata.</p>
