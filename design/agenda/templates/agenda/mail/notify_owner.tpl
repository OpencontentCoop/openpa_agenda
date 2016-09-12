{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=message_id}{concat('<node.',$post.object.main_node_id,'.editorialstuff_actionnotify','@',ezini("SiteSettings","SiteURL"),'>')}{/set-block}
{set-block scope=root variable=subject}Notifica su {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

La presente per comunicare che il contenuto <a href="{$post.editorial_url|ezurl(no,full)}">{$post.object.name|wash()}</a> è stato cambiato di stato.
Lo stato corrente è {$post.current_state.current_translation.name|wash}
