{def $social_pagedata = social_pagedata('agenda')}
{if $is_comment}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] Commento a {$event.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

La presente per comunicare che è stato pubblicato il commento <em>{$post.object.name|wash()}</em> all'evento <a href="{concat('agenda/event/',$event.main_node_id)|ezurl(no,full)}">{$event.name|wash()}</a>.
Il commento è ora in stato <strong>{$post.current_state.current_translation.name|wash}</strong>.



{else}
{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=subject}Notifica su {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

La presente per comunicare che il contenuto <a href="{$post.editorial_url|ezurl(no,full)}">{$post.object.name|wash()}</a> è stato cambiato di stato.
Lo stato corrente è {$post.current_state.current_translation.name|wash}

{/if}
