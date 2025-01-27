{default attribute_base=ContentObjectAttribute html_class='full' placeholder=false()}
{if $placeholder}<label>{$placeholder}</label>{/if}

{if ne( $attribute_base, 'ContentObjectAttribute' )}
    {def $id_base = concat( 'ezcoa-', $attribute_base, '-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
{else}
    {def $id_base = concat( 'ezcoa-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
{/if}


    {* Username. *}

{if and( $attribute.content, $attribute.content.has_stored_login, $attribute.content.login|ne(''), $attribute.object.main_node_id|ne(''))}
    <label class="form-label" for="{$attribute_base}_data_user_login_{$attribute.id}_stored_login">{'Username'|i18n( 'design/standard/content/datatype' )}</label>
    <p>
        <input id="{$id_base}_login" autocomplete="off" type="text" name="{$attribute_base}_data_user_login_{$attribute.id}_stored_login" class="{$html_class}" value="{$attribute.content.login|wash()}" disabled="disabled" />
    </p>
    <input id="{$id_base}_login_hidden" type="hidden" name="{$attribute_base}_data_user_login_{$attribute.id}" value="{$attribute.content.login|wash()}" />
{else}
    <label class="form-label" for="{$attribute_base}_data_user_login_{$attribute.id}">{'Username'|i18n( 'design/standard/content/datatype' )}</label>
    <p>
        <input autocomplete="off" {*placeholder="{'Username'|i18n( 'design/standard/content/datatype' )}"*}
               id="{$id_base}_login"
               class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text"
               name="{$attribute_base}_data_user_login_{$attribute.id}" value="{if $attribute.content}{$attribute.content.login|wash()}{/if}" />
    </p>
{/if}
    <label class="form-label" for="{$attribute_base}_data_user_email_{$attribute.id}">{'Email'|i18n( 'design/standard/content/datatype' )}</label>
    <p>
        <input autocomplete="off" {*placeholder="{'Email'|i18n( 'design/standard/content/datatype' )}"*}
              id="{$id_base}_email" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text"
              name="{$attribute_base}_data_user_email_{$attribute.id}"
              value="{if $attribute.content}{$attribute.content.email|wash( xhtml )}{/if}" />
    </p>

    {if ezini( 'UserSettings', 'RequireConfirmEmail' )|eq( 'true' )}
        <p>
            <input autocomplete="off" placeholder="{'Confirm email'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_email_confirm" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_user_email_confirm_{$attribute.id}" value="{cond( ezhttp_hasvariable( concat( $attribute_base, '_data_user_email_confirm_', $attribute.id ), 'post' ), ezhttp( concat( $attribute_base, '_data_user_email_confirm_', $attribute.id ), 'post')|wash( xhtml ), $attribute.content.email )}" />
        </p>
    {/if}
{def $hide_account_password = and($attribute.object.current_version|ne(1), $attribute.content.has_stored_login, $attribute.content.login|ne(''))}
{if $attribute.object.status|eq(1)}
    {set $hide_account_password = true()}
{/if}
{def $password_problem = false()}
{foreach $validation.attributes as $validation_attribute}
    {if $validation_attribute.identifier|eq('password_lifetime')}{set $password_problem = true()}{/if}
{/foreach}

<div class="{if $hide_account_password}hide{/if}">
    {* Password #1. *}
    <label class="form-label" for="{$attribute_base}_data_user_password_{$attribute.id}">{'Password'|i18n( 'design/standard/content/datatype' )}</label>
    <p>
      <input autocomplete="off" {*placeholder="{'Password'|i18n( 'design/standard/content/datatype' )}"*} id="{$id_base}_password"
             class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
            {if $hide_account_password|not()}required{/if}
             type="{if $hide_account_password}hidden{else}password{/if}"
             name="{$attribute_base}_data_user_password_{$attribute.id}"
             value="{if and($attribute.content,$attribute.content.original_password)}{$attribute.content.original_password}{elseif and($password_problem|not(), $attribute.content,$attribute.content.has_stored_login)}_ezpassword{/if}" />
      {include uri='design:parts/password_meter.tpl'}
    </p>

    {* Password #2. *}
    <label class="form-label" for="{$attribute_base}_data_user_password_confirm_{$attribute.id}">{'Confirm password'|i18n( 'design/standard/content/datatype' )}</label>
    <p>
        <input autocomplete="off"
              {*placeholder="{'Confirm password'|i18n( 'design/standard/content/datatype' )}"*} id="{$id_base}_password_confirm"
              class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
              type="{if $hide_account_password}hidden{else}password{/if}"
              name="{$attribute_base}_data_user_password_confirm_{$attribute.id}"
              value="{if and($attribute.content,$attribute.content.original_password_confirm)}{$attribute.content.original_password_confirm}{elseif and($password_problem|not(), $attribute.content,$attribute.content.has_stored_login)}_ezpassword{/if}" />
    </p>
</div>
{undef $hide_account_password}

{if or($attribute.object.current_version|eq(1), $attribute.content, $attribute.content.has_stored_login|not(), $attribute.content.login|eq(''))}
    {ezscript_require(array(
        "password-score/password-score.js",
        "password-score/password-score-options.js",
        "password-score/bootstrap-strength-meter.js",
        "password-score/password.js"
    ))}
    {ezcss_require(array('password-score/password.css'))}
{literal}
    <script type="text/javascript">
        $(document).ready(function() {
            $('#{/literal}{$id_base}{literal}_password').password({
                minLength:{/literal}{ezini('UserSettings', 'MinPasswordLength')}{literal},
                message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}",
                hierarchy: {
                  '0': ['text-danger', "{/literal}{'Evaluation of complexity: bad'|i18n('ocbootstrap')}{literal}"],
                  '10': ['text-danger', "{/literal}{'Evaluation of complexity: very weak'|i18n('ocbootstrap')}{literal}"],
                  '20': ['text-warning', "{/literal}{'Evaluation of complexity: weak'|i18n('ocbootstrap')}{literal}"],
                  '30': ['text-info', "{/literal}{'Evaluation of complexity: good'|i18n('ocbootstrap')}{literal}"],
                  '40': ['text-success', "{/literal}{'Evaluation of complexity: very good'|i18n('ocbootstrap')}{literal}"],
                  '50': ['text-success', "{/literal}{'Evaluation of complexity: excellent'|i18n('ocbootstrap')}{literal}"]
                }
            });
            $('#{/literal}{$id_base}{literal}_password_confirm').password({
              strengthMeter:false,
              message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}"
            });
        });
    </script>
{/literal}
{/if}


{/default}
