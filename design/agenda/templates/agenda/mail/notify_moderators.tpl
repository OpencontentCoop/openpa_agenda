{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=message_id}{concat('<node.',$post.object.main_node_id,'.editorialstuff_actionnotify','@',ezini("SiteSettings","SiteURL"),'>')}{/set-block}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] Notifica su {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

La presente per comunicare che è stato pubblicato/aggiornato il contenuto <a href="{$post.editorial_url|ezurl(no,full)}">{$post.object.name|wash()}</a>.
Lo stato corrente è {$post.current_state.current_translation.name|wash}
