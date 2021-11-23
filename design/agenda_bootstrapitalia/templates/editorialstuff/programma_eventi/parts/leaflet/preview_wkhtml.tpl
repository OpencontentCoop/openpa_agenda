<div class="position-relative" style="min-height: 400px">
    <div class="position-absolute" style="width: 100%;z-index: 1;padding: 200px 20px;text-align: center;"><i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i></div>
{*    <iframe id="leaflet-preview" src="{concat('/agenda/leaflet/', $post.object.id)|ezurl(no)}" style="width: 100%;height: 1650px;border: none;z-index: 2;position: relative;"></iframe>*}
    <object id="leaflet-preview" style="z-index: 2;position: relative;" width="100%" height="1500" data="{concat('/agenda/leaflet/', $post.object.id)|ezurl(no)}#toolbar=0&navpanes=0">
{*        <embed width="100%" height="1500" type="application/pdf" src="{concat('/agenda/leaflet/', $post.object.id)|ezurl(no)}#toolbar=0">*}
            <p>Insert your error message here, if the PDF cannot be displayed.</p>
{*        </embed>*}
    </object>

</div>
<script>
    $(document).ready(function () {ldelim}
        var iframeSrc = "{concat('/agenda/leaflet/', $post.object.id)|ezurl(no)}#toolbar=0&navpanes=0";
        var previewRefreshButton = $('#PreviewRefresh');
        previewRefreshButton.on('click', function (e) {ldelim}
            var currentLayout = $('input[name="layout"]:checked').val();
            var iframe = document.getElementById('leaflet-preview');
            iframe.style.visibility = 'hidden';
            iframe.data = iframeSrc + '?layout='+currentLayout;
            iframe.onload = function (){ldelim}
                iframe.style.visibility = 'visible';
            {rdelim}
        {rdelim});
    {rdelim});
</script>
