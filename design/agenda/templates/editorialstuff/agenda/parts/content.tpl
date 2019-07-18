<div class="panel-body" style="background: #fff">


    <div class="row">

        {if $post.object.can_edit}
            <div class="col-xs-4 col-md-2">
                <form method="post" action="{"content/action"|ezurl(no)}" style="display: inline;">
                    <input type="hidden" name="ContentObjectLanguageCode"
                           value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}"/>
                    <button class="btn btn-info btn-lg" type="submit" name="EditButton">
                        {'Edit'|i18n('agenda/dashboard')}
                    </button>
                    <input type="hidden" name="HasMainAssignment" value="1"/>
                    <input type="hidden" name="ContentObjectID" value="{$post.object.id}"/>
                    <input type="hidden" name="NodeID" value="{$post.node.node_id}"/>
                    <input type="hidden" name="ContentNodeID" value="{$post.node.node_id}"/>
                    {* If a translation exists in the siteaccess' sitelanguagelist use default_language, otherwise let user select language to base translation on. *}
                    {def $avail_languages = $post.object.available_languages
                    $content_object_language_code = ''
                    $default_language = $post.object.default_language}
                    {if and( $avail_languages|count|ge( 1 ), $avail_languages|contains( $default_language ) )}
                        {set $content_object_language_code = $default_language}
                    {else}
                        {set $content_object_language_code = ''}
                    {/if}
                    <input type="hidden" name="ContentObjectLanguageCode"
                           value="{$content_object_language_code}"/>
                    <input type="hidden" name="RedirectIfDiscarded"
                           value="{concat('editorialstuff/edit/', $factory_identifier, '/',$post.object.id)}"/>
                    <input type="hidden" name="RedirectURIAfterPublish"
                           value="{concat('editorialstuff/edit/', $factory_identifier, '/',$post.object.id)}"/>
                </form>
            </div>
        {/if}
        <div class="col-xs-4 col-md-2">
            <a class="btn btn-info btn-lg load-preview" data-object="{$post.object.id}" href="#">{'Preview'|i18n('agenda/dashboard')}</a>
        </div>
        <div class="col-xs-4 col-md-2">
            <form action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}" method="post">
                <p>
                    <input type="hidden" name="ActionParameters[]" value="" />
                    <input type="hidden" name="ActionIdentifier" value="ActionCopy" />
                    <button class="btn btn-warning btn-lg"
                            type="submit"
                            name="ActionCopy">
                        {'Copy'|i18n('design/standard/content/copy')}
                    </button>

                </p>
            </form>
        </div>

        {if $post.object.can_remove}
        <div class="col-xs-4 col-md-2">
            <form method="post" action="{"content/action"|ezurl(no)}" style="display: inline;">

            <button class="btn btn-danger btn-lg" type="submit" name="ActionRemove">{'Delete'|i18n('design/standard/gui')}</button>

            <input type="hidden" name="ContentObjectID" value="{$post.object.id}" />
            <input type="hidden" name="NodeID" value="{$post.object.main_node_id}" />
            <input type="hidden" name="ContentNodeID" value="{$post.object.main_node_id}" />

            <input type="hidden" name="RedirectIfCancel" value="{$post.editorial_url}" />
            <input type="hidden" name="RedirectURIAfterRemove" value="{concat('editorialstuff/dashboard/', $factory_identifier)}" />

            </form>
        </div>
        {/if}

    </div>

    <hr/>


    <div class="row edit-row">
        <div class="col-md-2"><strong><em>{'Author'|i18n('agenda/dashboard')}</em></strong></div>
        <div class="col-md-10">
            {if $post.object.owner}{$post.object.owner.name|wash()}{else}?{/if}
        </div>
    </div>

    <div class="row edit-row">
        <div class="col-md-2"><strong><em>{'Publication date'|i18n('agenda/dashboard')}</em></strong></div>
        <div class="col-md-10">
            <p>{$post.object.published|l10n(shortdatetime)}</p>
            {if $post.object.current_version|gt(1)}
                <small>Ultima modifica di <a
                            href={$post.object.main_node.creator.main_node.url_alias|ezurl}>{$post.object.main_node.creator.name}</a>
                    il {$post.object.modified|l10n(shortdatetime)}</small>
            {/if}
        </div>
    </div>

	{def $attribute_categories = ezini( 'ClassAttributeSettings', 'CategoryList', 'content.ini' )}
    {foreach $post.content_attributes_grouped_data_map as $category => $attributes}
        {if $category|eq('hidden')}{skip}{/if}
		<div class="row edit-row">
            <div class="col-md-2"><strong>{$attribute_categories[$category]}</strong></div>
            <div class="col-md-10">
				{foreach $attributes as $attribute}
				<div class="row edit-row">
				  <div class="col-md-2"><strong>{$attribute.contentclass_attribute_name}</strong></div>
				  <div class="col-md-10">{attribute_view_gui attribute=$attribute image_class=medium}</div>
				</div>
				{/foreach}
            </div>
        </div>
    {/foreach}


</div>

{ezscript_require( array(
  'ezjsc::jquery',
  'plugins/owl-carousel/owl.carousel.min.js',
  "plugins/blueimp/jquery.blueimp-gallery.min.js"
) )}
{ezcss_require( array(
  'plugins/owl-carousel/owl.carousel.css',
  'plugins/owl-carousel/owl.theme.css',
  "plugins/blueimp/blueimp-gallery.css"
) )}
