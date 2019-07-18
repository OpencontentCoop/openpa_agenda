<div id="layer-preview" class="flyer-body">
    <div id="page-2" class="page border shadow row" style="margin:20px 0; overflow:hidden;min-width:1220px; max-width:1220px; height: 855px;"></div>
    <div id="page-1" class="page border shadow row" style="margin:20px 0; overflow:hidden;min-width:1220px; max-width:1220px; height: 855px;"></div>

    {def $root_node = agenda_root_node()}
    <div id="copertina-model" class="hide">
        <h1 class="title">{$post.object.data_map.title.content}</h1>
        <hr/>
        <h3 class="subtitle">{$post.object.data_map.subtitle.content}</h3>
        {attribute_view_gui attribute=$post.object.data_map.description}

        <img class="my-3" src="{$root_node.data_map.logo.content.medium.url|ezroot(no)}" alt=""/>

        <div class="contacts">
            {attribute_view_gui attribute=$root_node.data_map.contacts}
        </div>
    </div>
    {undef $root_node}

    {literal}
        <script>
            $(document).ready(function () {
                var maxLength = {/literal}{$post.abstract_length}{literal};
                var countChars = function(element) {
                    var length = element.val().length;
                    length = maxLength-length;
                    var textLength = Math.abs(length).toString();
                    var text = length === 0 ? '' : length > 0 ? {/literal}textLength+' {'missing characters'|i18n('agenda/leaflet')}' : textLength+' {'characters in excess'|i18n('agenda/leaflet')}'{literal};
                    $('.chars', element.parent()).text(text);
                };
                var preview = $('#layer-preview');
                var layoutSelector = $('input[name="layout"]');
                var copertina = $('#copertina-model');
                var page1 = $('#page-1');
                var page2 = $('#page-2');
                var buildLayout = function (currentLayout) {
                    var cols = currentLayout.cols;
                    var eventsPerCol = currentLayout.events_per_col;
                    var events = $('table.event');
                    page1.html('');
                    page2.html('');
                    preview.removeClass().addClass('flyer-body layout-'+currentLayout.id);
                    for (i = 1; i <= cols; i++) {
                        page1.append('<div class="col p-3 column-'+i+'"><table class="table event-container"></table></div>');
                        page2.append('<div class="col p-3 column-'+i+'"><table class="table event-container"></table></div>');
                    }
                    var eventDisplayed = 0;
                    var maxPerPage = cols*eventsPerCol;
                    console.log(events.length);
                    for (a = 1; a <= 2; a++) {
                        for (i = 1; i <= cols; i++) {
                            for (o = 0; o < eventsPerCol; o++) {
                                var slice = events.slice(eventDisplayed);
                                if (slice.length > 0) {
                                    if (eventDisplayed >= maxPerPage) {
                                        page1.find('.column-' + i + ' .event-container').append(slice.find('tbody').html());
                                    } else {
                                        page2.find('.column-' + i + ' .event-container').append(slice.find('tbody').html());
                                    }
                                    eventDisplayed++;
                                }
                            }
                        }
                    }
                    page1.find('.col:last-child').addClass('text-center').attr('id', 'copertina').html(copertina.html());
                    preview.find('textarea').each(function () {
                        var self = $(this);
                        self.on('focus', function () {
                            self.next().removeClass('hide');
                        }).on('blur', function () {
                            self.next().addClass('hide');
                        });
                        self.autoResize({extraSpace:0});
                        self.each(function(){countChars(self)});
                        self.keyup(function(){countChars(self)});
                    });
                    if (currentLayout.id === 4){
                        $('.event-abstract').addClass('hide');
                    }else{
                        $('.event-abstract').removeClass('hide');
                    }
                };
                layoutSelector.on('change', function (e) {
                    var currentLayout = $('input[name="layout"]:checked').data();
                    buildLayout(currentLayout);
                });
                $('input[name="layout"]:checked').trigger('change');
            });
        </script>
    {/literal}
    {ezscript_require('jquery.autoresize.js')}
    {ezcss_require('print-default.css')}
</div>
