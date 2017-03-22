## Requisiti
*  Se non ancora fatto installare tabella editorialstuff
```php extension/openpa/bin/php/install_sql.php -sala_backend --file=/home/httpd/comunweb/html/extension/oceditorialstuff/sql/postgesql/schema.sql --run```

 * Versione minima openpa 2.11
 * Versione minima eztags 2.2.1
 * Versione minima ocopendata 2.8
 * ngopengraph
 ```composer require netgen/ngopengraph```

### Utilizzo di eztags invece di ezobjectrelationlist o ezselection

### Installare eztags

`php extension/openpa/bin/php/check_eztags.php -sala_backend`

Se risponde "Non installato"

`php extension/openpa/bin/php/install_sql.php -sala_backend --file=/home/httpd/comunweb/html/extension/eztags/sql/postgresql/schema.sql --run`

### Installare alberatura tags tcu

`php extension/openpa_agenda/bin/php/generate_eztags_from_tcu.php -sala_backend`

### Modifica della classe event

 * modificare l'identificatore tipo_evento in tipo_evento_relations
 * creare attributo tipo_evento Tags
 * `php extension/openpa_agenda/bin/php/convert_relations_in_tags.php --class=event --relations_attribute=tipo_evento_relations --tags_attribute=tipo_evento --tag_root_id=1 -sala_backend` (controlla il tag root in /tags/dashboard)
 * eliminare attributo tipo_evento_relations

  * modificare l'identificatore target in target_selection
  * creare attributo target Tags
  * `php extension/openpa_agenda/bin/php/convert_selection_in_tags.php --class=event --selection_attribute=target_selection --tags_attribute=target --tag_root_id=43 -sala_backend` (controlla il tag root in /tags/dashboard)
  * eliminare attributo target_selection

### Reindicizzare tutto