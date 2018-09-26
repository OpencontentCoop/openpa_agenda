{default attribute_base=ContentObjectAttribute}
    <div id="uploader_{$attribute_base}_data_multibinaryfilename_{$attribute.id}">

        {def $file_count = 0}

        {if $attribute.has_content}
            <table class="list" cellpadding="0" cellspacing="0">
                <tr>
                    <th>
                        File allegati:
                        <button class="btn btn-default btn-xs pull-right" type="submit"
                                name="CustomActionButton[{$attribute.id}_delete_binary]" title="Rimuovi tutti i file">
                            Elimina tutti i file
                        </button>
                    </th>
                </tr>
                {foreach $attribute.content as $file}
                    <tr>
                        <td>
                            <button class="ocmultibutton btn btn-link btn-xs" type="submit"
                                    name="CustomActionButton[{$attribute.id}_delete_multibinary][{$file.filename}]"
                                    title="Rimuovi questo file"><img src="{'trash.png'|ezimage(no)}"/></button>
                            {$file.original_filename|wash( xhtml )}&nbsp;({$file.filesize|si( byte )})
                        </td>
                    </tr>
                {/foreach}
            </table>
        {else}
            <p>Nessun file caricato.</p>
        {/if}

        {if $attribute.has_content}
            {set $file_count = $attribute.content|count()}
        {/if}
        {if or($file_count|lt( $attribute.contentclass_attribute.data_int2 ), $attribute.contentclass_attribute.data_int2|eq(0) )}
            <div class="block">
                <label class="ocmultilabel"
                       for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">{'New file for upload'|i18n( 'design/standard/content/datatype' )}
                    :</label>
                <input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1}000000"/>
                <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                       class="box ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       name="{$attribute_base}_data_multibinaryfilename_{$attribute.id}" type="file"/>
                <input class="ocmultibutton btn btn-default btn-sm" type="submit"
                       name="CustomActionButton[{$attribute.id}_upload_multibinary]" value="Allega file"
                       title="Allega il file"/>
            </div>
        {/if}


    </div>
{/default}