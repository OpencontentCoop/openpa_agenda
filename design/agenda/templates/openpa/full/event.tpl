<div class="row">

    <div class="col-md-12">
        {include uri='design:openpa/full/parts/node_languages.tpl'}
        <h1>{$node.name|wash()}</h1>
    </div>

    <div class="col-md-8">

        {include uri=$openpa.content_main.template}

        {include uri=$openpa.content_detail.template}

        {include uri=$openpa.content_infocollection.template}

    </div>

    <div class="col-md-4">

        <h2><i class="fa fa-calendar-o"></i> Quando</h2>
        <div class="widget">
            <div class="widget_content">

                {if $node|has_attribute( 'periodo_svolgimento' )}
                    <p>
                        <strong>{$node.data_map.periodo_svolgimento.contentclass_attribute_name}</strong>
                        {attribute_view_gui attribute=$node.data_map.periodo_svolgimento}
                    </p>
                {else}
                    <p>
                        {include uri='design:atoms/dates.tpl' item=$node}
                    </p>
                {/if}

                {if $node|has_attribute( 'orario_svolgimento' )}
                    <p>
                        <strong>{$node.data_map.orario_svolgimento.contentclass_attribute_name}</strong>
                        {attribute_view_gui attribute=$node.data_map.orario_svolgimento}
                    </p>
                {/if}

                {if $node|has_attribute( 'durata' )}
                    <p>
                        <strong>{$node.data_map.durata.contentclass_attribute_name}</strong>
                        {attribute_view_gui attribute=$node.data_map.durata}
                    </p>
                {/if}

                {if $node|has_attribute( 'iniziativa' )}
                    <div class="well well-sm">
                        parte di:{attribute_view_gui attribute=$node|attribute( 'iniziativa' ) show_link=true()}
                    </div>
                {/if}
            </div>
        </div>

        {if or($node|has_attribute( 'indirizzo' ),$node|has_attribute( 'luogo_svolgimento' ),$node|has_attribute( 'comune' ),$node|has_attribute( 'geo' ))}

            <h2><i class="fa fa-map-marker"></i> Dove</h2>
            <div class="widget">
                <div class="widget_content">
                    {if $node|has_attribute( 'indirizzo' )}
                        {attribute_view_gui attribute=$node.data_map.indirizzo}
                    {/if}
                    {if $node|has_attribute( 'luogo_svolgimento' )}
                        {attribute_view_gui attribute=$node.data_map.luogo_svolgimento}
                    {/if}
                    {if $node|has_attribute( 'comune' )}
                        {*if $node|has_attribute( 'cap' )}
                          {attribute_view_gui attribute=$node.data_map.cap}
                        {/if*}
                        {attribute_view_gui attribute=$node.data_map.comune}
                    {/if}
                    {if $node|has_attribute( 'geo' )}
                        {attribute_view_gui attribute=$node.data_map.geo zoom=3}
                    {/if}
                </div>
            </div>

        {/if}

        {if or($node|has_attribute( 'url' ),$node|has_attribute( 'email' ),$node|has_attribute( 'telefono' ),$node|has_attribute( 'fax' ))}
            <h2>Contatti</h2>
            <div class="widget">
                <div class="widget_content">
                    <ul class="list-group">
                        {if $node|has_attribute( 'telefono' )}
                            <li class="list-group-item"><i class="fa fa-phone"></i> {attribute_view_gui attribute=$node.data_map.telefono}</li>
                        {/if}
                        {if $node|has_attribute( 'fax' )}
                            <li class="list-group-item"><i class="fa fa-fax"></i> {attribute_view_gui attribute=$node.data_map.fax}</li>
                        {/if}
                        {if $node|has_attribute( 'email' )}
                            <li class="list-group-item"><i class="fa fa-envelope"></i> {attribute_view_gui attribute=$node.data_map.email}</li>
                        {/if}
                        {if $node|has_attribute( 'url' )}
                            <li class="list-group-item"><i class="fa fa-globe"></i> {attribute_view_gui attribute=$node.data_map.url}</li>
                        {/if}
                    </ul>
                </div>
            </div>
        {/if}


        {if $openpa.content_gallery.has_images}
            <h2><i class="fa fa-camera"></i> {$openpa.content_gallery.title}</h2>
            <div class="widget">
                <div class="widget_content">
                    {include uri='design:atoms/gallery.tpl' items=$openpa.content_gallery.images title=false()}
                </div>
            </div>
        {/if}


    </div>

</div>