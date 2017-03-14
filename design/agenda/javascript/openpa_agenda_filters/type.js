var OpenpaAgendaTypeFilter = $.extend({}, OpenpaAgendaBaseFilter, {

    name: 'type',

    container: '.widget[data-filter="type"] ul',

    buildQueryFacet: function () {
        return 'type|count|100';
    },

    buildQuery: function () {
        var currentValues = this.getCurrent();
        if (currentValues.length && jQuery.inArray('all', currentValues) == -1) {
            return 'type in [\'' + currentValues.join("','") + '\']';
        }
    }

});
