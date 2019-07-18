{def $social_pagedata = social_pagedata('agenda')}
{if $post.current_state.identifier|eq('public')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Association registration'|i18n('agenda/mail')} {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

{'We inform you that the data concerning the %name association have been validated.'|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}
{'It is therefore possible to log in to the system and insert content.'|i18n('agenda/mail')}


- Staff {$social_pagedata.logo_title}
{/if}

