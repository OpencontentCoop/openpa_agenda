<br />
<div class="row">
    <div class="col-md-12">

        <!-- AddThis Button BEGIN -->
        <div class="addthis_toolbox addthis_default_style addthis_32x32_style">
            <a class="addthis_button_preferred_1"></a>
            <a class="addthis_button_preferred_2"></a>
            <a class="addthis_button_preferred_3"></a>
            <a class="addthis_button_preferred_4"></a>
            <a class="addthis_button_compact"></a>
            <a class="addthis_counter addthis_bubble_style"></a>
        </div>
        <script type="text/javascript" src="://s7.addthis.com/js/250/addthis_widget.js#pubid=xa-4f1466e1721a5c5b"></script>
        <!-- AddThis Button END -->


    </div>

    {if is_set( $node.data_map.star_rating )}
        <div class="attribute-star_rating right">
            <strong>{$node.data_map.star_rating.contentclass_attribute_name}:</strong>
            {attribute_view_gui attribute=$node.data_map.star_rating}
        </div>
    {/if}
</div>
