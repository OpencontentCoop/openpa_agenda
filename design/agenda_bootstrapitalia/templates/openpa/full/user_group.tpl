{if $node.node_id|eq(associazioni_root_node_id())}
    {include uri='design:agenda/associazioni.tpl' node=$node}
{else}
    <section class="container">
        <div class="row">
            <div class="col px-lg-4 py-lg-2">

                <h1>{$node.name|wash()}</h1>
                {include uri='design:openpa/full/parts/main_attributes.tpl'}

            </div>
        </div>
    </section>

{/if}
