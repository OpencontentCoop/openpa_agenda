{default attribute_base=ContentObjectAttribute}

{set $attribute = fill_social_matrix( $attribute )}

{let matrix=$attribute.content}

{def $rows = $matrix.rows.sequential}

    <table cellspacing="0" class="list">
        <tbody>
        {foreach social_matrix_fields() as $index => $name}
            <tr>
                <td>
                    <input type="hidden" value="{$name}" name="{$attribute_base}_ezmatrix_cell_{$attribute.id}[]" />
                    <label>{$name}</label>
                </td>
                <td>
                    <input class="form-control" type="text" value="{$rows[$index].columns[1]}" name="{$attribute_base}_ezmatrix_cell_{$attribute.id}[]">
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
{undef $rows}
{/let}
{/default}
