{* DO NOT EDIT THIS FILE! Use an override template instead. *}
{default input_handler=$attribute.content.input
         attribute_base='ContentObjectAttribute'
         html_class='full' placeholder=false()}
{if $placeholder}<label>{$placeholder}</label>{/if}
    <textarea class="{$html_class}" id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}" class="box ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" name="{$attribute_base}_data_text_{$attribute.id}" cols="97" rows="{$attribute.contentclass_attribute.data_int1}">{$input_handler.input_xml|wash( xhtml )}</textarea>
{/default}