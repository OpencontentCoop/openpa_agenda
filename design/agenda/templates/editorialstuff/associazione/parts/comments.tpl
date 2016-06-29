{def $attribute = $post.object.data_map.internal_comments}

{if $attribute.content.show_comments}

  {def $attribute_node=$post.node}
  {def $contentobject = $attribute.object}
  {def $language_id =  $attribute.object.current_language_object.id}
  {def $language_code = $attribute.language_code}
  {def $can_read = fetch( 'comment', 'has_access_to_function', hash( 'function', 'read', 'contentobject', $contentobject, 'language_code', $language_code, 'node', $attribute_node ) )}
      
  {def $sort_field=ezini( 'GlobalSettings', 'DefaultEmbededSortField', 'ezcomments.ini' )}
  {def $sort_order=ezini( 'GlobalSettings', 'DefaultEmbededSortOrder', 'ezcomments.ini' )}
  {def $default_shown_length=ezini( 'GlobalSettings', 'DefaultEmbededCount', 'ezcomments.ini' )}

  {* Fetch comment count *}
  {def $total_count=fetch( 'comment','comment_count', hash( 'contentobject_id', $contentobject.id, 'language_id', $language_id, 'status' ,1 ) )}

  {* Fetch comments *}
  {def $comments=fetch( 'comment', 'comment_list', hash( 'contentobject_id', $contentobject.id, 
                                                         'language_id', $language_id, 
                                                         'sort_field', $sort_field, 
                                                         'sort_order', $sort_order, 
                                                         'offset', 0, 
                                                         'length' ,$default_shown_length,
                                                         'status', 1 ) )}

  {* Find out if the currently used role has a user based edit/delete policy *}
  {def $self_policy=fetch( 'comment', 'self_policies', hash( 'contentobject', $contentobject, 'node', $attribute_node ) )}

  {* Adding comment form START *}        
  {if $attribute.content.enable_comment}
    {def $can_add = fetch( 'comment', 'has_access_to_function', hash( 'function', 'add', 'contentobject', $contentobject, 'language_code', $language_code, 'node', $attribute_node ) )}
    {if $can_add}
        
      {* Adding comment START *}
      {def $user=fetch( 'user', 'current_user' )}
      {def $anonymous_user_id=ezini('UserSettings', 'AnonymousUserID' )}
      {def $is_anonymous=$user.contentobject_id|eq( $anonymous_user_id )}
      {def $comment_notified=ezini( 'GlobalSettings', 'EnableNotification', 'ezcomments.ini' )}
      {def $fields = ezini( 'FormSettings', 'AvailableFields', 'ezcomments.ini' )}
      {def $fieldRequiredText = '<span class="ezcom-field-mandatory">*</span>'}
      
      <form method="post" action={'/comment/add'|ezurl} name="CommentAdd" class="add-comment">
        <input type="hidden" name="ContentObjectID" value="{$contentobject.id}" />
        <input type="hidden" name="CommentLanguageCode" value="{$language_code}" />
        <input type="hidden" name="RedirectURI" value={concat('editorialstuff/edit/',$factory_identifier, '/',$post.object.id)|ezurl( , 'full' )} />
    
        <div class="panel panel-default">
          <div class="panel-body">
            {*if $fields|contains( 'title' )}
                {def $titleRequired = ezini( 'title', 'Required', 'ezcomments.ini' )|eq( 'true' )}
                <div class="form-group">
                    <label class="control-label" for="CommentTitle">
                        {'Title:'|i18n( 'ezcomments/comment/add/form' )}{if $titleRequired}{$fieldRequiredText}{/if}
                    </label>
                    <input id="CommentTitle" type="text" class="form-control " maxlength="100" name="CommentTitle" />
                </div>
                {undef $titleRequired}
            {/if*}
            <input type="hidden" class="form-control " maxlength="50" id="CommentName" name="CommentName" value="{$user.contentobject.name|wash()}" />
            <input type="hidden" name="CommentEmail" />
            <div class="form-group">
              {*<label class="control-label" for="CommentContent">
                {'Content:'|i18n( 'ezcomments/comment/add/form' )}{$fieldRequiredText}
              </label>*}
              <textarea class="form-control " name="CommentContent" rows="6" cols=""></textarea>
            </div>
            <!--
            {if $fields|contains( 'notificationField' )}
                {* When email is enabled or email is enabled but user logged in *}
                {if or( $fields|contains( 'email' ), and( $fields|contains( 'email' )|not, $is_anonymous|not ) )}
                <div class="form-group">
                  <div class="checkbox">
                    <label>
                      <input type="checkbox" name="CommentNotified" {if $comment_notified|eq('true')}checked="checked"{/if} value="1" />
                      {'Notify me of new comments'|i18n( 'ezcomments/comment/add/form' )}
                    </label>
                  </div>
                </div>
                {/if}
            {/if}
            -->
          </div>
          <div class="panel-footer">
            <input type="submit" value="Aggiungi commento" class="btn btn-success btn-block btn-lg" name="AddCommentButton" />                    
          </div>
        </div>              
      </form>
      
      {ezscript_require( array( 'ezjsc::yui3', 'ezjsc::yui3io', 'ezcomments.js' ) )}
      
      <script type="text/javascript">
      eZComments.cfg = {ldelim}
                          postbutton: '#ezcom-post-button',
                          postform: '#ezcom-comment-form',
                          postlist: '#ezcom-comment-list',
                          postcontainer: '#ezcom-comment-list',
                          sessionprefix: '{ezini('Session', 'SessionNamePrefix', 'site.ini')}',
                          sortorder: '{ezini('GlobalSettings', 'DefaultEmbededSortOrder', 'ezcomments.ini')}',
                          fields: {ldelim} 
                                      name: '#CommentName',
                                      website: '#CommentWebsite',
                                      email: '#CommentEmail' 
                                  {rdelim}
                       {rdelim};
      eZComments.init();
      </script>
      
      {undef $comment_notified $fields}
      {undef $user $anonymous_user_id $is_anonymous}
      {* Adding comment END *}        

    {/if}
    {undef $can_add}
  {/if}
  {* Adding comment form END *}
  
  {* Displaying comments START *}
  {if $can_read}
  
    {* Comment item START *}
    {if $comments|count|gt( 0 )}
      <div class="ezcom-view-all">
        <p>
          {if $total_count|gt( count( $comments ) )}
            <div class="alert alert-success">
              <a href={concat( '/comment/view/', $contentobject.id )|ezurl}>
                {'View all %total_count comments'|i18n( 'ezcomments/comment/view', , hash( '%total_count', $total_count ))}
              </a>
            </div>                              
          {/if}
        </p>
      </div>
  
      <div id="ezcom-comment-list" class="ezcom-view-list" style="max-height: 800px; overflow-y: auto; overflow-x: hidden;">
          {for 0 to $comments|count|sub( 1 ) as $index}
                  {include contentobject=$contentobject
                          language_code=$language_code
                          comment=$comments.$index
                          index=$index
                          base_index=0
                          can_self_edit=$self_policy.edit
                          can_self_delete=$self_policy.delete
                          node=$attribute_node
                          uri=concat('design:',$template_directory, '/parts/comments/comment_item.tpl')}
          {/for}                
      </div>
    {/if}
    {* Comment item END *}
      
  {/if}    
  {* Displaying comments END *}  

  
  {undef $can_read}
  {undef $contentobject $language_id $language_code}
  {undef $comments $total_count $default_shown_length $sort_order $sort_field }

{/if} 

{undef $attribute}