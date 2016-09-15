{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=message_id}{concat('<node.',$post.object.main_node_id,'.editorialstuff_actionnotify','@',ezini("SiteSettings","SiteURL"),'>')}{/set-block}
{set-block scope=root variable=subject}Commento a {$event.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

La presente per comunicare che il tuo commento <em>{$post.object.name|wash()}</em> all'evento <a href="{concat('agenda/event/',$event.main_node_id)|ezurl(no,full)}">{$event.name|wash()}</a> è ora in stato <strong>{$post.current_state.current_translation.name|wash}</strong>.

