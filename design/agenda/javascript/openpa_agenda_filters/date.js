var OpenpaAgendaDateFilter = {

    name: 'date',

    container: '.widget[data-filter="date"] ul',

    current: ['next 30 days'],

    filterClickEvent: function (e, view) {
        var current = $(e.currentTarget);
        this.setCurrent(current.data('value'));
        view.doSearch();
        e.preventDefault();
    },

    init: function (view, filter) {
        var currentPreselected = $('li.active a', $(filter.container)).data('value');
        if (currentPreselected){
            filter.current = [currentPreselected];
        }
        $(filter.container).find('a').on('click', function(e){filter.filterClickEvent(e,view)});
    },

    setCurrent: function (value) {
        this.current = [value];
        $('li', $(this.container)).removeClass('active');
        $('li a[data-value="'+value+'"]', $(this.container)).parents('aside').find('h4').append('<span class="loading"> <i class="fa fa-circle-o-notch fa-spin"></i></span>');
    },

    getCurrent: function () {
        return this.current;
    },

    buildQuery: function () {
        var currentDateList = this.getCurrent();
        var currentDate = currentDateList.length > 0 ? currentDateList[0] : null;
        if (currentDate) {
            var start;
            var end;
            switch (currentDate) {
                case 'today':
                    start = moment();
                    end = moment();
                    break;
                case 'weekend':
                    start = moment().day(6);
                    end = moment().day(7);
                    break;
                case 'next 7 days':
                    start = moment();
                    end = moment().add(7, 'days');
                    break;
                case 'next 30 days':
                    start = moment();
                    end = moment().add(30, 'days');
                    break;
                case 'all':
                    start = '*';
                    end = '*';
                    break;
            }

            if (start != '*'){
                if (end == '*') {
                    return 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',*]';
                } else {
                    return 'calendar[] = [' + start.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',' + end.set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + ']';
                }
            }
        }
    },

    reset: function (response, view) {
        var self = this;
        $('li', $(self.container)).removeClass('active');
        var currentValues = this.getCurrent();
        $.each(currentValues, function(){
            $('li a[data-value="'+this+'"]', $(self.container)).parent().addClass('active');
        });
    }
};
