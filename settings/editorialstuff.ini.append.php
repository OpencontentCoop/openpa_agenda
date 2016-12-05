<?php /* #?ini charset="utf-8"?


[AvailableActions]
Actions[]=NotifyEventOwner
Actions[]=NotifyCommentOwner

[NotifyEventOwner]
ClassName=OpenPAAgenda
MethodName=notifyEventOwner

[NotifyCommentOwner]
ClassName=OpenPAAgenda
MethodName=notifyCommentOwner


[AvailableFactories]
Identifiers[]=agenda
Identifiers[]=associazione
Identifiers[]=programma_eventi
Identifiers[]=commenti

[agenda]
ClassName=AgendaFactory
ClassIdentifier=event
CreationButtonText=Crea un nuovo evento
AttributeIdentifiers[]
AttributeIdentifiers[images]=images
AttributeIdentifiers[videos]=video
AttributeIdentifiers[audios]=audio
AttributeIdentifiers[tags]=argomento
StateGroup=moderation
States[skipped]=Non necessita di moderazione
States[draft]=In lavorazione
States[waiting]=In attesa di moderazione
States[accepted]=Accettato
States[refused]=Rifiutato
Actions[]
Actions[waiting-accepted]=NotifyEventOwner
Actions[waiting-refused]=NotifyEventOwner

[associazione]
ClassName=AssociazioneFactory
ClassIdentifier=associazione
CreationButtonText=Crea una nuova associazione
AttributeIdentifiers[]
StateGroup=privacy
States[public]=Pubblico
States[private]=Privato
NotificationAttributeIdentifiers[]

[programma_eventi]
ClassName=ProgrammaEventiFactory
ClassIdentifier=programma_eventi
CreationButtonText=Crea un nuovo programma eventi
AttributeIdentifiers[]
StateGroup=programma_eventi
StateGroup=privacy
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

