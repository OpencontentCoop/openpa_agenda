{def $show_login = cond(is_login_enabled(), true(), false())
     $show_signup = cond(is_registration_enabled(), true(), false())
     $show_associazioni_signup = cond(is_auto_registration_enabled(), true(), false())}
{def $has_gdpr = false()}
{if or($show_login, $show_signup, $show_associazioni_signup)}
<section class="hgroup" id="login">
    {if is_comment_enabled()}
    <div class="row">
        <div class="col-sm-12 col-md-12 text-center">
            <h1 style="margin-bottom: 1em">
              {'In order to leave comments, you need to be logged in'|i18n('agenda')}
            </h1>
        </div>
    </div>
    {/if}

    {def $col_signin_container = 'col-sm-6 col-md-4'
         $col_signup_container = 'col-sm-6 col-md-4'
         $col_signupassociazione_container = 'col-sm-6 col-md-4'
         $col_signin_inside = 'col-sm-12'
         $col_signup_inside = 'col-sm-12'}

    {if and($show_login, $show_signup|not(), $show_associazioni_signup|not())}
        {set $col_signin_container = 'col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3'
             $col_signin_inside = 'col-sm-12 col-md-8 col-md-offset-2'}
    {/if}

    {if and($show_login, $show_signup, $show_associazioni_signup|not())}
        {set $col_signin_container = 'col-sm-6 col-md-6'
             $col_signup_container = 'col-sm-6 col-md-6'
             $col_signin_inside = 'col-sm-12 col-md-8 col-md-offset-2'
             $col_signup_inside = 'col-sm-12 col-md-8 col-md-offset-2'}
    {/if}

    {if and($show_login, $show_signup|not(), $show_associazioni_signup)}
        {set $col_signin_container = 'col-sm-6 col-md-6'
             $col_signupassociazione_container = 'col-sm-6 col-md-6'
             $col_signin_inside = 'col-sm-12 col-md-8 col-md-offset-2'}
    {/if}

    {if and($show_login|not(), $show_signup, $show_associazioni_signup)}
        {set $col_signup_container = 'col-sm-6 col-md-6'
             $col_signupassociazione_container = 'col-sm-6 col-md-6'
             $col_signup_inside = 'col-sm-12 col-md-8 col-md-offset-2'}
    {/if}

    {if and($show_login|not(), $show_signup, $show_associazioni_signup|not())}
        {set $col_signup_container = 'col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3'
             $col_signup_inside = 'col-sm-12 col-md-8 col-md-offset-2'}
    {/if}

    {if and($show_login|not(), $show_signup|not(), $show_associazioni_signup)}
        {set $col_signupassociazione_container = 'col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3'}
    {/if}


    <div class="row">
        {if $show_login}
        <div class="{$col_signin_container}">
            <div class="signin">
                <div class="social_sign">
                    <h3>
                        {'Are you already a member?'|i18n('social_user/signin')}
                        <strong>{'Log in now!'|i18n('social_user/signin')}</strong>
                    </h3>
                </div>
                <hr />
                <div class="row">
                    <div class="form {$col_signin_inside}">
                        <form name="loginform" method="post" action={'/user/login/'|ezurl}>
                            <input autocomplete="off" placeholder="{'Indirizzo Email'|i18n('social_user/signin')}" class="form-control" type="text" name="Login">
                            <input autocomplete="off" placeholder="{'Password'|i18n('social_user/signin')}" class="form-control" type="password" name="Password">
                            <button name="LoginButton" type="submit" class="btn btn-primary btn-lg">{'Log in'|i18n('social_user/signin')}</button>
                            <hr />
                            <div class="forgot">
                              {if ezmodule( 'userpaex' )}
                                <a href={'/userpaex/forgotpassword'|ezurl}>{'Did you forget your password?'|i18n('social_user/signin')}</a>
                              {else}
                                <a href={'/user/forgotpassword'|ezurl}>{'Did you forget your password?'|i18n('social_user/signin')}</a>
                              {/if}
                            </div>
                            <input type="hidden" name="RedirectURI" value="/" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
        {/if}
        {if $show_signup}
        <div class="{$col_signup_container}">
            <div class="signup">
                <form name="signupform" method="post" action={'/social_user/signup/'|ezurl}>
                    <fieldset>
                        <div class="social_sign">
                            <h3>
                                <strong>{'Are you not registered yet?'|i18n('social_user/signup')}<br /></strong>
                                {'It takes just 5 seconds to register!'|i18n('social_user/signup')}
                            </h3>
                        </div>
                        {*<p class="sign_title">{'Create an account now: it's easy and free!'|i18n('social_user/signup')}</p>*}
                        <div class="row">
                            <div class="{$col_signup_inside}">
                                <input autocomplete="off" id="Name" name="Name" placeholder="{'Name and surname'|i18n('social_user/signup')}" class="form-control" required="" type="text" value="{if is_set($name)}{$name}{/if}" />
                                <input autocomplete="off" id="Emailaddress" name="EmailAddress" placeholder="{'Email address'|i18n('social_user/signup')}" class="form-control" required="" type="text" value="{if is_set($email)}{$email}{/if}" />
                                <input autocomplete="off" id="Password" name="Password" placeholder="{'Password'|i18n('social_user/signup')}" class="form-control" required="" type="password">
                                {foreach signup_custom_fields() as $custom_field}
                                    {include uri=$custom_field.template custom_field=$custom_field}
                                    {if and($custom_field.is_valid, is_set($custom_field.gdpr_text))}
                                        {set $has_gdpr = true()}
                                    {/if}
                                {/foreach}
                            </div>
                        </div>
                        {if and( is_set( $terms_url ), is_set( $privacy_url ), $has_gdpr|not() )}
                            <div class="row">
                                <div class="col-md-12">
                                    <small>
                                        {"Clicking the Subscribe button you accept <a href=%term_url>the terms of use</a> and confirm that you have read our <a href=%privacy_url>Privacy Policy</a>"|i18n('social_user/signup',, hash( '%term_url', $terms_url, '%privacy_url', $privacy_url ))}
                                    </small>
                                </div>
                            </div>
                        {/if}
                        <button name="RegisterButton" type="submit" class="btn btn-success btn-lg" style="margin-top: 18px">{'Subscribe'|i18n('social_user/signup')}</button>
                    </fieldset>
                </form>
            </div>
        </div>
        {/if}
        {if $show_associazioni_signup}
        <div class="{$col_signupassociazione_container}">
            <div class="signup">
                <form name="signupassociazioneform" method="post" action={'agenda/register_associazione'|ezurl}>
                    <fieldset>
                        <div class="social_sign">
                            <h3>
                                <strong>{'Do you want to register your association?'|i18n('agenda/signupassociazione')}<br /></strong>
                            </h3>
                        </div>
                        <hr />
                        <p>
                            {"To register an association, you must click on the button and fill out the required info. After our operators have checked your info, you can use the credentials you've chosen to log in and post new events."|i18n('agenda/signupassociazione')}
                        </p>
                        <div class="row">
                            <div class="col-lg-12">
                            </div>
                        </div>
                        <button name="RegisterAssociazioneButton" type="submit" class="btn btn-success btn-lg" style="margin-top: 18px">{'Register an association'|i18n('agenda/signupassociazione')}</button>
                    </fieldset>
                </form>
            </div>
        </div>
        {/if}
    </div>
</section>
{/if}
{undef $has_gdpr}


{ezscript_require(array("password-score/password.js"))}
{literal}
  <script type="text/javascript">
    $(document).ready(function() {
      $('.password-field').password({
        strengthMeter:false,
        message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}",
      });
    });
  </script>
{/literal}
