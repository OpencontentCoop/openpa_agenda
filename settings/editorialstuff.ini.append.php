<?php /* #?ini charset="utf-8"?


[AvailableActions]
Actions[]=NotifyEventOwner

[NotifyEventOwner]
ClassName=OpenPAAgenda
MethodName=notifyEventOwner


[AvailableFactories]
Identifiers[]=agenda
Identifiers[]=associazione
Identifiers[]=programma_eventi

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

