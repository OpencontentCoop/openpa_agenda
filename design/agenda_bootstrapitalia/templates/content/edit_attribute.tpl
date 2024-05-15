{default $view_parameters = array()}


{def $edit_attribute_groups = edit_attribute_groups($class, $content_attributes, array())}

<div class="row mt-4 mb-5">
    {if $edit_attribute_groups.count|gt(1)}
        <div class="col-3 affix-parent">
            <ul id="edit-groups" class="affix-top nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical">
                <li class="pl-0 pt-4 pb-2 text-uppercase"><span>{'Table of contents'|i18n('bootstrapitalia')}</span></li>
                {foreach $edit_attribute_groups.groups as $index => $attribute_group}
                    {if $attribute_group.show}
                        <li class="nav-item">
                            <a class="nav-link pl-0{if $index|eq(0)} active{/if}" data-bs-toggle="tab" data-toggle="tab" data-bs-target="#attribute-group-{$attribute_group.identifier}"
                               href="#attribute-group-{$attribute_group.identifier}">{$attribute_group.label|wash()}</a>
                        </li>
                    {/if}
                {/foreach}
            </ul>
        </div>
    {/if}

    <div class="col{if $edit_attribute_groups.count|gt(1)}-9{/if} tab-content">
        {foreach $edit_attribute_groups.groups as $index => $attribute_group}
            <div class="position-relative clearfix attribute-edit tab-pane{if $index|eq(0)} active{/if} p-2 mt-2" id="attribute-group-{$attribute_group.identifier}"{if $attribute_group.show|not()} style="display: none !important;"{/if}>
                {foreach $attribute_group.attributes as $attribute_identifier => $attribute}

                    {def $contentclass_attribute = $attribute.contentclass_attribute}
                    {def $contentclass_attribute_category = $contentclass_attribute.category}
                    {if $contentclass_attribute_category|eq('')}
                        {set $contentclass_attribute_category = ezini('ClassAttributeSettings', 'DefaultCategory', 'content.ini')}
                    {/if}
                    <div id="edit-{$attribute_identifier}"
                         data-attribute_group="{$attribute_group.identifier}"
                         data-attribute_identifier="{$attribute_identifier}"
                         class="anchor-offset row border rounded border-light p-3 mb-4 ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$attribute_identifier}{if $attribute.is_required|not()} attribute-not-required{/if}">
                        {* Show view GUI if we can't edit, otherwise: show edit GUI. *}
                        {if and( eq( $attribute.can_translate, 0 ), ne( $object.initial_language_code, $attribute.language_code ) )}
                            <div class="col-12">
                                <h5>
                                    {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}{if $attribute.can_translate|not}<span class="nontranslatable">({'not translatable'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}:
                                    {if $contentclass_attribute.description}
                                        <small class="lora text-muted mb-3 d-block">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                    {/if}
                                </h5>
                            </div>
                            <div class="col-12">
                                {if $is_translating_content}
                                    <div class="original">
                                        {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                    </div>
                                {else}
                                    {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                {/if}
                            </div>
                        {else}
                            {if $is_translating_content}
                                <div class="col-12">
                                    <h5{if $attribute.has_validation_error} class="text-danger"{/if}>
                                        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                        {if $attribute.is_required}
                                        <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                        {if $attribute.is_information_collector}
                                            <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                        {/if}
                                        {if $contentclass_attribute.description}
                                            <small class="lora text-muted mb-3 d-block">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                        {/if}
                                    </h5>
                                </div>
                                <div class="col-12">
                                    <div class="card bg-light mb-2">
                                        <div class="card-body">
                                            {attribute_view_gui attribute_base=$attribute_base attribute=$from_content_attributes_grouped_data_map[$contentclass_attribute_category][$attribute_identifier] view_parameters=$view_parameters image_class=medium}
                                        </div>
                                    </div>
                                    <div>
                                        {if $attribute.display_info.edit.grouped_input}
                                            <fieldset>
                                                {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                                <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                            </fieldset>
                                        {else}
                                            {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                            <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                        {/if}
                                    </div>
                                </div>
                            {else}
                                {if $attribute.display_info.edit.grouped_input}
                                    <div class="col-12">
                                        <h5{if $attribute.has_validation_error} class="text-danger"{/if}>
                                            {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                            {if $attribute.is_required}
                                            <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                            {if $attribute.is_information_collector}
                                                <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                            {/if}
                                        </h5>
                                    </div>
                                    <div class="col-12">
                                        {if $contentclass_attribute.description}
                                            <small class="lora text-muted mb-3 d-block">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                        {/if}
                                        {if array('ezimage', 'ezbinaryfile', 'ocmultibinary')|contains($contentclass_attribute.data_type_string)}
                                            <small class="lora text-muted mb-3 d-block">
                                                {'Max file size'|i18n( 'design/standard/class/datatype' )}: {$contentclass_attribute.data_int1|max_upload_size()} MB
                                            </small>
                                        {/if}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                    </div>
                                {else}
                                    <div class="col-12">
                                        <h5{if $attribute.has_validation_error} class="text-danger"{/if}>
                                            {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                            {if $attribute.is_required}
                                                <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>
                                            {/if}
                                            {if $attribute.is_information_collector}
                                                <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                            {/if}
                                        </h5>
                                    </div>
                                    <div class="col-12">
                                        {if $contentclass_attribute.description}
                                            <small class="lora text-muted mb-3 d-block">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                        {/if}
                                        {if array('ezimage', 'ezbinaryfile', 'ocmultibinary')|contains($contentclass_attribute.data_type_string)}
                                            <small class="lora text-muted mb-3 d-block">
                                                {'Max file size'|i18n( 'design/standard/class/datatype' )}: {$contentclass_attribute.data_int1|max_upload_size()} MB
                                            </small>
                                        {/if}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                    </div>
                                {/if}
                            {/if}
                        {/if}
                    </div>
                    {undef $contentclass_attribute $contentclass_attribute_category}
                {/foreach}

            </div>
        {/foreach}
    </div>
</div>
