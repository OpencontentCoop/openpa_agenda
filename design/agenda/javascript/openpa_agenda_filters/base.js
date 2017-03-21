var OpenpaAgendaBaseFilter = {

    current: ['all'],

    filterClickEvent: function (e, view) {
        var current = $(e.currentTarget);
        this.setCurrent(current.data('value'));
        view.doSearch();
        e.preventDefault();
    },

    init: function (view, filter) {
        $(filter.container).find('a').on('click', function (e) {
            filter.filterClickEvent(e, view)
        });
    },

    setCurrent: function (value) {
        $('li', $(this.container)).removeClass('active');
        $('li a[data-value="' + value + '"]', $(this.container))
            .parent().addClass('active')
            .parents('aside').find('h4').append('<span class="loading"> <i class="fa fa-circle-o-notch fa-spin"></i></span>');
        this.current = [value];
    },

    getCurrent: function () {
        return this.current;
    },

    refresh: function (response, view) {
        var self = this;
        $('span.loading').remove();
        $('li', $(self.container)).hide();
        $('li a[data-value="all"]', $(self.container)).parent().show();

        var current = self.getCurrent();
        var currentLength = 0;
        $.each(current, function () {
            if (this != 'all') {
                var item = $('a[data-value="' + this + '"]', $(self.container));
                item.html(this).parent().addClass('active').show();
                currentLength++;
            }
        });

        $.when($.each(response.facets, function () {
            var name = this.name;
            if (this.name == self.name) {
                $.each(this.data, function (value, count) {
                    if (value != '') {
                        var quotedValue = value;
                        if ($('li a[data-value="' + quotedValue + '"]', $(self.container)).length) {
                            $('li a[data-value="' + quotedValue + '"]', $(self.container)).html(value + ' (' + count + ')').parent().show();
                        } else {
                            var li = $('<li><a href="#" data-value="' + quotedValue + '">' + value + ' (' + count + ')' + '</a></li>');
                            li.find('a').on('click', function (e) {
                                self.filterClickEvent(e, view);
                            });
                            $(self.container).append(li);
                        }
                        $(self.container).parent().show();
                    }
                });
            }
        })).then(function(){
            if( $(self.container).find('li:visible').length < 2 && currentLength == 0){
                $(self.container).parent().hide();
            }
        });
    },

    reset: function (view) {
        var self = this;
        $('li', $(self.container)).removeClass('active');
        var currentValues = this.getCurrent();
        $.each(currentValues, function () {
            $('li a[data-value="' + this + '"]', $(self.container)).parent().addClass('active');
        });
    }
};
