## Requisiti
*  Se non ancora fatto installare tabella editorialstuff
```php extension/openpa/bin/php/install_sql.php -sala_backend --file=extension/oceditorialstuff/sql/postgesql/schema.sql --run```

 * Versione minima openpa 2.11
 * Versione minima eztags 2.2.1
 * Versione minima ocopendata 2.8
 * Versione minima oceditorialstuff 1.2.1
 * Versione minima ocbootstrap 1.3.3
 * ngopengraph
 ```composer require netgen/ngopengraph```

### Modifica ini

 * in override/ezfind.ini rendere le immagini ricercabili
 * copiare in ala_agenda i file della cartella siteaccess_settings

### Utilizzo di eztags invece di ezobjectrelationlist o ezselection

### Installare eztags

`php extension/openpa/bin/php/check_eztags.php -sala_backend`

Se risponde "Non installato"

`php extension/openpa/bin/php/install_sql.php -sala_backend --file=extension/eztags/sql/postgresql/schema.sql --run`

correggere le conf di solr inserendo in java/solr/ala/conf/custom-fields.xml le stringhe
<field name="ezf_df_tags" type="lckeyword" indexed="true" stored="true" multiValued="true" termVectors="true"/>
<field name="ezf_df_tag_ids" type="sint" indexed="true" stored="true" multiValued="true" termVectors="true"/>

### Installare alberatura tags tcu

`php extension/openpa_agenda/bin/php/generate_eztags_from_tcu.php -sala_backend`

### Modifica della classe image

 * modificare l'identificatore license in license_selection
 * creare attributo license Tags
 * `php extension/openpa_agenda/bin/php/convert_selection_in_tags.php --class=image --selection_attribute=license --tags_attribute=license_tags --tag_root_id=261 -sala_backend` (controlla il tag root in /tags/dashboard)
 * eliminare attributo license_selection

### Modifica della classe event

 * modificare l'identificatore tipo_evento in tipo_evento_relations
 * creare attributo tipo_evento Tags
 * `php extension/openpa_agenda/bin/php/convert_relations_in_tags.php --class=event --relations_attribute=tipo_evento_relations --tags_attribute=tipo_evento --tag_root_id=1 -sala_backend` (controlla il tag root in /tags/dashboard)
 * eliminare attributo tipo_evento_relations

 * modificare l'identificatore target in target_selection
 * creare attributo target Tags
 * `php extension/openpa_agenda/bin/php/convert_selection_in_tags.php --class=event --selection_attribute=target_selection --tags_attribute=target --tag_root_id=43 -sala_backend` (controlla il tag root in /tags/dashboard)
 * eliminare attributo target_selection
 
 * correggere etichette
 
 * impotare attributo iniziativa in odalita Elenco a cascata

### Modifica della classe iniziativa
    
 * nascondere o eliminare attributo image
 * aggiungere attributo images ezrelationlist
 
 * correggere etichette e campi obbligatori

### Modifica della classe agenda_root
 
 * aggiungere attributo "Blocchi homepage" layout ezpage
 * aggiungere attributo "Nascondi classificazioni nell'agenda principale" hide_tags eztags 
 * aggiungere attributo "Nascondi manifestazioni nell'agenda principale" hide_iniziative ezrelationlist

### Far girare script di aggiornamento
`php extension/openpa_agenda/update/update_to_1_5.php -sala_backend`


### Reindicizzare tutto
