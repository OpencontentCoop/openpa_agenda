<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>OpenAgenda</title>
    <style>
        @font-face {ldelim}
            font-family: 'Titillium Web';
            font-style: normal;
            font-weight: 300;
            src: url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.eot'); /* IE9 Compat Modes */
            src: local(''),
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.woff2') format('woff2'), /* Super Modern Browsers */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.woff') format('woff'), /* Modern Browsers */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.ttf') format('truetype'), /* Safari, Android, iOS */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-300.svg#TitilliumWeb') format('svg'); /* Legacy iOS */
        {rdelim}
        @font-face {ldelim}
            font-family: 'Titillium Web';
            font-style: normal;
            font-weight: 700;
            src: url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.eot'); /* IE9 Compat Modes */
            src: local(''),
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.woff2') format('woff2'), /* Super Modern Browsers */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.woff') format('woff'), /* Modern Browsers */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.ttf') format('truetype'), /* Safari, Android, iOS */
            url('https://static.opencityitalia.it/fonts/Titillium_Web/titillium-web-v10-latin-ext_latin-700.svg#TitilliumWeb') format('svg'); /* Legacy iOS */
        {rdelim}
    </style>
</head>
<body>
{def $script_url = '/agenda/widget/script'}
{if $height}
    {set $script_url = concat($script_url, '?height=', $height)}
{/if}
<script type="text/javascript" src="{$script_url|ezurl(no, full)}"></script>
<div data-agenda-widget="{$widget_id}" class="agenda-widget"></div>
</body>
</html>

