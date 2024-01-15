<?php /* #?ini charset="utf-8"?


[AvailableActions]
Actions[]=NotifyEventOwner
Actions[]=NotifyCommentOwner
Actions[]=NotifyModerationGroup
Actions[]=TriggerPublishEvent
Actions[]=TriggerDeleteEvent

[NotifyEventOwner]
ClassName=OpenPAAgenda
MethodName=notifyEventOwner

[NotifyCommentOwner]
ClassName=OpenPAAgenda
MethodName=notifyCommentOwner

[NotifyModerationGroup]
ClassName=OpenPAAgenda
MethodName=notifyModerationGroup

[TriggerPublishEvent]
ClassName=OpenPAAgendaEventEmitter
MethodName=triggerPublishEvent

[TriggerDeleteEvent]
ClassName=OpenPAAgendaEventEmitter
MethodName=triggerDeleteEvent

[AvailableFactories]
Identifiers[]=agenda
Identifiers[]=associazione
Identifiers[]=programma_eventi
Identifiers[]=commenti

[agenda]
ClassName=AgendaFactory
ClassIdentifier=event
CreationButtonText=Create new event
AttributeIdentifiers[]
AttributeIdentifiers[image]=image
AttributeIdentifiers[images]=image
StateGroup=moderation
States[skipped]=Non necessita di moderazione
States[draft]=In lavorazione
States[waiting]=In attesa di moderazione
States[accepted]=Accettato
States[refused]=Rifiutato
Actions[]
Actions[waiting-accepted]=TriggerPublishEvent
Actions[waiting-refused]=TriggerDeleteEvent
Actions[draft-accepted]=TriggerPublishEvent
Actions[refused-accepted]=TriggerPublishEvent
Actions[accepted-refused]=TriggerDeleteEvent
Actions[accepted-draft]=TriggerDeleteEvent
Actions[accepted-waiting]=TriggerDeleteEvent
Actions[draft-skipped]=TriggerPublishEvent
Actions[waiting-skipped]=TriggerPublishEvent
Actions[accepted-skipped]=TriggerPublishEvent
Actions[refused-skipped]=TriggerPublishEvent

[associazione]
ClassName=AssociazioneFactory
ClassIdentifier=associazione
CreationButtonText=Create new organization
AttributeIdentifiers[]
StateGroup=privacy
States[public]=Pubblico
States[private]=Privato
NotificationAttributeIdentifiers[]

[programma_eventi]
ClassName=ProgrammaEventiFactory
ClassIdentifier=programma_eventi
CreationButtonText=Create new event program
AttributeIdentifiers[]
StateGroup=programma_eventi
States[public]=Pubblico
States[private]=Privato
NotificationAttributeIdentifiers[]

[commenti]
ClassName=CommentoFactory
ClassIdentifier=comment
AttributeIdentifiers[]
StateGroup=moderation
States[skipped]=Non necessita di moderazione
States[waiting]=In attesa di moderazione
States[accepted]=Accettato
States[refused]=Rifiutato
NotificationAttributeIdentifiers[]
Actions[]
AttributeIdentifiers[]

*/ ?>
