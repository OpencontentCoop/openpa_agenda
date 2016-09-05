<div style="background: #fff" class="panel-body">

    {*<form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id)|ezurl(no)}" enctype="multipart/form-data" method="post" class="form-inline">
        <input type="hidden" name="ActionIdentifier" value="GetLeaflet" />
        <button type="submit" class="btn btn-primary btn-lg" name="GetLeaflet">Download volantino</button>
    </form>*}

    {if $post.object.can_edit}
        <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id)|ezurl(no)}" enctype="multipart/form-data" method="post">
            <input type="hidden" name="ActionIdentifier" value="SaveAndGetLeaflet" />
            <div class="row">
                <div class="col-md-8">
                    <h2>Eventi</h2>
                    <div class="alert alert-danger" role="alert">
                        <strong>Attenzione!!!</strong> Gli abstract degli eventi superiori a <strong>{$post.abstract_length}</strong> caratteri verrano tagliati automaticamente.
                        Utilizzare il form in basso per personalizzare l'abstract dell'evento sul volantino.
                    </div>
                    {foreach $post.events as $event}
                        <div class="form-group">
                            <h4>{$event.name}</h4>
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
            <div class="row text-center">
                <div class="col-md-12">
                    <button type="submit" class="btn btn-success btn-lg" name="SaveAndGetLeaflet">Salva e scarica volantino</button>
                </div>
            </div>
        </form>
    {else}
        <div class="alert alert-warning" role="alert">
            Noi hai permessi sufficienti per accedere a quest'area!
        </div>
    {/if}
</div>


<script>
    {literal}
    var maxLength = {/literal}{$post.abstract_length}{literal};
    $('textarea').keyup(function() {
        var length = $(this).val().length;
        var length = maxLength-length;
        $('.chars', $(this).parent()).text(length);
    });
    {/literal}
</script>