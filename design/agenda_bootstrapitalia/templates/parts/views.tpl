{set_defaults(hash('view_style', 'section'))}
{def $viewport = openagenda_default_geolocation()}
<div class="events tab-content">
    {if $views|contains('grid')}
        <section id="grid" class="tab-pane {if $views[0]|eq('grid')}active {/if}{$view_style} pt-0"></section>
    {/if}
    {if $views|contains('list')}
        <section id="list" class="tab-pane {if $views[0]|eq('list')}active {/if}{$view_style} pt-0 pl-0"></section>
    {/if}
    {if $views|contains('geo')}
        <section id="geo" class="tab-pane {if $views[0]|eq('geo')}active {/if}p-0">
            <div id="map" style="width: 100%; height: 700px"{if $viewport} data-lat="{$viewport.latitude}" data-lng="{$viewport.longitude}" data-zoom="15"{/if}></div>
        </section>
    {/if}
    {if $views|contains('agenda')}
        <section id="agenda" class="tab-pane {if $views[0]|eq('agenda')}active {/if}{$view_style} pt-0">
            <div class="block-calendar-default shadow block-calendar block-calendar-big">
                <div id="calendar" class="bg-white"></div>
            </div>
        </section>
    {/if}
</div>
{undef $viewport}
{unset_defaults(array('view_style'))}
