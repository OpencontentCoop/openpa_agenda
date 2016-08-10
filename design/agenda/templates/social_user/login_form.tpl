<section class="hgroup" id="login">
    <div class="row">
        <div class="col-sm-12 col-md-12 text-center">
            <h1 style="margin-bottom: 1em">
                {'Per lasciare i tuoi commenti, devi iscriverti!'|i18n('social_user/signin')}
            </h1>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-6 col-md-6">
            {include uri='design:social_user/signin_form.tpl'}
        </div>
        <div class="col-sm-6 col-md-6">
            {include uri='design:social_user/signup_form.tpl'}
        </div>
    </div>
</section>