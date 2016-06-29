<tr>
    <th style="text-align;left">Autore</th>
    <td>
        {if $post.object.owner}{$post.object.owner.name|wash()}{else}?{/if}
    </td>
</tr>
<tr>
    <th style="text-align;left">Data di pubblicazione</th>
    <td>
        <p>{$post.object.published|l10n(shortdatetime)}</p>
        {if $post.object.current_version|gt(1)}
            <small>Ultima modifica di <a href={$post.object.main_node.creator.main_node.url_alias|ezurl}>{$post.object.main_node.creator.name}</a>
                il {$post.object.modified|l10n(shortdatetime)}</small>
        {/if}
    </td>
</tr>


{foreach $post.object.data_map as $identifier => $attribute}
    {if $factory_configuration.AttributeIdentifiers|contains( $identifier )|not()}
        <tr>
            <th style="text-align;left">{$attribute.contentclass_attribute_name}</th>
            <td>
                {attribute_view_gui attribute=$attribute image_class=medium}
            </td>
        </tr>
    {/if}
{/foreach}