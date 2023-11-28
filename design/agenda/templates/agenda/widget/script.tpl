{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
{literal}
(function () {

    var jQuery, spinner, settings = [], script_tag;

    if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.10.2') {
        script_tag = document.createElement('script');
        script_tag.setAttribute("type", "text/javascript");
        script_tag.setAttribute("src","https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js");
        if (script_tag.readyState) {
            script_tag.onreadystatechange = function () { // For old versions of IE
                if (this.readyState == 'complete' || this.readyState == 'loaded') {
                    scriptLoadHandler();
                }
            };
        } else { // Other browsers
            script_tag.onload = scriptLoadHandler;
        }
        (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
    } else {
        jQuery = window.jQuery;
        main();
    }

    script_tag = document.createElement('script');
    script_tag.setAttribute("type", "text/javascript");
    script_tag.setAttribute("src", "https://cdnjs.cloudflare.com/ajax/libs/jsrender/0.9.84/jsrender.min.js");
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
    script_tag = document.createElement('script');
    script_tag.setAttribute("type", "text/javascript");
    script_tag.setAttribute("src", "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment-with-locales.min.js");
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);

    var style_tag = document.createElement('link');
    style_tag.setAttribute("rel", "stylesheet");
    style_tag.setAttribute("media", "all");
    style_tag.setAttribute("href", "{/literal}{$css|ezroot(no,full)}{literal}");
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(style_tag);
    style_tag = document.createElement('link');
    style_tag.setAttribute("rel", "stylesheet");
    style_tag.setAttribute("media", "all");
    style_tag.setAttribute("href", "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css");
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(style_tag);

    function scriptLoadHandler() {
        jQuery = window.jQuery.noConflict(true);
        main();
    }

    var i18n = function (data, key, fallbackLanguage) {
        var currentLanguage = settings['language'];
        fallbackLanguage = fallbackLanguage || 'ita-IT';
        var returnData = false;
        if (data && key) {
            if (typeof data[currentLanguage] != 'undefined' && data[currentLanguage][key]) {
                returnData = data[currentLanguage][key];
            }
            else if (fallbackLanguage && typeof data[fallbackLanguage] != 'undefined' && data[fallbackLanguage][key]) {
                returnData = data[fallbackLanguage][key];
            }
        } else if (data) {
            if (typeof data[currentLanguage] != 'undefined' && data[currentLanguage]) {
                returnData = data[currentLanguage];
            }
            else if (fallbackLanguage && typeof data[fallbackLanguage] != 'undefined' && data[fallbackLanguage]) {
                returnData = data[fallbackLanguage];
            }
        }
        return returnData != 0 ? returnData : false;
    };
    function main() {
        jQuery(document).ready(function ($) {
            {/literal}
            settings['accessPath'] = "{''|ezurl(no,full)}";
            settings['language'] = "{$current_language}";
            settings['locale'] = "{$moment_language}";
            spinner = jQuery('<div style="text-align:center"><i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i></div>');
            {literal}
            $('[data-agenda-widget]').each(function() {
                var widgetId = $(this).data('agenda-widget');
                var $container = $(this);
                var helpers = {
                    'formatDate': function (date, format) {
                        moment.locale(settings['locale']);
                        return moment(new Date(date)).format(format);
                    },
                    'mainImageUrl': function (data) {
                        var images = i18n(data, 'images');
                        if (images.length > 0) {
                            return settings['accessPath'] + '/agenda/image/' + images[0].id;
                        }
                        var image = i18n(data, 'image');
                        if (image) {
                            return image.url;
                        }
                        return null;
                    },
                    'settings': function (setting) {
                        return settings[setting];
                    },
                    'language': function (setting) {
                        return language(setting);
                    },
                    'i18n': function (data, key, fallbackLanguage) {
                        return i18n(data, key, fallbackLanguage);
                    },
                    'agendaUrl': function (id) {
                        return settings['accessPath'] + '/agenda/event/' + id;
                    },
                    'associazioneUrl': function (objectId) {
                        return settings['accessPath'] + '/openpa/object/' + objectId;
                    }
                }
                $container.html(spinner);
                $.ajax({
                    url: "{/literal}{'agenda/widget/'|ezurl(no,full)}{literal}/"+widgetId,
                    jsonp: "callback",
                    dataType: "jsonp",
                    success: function( widget ) {
                        spinner.remove();
                        if ($.views) $.views.helpers(helpers);
                        else jsrender.views.helpers(helpers);
                        if(widget.show_header){
                            var templateHeader = ($.isFunction($.templates)) ? $.templates(widget.templates.header) : jsrender.templates(widget.templates.header);
                            var header = templateHeader.render(widget);
                            $container.html(header);
                        }
                        $wrapper = $('<div{/literal}{if $height} style="height:{$height}{literal};overflow-y: auto"{/if}></div>');
                        if(!widget.data.error_message && widget.data.totalCount > 0){
                            var templateEvents = ($.isFunction($.templates)) ? $.templates(widget.templates.events) : jsrender.templates(widget.templates.events);
                            var events = templateEvents.render(widget.data.searchHits);
                            $wrapper.append(events);
                            $container.append($wrapper);

                            if(widget.show_footer){
                                var templateFooter = ($.isFunction($.templates)) ? $.templates(widget.templates.footer) : jsrender.templates(widget.templates.footer);
                                $container.append(templateFooter);
                            }

                        }else{
                            $container.hide().html('<small><em>'+widget.data.error_message+'</em></small>');
                        }
                    }
                });
            });
        });
    }
})();
{/literal}
