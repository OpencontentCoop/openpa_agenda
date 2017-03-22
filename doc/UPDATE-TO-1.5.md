## Requisiti

 - Versione minima openpa 2.11
 - Versione minima eztags 2.2.1
 - Versione minima ocopendata 2.8

### Utilizzo di eztags invece di ezobjectrelationlist o ezselection

### Installare eztags

`php extension/openpa/bin/php/check_eztags.php -sala_backend`

Se risponde "Non installato"

`php extension/openpa/bin/php/install_sql.php -sala_backend --file=/home/httpd/comunweb/html/extension/eztags/sql/postgresql/schema.sql --run`

### Installare alberatura tags tcu

`php extension/openpa_agenda/bin/php/generate_eztags_from_tcu.php -sala_backend`

### Modifica della classe event

- modificare l'identificatore tipo_evento in tipo_evento_relation
