{def $social_pagedata = social_pagedata('agenda')}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Notify on'|i18n('agenda/mail')} {$post.object.name}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}
{def $name = concat('<a href="', $post.editorial_url|ezurl(no,full), '">', $post.object.name|wash(), '</a>')}

<p>{'We inform you that that the content %name has been published/updated.'|i18n('agenda/mail', '', hash('%name', $name))}</p>
<p>{'The current status is %name.'|i18n('agenda/mail', '', hash('%name', $post.current_state.current_translation.name|wash))}</p>

<p>- Staff {$social_pagedata.logo_title}</p>
