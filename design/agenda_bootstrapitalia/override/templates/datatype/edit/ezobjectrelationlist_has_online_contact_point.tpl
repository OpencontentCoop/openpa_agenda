<div id="online-contact-point"
     data-context="{$attribute.object.id}"
     data-attribute="{$attribute.id}"
     data-validation="{"Input did not validate"|i18n("design/standard/content/edit")}: {$attribute.contentclass_attribute.name|wash()}"
     class="bg-white">
</div>
{if $attribute.content.relation_list}
    {foreach $attribute.content.relation_list as $item}
    <input type="hidden" name="ContentObjectAttribute_data_object_relation_list_{$attribute.id}[]" value="{$item.contentobject_id}" />
    {/foreach}
{/if}

<script>

$(document).ready(function () {ldelim}
{literal}
    var form = $('form');
    var container = $('#online-contact-point');
    container.opendataForm({context: container.data('context')}, {
        connector: 'has_online_contact_point',
        onSuccess: function (data) {
            alert(JSON.stringify(data))
        },
        i18n: {{/literal}
            'actions': "...",
            'store': "{'Store'|i18n('opendata_forms')}",
            'cancel': "{'Cancel'|i18n('opendata_forms')}",
            'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
            'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
            'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
            {literal}},
        alpaca: {
            "options": {
                "form": {
                    "buttons": {
                        "submit": {
                            "styles": "d-none",
                            'id': 'save-contact-point',
                            "click": function() {},
                        },
                        "reset": {
                            "click": function () {},
                            "styles": "d-none"
                        }
                    }
                }
            }
        }
    });
    form.on('submit', function (e){
        var submitter = $(e.originalEvent.submitter).attr('name') ?? '';
        if (submitter === 'PublishButton') {
            var contactForm = container.alpaca("get").form;
            var canSubmit = false;
            if (contactForm.isValid(true)) {
                contactForm.ajaxSubmit({
                    async: false,
                    success: function (data) {
                        let error = data.error || false
                        canSubmit = !error;
                        if (canSubmit) {
                            container.append('<input type="hidden" name="ContentObjectAttribute_data_object_relation_list_' + container.data('attribute') + '[]" value="' + data + '" />')
                        }
                    }
                })
            }
            if (!canSubmit) {
                alert(container.data('validation'))
                e.preventDefault();
            }
        }
    })
{/literal}
{rdelim});
</script>
