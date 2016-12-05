<?php /*

[RegionalSettings]
TranslationExtensions[]=openpa_agenda

[TemplateSettings]
ExtensionAutoloadPath[]=openpa_agenda

[RoleSettings]
PolicyOmitList[]=agenda/use

[Event]
Listeners[]=content/cache@OpenPAAgendaModuleFunctions::onClearObjectCache


[Cache]
CacheItems[]=agenda

[Cache_agenda]
name=Agenda cache
id=agenda
tags[]=template
path=agenda

[RoleSettings]
PolicyOmitList[]=agenda/qrcode
PolicyOmitList[]=agenda/download


*/ ?>
