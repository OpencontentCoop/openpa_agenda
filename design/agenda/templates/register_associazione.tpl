<div class="service_teaser vertical row">
    <div class="service_details clearfix">

        <section class="hgroup">
            <h1>{'Registra nuova associazione'|i18n('agenda/signupassociazione')}</h1>
        </section>

        {if $success}

            <div class="alert alert-info text-center">
                <i class="fa fa-check fa-5x"></i>
                <h3>{"I dati sono stati salvati e inviati per la validazione"|i18n('agenda/signupassociazione')}</h3>
                <h4>{"Quando saranno validati ti verrà inviata una notifica mail all'indirizzo che hai specificato"|i18n('social_user/signup')}</h4>
            </div>

        {else}
        <form enctype="multipart/form-data" action="{"agenda/associazioni/register/"|ezurl(no)}" method="post"
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

            {def $exclude = array('data_archiviazione', 'data_inizio_validita', 'cod_associazione', 'circoscrizione', 'argomento')}

            {if count($content_attributes)|gt(0)}
                {foreach $content_attributes as $attribute}
                    {def $class_attribute = $attribute.contentclass_attribute}

                    {if $exclude|contains($class_attribute.identifier)}
                        {undef $class_attribute}
                        {skip}
                    {/if}

                    {if or($class_attribute.category|eq('content'), $class_attribute.category|eq(''))}
                        <div class="row edit-row ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$class_attribute.identifier}">
                            <div class="col-md-3">
                                <p{if $attribute.has_validation_error} class="message-error"{/if}>{first_set( $class_attribute.nameList[$content_language], $class_attribute.name )|wash}
                                    {if $attribute.is_required} <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                    {if $attribute.is_information_collector} <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>{/if}
                                </p>
                            </div>
                            <div class="col-md-9">
                                {if $class_attribute.description} <span
                                        class="classattribute-description">{first_set( $class_attribute.descriptionList[$content_language], $class_attribute.description)|wash}</span>{/if}
                                {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                <input type="hidden" name="ContentObjectAttribute_id[]"
                                       value="{$attribute.id}"/>
                            </div>
                        </div>
                    {/if}

                    {undef $class_attribute}
                {/foreach}

                <div class="">
                    {def $bypass_captcha = false()}
                    {if $bypass_captcha|not}
                    <div class="row">
                        <div class="col-md-3">
                            <p>{'Codice di sicurezza'|i18n( 'social_user/signup' )}</p>
                        </div>
                        <div class="col-md-9">
                            {if ezini( 'RecaptchaSetting', 'PublicKey', 'ezcomments.ini' )|eq('')}
                                <div class="message-warning">
                                    {'reCAPTCHA API key non trovata'|i18n( 'social_user/signup' )}
                                </div>
                            {else}
                                <script type="text/javascript">
                                    {def $theme = ezini( 'RecaptchaSetting', 'Theme', 'ezcomments.ini' )}
                                    {def $language = ezini( 'RecaptchaSetting', 'Language', 'ezcomments.ini' )}
                                    {def $tabIndex = ezini( 'RecaptchaSetting', 'TabIndex', 'ezcomments.ini' )}
                                    var RecaptchaOptions = {literal}{{/literal} theme : '{$theme}',
                                        lang : '{$language}',
                                        tabindex : {$tabIndex} {literal}}{/literal};
                                </script>
                            {if $theme|eq('custom')}
                                {*Customized theme start*}
                                <p>
                                    {'Inserisci il codice di sicurezza'|i18n( 'social_user/signup' )}
                                    <a href="javascript:;" onclick="Recaptcha.reload();">
                                        {'Clicca qui per ottenere un nuovo codice'|i18n( 'social_user/signup' )}
                                    </a>
                                </p>
                                <div id="recaptcha_image"></div>
                                <div style="width: 300px;">
                                    <p>
                                        <input style="width: 300px;font-size: 2em" type="text" class="box" id="recaptcha_response_field" name="recaptcha_response_field" />
                                    </p>
                                </div>
                                {*Customized theme end*}
                            {/if}
                                {fetch( 'social_user', 'recaptcha_html' )}

                            {/if}
                        </div>
                    </div>
                    {/if}
                    {undef $bypass_captcha}
                </div>

                <div class="buttonblock">
                    <input type="hidden" name="UserID" value="{$content_attributes[0].contentobject_id}"/>
                    <input class="btn btn-lg btn-primary pull-right" type="submit" id="PublishButton"
                           name="PublishButton" value="{'Registra'|i18n('agenda/signupassociazione')}"
                           onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
                    <input class="btn btn-lg btn-inverse pull-left" type="submit" id="CancelButton"
                           name="CancelButton"
                           value="{'Annulla'|i18n('agenda/signupassociazione')}"
                           onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
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