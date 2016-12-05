{ezscript_require( array(
    'ezjsc::jquery',
    'jquery.opendataTools.js',
    'moment-with-locales.min.js',
    'bootstrap-datepicker/bootstrap-datepicker.js',
    'bootstrap-datepicker/locales/bootstrap-datepicker.it.min.js',
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'openpa_agenda.js',
    'jsrender.js'
))}
{ezcss_require(array(
    'bootstrap-datepicker/bootstrap-datepicker.min.css'
))}


<script>
    moment.locale('it');
    $.opendataTools.settings('onError', function(errorCode,errorMessage,jqXHR){ldelim}
        console.log(errorMessage + ' (error: '+errorCode+')');
        $("#calendar").html('<div class="alert alert-danger">'+errorMessage+'</div>')
    {rdelim});
    $.opendataTools.settings('endpoint',{ldelim}
      'geo': '{'/opendata/api/geo/search/'|ezurl(no,full)}',
      'search': '{'/opendata/api/content/search/'|ezurl(no,full)}',
      'class': '{'/opendata/api/classes/'|ezurl(no,full)}'
    {rdelim});
    {if is_set($site_identifier)}
        $.opendataTools.settings('session_key','agenda-{$site_identifier}-{$current_language}');
    {/if}
    $.opendataTools.settings('accessPath', "{''|ezurl(no,full)}");
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('base_query', "{$base_query}");    
</script>
