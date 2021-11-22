<div style="background: #fff" class="panel-body">
    <div class="row">
        <div class="col">
            <h4>QRCode</h4>
            <img src="{concat('agenda/qrcode/',$post.node.node_id)|ezurl(no)}"/>
        </div>
        {if ezmodule('newsletter','subscribe')}
            {def $newsletter_edition_hash = newsletter_edition_hash()}
            {if and( $post.node|can_add_to_newsletter(true()), $newsletter_edition_hash|count()|gt(0) )}
                <div class="col">
                    <h4>Newsletter</h4>
                    <form id="AddToNewsletter" action={concat("/openpa/addlocationto/",$post.node.contentobject_id)|ezurl} method="post">
                        <label for="add_to_newsletter">Aggiungi alla prossima newsletter:</label>
                        <div class="input-group">
                            <select name="SelectedNodeIDArray[]" id="add_to_newsletter" class="form-control custom-select">
                                {foreach $newsletter_edition_hash as $edition_id => $edition_name}
                                    <option value="{$edition_id}">{$edition_name|wash()}</option>
                                {/foreach}
                            </select>
                            <div class="input-group-append">
                                <button class="btn btn-xs btn-secondary" type="submit" name="AddLocation">Aggiungi</button>
                            </div>
                        </div>
                    </form>
                    <script>{literal}
                        $(document).ready(function (){
                            $('#AddToNewsletter').on('submit', function (e){
                                var button = $(this).find('[name="AddLocation"]');
                                button.html('<i class="fa fa-circle-o-notch fa-spin"></i>');
                                e.preventDefault();
                                var form = $(this);
                                var url = form.attr('action');
                                $.ajax({
                                    type: "POST",
                                    url: url,
                                    data: form.serialize(), // serializes the form's elements.
                                    success: function(data) {
                                        button.attr('disabled', 'disabled');
                                    }
                                });

                            })
                        })
                    {/literal}</script>
                </div>
            {/if}
            {undef $newsletter_edition_hash}
        {/if}
    </div>
</div>
