{def $social_pagedata = social_pagedata('agenda')}

{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] Notifica su {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}
{def $name = concat('<a href="', $post.editorial_url|ezurl(no,full), '">', $post.object.name|wash()}, '</a>')}

{'We inform you that that the content %name has been published/updated.'|i18n('agenda/mail', '', hash('%name', $name))}
{'The current status is %name.'|i18n('agenda/mail', '', hash('%name', $post.current_state.current_translation.name|wash))}

- Staff {$social_pagedata.logo_title}
