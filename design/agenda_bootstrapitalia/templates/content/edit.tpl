{def $_redirect = false()}
{if $object.id|eq(fetch(user, current_user).contentobject_id)}
    {set $_redirect = 'user/edit'}
{elseif ezhttp_hasvariable( 'RedirectURIAfterPublish', 'session' )}
    {set $_redirect = ezhttp( 'RedirectURIAfterPublish', 'session' )}
{elseif ezhttp( 'url', 'get', true() )}
    {set $_redirect = ezhttp( 'url', 'get' )|wash()}
{/if}

{def $tab = ''}
{if and( ezhttp_hasvariable( 'tab', 'get' ), is_set( $view_parameters.tab )|not() )}    
    {set $_redirect = concat( $_redirect, '/(tab)/', ezhttp( 'tab', 'get' ) )}
{/if}

<form class="edit"
      enctype="multipart/form-data"
      method="post"
      data-original_action="{concat("/content/edit/",$object.id,"/",$edit_version,"/",$edit_language|not|choose(concat($edit_language,"/"),''))|ezurl(no)}"
      action="{concat("/content/edit/",$object.id,"/",$edit_version,"/",$edit_language|not|choose(concat($edit_language,"/"),''))|ezurl(no)}">
    
    {include uri='design:parts/website_toolbar_edit.tpl'}
    <div class="clearfix">
        <h4 class="float-left">{if $edit_version|eq(1)}{"Create"|i18n( 'design/ocbootstrap/content/edit' )}{else}{"Edit"|i18n( 'design/ocbootstrap/content/edit' )}{/if} <span class="text-lowercase">{$class.name|wash}</span></h4>
        <div class="chip chip-lg float-right mt-2">
            {def $language_index = 0
                 $from_language_index = 0
                 $translation_list = $content_version.translation_list}

            {foreach $translation_list as $index => $translation}
               {if eq( $edit_language, $translation.language_code )}
                  {set $language_index = $index}
               {/if}
            {/foreach}

            {if $is_translating_content}
                {def $from_language_object = $object.languages[$from_language]}
                {'Translating content from %from_lang to %to_lang'|i18n( 'design/ezwebin/content/edit',, hash(
                    '%from_lang', concat( $from_language_object.name, '&nbsp;<img src="', $from_language_object.locale|flag_icon, '" style="vertical-align: middle;" alt="', $from_language_object.locale, '" />' ),
                    '%to_lang', concat( $translation_list[$language_index].locale.intl_language_name, '&nbsp;<img src="', $translation_list[$language_index].language_code|flag_icon, '" style="vertical-align: middle;" alt="', $translation_list[$language_index].language_code, '" />' ) ) )}
            {else}
                {$translation_list[$language_index].locale.language_name|wash()}&nbsp;<img src="{$translation_list[$language_index].language_code|flag_icon}" style="vertical-align: middle;" alt="{$translation_list[$language_index].language_code}" />
            {/if}
        </div>
    </div>

    <h1>{$object.name|wash}</h1>

    {include uri="design:content/edit_validation.tpl"}

    <div class="mb-3">
          {if ezini_hasvariable( 'EditSettings', 'AdditionalTemplates', 'content.ini' )}
            {foreach ezini( 'EditSettings', 'AdditionalTemplates', 'content.ini' ) as $additional_tpl}
              {include uri=concat( 'design:', $additional_tpl )}
            {/foreach}
          {/if}

          {include uri="design:content/edit_attribute.tpl"}

          <div class="clearfix">
              <input class="btn btn-lg btn-success float-right" type="submit" name="PublishButton" value="{'Send for publishing'|i18n( 'design/ocbootstrap/content/edit' )}" />
              <input class="btn btn-lg btn-warning float-right mr-3 me-3" type="submit" name="StoreButton" value="{'Store draft'|i18n( 'design/ocbootstrap/content/edit' )}" />
              <input class="btn btn-lg btn-warning float-right mr-3 me-3" type="submit" name="StoreExitButton" value="{'Store draft and exit'|i18n( 'design/ocbootstrap/content/edit' )}" />
              <input class="btn btn-lg btn-dark" type="submit" name="DiscardButton" value="{'Discard draft'|i18n( 'design/ocbootstrap/content/edit' )}" />
              <input type="hidden" name="DiscardConfirm" value="0" />
              {if ezhttp_hasvariable( 'RedirectIfDiscarded', 'session' )}<input type="hidden" name="RedirectIfDiscarded" value="{ezhttp( 'RedirectIfDiscarded', 'session' )}" />{/if}
              {if $_redirect}<input type="hidden" name="RedirectURIAfterPublish" value="{$_redirect}" />{/if}
          </div>
    </div>
</form>

{undef $_redirect}

{ezscript_require(array(
    'ezjsc::jquery',
    'ezjsc::jqueryio',
    'ezjsc::jqueryUI',
    'jstree.min.js',
    'jquery.eztags.js',
    'jquery.eztags.select.js',
    'jquery.eztags.tree.js',
    'tagsstructuremenu.js'
))}
{ezcss_require(array('contentstructure-tree.css'))}
{run-once}
{literal}
<style>
    div.tag-block-select.contentstructure ul {padding:0}
    div.tag-block-select.contentstructure a {text-decoration:none}
</style>
<script>
{/literal}
var currentDate  = new Date().valueOf();
var TagBlockSelectStructureMenuParams = {ldelim}{*
    *}"path":[],{*
    *}"useCookie":false,{*
    *}"perm":"",{*
    *}"expiry":"{fetch( content, content_tree_menu_expiry )}",{*
    *}"modal":true,{*
    *}"context":"browse",{*
    *}"showTips":true,{*
    *}"autoOpen":false,{*
    *}"tag_id_string":"{'Tag ID'|i18n( 'extension/eztags/tags/treemenu' )|wash( javascript )}",{*
    *}"parent_tag_id_string":"{'Parent tag ID'|i18n( 'extension/eztags/tags/treemenu' )|wash( javascript )}",{*
    *}"treemenu_base_url":"{'tags/treemenu'|ezurl( no )}",{*
    *}"not_allowed_string":"{'Dynamic tree not allowed for this siteaccess'|i18n( 'extension/eztags/tags/treemenu' )|wash( javascript )}",{*
    *}"no_tag_string":"{'Tag does not exist'|i18n( 'extension/eztags/tags/treemenu' )|wash( javascript )}",{*
    *}"internal_error_string":"{'Internal error'|i18n( 'extension/eztags/tags/treemenu' )|wash( javascript )}"{*
*}{rdelim};
var TagBlockRootTag = {ldelim}{*
    *}"id":0,{*
    *}"parent_id":0,{*
    *}"has_children":true,{*
    *}"keyword":"{"Top level tags"|i18n('extension/eztags/tags/treemenu')|wash(javascript)}",{*
    *}"url":{'tags/dashboard'|ezurl},{*
    *}"icon":"{ezini( 'Icons', 'Default', 'eztags.ini' )|tag_icon}",{*
    *}"modified":currentDate{rdelim};
{literal}
var treeMenu_0;
var tag_tree_select = function (element){
    var self = $(element);
    var parent = self.parent();
    var returnAfterDestroy = parent.find('.tag-block-select.contentstructure').length > 0;
    $('.tag-block-select.contentstructure').remove();
    if (returnAfterDestroy){
        return false;
    }
    var $input = $(element).prev();
    var browserContainer = $('<div class="tag-block-select contentstructure"></div>');
    self.parent().append(browserContainer);
    browserContainer.data('tag_browser_input', $input);
    treeMenu_0 = new TagsStructureMenu(TagBlockSelectStructureMenuParams, '0');
    browserContainer.append($('<ul class="content_tree_menu">').append(treeMenu_0.generateEntry(TagBlockRootTag, false, true)));
    treeMenu_0.load(false, 0, currentDate);
}
$(document).on('click', '.tag-block-select.contentstructure a:not([class^="openclose"])', function(e) {
    e.preventDefault();
    function getParentTagHierarchy(tag, i) {
        if (tag.attr('rel') === '0'){ return i === 0 ? '(no parent)' : ''; }
        var parent = getParentTagHierarchy(tag.parents('div:first').prev('a'), ++i);
        var data = (parent ? parent + '/' : '') + tag.parent().find('span').html();
        return data.split(' (+')[0];
    }
    var tag = $(this);
    var container = tag.parents('.tag-block-select.contentstructure');
    if (tag.parents('li.disabled').length){ return false; }
    var $input = container.data('tag_browser_input');
    var newValue = getParentTagHierarchy(tag, 0);
    if (newValue.length > 0 && tag.attr('rel') > 0) {
        var current = $input.val().length > 0 ? $input.val().split(',') : [];
        current.push(newValue);
        function unique(array) {
            return array.filter(function (el, index, arr) {
                return index === arr.indexOf(el);
            });
        }
        $input.val(unique(current).join(','));
        container.remove();
    }
});

var select_to_string = function(element) {
    var newValue = $(element).val();
    var $input = $(element).next();
    if (newValue.length > 0) {
        var current = $input.val().length > 0 ? $input.val().split(',') : [];
        current.push(newValue);
        function unique(array){
            return array.filter(function(el, index, arr) {
                return index === arr.indexOf(el);
            });
        }
        $input.val(unique(current).join(','));
    }else{
        $input.val('');
    }
}

$(document).ready(function () {
    $(document).on('keydown', 'input, select', function(e){
        if(e.keyCode === 13)
            e.preventDefault();
    });
});
</script>
{/literal}
{/run-once}
