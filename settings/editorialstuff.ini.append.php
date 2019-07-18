<?php /* #?ini charset="utf-8"?


[AvailableActions]
Actions[]=NotifyEventOwner
Actions[]=NotifyCommentOwner
Actions[]=NotifyModerationGroup

[NotifyEventOwner]
ClassName=OpenPAAgenda
MethodName=notifyEventOwner

[NotifyCommentOwner]
ClassName=OpenPAAgenda
MethodName=notifyCommentOwner

[NotifyModerationGroup]
ClassName=OpenPAAgenda
MethodName=notifyModerationGroup


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
AttributeIdentifiers[images]=image
StateGroup=moderation
States[skipped]=Non necessita di moderazione
States[draft]=In lavorazione
States[waiting]=In attesa di moderazione
States[accepted]=Accettato
States[refused]=Rifiutato
Actions[]
Actions[draft-waiting]=NotifyModerationGroup
Actions[waiting-accepted]=NotifyEventOwner
Actions[waiting-refused]=NotifyEventOwner

[associazione]
ClassName=AssociazioneFactory
ClassIdentifier=associazione
CreationButtonText=Create new association
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
