{ezscript_require( array('addtocalendar.min.js' ) )}

<div class="row">
    <div class="col-md-12">
        <span class="addtocalendar atc-style-blue">
            <a class="atcb-link"><i class="fa fa-calendar" aria-hidden="true"></i> {'Aggiungi al tuo calendario'|i18n('agenda')}</a>
            <var class="atc_event">
            {if $node.data_map.from_time.has_content}
                <var class="atc_date_start">{$node.data_map.from_time.content.timestamp|datetime( custom, '%Y-%m-%d %H:%i:%s')}</var>
            {/if}
            {if $node.data_map.to_time.has_content}
                <var class="atc_date_end">{$node.data_map.to_time.content.timestamp|datetime( custom, '%Y-%m-%d %H:%i:%s')}</var>
            {else}
                <var class="atc_date_end">{$node.data_map.from_time.content.timestamp|datetime( custom, '%Y-%m-%d %H:%i:%s')}</var>
            {/if}
            <var class="atc_timezone">Europe/Rome</var>
            <var class="atc_title">{$node.data_map.titolo.content|wash()}</var>
            {if $node|has_attribute('abstract')}
                <var class="atc_description">{attribute_view_gui attribute=$node|attribute('abstract')}</var>
            {/if}

            {if $node|has_attribute( 'luogo' )}
                {def $luogo = false()}
                {set $luogo = fetch('content','node',hash('node_id', $node.data_map.luogo.content.relation_list[0].node_id))}
                <var class="atc_location">
                    {if or($luogo, $node|has_attribute( 'indirizzo' ), $node|has_attribute( 'luogo_svolgimento' ),$node|has_attribute( 'comune' ))}
                        {if $luogo}
                            {$luogo.name|wash()}
                            {if $luogo|has_attribute( 'indirizzo')}{if $luogo.data_map.indirizzo.content|ne($luogo.data_map.title.content)} ,{$luogo|attribute('indirizzo' ).content}{/if}{/if}
                            {if $luogo|has_attribute( 'comune' )} {$luogo|attribute( 'comune' ).content}{/if}
                        {else}
                            {if $node|has_attribute( 'luogo_svolgimento' )}
                                {$node.data_map.luogo_svolgimento.content}
                            {/if}
                            {if $node|has_attribute( 'comune' )}
                                {$node.data_map.comune.content}
                            {/if}
                        {/if}
                    {/if}
                </var>
            {else}
                <var class="atc_location">-</var>
            {/if}

            {if $node|has_attribute( 'organizzazione' )}
                <var class="atc_organizer">
                    {def $itemObject = false()}
                    {foreach $node.data_map.organizzazione.content.relation_list as $item}
                        {set $itemObject = fetch(content, object, hash(object_id, $item.contentobject_id))}
                        {$itemObject.name|wash()}
                        {delimiter}', '{/delimiter}
                        {undef $itemObject}
                    {/foreach}
                </var>
            {/if}
            {if $node|has_attribute( 'email' )}
                <var class="atc_organizer_email">{attribute_view_gui attribute=$node.data_map.email}</var>
            {/if}
        </var>
        </span>
    </div>
</div>
{literal}
    <script type="text/javascript">(function () {
            if (window.addtocalendar)if(typeof window.addtocalendar.start == "function")return;
            if (window.ifaddtocalendar == undefined) { window.ifaddtocalendar = 1;
                var d = document, s = d.createElement('script'), g = 'getElementsByTagName';
                s.type = 'text/javascript';s.charset = 'UTF-8';s.async = true;
                s.src = ('https:' == window.location.protocol ? 'https' : 'http')+'://addtocalendar.com/atc/1.5/atc.min.js';
                var h = d[g]('body')[0];h.appendChild(s); }})();
    </script>
{/literal}