var OpenpaAgendaTypeFilter = $.extend({}, OpenpaAgendaBaseFilter, {

    name: 'tipo_evento',

    container: '.widget[data-filter="type"] ul',

    buildQueryFacet: function () {
        return 'tipo_evento|count|100';
    },

    buildQuery: function () {
        var currentValues = this.getCurrent();
        if (currentValues.length && jQuery.inArray('all', currentValues) == -1) {
            return 'tipo_evento in [\'' + currentValues.join("','") + '\']';
        }
    }

});
