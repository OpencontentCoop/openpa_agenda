{def $social_links = social_links()}
{if or(is_set($social_links.facebook), is_set($social_links.twitter), is_set($social_links.linkedin), is_set($social_links.instagram), is_set($social_links.youtube))}
<div class="it-socials d-none d-md-flex">
    <span>{'Follow us'|i18n('openpa/footer')}</span>
    <ul>
        {if is_set($social_links.facebook)}
        <li>
            <a href="{$social_links.facebook}" aria-label="Facebook" target="_blank">
                {display_icon('it-facebook', 'svg', 'icon')}
            </a>
        </li>
        {/if}

        {if is_set($social_links.twitter)}
            <li>
                <a href="{$social_links.twitter}" aria-label="Twitter" target="_blank">
                    {display_icon('it-twitter', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($social_links.linkedin)}
            <li>
                <a href="{$social_links.linkedin}" aria-label="Linkedin" target="_blank">
                    {display_icon('it-linkedin', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($social_links.instagram)}
            <li>
                <a href="{$social_links.instagram}" aria-label="Instagram" target="_blank">
                    {display_icon('it-instagram', 'svg', 'icon')}
                </a>
            </li>
        {/if}

        {if is_set($social_links.youtube)}
            <li>
                <a href="{$social_links.youtube}" aria-label="YouTube" target="_blank">
                    {display_icon('it-youtube', 'svg', 'icon')}
                </a>
            </li>
        {/if}

    </ul>
</div>
{/if}
