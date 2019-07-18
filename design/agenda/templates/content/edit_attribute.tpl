{default $view_parameters   = array()
         $attribute_categorys        = ezini( 'ClassAttributeSettings', 'CategoryList', 'content.ini' )
         $attribute_default_category = ezini( 'ClassAttributeSettings', 'DefaultCategory', 'content.ini' )}


{def $hasLimitedEdit = current_user_has_limited_edit_agenda_event($object, $edit_version)}

{def $count = 0}
{foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
    {if $attribute_group|ne('hidden')}
        {set $count = $count|inc()}
    {/if}
{/foreach}

{if $count|gt(1)}
<ul class="nav nav-tabs">    
    {set $count = 0}
    {foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
        {if $attribute_group|ne('hidden')}
            <li class="{if $count|eq(0)} active{/if}">
                <a data-toggle="tab" href="#attribute-group-{$attribute_group}">{$attribute_categorys[$attribute_group]}</a>
            </li>
            {set $count = $count|inc()}
        {/if}
    {/foreach}    
</ul>
{/if}

<div class="tab-content">
    {set $count = 0}
    {foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
        <div class="clearfix attribute-edit tab-pane{if $count|eq(0)} active{/if}" id="attribute-group-{$attribute_group}">
            {set $count = $count|inc()}

            {foreach $content_attributes_grouped as $attribute_identifier => $attribute}
                {def $contentclass_attribute = $attribute.contentclass_attribute}
                <div class="row edit-row ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$attribute_identifier}">
                    {* Show view GUI if we can't edit, otherwise: show edit GUI. *}
                    {if and( eq( $attribute.can_translate, 0 ), ne( $object.initial_language_code, $attribute.language_code ) )}
                        <div class="col-md-3">
                            <p>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                {if $attribute.can_translate|not} <span class="nontranslatable">({'not translatable'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}:
                                {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                            </p>
                        </div>
                        <div class="col-md-9">
                            {if $is_translating_content}
                                <div class="original">
                                    {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                </div>
                            {else}
                                {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                            {/if}
                        </div>
                    {else}
                        {if $is_translating_content}
                            <div class="col-md-3">
                                <p{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                    {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                    {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}:
                                    {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                                </p>
                            </div>
                            <div class="col-md-9">
                                <div class="well well-sm">
                                    {attribute_view_gui attribute_base=$attribute_base attribute=$from_content_attributes_grouped_data_map[$attribute_group][$attribute_identifier] view_parameters=$view_parameters image_class=medium}
                                </div>
                                <div>
                                    {if $attribute.display_info.edit.grouped_input}
                                        <fieldset>
                                            {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                            <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                        </fieldset>
                                    {else}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                    {/if}
                                </div>
                            </div>
                        {else}
                            {if and($hasLimitedEdit, current_user_has_limited_edit_agenda_event_attribute($attribute))}
                                <div class="col-md-3">
                                    <p{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                        {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                        {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}
                                    </p>
                                </div>
                                <div class="col-md-9">
                                    {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                    <div style="display: none !important;">
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                    </div>
                                </div>
                            {else}
                                {if $attribute.display_info.edit.grouped_input}
                                    <div class="col-md-3">
                                        <p{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                            {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                            {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}
                                        </p>
                                    </div>
                                    <div class="col-md-9">
                                        {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                    </div>
                                {else}
                                    <div class="col-md-3">
                                        <p{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                            {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                            {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}
                                        </p>
                                    </div>
                                    <div class="col-md-9">
                                        {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                                    </div>
                                {/if}
                            {/if}
                        {/if}
                    {/if}
                </div>
                {undef $contentclass_attribute}
            {/foreach}
        </div>
    {/foreach}
</div>
