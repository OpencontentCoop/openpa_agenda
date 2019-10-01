{if is_set( $view_parameters.forum )}
  {def $forum = fetch( content, node, hash( node_id, $view_parameters.forum ) )}
{/if}

{def $current_reply = false()}
{if and( is_set( $view_parameters.reply ), $view_parameters.reply|gt(0) )}
  {set $current_reply = fetch( content, node, hash( node_id, $view_parameters.reply ) )}
{/if}

{def $view_parameters_string = ''}
{foreach $view_parameters as $key => $value}
  {set $view_parameters_string = concat( $view_parameters_string, '/(', $key, ')/', $value )}
{/foreach}
{set-block variable=$comment_form}
<form id="edit" class="edit col-md-12 col-xs-12" enctype="multipart/form-data" method="post" action={concat("/content/edit/",$object.id,"/",$edit_version,"/",$edit_language|not|choose(concat($edit_language,"/"),''),$view_parameters_string,'#edit')|ezurl}>

<div class="panel panel-default">

  {if is_set($forum)}
    <div class="panel-heading">
      <h4 class="panel-title">
        {if $current_reply}
          {'Enter answer'|i18n('agenda/event/comments')}
        {else}
          {'Insert your comment'|i18n('agenda/event/comments')}
        {/if}
      </h4>
    </div>
  {/if}

  <div class="panel-body">

    {section show=$validation.processed}
    {section show=or( $validation.attributes, $validation.placement, $validation.custom_rules )}
      <div class="alert alert-warning alert-dismissible" role="alert">
        <button type="button" class="close" data-dismiss="alert">
          <span aria-hidden="true">&times;</span><span class="sr-only">{'Close'|i18n('agenda')}</span></button>
        {section show=$validation.attributes}
          <p>{'Required data is either missing or is invalid'|i18n( 'design/admin/content/edit' )}:</p>
          <ul class="list-unstyled">
            {section var=UnvalidatedAttributes loop=$validation.attributes}
              <li><strong>{$UnvalidatedAttributes.item.name|wash}:</strong> {$UnvalidatedAttributes.item.description}</li>
            {/section}
          </ul>
        {/section}

        {section show=$validation.placement}
          <p>{'The following locations are invalid'|i18n( 'design/admin/content/edit' )}:</p>
          <ul class="list-unstyled">
            {section var=UnvalidatedPlacements loop=$validation.placement}
              <li>{$UnvalidatedPlacements.item.text}</li>
            {/section}
          </ul>
        {/section}

        {section show=$validation.custom_rules}
          <p>{'The following data is invalid according to the custom validation rules'|i18n( 'design/admin/content/edit' )}:</p>
          <ul class="list-unstyled">
            {section var=UnvalidatedCustomRules loop=$validation.custom_rules}
              <li>{$UnvalidatedCustomRules.item.text}</li>
            {/section}
          </ul>
        {/section}
      </div>

      {section-else}

        {section show=$validation_log}
          <div class="alert alert-warning alert-dismissible" role="alert">
            <button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">{'Close'|i18n('agenda')}</span></button>
            {section var=ValidationLogs loop=$validation_log}
              <p>{$ValidationLogs.item.name|wash}:</p>
              <ul>
                {section var=LogMessages loop=$ValidationLogs.item.description}
                  <li>{$LogMessages.item}</li>
                {/section}
              </ul>
            {/section}
          </div>
        {/section}
      {/section}
    {/section}

    {if ezini_hasvariable( 'EditSettings', 'AdditionalTemplates', 'content.ini' )}
      {foreach ezini( 'EditSettings', 'AdditionalTemplates', 'content.ini' ) as $additional_tpl}
        {include uri=concat( 'design:', $additional_tpl )}
      {/foreach}
    {/if}

    {default $attribute_categorys        = ezini( 'ClassAttributeSettings', 'CategoryList', 'content.ini' ) $attribute_default_category = ezini( 'ClassAttributeSettings', 'DefaultCategory', 'content.ini' )}

    {def $count = 0}
    {foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
      {if $attribute_group|ne('hidden')}
        {set $count = $count|inc()}
      {/if}
    {/foreach}

    {if $count|gt(1)}
      {set $count = 0}
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
                  <label>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                    {if $attribute.can_translate|not} <span class="nontranslatable">({'not translatable'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}:
                    {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                  </label>
                </div>
                <div class="col-md-8">
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
                    <label{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                      {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                      {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}:
                      {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                    </label>
                  </div>
                  <div class="col-md-8">
                    <div class="original">
                      {attribute_view_gui attribute_base=$attribute_base attribute=$from_content_attributes_grouped_data_map[$attribute_group][$attribute_identifier] view_parameters=$view_parameters}
                    </div>
                    <div class="translation">
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
                      {if $contentclass_attribute.data_type_string|ne('ezboolean')}
                        <p{if $attribute.has_validation_error} class="message-error"{/if}>
                          <span style="white-space: nowrap">{first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}{if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}</span>
                          {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}
                        </p>
                      {/if}
                    </div>
                    <div class="col-md-9">
                      {if $contentclass_attribute.description} <span class="classattribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</span>{/if}
                      {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                      <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}" />
                    </div>
                  {/if}
                {/if}
              {/if}
            </div>
            {undef $contentclass_attribute}
          {/foreach}
        </div>
      {/foreach}
    </div>

    <div class="buttonblock">
      <input class="btn btn-lg btn-danger pull-right" type="submit" name="PublishButton" value="{'Publish your comment'|i18n('agenda/event/comments')}" />
      <input class="btn btn-lg btn-warning" type="submit" name="DiscardButton" value="{'Cancel'|i18n('agenda/event/comments')}" />
      <input type="hidden" name="DiscardConfirm" value="0" />
      <input type="hidden" name="RedirectIfDiscarded" value="{if is_set( $forum )}{concat('agenda/event/',$forum.node_id,'/(offset)/',$view_parameters.offset)}{else}/agenda{/if}" />
      <input type="hidden" name="RedirectURIAfterPublish" value="{if is_set( $forum )}{concat('agenda/event/',$forum.node_id,'/(offset)/',$view_parameters.offset)}{else}/agenda{/if}" />
    </div>

    {/default}

  </div>
</div>

</form>
{/set-block}

{if is_set( $forum )}
  {include uri='design:agenda/event.tpl' node=$forum comment_form=$comment_form current_reply=$current_reply}
{else}
  {$comment_form}
{/if}