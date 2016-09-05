<?php /* #?ini charset="utf-8"?

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
NotificationAttributeIdentifiers[]


[associazione]
ClassName=AssociazioneFactory
ClassIdentifier=associazione
CreationButtonText=Crea una nuova associazione
AttributeIdentifiers[]
StateGroup=privacy
States[public]=Pubblico
States[provate]=Privato
NotificationAttributeIdentifiers[]


[programma_eventi]
ClassName=ProgrammaEventiFactory
ClassIdentifier=programma_eventi
CreationButtonText=Crea un nuovo programma eventi
AttributeIdentifiers[]
StateGroup=programma_eventi
StateGroup=privacy
States[public]=Pubblico
States[provate]=Privato
NotificationAttributeIdentifiers[]
