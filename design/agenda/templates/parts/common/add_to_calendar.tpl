{ezscript_require( array('addtocalendar.min.js' ) )}






<div class="row">
    <div class="col-md-12">
        <span class="addtocalendar atc-style-blue">
            <var class="atc_event">
            {* todo: sistemare date, vedete comportamento periodo svolgimento e dates *}
            {*<var class="atc_date_start">2017-05-04 12:00:00</var>
            <var class="atc_date_end">2017-05-04 18:00:00</var>*}
            <var class="atc_timezone">Europe/Rome</var>
            <var class="atc_title">{$node.data_map.titolo.content|wash()}</var>
            {if $node|has_attribute('abstract')}
                <var class="atc_description">{attribute_view_gui attribute=$node|attribute('abstract')}</var>
            {/if}
            {def $luogo = false()}
            {if $node|has_attribute( 'luogo' )}
                {set $luogo = fetch('content','node',hash('node_id', $node.data_map.luogo.content.relation_list[0].node_id))}
            {/if}
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
            {*<var class="atc_organizer">Luke Skywalker</var>
            <var class="atc_organizer_email">luke@starwars.com</var>*}
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