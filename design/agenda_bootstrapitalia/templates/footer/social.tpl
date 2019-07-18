<ul class="list-inline text-left social">
    {if is_set($social_links.facebook)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$social_links.facebook}" aria-label="Facebook" target="_blank">
                {display_icon('it-facebook', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($social_links.twitter)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$social_links.twitter}" aria-label="Twitter" target="_blank">
                {display_icon('it-twitter', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($social_links.linkedin)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$social_links.linkedin}" aria-label="Linkedin" target="_blank">
                {display_icon('it-linkedin', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($social_links.instagram)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$social_links.instagram}" aria-label="Instagram" target="_blank">
                {display_icon('it-instagram', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}

    {if is_set($social_links.youtube)}
        <li class="list-inline-item">
            <a class="p-2 text-white" href="{$social_links.youtube}" aria-label="YouTube" target="_blank">
                {display_icon('it-youtube', 'svg', 'icon icon-sm icon-white align-top')}
            </a>
        </li>
    {/if}
</ul>
