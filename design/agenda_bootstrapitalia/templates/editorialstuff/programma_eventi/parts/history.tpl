<div class="panel-body" style="background: #fff">
    <div class="table-responsive">
        <table class="table table-striped">
            {foreach $post.history as $time => $history_items}
                {foreach $history_items as $item}
                    <tr>
                        <td>{$time|l10n( shortdatetime )}</td>
                        <td>{fetch( content, object, hash( 'object_id', $item.user ) ).name|wash()}</td>
                        <td>
                            {include uri=concat( 'design:editorialstuff/history/', $item.action,'.tpl')}
                            {*$item.action|wash()} {if $item.parameters|count()}{foreach $item.parameters as $name => $value}{$name|wash()}: {$value|wash()} {/foreach}{/if*}
                        </td>
                    </tr>
                {/foreach}
            {/foreach}
        </table>
    </div>
</div>
