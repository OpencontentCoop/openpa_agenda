;(function ($, window, document) {

    var pluginName = 'OpenPAAgendaFullCalendar',
        defaults = {
            DateFormat: "DD/MM/YYYY HH:mm",
            fullCalendar: {
                header:{
                    center: "title",
                    right: "agendaDay,agendaWeek,month",
                    left: "prev,today,next"
                },
                defaultView: 'month',
                buttonText: {
                    today: "Oggi",
                    agendaDay: "Giorno",
                    basicDay: "Giorno",
                    agendaWeek: "Settimana",
                    basicWeek: "Settimana",
                    month: "Mese",
                    listDay: "Giorno",
                    listWeek: "Settimana",
                    listMonth: "Mese"
                }
            }
        };

    function Plugin(element, options) {
        this.element = element;
        this.options = $.extend(true, {}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.$calendar = $(this.element);
    }

    $.extend(Plugin.prototype, {
        init: function (cb, context) {
            if (!this.$calendar.data('fullCalendar')) {
                var settings = $.extend(true, {}, {
                    locale: 'it',
                    axisFormat: 'H(:mm)',
                    aspectRatio: 1.35,
                    selectable: false,
                    editable: false,
                    timeFormat: 'H(:mm)'
                }, this.options.fullCalendar);
                this.$calendar.fullCalendar(settings);
            }
            this.$calendar.data('fullCalendar').render();
            if ($.isFunction(cb)) {
                cb.call(context);
            }
        }
    });

    $.fn[pluginName] = function (options) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' + pluginName,
                    new Plugin(this, options));
            }
        });
    }

})(jQuery, window, document);
