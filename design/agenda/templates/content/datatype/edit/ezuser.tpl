{ezscript_require(array(
  "password-score/password-score.js",
  "password-score/password-score-options.js",
  "password-score/bootstrap-strength-meter.js"
))}

{default attribute_base=ContentObjectAttribute html_class='full' placeholder=false()}
{if $placeholder}<label>{$placeholder}</label>{/if}
    <!-- {$attribute.content.contentobject_id} {$attribute.content.is_enabled} -->

{if ne( $attribute_base, 'ContentObjectAttribute' )}
    {def $id_base = concat( 'ezcoa-', $attribute_base, '-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
{else}
    {def $id_base = concat( 'ezcoa-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
{/if}


    {* Username. *}

{if and( $attribute.content.has_stored_login, $attribute.content.login|ne(''), $attribute.object.main_node_id|ne(''))}
    <p><input id="{$id_base}_login" autocomplete="off" type="text" name="{$attribute_base}_data_user_login_{$attribute.id}_stored_login" class="{$html_class}" value="{$attribute.content.login|wash()}" disabled="disabled" /></p>
    <input id="{$id_base}_login_hidden" type="hidden" name="{$attribute_base}_data_user_login_{$attribute.id}" value="{$attribute.content.login|wash()}" />
{else}
    <input autocomplete="off" placeholder="{'Username'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_login" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_user_login_{$attribute.id}" value="{$attribute.content.login|wash()}" />
{/if}

    {* Email. *}
    <p><input autocomplete="off" placeholder="{'Email'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_email" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_user_email_{$attribute.id}" value="{$attribute.content.email|wash( xhtml )}" /></p>

    {* Email #2. Require e-mail confirmation *}
{if ezini( 'UserSettings', 'RequireConfirmEmail' )|eq( 'true' )}
    <p><input autocomplete="off" placeholder="{'Confirm email'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_email_confirm" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_user_email_confirm_{$attribute.id}" value="{cond( ezhttp_hasvariable( concat( $attribute_base, '_data_user_email_confirm_', $attribute.id ), 'post' ), ezhttp( concat( $attribute_base, '_data_user_email_confirm_', $attribute.id ), 'post')|wash( xhtml ), $attribute.content.email )}" /></p>
{/if}

    {* Password #1. *}
    <p>
      <input autocomplete="off" placeholder="{'Password'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_password" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="password" name="{$attribute_base}_data_user_password_{$attribute.id}" value="{if $attribute.content.original_password}{$attribute.content.original_password}{else}{if $attribute.content.has_stored_login}_ezpassword{/if}{/if}" />
      <span id="{$id_base}_help" style="font-size: .8em"></span>
    </p>

    {* Password #2. *}
    <p><input autocomplete="off" placeholder="{'Confirm password'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_password_confirm" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="password" name="{$attribute_base}_data_user_password_confirm_{$attribute.id}" value="{if $attribute.content.original_password_confirm}{$attribute.content.original_password_confirm}{else}{if $attribute.content.has_stored_login}_ezpassword{/if}{/if}" /></p>


  <script type="text/javascript">
    $(document).ready(function() {ldelim}
      $('#{$id_base}_password').strengthMeter('text', {ldelim}
        container: $('#{$id_base}_help'),
        hierarchy: {ldelim}
        '0':  ['text-danger', 'Valutazione della complessità: pessima'],
        '10': ['text-danger', 'Valutazione della complessità: molto debole'],
        '20': ['text-warning', 'Valutazione della complessità: debole'],
        '30': ['text-info', 'Valutazione della complessità: buona'],
        '40': ['text-success', 'Valutazione della complessità: molto buona'],
        '50': ['text-success', 'Valutazione della complessità: ottima']
          {rdelim}
        {rdelim});
      {rdelim});
  </script>


{/default}
