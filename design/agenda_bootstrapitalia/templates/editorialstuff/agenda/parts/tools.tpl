<div style="background: #fff" class="panel-body">
    <div class="row">
        <div class="col col-md-6 mb-4">
            <h4>QRCode</h4>
            <img src="{concat('agenda/qrcode/',$post.node.node_id)|ezurl(no)}"/>
        </div>
        {if and(fetch( 'user', 'has_access_to', hash( 'module', 'agenda', 'function', 'push' ) ), is_set($post.object.data_map.target_site))}
        <div class="col col-md-6 mb-4">
            <h4>Siti target</h4>
            <form action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}" method="post" class="border p-2">
                <input type="hidden" name="ActionIdentifier" value="ActionSetTargetSites"/>
                {attribute_edit_gui attribute=$post.object.data_map.target_site}
                <p class="text-right mt-2">
                    <button class="btn btn-primary" type="submit" name="ActionSetTargetSites">{'Store'|i18n('ocbootstrap')}</button>
                </p>
            </form>
        </div>
        {/if}
        {if ezmodule('newsletter','subscribe')}
            {def $newsletter_edition_hash = newsletter_edition_hash()}
            {if and( $post.node|can_add_to_newsletter(true()), $newsletter_edition_hash|count()|gt(0) )}
                <div class="col col-md-6 mb-4">
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
        {if fetch( 'user', 'has_access_to', hash( 'module', 'webhook', 'function', 'list' ))}
            <div class="col col-md-6 mb-4">
                <h4>Webhook</h4>
                <form action="{concat('editorialstuff/action/agenda/', $post.object_id)|ezurl(no)}" method="post">
                    <input type="hidden" name="ActionIdentifier" value="ActionTriggerWebhook"/>
                    <p class="text-left mt-2">
                        <button class="btn btn-primary" type="submit" name="ActionTriggerWebhook">Esegui webhooks</button>
                    </p>
                </form>
            </div>
        {/if}
    </div>
</div>
