<div style="background: #fff" class="panel-body">
    <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id, '#tab_leaflet')|ezurl(no)}" enctype="multipart/form-data" method="post">
        <div class="row">
            <div class="col-md-4">
                {if $post.events|count()|gt(0)}
                    <button type="submit" class="btn btn-danger btn-lg" name="ActionProgram" value="DeleteSelected"><i class="fa fa-minus" aria-hidden="true"></i> Elimina eventi selezionati</button>
                    <hr />
                {/if}
                <button type="submit" class="btn btn-success btn-lg" name="ActionProgram" value="BrowseEvent"><i class="fa fa-plus" aria-hidden="true"></i> Aggiungi evento esistente</button>
            </div>

            <div class="col-md-4">
                <div class="alert alert-info" role="alert">Scegli il layout per il volantino.</div>
                {def $count = 0}
                {foreach $post.layouts as $layout}
                    <div class="radio">
                        <label>
                            <input type="radio" name="layout" value="{$layout.id}" {if $count|eq(0)} checked="checked"{/if}>
                            <img src="{concat($layout.id, '-columns.png')|ezimage(no)}" title="{$layout.title}">
                            {$layout.title}<br /><small>{$layout.displayed_attributes|implode( ', ' )}</small>
                        </label>
                    </div>
                    {set $count = $count|inc()}
                {/foreach}
            </div>

            <div class="col-md-4">
                <button type="submit" class="btn btn-info btn-lg" name="ActionProgram" value="SaveAndGetProgram"><i class="fa fa-download" aria-hidden="true"></i> Salva e scarica volantino</button>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <h2>{count($post.events)} eventi selezionati</h2>
                <div class="alert alert-danger" role="alert">
                    Gli abstract degli eventi superiori a <strong>{$post.abstract_length}</strong> caratteri verrano tagliati automaticamente.
                    Utilizzare il form in basso per personalizzare l'abstract dell'evento sul volantino.
                </div>
                <table class="table table-striped">
                    <tr>
                        <th width="1"></th>
                        <th width="40%">Titolo</th>
                        <th>Abstarct</th>
                    </tr>
                {foreach $post.events as  $event}
                    {include uri=concat("design:",$post.template_directory,'/parts/leaflet/event_row.tpl') event=$event}
                {/foreach}
                </table>
            </div>
        </div>
        <input type="hidden" name="ActionIdentifier" value="ActionProgram" />
    </form>
</div>


<script>
    {literal}
    var maxLength = {/literal}{$post.abstract_length}{literal};
    var textarea = $('textarea');
    var countChars = function(element) {        
        var length = element.val().length;
        length = maxLength-length;
        var text = length > 0 ? ' caratteri mancanti' : ' caratteri in eccesso';
        console.log(length);
        length = Math.abs(length).toString();        
        $('.chars', element.parent()).text(length+text);
    };
    textarea.each(function(){countChars($(this))});
    textarea.keyup(function(){countChars($(this))});
    {/literal}
</script>
