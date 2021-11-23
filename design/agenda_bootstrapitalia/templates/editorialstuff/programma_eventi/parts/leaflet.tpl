<div style="background: #fff" class="panel-body">
    <form action="{concat('editorialstuff/action/programma_eventi/', $post.object_id, '#tab_leaflet')|ezurl(no)}" enctype="multipart/form-data" method="post">

        <div class="row">
            <div class="col">
                <h1>{$post.object.name|wash()} <span class="badge badge-light">{count($post.events)} {'selected events'|i18n('agenda/leaflet')}</span></h1>
                {if openagenda_use_wkhtmltopdf()|eq(false())}
                <p>{'Choose the layout for the flyer'|i18n('agenda/leaflet')}</p>
                {/if}
            </div>
        </div>
        <div class="row"{if openagenda_use_wkhtmltopdf()|ne(false())} style="display:none"{/if}>
            {def $count = 0}
            {foreach $post.layouts as $layout}
            <div class="col-md-4">
                <div class="radio">
                    <label>
                        <input type="radio"
                               name="layout"
                               data-id="{$layout.id}"
                               data-cols="{$layout.columns}"
                               data-events_per_col="{$layout.events_per_page}"
                               value="{$layout.id}" {if $count|eq(0)} checked="checked"{/if}>
                        <img src="{concat($layout.id, '-columns.png')|ezimage(no)}" title="{$layout.title}">
                        {$layout.title}<br /><small>{$layout.displayed_attributes|implode( ', ' )}</small>
                    </label>
                </div>
                {set $count = $count|inc()}
            </div>
            {/foreach}
        </div>
        <div class="row my-4">
            <div class="col">
                {if $post.events|count()|gt(0)}
                    <button type="submit" class="btn btn-info rounded-0 text-white" name="ActionProgram" value="DeleteSelected"><i class="fa fa-minus mr-1" aria-hidden="true"></i> {'Delete selected events'|i18n('agenda/leaflet')}</button>
                {/if}
                <button type="submit" class="btn btn-info rounded-0 text-white" name="ActionProgram" value="BrowseEvent"><i class="fa fa-plus mr-1" aria-hidden="true"></i> {'Add existing event'|i18n('agenda/leaflet')}</button>
                <button type="submit" class="btn btn-info rounded-0 pull-right text-white ml-1" name="ActionProgram" value="SaveAndGetProgram"><i class="fa fa-download mr-1" aria-hidden="true"></i> {'Save and download flyer'|i18n('agenda/leaflet')}</button>
                <button type="submit" class="btn btn-info rounded-0 pull-right text-white ml-1" name="ActionProgram" value="SaveProgram"><i class="fa fa-save mr-1" aria-hidden="true"></i> {'Save flyer'|i18n('agenda/leaflet')}</button>
                {if openagenda_use_wkhtmltopdf()}
                    <button id="PreviewRefresh" class="btn btn-info rounded-0 pull-right text-white"><i class="fa fa-refresh mr-1" aria-hidden="true"></i> Aggiorna anteprima</button>
                {/if}
            </div>
        </div>
        <div class="row my-2 event-abstract"{if openagenda_use_wkhtmltopdf()|ne(false())} style="display:none"{/if}>
            <div class="col">
                <p>{"Event abstracts greater than %number characters will be automatically cut."|i18n('agenda/leaflet', '', hash( '%number', concat('<strong>', $post.abstract_length, '</strong>') ) )}
                    {'You can use the form below to customize the event abstract on the flyer.'|i18n('agenda/leaflet')}</p>
            </div>
        </div>

        {if openagenda_use_wkhtmltopdf()}
            {include uri=concat("design:",$post.template_directory,'/parts/leaflet/preview_wkhtml.tpl')}
        {else}
            {include uri=concat("design:",$post.template_directory,'/parts/leaflet/preview.tpl')}
        {/if}

        <input type="hidden" name="ActionIdentifier" value="ActionProgram" />
    </form>
</div>

{foreach $post.events as $event}
    <table class="table event hide" style="height:100%">
        <tbody>
        <tr>
            <td class="position-relative">
                <input type="checkbox" class="event" name="SelectEvent[]" value="{$event.id}" style="position: absolute;left: -12px"/>
                <ul class="unstyled">
                    <li><small>
                            {$event.from_time|datetime('custom', '%j %F')}
                            {if sub($event.to_time,$event.from_time)|gt(86399)}
                                - {$event.to_time|datetime('custom', '%j %F')}
                            {/if}
                            {if $event.periodo_svolgimento}
                                - {$event.periodo_svolgimento}
                            {/if}
                            {if $event.luogo_svolgimento}
                                - <span style="font-weight: bold">{$event.luogo_svolgimento}</span>
                            {/if}
                        </small>
                    </li>
                </ul>

                <h4>
                    {$event.name|oc_shorten(150)|wash()}
                </h4>
                <textarea class="event-abstract" name="Events[{$event.id}]" style="border:1px solid #eee;padding: 0;font-weight: normal;">{$event.abstract}</textarea>
                <div class="position-absolute hide" style="bottom: 0; font-size: 10px !important;padding: 3px;background: #eee">
                    {if $event.auto}{'Automatically generated abstract'|i18n('agenda/leaflet')}{/if}
                    <strong class="chars" style="font-size: 10px !important;"></strong>
                </div>
            </td>

            {if $post.show_qrcode}
                <td width="80px">
                    <img src="{$event.qrcode_url|ezurl(no)}" alt="" height="80px"/>
                </td>
            {/if}
        </tr>
        </tbody>
    </table>
{/foreach}

