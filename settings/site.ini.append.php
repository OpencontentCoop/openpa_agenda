<?php /*

[RegionalSettings]
TranslationExtensions[]=openpa_agenda

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


*/ ?>
