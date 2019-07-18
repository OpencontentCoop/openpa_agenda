<tr>
    <td>
        <div class="checkbox">
            <label>
                <input type="checkbox" class="event" name="SelectEvent[]" value="{$event.id}" />
            </label>
        </div>
    </td>
    <td>
        <h4>{$event.name}</h4>
        <ul class="list-unstyled">
            <li><strong>{'Period'|i18n('agenda/leaflet')}:</strong>
            {if $event.periodo_svolgimento}
                {$event.periodo_svolgimento}
            {elseif and(is_set($event.recurrences_text), $event.recurrences_text|ne(''))}
              {$event.recurrences_text}
            {else}
                {$event.from_time|datetime('custom', '%j %F')}
                {if $event.from_time|ne($event.to_time)}
                    - {$event.to_time|datetime('custom', '%j %F')}
                {/if}
            {/if}
            </li>
            <li><strong>{'Hours'|i18n('agenda/leaflet')}:</strong> {$event.orario_svolgimento}</li>
            <li><strong>{'Duration'|i18n('agenda/leaflet')}:</strong> {$event.durata}</li>
            <li><strong>{'Location'|i18n('agenda/leaflet')}:</strong> {$event.luogo_svolgimento}</li>
        </ul>
    </td>
    <td>
        <textarea class="form-control" name="Events[{$event.id}]" rows="3">{$event.abstract}</textarea>
        {if $event.auto}<span class="text-warning">{'Automatically generated abstract'|i18n('agenda/leaflet')}</span>{/if}
        <span class="text-info"><strong class="chars"></strong>.</span>
    </td>
</tr>
