<div class="tab-content" style="margin-bottom: 40px;">
    {if $views|contains('list')}
    <div id="list" class="tab-pane active"><section id="calendar" class="service_teasers row"></section></div>
    {/if}
    {if $views|contains('geo')}
    <div id="geo" class="tab-pane"><div id="map" style="width: 100%; height: 700px"></div></div>
    {/if}
    {if $views|contains('agenda')}
    <div id="agenda" class="tab-pane"></div>
    {/if}
</div>
