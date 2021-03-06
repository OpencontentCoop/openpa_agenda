{def $locales = fetch( 'content', 'translation_list' )}
{ezscript_require( array( 'ezjsc::jquery', 'jquery.quicksearch.min.js' ) )}
{literal}
<script type="text/javascript">
$(document).ready(function(){  
  $('input.quick_search').quicksearch('table tr');
});  
</script>
{/literal}


<section class="hgroup">
    <h1>{'Settings'|i18n('agenda/menu')}</h1>
</section>

<div class="row">
    <div class="col-md-12">
        <ul class="list-unstyled">
            <li>{'Change general settings'|i18n('agenda/config')} {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$root redirect_if_discarded='/agenda/config' redirect_after_publish='/agenda/config'}</li>
            {if is_moderation_enabled()}
                <li><strong>{'Moderation is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_registration_enabled()}
                <li><strong>{'User registration is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_auto_registration_enabled()}
                <li><strong>{'Organizations registration is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_comment_enabled()}
                <li><strong>{'Comments enabled'|i18n('agenda/config')}</strong></li>
            {/if}
            {if is_login_enabled()}
                <li><strong>{'Login is active'|i18n('agenda/config')}</strong></li>
            {/if}
            {if $root|has_attribute('hide_tags')}
            <li><strong>{'Topics to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_tags')}</li>
            {/if}
            {if $root|has_attribute('hide_iniziative')}
            <li><strong>{'Event collections to hide in the main agenda'|i18n('agenda/config')}:</strong> {attribute_view_gui attribute=$root|attribute('hide_iniziative')}</li>
            {/if}
        </ul>
        

        <hr />

        <div class="row">

            <div class="col-md-3">
              <ul class="nav nav-pills nav-stacked">
                <li role="presentation" {if $current_part|eq('users')}class="active"{/if}><a href="{'agenda/config/users'|ezurl(no)}">{'Users'|i18n('agenda/config')}</a></li>
                <li role="presentation" {if $current_part|eq('moderators')}class="active"{/if}><a href="{'agenda/config/moderators'|ezurl(no)}">{'Moderators'|i18n('agenda/config')}</a></li>
                <li role="presentation" {if $current_part|eq('external_users')}class="active"{/if}><a href="{'agenda/config/external_users'|ezurl(no)}">{'External Users'|i18n('agenda/config')}</a></li>
			  
			  {if $data|count()|gt(0)}
				{foreach $data as $item}
				  <li role="presentation" {if $current_part|eq(concat('data-',$item.contentobject_id))}class="active"{/if}><a href="{concat('agenda/config/data-',$item.contentobject_id)|ezurl(no)}">{$item.name|wash()}</a></li>
				{/foreach}
			  {/if}
			  
              </ul>
            </div>

            <div class="col-md-9">

              {if $current_part|eq('moderators')}
              <div class="tab-pane active" id="moderators">
                <form class="form-inline" action="{'agenda/config/moderators'|ezurl(no)}">
                  <div class="form-group">
                    <input type="text" class="form-control" name="s" placeholder="{'Search'|i18n('agenda/config')}" value="{$view_parameters.query|wash()}" autofocus>
                  </div>
                  <button type="submit" class="btn btn-success"><i class="fa fa-search"></i></button>
                </form>
                {include name=users_table uri='design:agenda/config/moderators_table.tpl' view_parameters=$view_parameters moderator_parent_node_id=$moderators_parent_node_id redirect='/agenda/config/moderators'}
                <div class="pull-right"><a class="btn btn-danger" href="{concat('add/new/user/?parent=',$moderators_parent_node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Add a moderator'|i18n('agenda/config')}</a>
                  <form class="form-inline" style="display: inline" action="{'agenda/config/moderators'|ezurl(no)}" method="post">
                    <button class="btn btn-danger" name="AddModeratorLocation" type="submit"><i class="fa fa-plus"></i> {'Add Existing User'|i18n('agenda/config')}</button>
                  </form>
              </div>
              </div>
              {/if}

              {if $current_part|eq('external_users')}
              <div class="tab-pane active" id="external_users">
                <form class="form-inline" action="{'agenda/config/external_users'|ezurl(no)}">
                  <div class="form-group">
                    <input type="text" class="form-control" name="s" placeholder="{'Search'|i18n('agenda/config')}" value="{$view_parameters.query|wash()}" autofocus>
                  </div>
                  <button type="submit" class="btn btn-success"><i class="fa fa-search"></i></button>
                </form>
                {include name=users_table uri='design:agenda/config/moderators_table.tpl' view_parameters=$view_parameters moderator_parent_node_id=$external_users_parent_node_id redirect='/agenda/config/external_users'}
                <div class="pull-right"><a class="btn btn-danger" href="{concat('add/new/user/?parent=',$external_users_parent_node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Add user'|i18n('agenda/config')}</a>
                  <form class="form-inline" style="display: inline" action="{'agenda/config/external_users'|ezurl(no)}" method="post">
                    <button class="btn btn-danger" name="AddExternalUsersLocation" type="submit"><i class="fa fa-plus"></i> {'Add Existing User'|i18n('agenda/config')}</button>
                  </form>
                </div>
              </div>
              {/if}

              {if $current_part|eq('users')}
              <div class="tab-pane active" id="users">
                <form class="form-inline" action="{'agenda/config/users'|ezurl(no)}">
                  <div class="form-group">
                    <input type="text" class="form-control" name="s" placeholder="{'Search'|i18n('agenda/config')}" value="{$view_parameters.query|wash()}" autofocus>
                  </div>
                  <button type="submit" class="btn btn-success"><i class="fa fa-search"></i></button>
                </form>
                {include name=users_table uri='design:agenda/config/users_table.tpl' view_parameters=$view_parameters user_parent_node=$user_parent_node}
                <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/user/',ezini("UserSettings", "DefaultUserPlacement"))|ezurl(no)}">{'Export to CSV'|i18n('agenda/config')}</a></div>
              </div>
              {/if}


			{if $data|count()|gt(0)}
			  {foreach $data as $item}
				{if $current_part|eq(concat('data-',$item.contentobject_id))}
				<div class="tab-pane active" id="{$item.name|slugize()}">
				  {if $item.children_count|gt(0)}
				  <form action="#">
					<fieldset>
					  <input type="text" name="search" value="" class="quick_search form-control" placeholder="{'Search'|i18n('agenda/config')}" autofocus />
					</fieldset>
				  </form>
				  <table class="table table-hover">
					{foreach $item.children as $child}
					<tr>
					  <td>
						<a href="{concat('agenda/event/',$child.node_id)|ezurl(no)}">
                            {$child.name|wash()}
                        </a>
					  </td>
					  <td>              
						{foreach $child.object.available_languages as $language}
						  {foreach $locales as $locale}
							{if $locale.locale_code|eq($language)}
							  <img src="{$locale.locale_code|flag_icon()}" />
							{/if}
						  {/foreach}
						{/foreach}
					  </td>
					  <td width="1">{include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$child redirect_if_discarded=concat('/agenda/config/data-',$item.contentobject_id) redirect_after_publish=concat('/agenda/config/data-',$item.contentobject_id)}</td>
					  <td width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$child redirect_if_cancel=concat('/agenda/config/data-',$item.contentobject_id) redirect_after_remove=concat('/agenda/config/data-',$item.contentobject_id)}</td>
					</tr>
					{/foreach}
				  </table>
                  {/if}
                  {def $class_identifier = false()
                       $class_name = false()}
                  {if is_set($item.children[0])}
                      {set $class_identifier = $item.children[0].class_identifier
                           $class_name = $item.children[0].class_name}
                  {elseif $item|has_attribute('tags')}
                      {set $class_identifier = $item|attribute('tags').content.keyword_string|explode(', ')[0]
                           $class_name = $class_identifier}
                  {/if}
				  <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/', $class_identifier, '/',$item.node_id)|ezurl(no)}">{'Export to CSV'|i18n('agenda/config')}</a></div>
				  <div class="pull-right"><a class="btn btn-danger"<a href="{concat('add/new/', $class_identifier, '/?parent=',$item.node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Add %classname'|i18n('agenda/config',, hash( '%classname', $class_name ))}</a></div>
                  {undef $class_identifier $class_name}
				</div>
				{/if}
			  {/foreach}
			{/if}  

          </div>

      </div>
  </div>
</div>
