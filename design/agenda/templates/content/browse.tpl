{if $browse.action_name|eq('ProgrammaEventiItemAddSelectedEvent')}
    {include uri='design:content/browse/calendar.tpl'}
{else}
    {include uri=concat( 'design:content/browse/', $browse|browse_template() )}
{/if}
