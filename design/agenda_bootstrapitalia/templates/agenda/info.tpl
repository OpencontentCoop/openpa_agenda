{cache-block ignore_content_expiry keys=array( $identifier )}
<section class="container">
    <div class="row">
        <div class="col px-lg-4 py-lg-2">

            <h1>{$page.contentclass_attribute_name|wash()}</h1>

            {attribute_view_gui attribute=$page}

        </div>
    </div>
</section>
{/cache-block}

