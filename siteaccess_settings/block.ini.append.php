<?php /*

[PushToBlock]
ContentClasses[]

[General]
AllowedTypes[]
AllowedTypes[]=Evento
#AllowedTypes[]=PdfLink
AllowedTypes[]=CalendarLink


[Evento]
Name=Evento o iniziativa
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=node
CustomAttributes[]=text
CustomAttributeTypes[text]=text
UseBrowseMode[node]=true
CustomAttributeNames[text]=Testo
ViewList[]
ViewList[]=evento
ViewName[]
ViewName[evento]=default
BrowseTemplate=block_event_iniziativa

[PdfLink]
Name=Link al download volantino
ManualAddingOfItems=disabled
CustomAttributes[]
CustomAttributes[]=text
CustomAttributeTypes[text]=text
CustomAttributes[]=image
UseBrowseMode[image]=true
CustomAttributeNames[text]=Testo
CustomAttributeNames[image]=Seleziona immagine
ViewList[]
ViewList[]=pdf_link
ViewName[html]=pdf_link
BrowseTemplate=images
BrowseStartNode=media/images

[CalendarLink]
Name=Link a un calendario specifico
ManualAddingOfItems=enabled
NumberOfValidItems=1
NumberOfArchivedItems=0
ViewList[]
ViewList[]=calendar_link
ViewName[html]=calendar_link



*/ ?>
