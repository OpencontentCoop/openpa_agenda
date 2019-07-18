<div class="service_teaser vertical row">
    <div class="service_details clearfix">

        {if $success}

            <div class="text-center py-5">
                <i class="fa fa-check fa-5x"></i>
                <h3>{"Info were saved and sent for validation"|i18n('agenda/signupassociazione')}</h3>
                <h4>{"When they are validated you will receive an email notification to the email address you entered"|i18n('agenda/signupassociazione')}</h4>
            </div>

        {else}

        <div class="row">
            <div class="col p-3">
                <h1>{'Register a new association'|i18n('agenda/signupassociazione')}</h1>

                {if and(is_set($view_parameters.error), $view_parameters.error|eq('invalid_recaptcha'))}
                <div class="alert alert-danger">
                    <p>{'Security code'|i18n( 'social_user/signup' )} {'Input required.'|i18n( 'kernel/classes/datatypes' )}</p>
                </div>
                {/if}
            </div>
        </div>

        <form enctype="multipart/form-data" action="{"agenda/register_associazione/"|ezurl(no)}" method="post"
              name="RegisterAssociazione"
              class="form-signin">

            {if $validation.processed}
                {if $validation.attributes|count|gt(0)}
                    <div class="alert alert-danger">
                        <ul>
                            {foreach $validation.attributes as $attribute}
                                <li>{$attribute.name}: {$attribute.description}</li>
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            {/if}


            {if count($content_attributes)|gt(0)}
                {def $bypass_captcha = false()}
                {foreach $content_attributes as $attribute}
                    {def $class_attribute = $attribute.contentclass_attribute}

                    {if $class_attribute.is_required}
                        <div id="edit-{$class_attribute.identifier}" class="anchor-offset row p-3 mb-4 ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$class_attribute.identifier}">
                            <div class="col">
                                <h5{if $attribute.has_validation_error} class="text-error"{/if}>
                                    {first_set( $class_attribute.nameList[$content_language], $class_attribute.name )|wash}
                                </h5>
                                {if $class_attribute.description} <small class="form-text text-muted mb-1">{first_set( $class_attribute.descriptionList[$content_language], $class_attribute.description)|wash}</small>{/if}
                                {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                            </div>
                        </div>
                        {if $class_attribute.data_type_string|eq('ocrecaptcha')}
                            {set $bypass_captcha = true()}
                        {/if}
                    {else}
                        <div style="display: none">
                            {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                        </div>
                    {/if}

                    {undef $class_attribute}
                {/foreach}

                <div class="">
                    {if $bypass_captcha|not}
                    <div class="anchor-offset row p-3 mb-4">
                        <div class="col">
                            <h5>{'Security code'|i18n( 'social_user/signup' )}</h5>
                            {if $recaptcha_public_key|not()}
                                <div class="message-warning">
                                    {'reCAPTCHA API key not found'|i18n( 'social_user/signup' )}
                                </div>
                            {else}
                                <div class="g-recaptcha" data-sitekey="{$recaptcha_public_key}"></div>
                                <script type="text/javascript" src="https://www.google.com/recaptcha/api.js?hl={fetch( 'content', 'locale' ).country_code|downcase}"></script>
                            {/if}
                        </div>
                    </div>
                    {/if}
                    {undef $bypass_captcha}
                </div>

                <div class="clearfix">
                    <input class="btn btn-lg btn-success float-right" type="submit" name="PublishButton" value="{'Store'|i18n('ocbootstrap')}" onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
                    <input class="btn btn-lg btn-dark" type="submit" name="CancelButton" value="{'Discard'|i18n('ocbootstrap')}" onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
                </div>

            {else}
                <div class="alert alert-danger">
                    <p>{"Unable to register new user"|i18n("design/ocbootstrap/user/register")}</p>
                </div>
                <input class="btn btn-primary" type="submit" id="CancelButton" name="CancelButton"
                       value="{'Annulla'|i18n('agenda/signupassociazione')}"
                       onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
            {/if}
        </form>
        {/if}
    </div>
</div>

{literal}
    <script type="text/javascript">
        function disableButtons() {
            document.getElementById('PublishButton').disabled = true;
            document.getElementById('CancelButton').disabled = true;
        }
    </script>
{/literal}
