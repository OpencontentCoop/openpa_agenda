{def $from_year = cond( $item.data_map.from_time.has_content, $item.data_map.from_time.content.timestamp|datetime( custom, '%Y'), false() )
     $from_month = cond( $item.data_map.from_time.has_content, $item.data_map.from_time.content.timestamp|datetime( custom, '%m'), false() )
     $from_day = cond( $item.data_map.from_time.has_content, $item.data_map.from_time.content.timestamp|datetime( custom, '%j'), false() )
     $to_year = cond( $item.data_map.to_time.has_content, $item.data_map.to_time.content.timestamp|datetime( custom, '%Y'), false() )
     $to_month = cond( $item.data_map.to_time.has_content, $item.data_map.to_time.content.timestamp|datetime( custom, '%n'), false() )
     $to_day = cond( $item.data_map.to_time.has_content, $item.data_map.to_time.content.timestamp|datetime( custom, '%j'), false() )
     $same_day = false()
}

{if and( $from_year|eq( $to_year ), $from_month|eq( $to_month ), $from_day|eq( $to_day ) )}
  {set $same_day = true()}
{/if}
{* if $item.data_map.to_time.has_content|not()}
  {set $same_day = true()}
{/if*}

{if is_set($show_time)|not()}
    {def $show_time=true()}
{/if}

{if $same_day}
  {$item.data_map.from_time.content.timestamp|l10n( 'date' )}

    {if $show_time}
        {* il confronto va fatto con datetime, perchè in inglese mezzanotte è "12am" *}
        {if $item.data_map.from_time.content.timestamp|datetime( 'custom', '%H:%i' )|ne(0)}
        {if $item.data_map.to_time.content.timestamp|datetime( 'custom', '%H:%i' )|ne(0)}
          &middot; {'da'|i18n('agenda/event/hours')}
          {$item.data_map.from_time.content.timestamp|l10n( 'shorttime' )}
          {'a'|i18n('agenda/event/hours')}
          {$item.data_map.to_time.content.timestamp|l10n( 'shorttime' )}
        {else}
          &middot; {$item.data_map.from_time.content.timestamp|l10n( 'shorttime' )}
        {/if}
    {/if}
  {/if}
{elseif $item.data_map.to_time.has_content}
	{'da'|i18n('agenda/event/days')}
  {$item.data_map.from_time.content.timestamp|l10n( 'shortdate' )}
  {'a'|i18n('agenda/event/days')}
  {$item.data_map.to_time.content.timestamp|l10n( 'shortdate' )}
{else}
  {$item.data_map.from_time.content.timestamp|l10n( 'date' )}
  {if and( $show_time, $item.data_map.from_time.content.timestamp|datetime( 'custom', '%H:%i' )|ne(0) )}
    &middot; {$item.data_map.from_time.content.timestamp|l10n( 'shorttime' )}
  {/if}
{/if}

{undef}
