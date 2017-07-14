<section class="hgroup" id="login">
    <div class="row">
        <div class="col-sm-12 col-md-12 text-center">
            <h1 style="margin-bottom: 1em">
                {'Per lasciare i tuoi commenti, devi iscriverti!'|i18n('social_user/signin')}
            </h1>
        </div>
    </div>
    {def $col_container = '6'
         $col_inside = '8 col-md-offset-2'}
    {if and( is_collaboration_enabled(), is_auto_registration_enabled() )}
        {set $col_container = '4'
             $col_inside = '12'}
    {/if}
    <div class="row">
        <div class="col-sm-6 col-md-{$col_container}">
            <div class="signin">
                <div class="social_sign">
                    <h3>
                        {'Sei già iscritto?'|i18n('social_user/signin')}<br />
                        <strong>{'Accedi subito!'|i18n('social_user/signin')}</strong>
                    </h3>
                </div>
                <hr />
                <div class="row">
                    <div class="form col-lg-{$col_inside}">
                        <form name="loginform" method="post" action={'/user/login/'|ezurl}>
                            <input autocomplete="off" placeholder="{'Indirizzo Email'|i18n('social_user/signin')}" class="form-control" type="text" name="Login">
                            <input autocomplete="off" placeholder="{'Password'|i18n('social_user/signin')}" class="form-control" type="password" name="Password">
                            <button name="LoginButton" type="submit" class="btn btn-primary btn-lg">{'Accedi'|i18n('social_user/signin')}</button>
                            <hr />
                            <div class="forgot">
                                <a href={'/user/forgotpassword'|ezurl}>{'Hai dimenticato la password?'|i18n('social_user/signin')}</a>
                            </div>
                            <input type="hidden" name="RedirectURI" value="/" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-md-{$col_container}">
            <div class="signup">
                <form name="signupform" method="post" action={'/social_user/signup/'|ezurl}>
                    <fieldset>
                        <div class="social_sign">
                            <h3>
                                <strong>{'Non sei ancora iscritto?'|i18n('social_user/signup')}<br /></strong>
                                {'Bastano 5 secondi per registrarsi!'|i18n('social_user/signup')}
                            </h3>
                        </div>
                        {*<p class="sign_title">{'Crealo subito: &egrave facile e gratuito!'|i18n('social_user/signup')}</p>*}
                        <div class="row">
                            <div class="col-lg-{$col_inside}">
                                <input autocomplete="off" id="Name" name="Name" placeholder="{'Nome e cognome'|i18n('social_user/signup')}" class="form-control" required="" type="text" value="{if is_set($name)}{$name}{/if}" />
                                <input autocomplete="off" id="Emailaddress" name="EmailAddress" placeholder="{'Indirizzo Email'|i18n('social_user/signup')}" class="form-control" required="" type="text" value="{if is_set($email)}{$email}{/if}" />
                                <input autocomplete="off" id="Password" name="Password" placeholder="{'Password'|i18n('social_user/signup')}" class="form-control" required="" type="password">
                            </div>
                        </div>
                        {if and( is_set( $terms_url ), is_set( $privacy_url ) )}
                            <div class="row">
                                <div class="col-md-12">
                                    <small>
                                        {"Cliccando sul bottone Iscriviti accetti <a href=%term_url>le condizioni di utilizzo</a> e confermi di aver letto la nostra <a href=%privacy_url>Normativa sull'utilizzo dei dati</a>."|i18n('social_user/signup',, hash( '%term_url', $terms_url, '%privacy_url', $privacy_url ))}
                                    </small>
                                </div>
                            </div>
                        {/if}
                        <button name="RegisterButton" type="submit" class="btn btn-success btn-lg" style="margin-top: 18px">{'Iscriviti'|i18n('social_user/signup')}</button>
                    </fieldset>
                </form>
            </div>
        </div>
        {if and( is_collaboration_enabled(), is_auto_registration_enabled() )}
        <div class="col-sm-12 col-md-{$col_container}">
            <div class="signup">
                <form name="signupassociazioneform" method="post" action={'agenda/associazioni/register'|ezurl}>
                    <fieldset>
                        <div class="social_sign">
                            <h3>
                                <strong>{'Vuoi registrare la tua associazione?'|i18n('agenda/signupassociazione')}<br /></strong>
                            </h3>
                        </div>
                        <hr />
                        <p>
                            {"Per registrare un'associazione, devi cliccare sul bottone e compilare i dati richiesti. Dopo la validazione dei dati da parte di un nostro operatore, potrai usare le credenziali che hai inserito per pubblicare nuovi eventi."|i18n('agenda/signupassociazione')}
                        </p>
                        <div class="row">
                            <div class="col-lg-12">
                            </div>
                        </div>
                        <button name="RegisterAssociazioneButton" type="submit" class="btn btn-success btn-lg" style="margin-top: 18px">{'Registra associazione'|i18n('agenda/signupassociazione')}</button>
                    </fieldset>
                </form>
            </div>
        </div>
        {/if}
    </div>
</section>
