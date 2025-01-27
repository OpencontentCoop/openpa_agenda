{* DO NOT EDIT THIS FILE! Use an override template instead. *}
<div class="row">
    <div class="col">
        <strong class="d-block">{'User ID'|i18n( 'design/standard/content/datatype' )}:</strong>
        {$attribute.content.contentobject_id}
    </div>

    <div class="col">
        <strong class="d-block">{'Username'|i18n( 'design/standard/content/datatype' )}:</strong>
        {$attribute.content.login|wash( xhtml )}
    </div>

    <div class="col">
        <strong class="d-block">{'Email'|i18n( 'design/standard/content/datatype' )}:</strong>
        <a href="mailto:{$attribute.content.email|wash}">{$attribute.content.email|wash}</a>
    </div>
{if fetch('user', 'has_access_to', hash('module', 'switch', 'function', 'user' ))}
    <div class="col-12 my-3">
        <strong>{'Account status'|i18n( 'design/admin/content/datatype/ezuser' )}:</strong>
        {if $attribute.content.is_enabled}
            <span class="userstatus-enabled">{'enabled'|i18n( 'design/standard/content/datatype' )}</span>
        {else}
            <span class="userstatus-disabled"> {'disabled'|i18n( 'design/standard/content/datatype' )}</span>
        {/if}
        {if $attribute.content.is_locked}
            (<span class="userstatus-disabled">{'locked'|i18n( 'design/standard/content/datatype' )}</span>)
        {/if}
        <a class="d-block" href={concat( '/user/setting/', $attribute.contentobject_id )|ezurl}
        title="{'Enable/disable the user account and set the maximum allowed number of concurrent logins.'}">
            {'Configure user account settings'|i18n( 'design/standard/content/datatype' )}</a>
    </div>
{/if}
</div>
