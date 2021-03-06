<?php /*

[RegionalSettings]
TranslationExtensions[]=openpa_agenda

[TemplateSettings]
ExtensionAutoloadPath[]=openpa_agenda

[RoleSettings]
PolicyOmitList[]=agenda/use

[Event]
Listeners[]=content/cache@OpenPAAgendaModuleFunctions::onClearObjectCache
Listeners[]=request/input@OpenPAAgendaModuleFunctions::checkUserRegister

[Cache]
CacheItems[]=agenda

[Cache_agenda]
name=Agenda cache
id=agenda
tags[]=template
path=agenda
isClustered=true
class=OpenPAAgendaModuleFunctions

[RoleSettings]
PolicyOmitList[]=agenda/qrcode
PolicyOmitList[]=agenda/download
PolicyOmitList[]=agenda/register_associazione

*/ ?>
