{def $social_pagedata = social_pagedata('agenda')}
{if $post.current_state.identifier|eq('public')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}] {'Organization registration'|i18n('agenda/mail')} {$post.object.name|wash()}{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

<p>{'We inform you that the data concerning the %name organization have been validated.'|i18n('agenda/mail', '', hash('%name', $post.object.name|wash()))}</p>
<p>{'It is therefore possible to log in to the system and insert content.'|i18n('agenda/mail')}</p>


<p>- Staff {$social_pagedata.logo_title}</p>
{/if}

