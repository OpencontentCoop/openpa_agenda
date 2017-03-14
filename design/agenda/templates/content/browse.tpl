{def $browseHelper = agenda_browse_helper($browse)}
{if $browseHelper}
    {include uri=concat('design:content/browse/',$browseHelper,'.tpl')}
{else}
    {include uri=concat( 'design:content/browse/', $browse|browse_template() )}
{/if}
