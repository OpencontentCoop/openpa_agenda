var OpenpaAgendaHelpers = $.extend({}, $.opendataTools.helpers, {
    'agendaUrl': function (id) {
        return $.opendataTools.settings('accessPath') + '/agenda/event/' + id;
    },
    'associazioneUrl': function (objectId) {
        return $.opendataTools.settings('accessPath') + '/openpa/object/' + objectId;
    }
});
