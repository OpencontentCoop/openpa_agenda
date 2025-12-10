{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Comment to'|i18n('agenda/mail')} {$event.name)}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $message = concat('<em>', $post.object.name|wash(), '</em>')}
{def $name = concat('<a href="', concat('agenda/event/',$event.main_node_id)|ezurl(no,full), '">', $event.name|wash(), '</a>')}
{def $state = concat('<strong>', $post.current_state.current_translation.name|wash, '</strong>')}

<p>{'We inform you that your comment %message to the %name event is now in status %state.'|i18n('agenda/mail', '', hash('%message', $message, '%name', $name, '%state', $state))}</p>

<p>- Staff {$social_pagedata.logo_title}</p>
