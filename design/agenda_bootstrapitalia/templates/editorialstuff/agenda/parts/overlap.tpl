<div style="background: #fff" class="panel-body">

    {if $post.object|has_attribute('time_interval')}


        <div class="row">
            <div class="col text-center">
                Visualizza le sovrapposizioni delle date dell'evento corrente con altri eventi <i class="fa fa-refresh" id="RefreshOverlaps"></i> <br />
                {if $post.object|has_attribute('takes_place_in')}
                    {def $marker = false()}
                    {foreach $post.object|attribute('takes_place_in').content.relation_list as $relation_item}
                        {if $relation_item.in_trash|not()}
                            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
                            {if $content_object.can_read}
                                {if $content_object|has_attribute('has_address')}
                                    {set $marker = $content_object|attribute('has_address').content}
                                    {break}
                                {/if}
                            {/if}
                            {undef $content_object}
                        {/if}
                    {/foreach}
                    {if $marker}
                        <label class="d-inline">
                            <input type="checkbox" id="WithPlace" data-lat="{$marker.latitude}" data-lng="{$marker.longitude}" name="WithPlace" value="1" checked="checked"/>
                            solo nel raggio approssimativo di
                        </label>
                        <input id="Radius" name="Radius" type="text" value="70" class="d-inline border" style="width: 60px;text-align: right;height: auto;padding:2px" />
                        <label for="Radius"> metri rispetto al luogo impostato</label>
                    {/if}
                {/if}
                <p class="my-4" id="NoOverlap" style="display: none"><em>Nessuna sovrapposizione trovata</em></p>
            </div>
        </div>

        {def $attribute = $post.object.data_map.time_interval}
        <div id="Overlaps" class="point-list-wrapper my-4">
            {def $events = $attribute.content.events}
            {foreach $events as $event}
                <div class="point-list mb-3" data-timeevent="{$event.id}" data-start="{$event.id|explode('-')[0]}" data-end="{$event.id|explode('-')[1]}">
                    <div class="point-list-aside">
                        <div
                            class="point-date text-monospace" style="max-height: 53px;">{recurrences_strtotime($event.start)|datetime( 'custom', '%d' )}</div>
                        <div
                            class="point-month text-monospace" style="max-height: 20px;">{recurrences_strtotime($event.start)|datetime( 'custom', '%M' )}</div>
                    </div>
                    <div class="point-list-content">
                        <div class="card card-teaser shadow p-4 rounded border">
                            <div class="card-body">
                                <h5 class="card-title">
                                    {"Event start"|i18n('bootstrapitalia')} {recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )}
                                    {if recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )|ne(recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' ))}
                                        - {"Event end"|i18n('bootstrapitalia')} {recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' )}
                                    {/if}
                                </h5>
                                <table class="table table-sm my-2"></table>
                            </div>
                        </div>
                    </div>
                </div>
            {/foreach}
            {undef $events}
        </div>

        {literal}
        <style>
            .label-draft {  background-color: #bbb;  }
            .label-skipped {  background-color: #999;  }
            .label-waiting {  background-color: #f0ad4e;  }
            .label-accepted {  background-color: #5cb85c;  }
            .label-refused {  background-color: #d9534f;  }
        </style>
        <script id="tpl-overlap-event" type="text/x-jsrender">
        <tr data-overlap="{{:metadata.id}}">
            <td>
                <a target="_blank" class="btn btn-link btn-xs label-{{:moderationStateIdentifier}} text-white" href="/editorialstuff/edit/agenda/{{:metadata.id}}">
                    <small>{/literal}{'Detail'|i18n('agenda/dashboard')}{literal}</small>
                </a>
            </td>
            <td>
                <small class="d-block">{{:~i18n(metadata.name)}}</small>
                <strong class="badge badge-light">{{:~formatDate(overlap.start,'DD/MM/YYYY HH:mm')}} - {{:~formatDate(overlap.end,'DD/MM/YYYY HH:mm')}}</strong>
            </td>
            <td><small>
                {/literal}<strong class="d-block">{'Author'|i18n('agenda/dashboard')}</strong>{literal}
                {{:~i18n(metadata.ownerName)}}
            </small></td>
            <td>
                <small>
                {/literal}<strong class="d-block">{'When?'|i18n('agenda')}</strong>{literal}
                {{if ~i18n(data,'time_interval').default_value && ~i18n(data,'time_interval').default_value.count > 1}}
                    {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'DD/MM/YYYY')}}: {{:~i18n(data,'time_interval').text}}
                {{else}}
                    {{:~formatDate(~i18n(data,'time_interval').default_value.from_time,'DD/MM/YYYY HH:mm')}} - {{:~formatDate(~i18n(data,'time_interval').default_value.to_time,'DD/MM/YYYY HH:mm')}}
                {{/if}}
                {{if ~i18n(data,'takes_place_in')}}
                    {/literal}<strong class="d-block">{'Where?'|i18n('agenda')}</strong>{literal}
                    {{for ~i18n(data,'takes_place_in')}}<a target="_blank" href="/content/view/full/{{:mainNodeId}}">{{:~i18n(name)}}</a>{{/for}}
                {{/if}}
                </small>
            </td>
        </tr>
        </script>

        <script>
        var currentPostId = {/literal}{$post.object.id}{literal};
        $(document).ready(function (){
            var inputWithPlace = $('#WithPlace');
            var inputRadius = $('#Radius');
            var noOverlapContainer = $('#NoOverlap');
            var overlapsContainer = $('#Overlaps');
            var menuItem = $('a[href="#overlap"]');
            var refresh = $('#RefreshOverlaps')
            var appendLoader = function (){
                removeLoader();
                removeBadge();
                menuItem.append('<i id="overlapLoader" class="fa fa-circle-o-notch fa-spin ml-1"></i>');
            }
            var removeLoader = function (){
                menuItem.find('#overlapLoader').remove();
            }
            var appendBadge = function (overlapCount){
                removeLoader();
                removeBadge();
                menuItem.append('<span class="badge badge-danger ml-1">'+overlapCount+'</span>');
            };
            var removeBadge = function (){
                menuItem.find('.badge-danger').remove();
            };
            var appendNoProb = function (){
                removeLoader();
                removeBadge();
                menuItem.append('<i class="fa fa-check ml-1"></i>');
            };
            var removeNoProb = function (){
                menuItem.find('.fa-check').remove();
            };
            var appendOverlapEvent = function (overlapEvent) {
                $.views.helpers($.opendataTools.helpers);
                var eventId = overlapEvent.metadata.id;
                var moderationStateIdentifier = false;
                $.each(overlapEvent.metadata.stateIdentifiers, function () {
                    var parts = this.split('.');
                    if (parts[0] === 'moderation') {
                        moderationStateIdentifier = parts[1];
                    }
                });
                overlapEvent.moderationStateIdentifier = moderationStateIdentifier;
                var timeInterval = $.opendataTools.helpers.i18n(overlapEvent.data, 'time_interval');
                if (timeInterval) {
                    var events = timeInterval.events;
                    $.each(events, function (){
                        var event = this;
                        var startEnd = event.id.split('-');
                        var start = startEnd[0];
                        var end = startEnd[1];
                        $('[data-timeevent]').each(function (){
                            if ($(this).find('[data-overlap="'+eventId+'"]').length === 0) {
                                var currentStartEnd = $(this).data('timeevent').split('-');
                                var currentStart = currentStartEnd[0];
                                var currentEnd = currentStartEnd[1];
                                if ((start >= currentStart && end <= currentEnd)
                                    || (start <= currentStart && end >= currentEnd)
                                    || (start <= currentStart && end >= currentStart && end <= currentEnd)
                                    || (start >= currentStart && start <= currentEnd && end >= currentEnd)) {
                                    var template = $.templates('#tpl-overlap-event');
                                    overlapEvent.overlap = event;
                                    var htmlOutput = template.render(overlapEvent);
                                    $(this).find('table').append(htmlOutput);
                                }
                            }
                        })
                    })
                }
            }
            var findOverlap = function (postId){
                removeBadge();
                removeNoProb();
                appendLoader();
                $('[data-timeevent] tr').remove();

                var radius = 0;
                var polygonWkt = false;
                if (inputWithPlace.length > 0 && inputWithPlace.is(':checked')) {
                    var lng, lat, coords = [];
                    radius = inputRadius.length > 0 ? parseInt(inputRadius.val()) : 0;
                    if (radius > 0) {
                        var latLng = L.latLng(inputWithPlace.data('lat'), inputWithPlace.data('lng'))
                        var circle = L.circle(latLng, radius);
                        var circleBounds = circle.getBounds();
                        var rectangle = L.rectangle(circleBounds);
                        var latLngs = rectangle.getLatLngs();
                        for (var i = 0; i < latLngs.length; i++) {
                            coords.push(latLngs[i].lng + ' ' + latLngs[i].lat);
                            if (i === 0) {
                                lng = latLngs[i].lng;
                                lat = latLngs[i].lat;
                            }
                        }
                        polygonWkt = coords.join(',') + ',' + lng + ' ' + lat;
                        console.log(polygonWkt);
                    }
                }

                $.ez('openpaagendaajax::overlapInfo::'+postId+'::'+polygonWkt, false, function (data){
                    if (data.totalCount > 0){
                        appendBadge(data.totalCount);
                        noOverlapContainer.hide();
                        overlapsContainer.show();
                        $.each(data.searchHits, function (){
                            appendOverlapEvent(this);
                        })
                    }else{
                        appendNoProb();
                        noOverlapContainer.show();
                        overlapsContainer.hide();
                    }
                })
            }
            refresh.on('click', function (){
                findOverlap(currentPostId);
            })
            inputWithPlace.on('change', function (){
                if (inputWithPlace.is(':checked')){
                    inputRadius.removeAttr('disabled');
                }else{
                    inputRadius.attr('disabled', 'disabled');
                }
                findOverlap(currentPostId);
            })
            inputRadius.on('keyup', function (){
                if (inputWithPlace.length > 0 && inputWithPlace.is(':checked')) {
                    setTimeout((function () {
                        findOverlap(currentPostId);
                    }), 500);
                }
            })
            findOverlap(currentPostId);
        })
        {/literal}</script>

        {undef $attribute}
    {/if}

</div>
