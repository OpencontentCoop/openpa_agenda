{if $root.can_edit}
    {ezscript_require(array(
        'ezjsc::jquery',
        'ezjsc::jqueryUI',
        'ezjsc::jqueryio',
        'jquery.search-gui.js',
        'popper.js',
        'owl.carousel.js',
        'moment-with-locales.min.js',
        'chosen.jquery.js',
        'jquery.opendataTools.js',
        'leaflet/leaflet.0.7.2.js',
        'leaflet/Control.Geocoder.js',
        'leaflet/Control.Loading.js',
        'leaflet/Leaflet.MakiMarkers.js',
        'leaflet/leaflet.activearea.js',
        'leaflet/leaflet.markercluster.js',
        'jquery.dataTables.js',
        'dataTables.bootstrap4.min.js',
        'jquery.opendataDataTable.js',
        'jquery.blueimp-gallery.min.js',
        'handlebars.min.js',
        'bootstrap-datetimepicker.min.js',
        'jquery.fileupload.js',
        'jquery.fileupload-ui.js',
        'jquery.fileupload-process.js',
        'jquery.caret.min.js',
        'jquery.tag-editor.js',
        'alpaca.js',
        'jquery.price_format.min.js',
        'jquery.opendatabrowse.js',
        'jstree.min.js',
        'fields/OpenStreetMap.js',
        'fields/RelationBrowse.js',
        'fields/LocationBrowse.js',
        'fields/Tags.js',
        'fields/Ezxml.js',
        'fields/Tree.js',
        ezini('JavascriptSettings', 'IncludeScriptList', 'ocopendata_connectors.ini'),
        'jquery.opendataform.js'
    ))}
    {def $plugin_list = ezini('EditorSettings', 'Plugins', 'ezoe.ini',,true() )
    $ez_locale = ezini( 'RegionalSettings', 'Locale', 'site.ini')
    $language = '-'|concat( $ez_locale )
    $dependency_js_list = array( 'ezoe::i18n::'|concat( $language ) )}
    {foreach $plugin_list as $plugin}
        {set $dependency_js_list = $dependency_js_list|append( concat( 'plugins/', $plugin|trim, '/editor_plugin.js' ))}
    {/foreach}
    <script id="tinymce_script_loader" type="text/javascript" src={"javascript/tiny_mce_jquery.js"|ezdesign} charset="utf-8"></script>
    {ezscript( $dependency_js_list )}
    {ezcss_require(array(
        'alpaca.min.css',
        'bootstrap-datetimepicker.min.css',
        'jquery.fileupload.css',
        'jquery.tag-editor.css',
        'alpaca-custom.css',
        'jstree.min.css'
    ))}
    <div id="spinner" class="spinner my-3 text-center">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
    </div>
    <div id="form" class="clearfix px-4"></div>
    {literal}
    <style>
        .alpaca-layout-binding-holder{margin-bottom: 50px}
    </style>
    <script>
        $(document).ready(function () {
            var form = $('#form');
            var spinner = $('#spinner');
            $(document).on({
                ajaxStart: function(){
                    spinner.removeClass("d-none");
                },
                ajaxStop: function(){
                    spinner.addClass("d-none");
                }
            });
            $.opendataFormSetup({
                onBeforeCreate: function(){

                },
                onSuccess: function(data){

                },
                i18n: {{/literal}
                    'store': "{'Store'|i18n('opendata_forms')}",
                    'cancel': "{'Cancel'|i18n('opendata_forms')}",
                    'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
                    'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
                    'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
                {literal}}
            });
            form.opendataFormEdit({
                object: {/literal}{$root.contentobject_id}{literal}
            });
        });
    </script>
    {/literal}
{else}
    <ul class="list-unstyled">
        {if is_moderation_enabled()}
            <li><strong>{'Moderation is active'|i18n('agenda/config')}</strong></li>
        {/if}
        {if is_registration_enabled()}
            <li><strong>{'User registration is active'|i18n('agenda/config')}</strong></li>
        {/if}
        {if is_auto_registration_enabled()}
            <li><strong>{'Organizations registration is active'|i18n('agenda/config')}</strong></li>
        {/if}
        {if is_comment_enabled()}
            <li><strong>{'Comments enabled'|i18n('agenda/config')}</strong></li>
        {/if}
        {if is_login_enabled()}
            <li><strong>{'Login is active'|i18n('agenda/config')}</strong></li>
        {/if}
        {if $root|has_attribute('hide_tags')}
            <li><strong>{'Topics to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_tags')}</li>
        {/if}
        {if $root|has_attribute('hide_iniziative')}
            <li><strong>{'Event collections to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_iniziative')}</li>
        {/if}
    </ul>
{/if}
