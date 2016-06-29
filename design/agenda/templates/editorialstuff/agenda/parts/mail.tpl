{ezscript_require( array( 'ezjsc::jquery', 'typeahead.js' ) )}
<style>
{literal}
.typeahead,
.tt-query,
.tt-hint {    
}
.typeahead {
    background-color: #fff;
}
.tt-hint {
    color: #999;
    display: block;
    font-size: 14px;
    height: 34px;
    line-height: 1.42857;
    padding: 6px 12px;
    transition: border-color 0.15s ease-in-out 0s, box-shadow 0.15s ease-in-out 0s;
    vertical-align: middle;
    width: 100%;        
}
.tt-dropdown-menu {    
    width: 200%;
    margin-top: 12px;
    padding: 8px 0;
    background-color: #fff;
    border: 1px solid #ccc;
    border: 1px solid rgba(0, 0, 0, 0.2);
    -webkit-border-radius: 8px;
    -moz-border-radius: 8px;
    border-radius: 8px;
    -webkit-box-shadow: 0 5px 10px rgba(0,0,0,.2);
    -moz-box-shadow: 0 5px 10px rgba(0,0,0,.2);
    box-shadow: 0 5px 10px rgba(0,0,0,.2);
}
.tt-suggestion {
    padding: 3px 20px;    
    line-height: 24px;
}
.tt-suggestion.tt-is-under-cursor {
    color: #fff;
    background-color: #0097cf;
}
.tt-suggestion p {
    margin: 0;
}
{/literal}    
</style>

{def $workgroup_node = fetch( content, node, hash( node_id, 1659 ))}

<div class="panel-body" style="background: #fff">
  
  <div class="well">
    <form action="{concat('editorialstuff/send_mail/', $factory_identifier, '/',$post.object.id)|ezurl(no)}" method="post">
      <div class="form-group">
        <label for="extra_recipients" style="display: block">Destinatari</label>        
        <input type="text" class="form-control" id="typeahead" placeholder="Cerca utente">
        <p class="help-block">Inserisci un indirizzo email per riga.</p>
        <textarea id="extra_recipients" class="form-control" rows="3" name="ExtraRecipients"></textarea>
      </div>
      <div class="form-group">
        <label for="message" class="control-label">Messaggio</label>
        <p class="help-block">Opzionale: compare all'inizio del messaggio.</p>
        <textarea id="message" class="form-control" rows="3" name="Message"></textarea>
      </div>
      {if count($post.states)}
      <div class="checkbox">
        <label>
          <input type="checkbox" name="AddApproveButton"> Includi funzioni di approvazione          
        </label>
      </div>
      {/if}
      <div class="clearfix">
        <button type="submit" class="btn btn-warning btn-lg pull-right">Invia mail</button>
      </div>
    </form>
  </div>
  
  {if count( $post.notification_history )|gt(0)}
  <div class="table-responsive">
    <table class="table table-striped">
      <tr>    
          <th>Data</th>
		  <th>Mittente</th>
          <th>Destinatari</th>
          <th>Messaggio</th>        
          <th>Errori</th>        
      </tr>
      {foreach $post.notification_history as $item}
	  <tr{if count($item.params.errors)|gt(0)} class="danger"{/if}>
        <td>{$item.created_time|l10n( shortdatetime )}</td>
		<td>{$item.user.email}</td>
        <td>{if count( $item.params.recipients )|gt(0)}{foreach $item.params.recipients as $recipient}{$recipient|wash()}{delimiter}<br />{/delimiter}{/foreach}{/if}</td>
        <td>{$item.params.message|wash()}</td>
        <td>{foreach $item.params.errors as $error}{$error|wash()}{delimiter}<br />{/delimiter}{/foreach}</td>
      </tr>    
      {/foreach}
    </table>
  </div>
  {/if}

</div>


<script type="text/javascript">
{literal}  
  $(document).ready(function(){
      var url = {/literal}{concat('editorialstuff/find_user')|ezurl()}{literal};
      $('#typeahead').typeahead({              
          remote: url+'?q=%QUERY',
          limit: 10,
          minLength: 3
      });            
      $(document).on( 'typeahead:selected', '#typeahead', function(e,s,n){
        var val = $('#extra_recipients').val();
        val += s.value+'\n';
        $('#extra_recipients').val(val);
        $('#typeahead').typeahead('setQuery', '');
      });
      $('form').keypress(function(e){            
          if ( e.which == 13 ) e.preventDefault();
      });
  });
{/literal} 
</script>