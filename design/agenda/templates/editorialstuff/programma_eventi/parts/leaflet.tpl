<div style="background: #fff" class="panel-body">
    <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id, '#tab_leaflet')|ezurl(no)}" enctype="multipart/form-data" method="post">
        <div class="row">
            <div class="col-md-4">
                {if $post.events|count()|gt(0)}
                    <button type="submit" class="btn btn-danger btn-lg" name="ActionProgram" value="DeleteSelected"><i class="fa fa-minus" aria-hidden="true"></i> {'Delete selected events'|i18n('agenda/leaflet')}</button>
                    <hr />
                {/if}
                <button type="submit" class="btn btn-success btn-lg" name="ActionProgram" value="BrowseEvent"><i class="fa fa-plus" aria-hidden="true"></i> {'Add existing event'|i18n('agenda/leaflet')}</button>
            </div>

            <div class="col-md-4">
                <div class="alert alert-info" role="alert">{'Choose the layout for the flyer'|i18n('agenda/leaflet')}</div>
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
                <button type="submit" class="btn btn-info btn-lg" name="ActionProgram" value="SaveAndGetProgram"><i class="fa fa-download" aria-hidden="true"></i> {'Save and download flyer'|i18n('agenda/leaflet')}</button>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <h2>{count($post.events)} {'selected events'|i18n('agenda/leaflet')}</h2>
                <div class="alert alert-danger" role="alert">
                    <p>{"Event abstracts greater than %number characters will be automatically cut."|i18n('agenda/leaflet', '', hash( '%number', concat('<strong>', $post.abstract_length, '</strong>') ) )}</p>
                    <p>{'You can use the form below to customize the event abstract on the flyer.'|i18n('agenda/leaflet')}</p>
                </div>
                <table class="table table-striped">
                    <tr>
                        <th width="1"></th>
                        <th width="40%">{'Title'|i18n('agenda/leaflet')}</th>
                        <th>{'Abstract'|i18n('agenda/leaflet')}</th>
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
        var text = length > 0 ? {/literal}' {'missing characters'|i18n('agenda/leaflet')}' : ' {'characters in excess'|i18n('agenda/leaflet')}'{literal};
        console.log(length);
        length = Math.abs(length).toString();        
        $('.chars', element.parent()).text(length+text);
    };
    textarea.each(function(){countChars($(this))});
    textarea.keyup(function(){countChars($(this))});
    {/literal}
</script>
