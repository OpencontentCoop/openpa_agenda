{if is_set( $attribute_base )|not}
    {def $attribute_base = 'ContentObjectAttribute'}
{/if}
{def $latitude  = $attribute.content.latitude|explode(',')|implode('.')
     $longitude = $attribute.content.longitude|explode(',')|implode('.')
     $contacts = openpapagedata().contacts}
<div class="block float-break" data-osmap-attribute="{$attribute.id}"
     data-noresults="{'No search results...'|i18n('extension/ezfind/ajax-search')}"
     data-search="{'Search'|i18n('design/ezwebin/pagelayout')}"
     id="event-geo">

    <div id="map-{$attribute.id}" style="width: 100%; height: 300px; margin-top: 2px;"></div>

    <div class="block buttons float-break">
        <button class="pull-right button btn btn-sm btn-danger" name="Reset" style="display: none" title="{'Restores location and address values to what it was on page load.'|i18n('extension/ezgmaplocation/datatype')}">{'Restore'|i18n('extension/ezgmaplocation/datatype')}</button>
        <button class="pull-right button btn btn-sm btn-info" name="MyLocation" title="{'Gets your current position if your browser support GeoLocation and you grant this website access to it! Most accurate if you have a built in gps in your Internet device! Also note that you might still have to type in address manually!'|i18n('extension/ezgmaplocation/datatype')}">{'My current location'|i18n('extension/ezgmaplocation/datatype')}</button>
    </div>
    <div class="row">
        <div class="block address  col-md-12">
            <label>{'Address'|i18n('extension/ezgmaplocation/datatype')}</label>
            <input class="ezgml_new_address box form-control"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_address_{$attribute.id}"
                   value="{$attribute.content.address}"/>
            <input class="ezgml_hidden_address"
                   type="hidden"
                   name="ezgml_hidden_address"
                   value="{$attribute.content.address}"
                   disabled="disabled"/>
        </div>
    </div>
    <div class="row">
        <div class="element latitude col-md-6">
            <label>{'Latitude'|i18n('extension/ezgmaplocation/datatype')}</label>
            <input class="ezgml_new_latitude box form-control"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_latitude_{$attribute.id}"
                   value="{$latitude}"/>
            <input class="ezgml_hidden_latitude"
                   type="hidden"
                   name="ezgml_hidden_latitude"
                   value="{$latitude}"
                   disabled="disabled"/>
        </div>

        <div class="element longitude col-md-6">
            <label>{'Longitude'|i18n('extension/ezgmaplocation/datatype')}</label>
            <input class="ezgml_new_longitude box form-control"
                   type="text"
                   name="{$attribute_base}_data_gmaplocation_longitude_{$attribute.id}"
                   value="{$longitude}"/>
            <input class="ezgml_hidden_longitude"
                   type="hidden"
                   name="ezgml_hidden_longitude"
                   value="{$longitude}"
                   disabled="disabled"/>
        </div>
    </div>

</div>

{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css',
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css'
))}
{ezscript_require(array(
    'leaflet/leaflet.0.7.2.js',
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'leaflet/geocoder/Control.Geocoder.js',
    'leaflet/geocoder/osmaplocation.js'
))}

<script>
{literal}
$(document).ready(function () {
    $('select#luogo-della-cultura').on('change',function(e){
        var data = $(e.currentTarget).find('option:selected').data();
        if (data.latitude && data.longitude) {
            var latLng = new L.latLng(data.latitude, data.longitude);
            $('#event-geo').trigger('osmaplocation.setMarker', {
                'latLng': latLng,
                'address': data.address
            });
        }
    });
});
{/literal}
</script>
