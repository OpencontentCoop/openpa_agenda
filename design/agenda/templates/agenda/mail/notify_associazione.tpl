{def $social_pagedata = social_pagedata('agenda')}
{if $post.current_state.identifier|eq('public')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] Registrazione associzione {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}
La presente cper comunicare che i dati relativi all'associazione {$post.object.name|wash()} sono stati validati.
E' possibile perciò effettuare l'accesso al sistema e inserire contenuti.
{/if}

