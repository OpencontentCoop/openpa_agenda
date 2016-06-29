{cache-block ignore_content_expiry keys=array( $identifier )}

<section class="hgroup">
  <h1>
    {$page.contentclass_attribute_name|wash()}
  </h1>    
</section>

<div class="row">
  <div class="col-md-12">
    {attribute_view_gui attribute=$page}
  </div>
</div>

{/cache-block}