{def $social_pagedata = social_pagedata('agenda')}
{if $is_comment}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Comment to'|i18n('agenda/mail')}  {$event.name}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $message = concat('<em>', $post.object.name|wash(), '</em>')}
{def $name = concat('<a href="', concat('agenda/event/',$event.main_node_id)|ezurl(no,full), '">', $event.name|wash(), '</a>')}
{def $state = concat('<strong>', $post.current_state.current_translation.name|wash, '</strong>')}

{'We inform you that the comment %message has been published to the event %name.'|i18n('agenda/mail', '', hash('%message', $message, '%name', $name))}
{'The comment is now in state %state.'|i18n('agenda/mail', '', hash('%state', $state))}

{else}


{set-block scope=root variable=reply_to}{fetch(user,current_user).email}{/set-block}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Notify on'|i18n('agenda/mail')} {$post.object.name}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{def $name = concat('<a href="', $post.editorial_url|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}

{'We inform you that the status of the content "%name" has been changed.'|i18n('agenda/mail', '', hash('%name', $name))}
{'The current status is %name.'|i18n('agenda/mail', '', hash('%name', $post.current_state.current_translation.name|wash))}

{/if}

<p>- Staff {$social_pagedata.logo_title}</p>
