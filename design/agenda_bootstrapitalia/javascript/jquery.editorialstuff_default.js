$(document).ready(function () {
    var touch = false;
    if (window.Modernizr) {
        touch = Modernizr.touch;
    }
    if (!touch) {
        $(".has-tooltip").on("mouseenter", function () {
            var el;
            el = $(this);
            if (el.data("tooltip") === undefined) {
                el.tooltip({
                    placement: el.data("placement") || "top",
                    container: el.data("container") || "body"
                });
            }
            return el.tooltip("show");
        }).on("mouseleave", function () {
            return $(this).tooltip("hide");
        });
    }
    if (jQuery.fn.tabdrop !== undefined) {
        $('.nav-tabs').tabdrop();
    }

    $('#dashboard-filters-container').find('select').change(function () {
        $('#dashboard-search-button').click();
    });

    var hash = document.location.hash;
    var prefix = "tab_";
    if (hash) {
        $('.nav-tabs a[href="' + hash.replace(prefix, "") + '"]').tab('show');
    }
// Change hash for page-reload
    $('.nav-tabs a').on('shown.bs.tab', function (e) {
        window.location.hash = e.target.hash.replace("#", "#" + prefix);
        $('.sticky-wrapper').removeClass('is-sticky').attr('style', '');
    });
    $('[data-load-remote]').on('click', function (e) {
        e.preventDefault();
        var $this = $(this);
        $($this.data('remote-target')).html('<em>Loading...</em>');
        var remote = $this.data('load-remote');
        if (remote) {
            $($this.data('remote-target')).load(remote, null, function (responseTxt, statusTxt, xhr) {
                if (statusTxt === "success") {
                    var links = $($this.data('remote-target')).find('.modal-body').find('a');
                    links.each(function (i, v) {
                        $(v).attr('href', '#').attr('style', 'color:#ccc;');
                    });
                }
            });
        }
    });
    $(document).on('change', 'select.inline_edit_state', function () {
        var that = $(this);
        var selected = $(this).find('option:selected');
        that.hide();
        that.parent().append('<i id="inline-loading-' + selected.val() + '" class="fa fa-gear fa-spin"></i>');
        $.ajax({
            url: selected.data('href'),
            data: {'Ajax': true},
            method: 'GET',
            success: function (data) {
                $('#inline-loading-' + selected.val()).remove();
                if (data.result === 'error') {
                    that.parent().append('<p>' + data.error_message + '</p>');
                }
                that.show();
            }
        });
    });
});
