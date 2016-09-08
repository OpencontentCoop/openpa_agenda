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
                                <h4>{$event.name}</h4>
                            </label>
                        </div>
                        <div class="form-group">

                            <textarea class="form-control" name="Events[{$event.id}]" rows="3">{$event.abstract}</textarea>
                            {if $event.auto}
                                <span class="text-warning">Abstract generato automaticamente - </span>
                            {/if}
                            <span class="text-info"><strong class="chars">{$post.abstract_length|sub($$event.abstract|count_chars())}</strong> caratteri mancanti.</span>
                        </div>
                    {/foreach}
                </div>
                <div class="col-md-4">
                    <h2>Layout</h2>
                    <div class="alert alert-info" role="alert">
                        Scegli il layout per il volantino.
                    </div>
                    <div class="radio">
                        <label>
                            <input type="radio" name="Columns" value="2" checked="checked">
                            <img src="{'2-columns.png'|ezimage(no)}" title="2 colonne">
                            2 colonne
                        </label>
                    </div>
                    <div class="radio">
                        <label>
                            <input type="radio" name="Columns" value="3">
                            <img src="{'3-columns.png'|ezimage(no)}" title="3 colonne">
                            3 colonne
                        </label>
                    </div>
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
    $('textarea').keyup(function() {
        var length = $(this).val().length;
        var length = maxLength-length;
        $('.chars', $(this).parent()).text(length);
    });
    $('#EventsDeleteForm').submit( function() {
        $("input.event:checked").each(function (i) {
           checkedEvents.push($(this).val());
        });
        $('#SelectedEvents').val(checkedEvents.join('-'));
        return true;
    });
    {/literal}
</script>