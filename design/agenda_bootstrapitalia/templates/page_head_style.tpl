{def $css = array(concat($theme,'.css'))}

{if ezini('DebugSettings', 'DebugOutput')|eq('enabled')}
    {set $css = $css|append('debug.css')}
{/if}
{set $css = $css|merge(array(
    'alpaca-custom.css',
    'agenda-custom.css'
))}
{ezcss_load($css)}
{undef $css}
