{section show=$validation.processed}
{section show=or($validation.attributes,$validation.placement,$validation.custom_rules)}

<div class="alert alert-warning">
    {section show=or(and($validation.attributes,$validation.placement),$validation.custom_rules)}
    <h3>{"Validation failed"|i18n("design/standard/content/edit")}</h3>
    {section-else}
    {section show=$validation.attributes}
        <h3>{"Input did not validate"|i18n("design/standard/content/edit")}</h3>
        {section-else}
            <h3>{"Location did not validate"|i18n("design/standard/content/edit")}</h3>
        {/section}
    {/section}
    <ul class="list-unstyled">
        {section name=UnvalidatedPlacements loop=$validation.placement show=$validation.placement}
            <li>{$:item.text}</li>
        {/section}
        {section name=UnvalidatedAttributes loop=$validation.attributes show=$validation.attributes}
            <li><a href="#" data-invalid_identifier="{$:item.identifier|wash}"><strong>{$:item.name|wash}:</strong></a> {$:item.description}</li>
        {/section}
        {section name=UnvalidatedCustomRules loop=$validation.custom_rules show=$validation.custom_rules}
            {if is_set($:item.identifier)}
                <li><a href="#" data-invalid_identifier="{$:item.identifier|wash}">{$:item.text|wash}</a></li>
            {else}
                <li>{$:item.text}</li>
            {/if}
        {/section}
    </ul>
</div>
{section-else}
    {section show=$validation_log}
        <div class="alert alert-warning">
            <h3>{"Input was partially stored"|i18n("design/standard/content/edit")}
                {section name=ValidationLog loop=$validation_log}
                    <ul class="list-unstyled">
                        <li><strong>{$:item.name|wash}:</strong></li>
                        {section name=LogMessage loop=$:item.description}
                            <li>{$:item}</li>
                        {/section}
                    </ul>
                {/section}
        </div>
        {section-else}
            <div class="alert alert-success">
                {"Input was stored successfully"|i18n("design/standard/content/edit")}
            </div>
        {/section}
    {/section}
{/section}
