{def $social_pagedata = social_pagedata('agenda')}
{set-block scope=root variable=subject}[{$social_pagedata.logo_title|strip_tags()}]{/set-block}
{set-block scope=root variable=content_type}text/html{/set-block}

<h3>{"Info were saved and sent for validation"|i18n('agenda/signupassociazione')}</h3>

<p>{"When they are validated you will receive an email notification to the email address you entered"|i18n('agenda/signupassociazione')}</p>
