<tr>
    <td>
        <ul class="unstyled">
            <li>
                <small>
                    {$event.from_time|datetime('custom', '%j %F')}
                    {if sub($event.to_time,$event.from_time)|gt(86399)}
                        - {$event.to_time|datetime('custom', '%j %F')}
                    {/if}
                    {if and($event.periodo_svolgimento, $displayed_attributes|contains( 'periodo_svolgimento' ))}
                        - {$event.periodo_svolgimento}
                    {/if}

                    {if and($event.orario_svolgimento, $displayed_attributes|contains( 'orario_svolgimento' ))}
                        - {$event.orario_svolgimento}
                    {/if}

                    {if and($event.durata, $displayed_attributes|contains( 'durata' ))}
                        - {$event.durata}
                    {/if}

                    {if and($event.luogo_svolgimento, $displayed_attributes|contains( 'luogo_svolgimento' ))}
                        - <span style="font-weight: bold">{$event.luogo_svolgimento}</span>
                    {/if}
                </small>
            </li>
        </ul>


        <h4>{$event.name|oc_shorten(150)|wash()}</h4>
        {if and($event.abstract, $displayed_attributes|contains( 'abstract' ))}
            <div class="event-abstract"> {$event.abstract}</div>
        {/if}
    </td>

    {if $programma_eventi.show_qrcode}
        <td width="80px">
            {if or($debug, is_set($use_base64_src))}
                <img src="{$event.qrcode_base64_src}" alt="" height="80px"/>
            {else}
                <img src="{$prefix}/{$event.qrcode_file_url}" alt="" height="80px"/>
            {/if}
        </td>
    {/if}
</tr>
