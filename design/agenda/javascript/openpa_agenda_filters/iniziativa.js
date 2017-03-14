var OpenpaAgendaIniziativaFilter = $.extend({}, OpenpaAgendaBaseFilter, {

    name: 'iniziativa',

    container: '.widget[data-filter="iniziativa"] ul',

    buildQueryFacet: function(){
        return 'iniziativa|count|100';
    },

    buildQuery: function () {
        var currentValues = this.getCurrent();
        if (currentValues.length && jQuery.inArray('all', currentValues) == -1) {
            return 'iniziativa in [\'' + currentValues.join("','") + '\']';
        }
    }

});
