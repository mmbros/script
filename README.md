# Script

## move_to_serie_tv
Sposta i file video di una Serie TV.  

* `--source` : cartella sorgente da cui prelevare ricorsivamente i file video.
* `--dest` : cartella base di destinazione

Per ogni file vengonoe determinate le seguenti informazioni:
* nome della serie_tv
* stagione della serie

Il file viene spostato nella cartella

    <DEST> / <NOME SERIE> / <S0X>


### File di configurazione

La serie TV deve essere presente nel file di configurazione.  
Per ogni serie deve essere presente una riga con il seguente formato:

      MATCH[;FOLDER]
I due campi, separati da `;`, hanno il seguente significato:
* *MATCH*: stringa con cui effettuare il pattern matching del nome del file
* *FOLDER*: nome della cartella della serie. Il campo è opzionale; se mancante viene utilizzato il campo MATCH
