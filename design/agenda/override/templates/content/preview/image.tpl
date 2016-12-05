{foreach $object.data_map as $attribute}
    {if $attribute.data_type_string|eq('ezimage')}
        <div class="well well-sm">
            <p class="text-center">{attribute_view_gui attribute=$attribute image_class=large alignment=center}</p>
            {def $keys = array('width','height','mime_type','filename','alternative_text','url','filesize')}
            <dl class="dl-horizontal">
                {foreach $attribute.content.original as $name => $value}
                    {if $keys|contains($name)}
                        <dt>{$name}</dt>
                        <dd>
                            {if $name|eq('url')}
                                <a target="_blank" href={$value|ezroot()}>{$value|wash()}</a>
                            {elseif $name|eq('filesize')}
                                {$value|si(byte)}
                            {else}
                                {$value|wash()}
                            {/if}
                        </dd>
                    {/if}
                {/foreach}
            </dl>
        </div>
    {/if}
{/foreach}


{foreach $object.data_map as $attribute}

    {if $attribute.data_type_string|ne('ezimage')}
        <div class="row" style="margin-bottom: 8px">
            {*if $attribute.contentclass_attribute_identifier|eq('name')}
                <dt>{$attribute.contentclass_attribute_name}</dt>
                <dd>
                    <div class="input-group">
                        <input type="text" class="form-control" name="ChangeObjectName[{$attribute.object.id}][{$attribute.contentclass_attribute_identifier}]" value="{$attribute.content|wash()}" />
                        <span class="input-group-btn">
                        <button class="btn btn-info searchbutton">
                            <span class="glyphicon glyphicon-floppy-save"></span>
                        </button>
                        </span>
                    </div>
                </dd>
            {else*}
            <div class="col-xs-3 text-right">
                <strong>{$attribute.contentclass_attribute_name}</strong>
            </div>
            <div class="col-xs-9">
                {if array( 'ezstring', 'ezinteger', 'ezkeyword', 'eztext', 'ezobjectrelationlist' )|contains( $attribute.data_type_string )}

                    {def $inputTag = 'input'}
                    {if array( 'eztext' )|contains( $attribute.data_type_string )}
                        {set $inputTag = 'textarea'}
                    {elseif array( 'ezobjectrelationlist' )|contains( $attribute.data_type_string )}
                        {if $attribute.class_content.selection_type|eq(1)}
                            {set $inputTag = 'option:selected'}
                        {elseif $attribute.class_content.selection_type|eq(2)}
                            {set $inputTag = 'input:checked'}
                        {elseif $attribute.class_content.selection_type|eq(3)}
                            {set $inputTag = 'input:checked'}
                        {else}
                            {set $inputTag = 'nullTag'}
                        {/if}
                    {/if}
                    <span>
                        <button class="inline-edit btn btn-xs btn-info" data-input="{$inputTag}"
                                data-objectid="{$attribute.object.id}" data-attributeid="{$attribute.id}"
                                data-version="{$attribute.version}"><span class="glyphicon glyphicon-pencil"></span></button>

                        {attribute_view_gui attribute=$attribute image_class=large}
                    </span>
                    <span class="inline-form" style="display: none">
                        {attribute_edit_gui attribute=$attribute}
                        <button class="btn btn-danger pull-right">Salva</button>
                    </span>
                    {undef $inputTag}

                {else}
                    {attribute_view_gui attribute=$attribute image_class=large}
                {/if}

            </div>
            {*/if*}
        </div>
    {/if}
{/foreach}
