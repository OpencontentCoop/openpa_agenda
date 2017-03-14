var OpenpaAgendaTargetFilter = $.extend({}, OpenpaAgendaBaseFilter, {

    name: 'target',

    container: '.widget[data-filter="target"] ul',

    buildQueryFacet: function () {
        return 'target|count|100';
    },

    buildQuery: function () {
        var currentValues = this.getCurrent();
        if (currentValues.length && jQuery.inArray('all', currentValues) == -1) {
            return 'target in [\'' + currentValues.join("','") + '\']';
        }
    }

});
