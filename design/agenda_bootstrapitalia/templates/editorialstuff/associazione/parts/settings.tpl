<div class="panel-body" style="background: #fff">

    <div id="spinner" class="spinner my-3 text-center">
        <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
        <span class="sr-only">{'Loading...'|i18n('agenda')}</span>
    </div>
    <div id="settings-form" class="mb-5"></div>

<script>{literal}
$(document).ready(function () {
    var spinner = $('#spinner');
    $(document).on({
        ajaxStart: function(){
            spinner.removeClass("d-none");
        },
        ajaxStop: function(){
            spinner.addClass("d-none");
        }
    });

    var container = $('#settings-form');
    container.opendataFormEdit({
        object: "{/literal}{$post.object.id}{literal}"
    }, {
        connector: 'private_organization_settings',
        onSuccess: function (data) {},
    });

});
{/literal}</script>
{include uri='design:load_ocopendata_forms.tpl'}
</div>
