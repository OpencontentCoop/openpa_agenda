{ezpagedata_set( 'has_container', true() )}
<div class="container">
    {include uri=concat('design:', $template_directory, '/parts/workflow.tpl') post=$post}
</div>
<section class="container pt-0">
    <div class="row">
        <div class="col-md-{if is_set( $post.object.data_map.internal_comments )}9{else}12{/if}">

            <ul class="nav nav-tabs nav-fill overflow-hidden">
                {foreach $post.tabs as $index=> $tab}
                    <li role="presentation" class="nav-item">
                        <a class="text-decoration-none nav-link{if $index|eq(0)} active{/if}" data-toggle="tab" href="#{$tab.identifier}">
                            <span style="font-size: 1.2em">{$tab.name|i18n('agenda/dashboard')}</span>
                            {if $tab.identifier|eq('comments')}
                                <span class="ml-1 badge badge-light">{api_search(concat('classes [comment] subtree [',$post.node.node_id,'] limit 1')).totalCount}</span>
                            {/if}
                        </a>
                    </li>
                {/foreach}
            </ul>

            <div class="tab-content mt-3">
                {foreach $post.tabs as $index=> $tab}
                <div role="tabpanel" class="tab-pane{if $index|eq(0)} active{/if}" id="{$tab.identifier}">
                    {include uri=$tab.template_uri post=$post}
                </div>
                {/foreach}
            </div>


        </div>

        {if is_set( $post.object.data_map.internal_comments )}
            <div class="col-md-3">
                {include uri=concat('design:', $template_directory, '/parts/comments.tpl') post=$post}
            </div>
        {/if}

    </div>

    {ezscript_require( array(
        'modernizr.min.js',
        'bootstrap/tooltip.js',
        'jquery.editorialstuff_default.js',
        'jquery.opendataTools.js',
        'openpa_agenda_helpers.js',
        'jsrender.js'
    ) )}
    {def $current_language = ezini('RegionalSettings', 'Locale')}
    {def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
    {def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
    <script>
        var Translations = {ldelim}
            'Title':'{'Title'|i18n('agenda/dashboard')}',
            'Published':'{'Published'|i18n('agenda/dashboard')}',
            'Start date': '{'Start date'|i18n('agenda/dashboard')}',
            'End date': '{'End date'|i18n('agenda/dashboard')}',
            'Status': '{'Status'|i18n('agenda/dashboard')}',
            'Translations': '{'Translations'|i18n('agenda/dashboard')}',
            'Detail': '{'Detail'|i18n('agenda/dashboard')}',
            'Loading...': '{'Loading...'|i18n('agenda/dashboard')}'
        {rdelim};
        $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
        $.opendataTools.settings('language', "{$current_language}");
        $.opendataTools.settings('languages', ['{ezini('RegionalSettings','SiteLanguageList')|implode("','")}']);
        $.opendataTools.settings('locale', "{$moment_language}");
    </script>
    <style>
        .label-draft {ldelim}  background-color: #bbb;  {rdelim}
        .label-skipped {ldelim}  background-color: #999;  {rdelim}
        .label-waiting {ldelim}  background-color: #f0ad4e;  {rdelim}
        .label-accepted {ldelim}  background-color: #5cb85c;  {rdelim}
        .label-refused {ldelim}  background-color: #d9534f;  {rdelim}
        .border-draft {ldelim} border-width: 2px !important; border-color: #bbb !important;  {rdelim}
        .border-skipped {ldelim} border-width: 2px !important; border-color: #999  !important;  {rdelim}
        .border-waiting {ldelim}  border-width: 2px !important;border-color: #f0ad4e !important;  {rdelim}
        .border-accepted {ldelim} border-width: 2px !important; border-color: #5cb85c !important;  {rdelim}
        .border-refused {ldelim} border-width: 2px !important; border-color: #d9534f !important;  {rdelim}
    </style>

</section>
