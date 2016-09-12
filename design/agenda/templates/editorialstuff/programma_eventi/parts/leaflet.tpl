<div style="background: #fff" class="panel-body">

    {if $post.object.can_edit}
            <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id)|ezurl(no)}" enctype="multipart/form-data" method="post" class="clearfix">
            <input type="hidden" name="ActionIdentifier" value="SaveAndGetLeaflet" />
            <div class="row">
                <div class="col-md-8">
                    <h2>Eventi</h2>
                    <div class="alert alert-danger" role="alert">
                        Gli abstract degli eventi superiori a <strong>{$post.abstract_length}</strong> caratteri verrano tagliati automaticamente.
                        Utilizzare il form in basso per personalizzare l'abstract dell'evento sul volantino.
                    </div>
                    {foreach $post.events as $event}
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" class="event"  value="{$event.id}">
                                <h4>{$event.name} <a data-target="#preview" href="#" data-remote-target="#preview .modal-content" data-load-remote="{concat('layout/set/modal/content/view/full/',$event.main_node_id)|ezurl(no)}" data-toggle="modal" class="btn btn-info btn-xs">Anteprima</a></h4>
                            </label>
                        </div>
                        <div class="form-group">

                            <textarea class="form-control" name="Events[{$event.id}]" rows="3">{$event.abstract}</textarea>
                            {if $event.auto}
                                <span class="text-warning">Abstract generato automaticamente</span>
                            {/if}
                            <span class="text-info"><strong class="chars"></strong>.</span>
                        </div>
                    {/foreach}
                </div>
                <div class="col-md-4">
                    <h2>Layout</h2>
                    <div class="alert alert-info" role="alert">
                        Scegli il layout per il volantino.
                    </div>
                    {def $count = 0}
                    {foreach $post.layouts as $l}
                        <div class="radio">
                            <label>
                                <input type="radio" name="Columns" value="{$l}"{if $count|eq(0)} checked="checked"{/if}>
                                <img src="{concat($l, '-columns.png')|ezimage(no)}" title="{$l} colonne">
                                {$l} colonne ({$l|mul($post.events_per_page)} eventi)
                            </label>
                        </div>
                        {set $count = $count|sum(1)}
                    {/foreach}                    
                </div>
            </div>
            <hr />
            <div class="row">
                <div class="col-md-6">
                    <button type="submit" class="btn btn-info btn-lg" name="SaveAndGetLeaflet"><i class="fa fa-download" aria-hidden="true"></i> Salva e scarica volantino</button>
                </div>
            </form>
                <div class="col-md-3">
                    {if $post.events|count()|gt(0)}
                        <form id="EventsDeleteForm" action="{concat('editorialstuff/action/programma_eventi/', $post.object_id)|ezurl(no)}" enctype="multipart/form-data" method="post" class="pull-right">
                            <input type="hidden" name="ActionIdentifier" value="DeleteSelected" />
                            <input id="SelectedEvents" type="hidden" name="SelectedEvents" value="" />
                            <button type="submit" class="btn btn-danger btn-lg" name="DeleteSelected"><i class="fa fa-minus" aria-hidden="true"></i> Elimina eventi selezionati</button>
                        </form>
                    {/if}
                </div>
                <div class="col-md-3">
                    <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id)|ezurl(no)}" enctype="multipart/form-data" method="post" class="pull-right">
                        <input type="hidden" name="ActionIdentifier" value="BrowseEvent" />
                        <button type="submit" class="btn btn-success btn-lg" name="BrowseEvent"><i class="fa fa-plus" aria-hidden="true"></i> Aggiungi evento esistente</button>
                    </form>
                </div>
            </div>

    {else}
        <div class="alert alert-warning" role="alert">
            Noi hai permessi sufficienti per accedere a quest'area!
        </div>
    {/if}
</div>


<script>
    {literal}
    var maxLength = {/literal}{$post.abstract_length}{literal};
    var checkedEvents= [];
    var countChars = function(element) {        
        var length = element.val().length;
        var length = maxLength-length;
        var text = length > 0 ? ' caratteri mancanti' : ' caratteri in eccesso';
        console.log(length);
        length = Math.abs(length).toString();        
        $('.chars', element.parent()).text(length+text);
    };
    $('textarea').each(function(){countChars($(this))});
    $('textarea').keyup(function(){countChars($(this))});
    $('#EventsDeleteForm').submit( function() {
        $("input.event:checked").each(function (i) {
           checkedEvents.push($(this).val());
        });
        $('#SelectedEvents').val(checkedEvents.join('-'));
        return true;
    });
    {/literal}
</script>