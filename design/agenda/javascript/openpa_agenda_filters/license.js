var OpenpaAgendaLicenseTagsFilter = {

    name: 'license.tag_ids',

    container: '[data-filter="license"] > ul',

    current: ['all'],

    filterClickEvent: function (e, view) {
        var current = $(e.currentTarget);
        this.setCurrent(current.data('value'));
        view.doSearch();
        e.preventDefault();
    },

    renderTagTree: function (tag, container, filter) {
        var li = $('<li><a href="#" data-value="' + tag.id + '" data-name="' + tag.keyword + '" class="label label-default">' + tag.keyword + '</a></li>').hide();
        if (tag.hasChildren) {
            var childContainer = $('<ul/>');
            $.each(tag.children, function() {
                var childTag = this;
                filter.renderTagTree(childTag, childContainer, filter);
            });
            li.append(childContainer);
        }
        container.append(li);
    },

    init: function (view, filter) {
        var container = $(filter.container);
        $.opendataTools.tagsTree('Licenze di utilizzo', function (response) {
            $.each(response.children, function () {
                filter.renderTagTree(this, container, filter);
            });
            $(filter.container).find('a').on('click', function(e){filter.filterClickEvent(e,view)});
        });
    },

    setCurrent: function (value) {
        $('li', $(this.container)).removeClass('active');
        $('li a', $(this.container)).removeClass('label-succes');
        $('li a[data-value="'+value+'"]', $(this.container))
            .addClass('label-success')
            .parent().addClass('active')
            .parents('aside').find('h4').append('<span class="loading"> <i class="fa fa-circle-o-notch fa-spin"></i></span>');
        this.current = [value];
    },

    getCurrent: function () {
        return this.current;
    },

    buildQuery: function () {
        var currentValues = this.getCurrent();
        if (currentValues.length && jQuery.inArray( 'all', currentValues ) == -1) {
            return 'license.tag_ids in [\'' + currentValues.join("','") + '\']';
        }
    },

    buildQueryFacet: function(){
        return 'license.tag_ids|alpha|100';
    },

    refresh: function (response, view) {
        var self = this;
        $('span.loading').remove();

        $(self.container).find('li').hide();
        $(self.container).find('li a[data-value="all"]').parent().show();

        var current = self.getCurrent();
        var currentLength = 0;
        $.each(current, function () {
            if (this != 'all') {
                var item = $(self.container).find('a[data-value="' + this + '"]');
                item.html(item.data('name')).addClass('label-success').parent().addClass('active').show().parents('li').show();
                currentLength++;
            }
        });

        $.each(response.facets, function () {
            var name = this.name;
            if (this.name == self.name) {
                $('li a', $(self.container)).each(function () {
                    var name = $(this).data('name');
                    $(this).html(name);
                });
                $.each(this.data, function (value, count) {
                    var item = $('li a[data-value="' + value + '"]', $(self.container));
                    var name = item.data('name');
                    item.html(name + ' (' + count + ')').parent().show();
                    $(self.container).parent().show();
                });
            }
        });
        if( $(self.container).find('li:visible').length < 2 && currentLength == 0){
            $(self.container).parent().hide();
        }

    },

    reset: function (view) {
        var self = this;
        $(self.container).find('li').removeClass('active');
        $(self.container).find('li a').removeClass('label-success');
        var current = self.getCurrent();
        $.each(current, function(){
            $(self.container).find('li a[data-value="'+this+'"]').addClass('label-success').parent().addClass('active');
        });
    }
};
