# Audit Accessi Linux via Telegram

Questo progetto fornisce un sistema di notifica in tempo reale per l'autenticazione degli utenti su sistemi Linux. 
Integrandosi con PAM (Pluggable Authentication Modules), lo script invia avvisi dettagliati a un bot Telegram ogni volta che una sessione utente viene aperta o chiusa.

## Funzionalità
* **Esecuzione Asincrona**: Lo script viene eseguito in background per garantire che il login dell'utente non sia mai bloccato o rallentato dalla latenza di rete o dai tempi di risposta delle API di Telegram.
* **Integrazione PAM**: Monitora molteplici tipi di servizio, inclusi SSH, TTY locali e sessioni sudo.
* **Risoluzione Identità**: Utilizza `getent` per recuperare il nome completo dell'utente (GECOS) per una migliore identificazione.
* **Intelligence IP**: Include il rilevamento automatico dell'IP sorgente e fornisce un link diretto alle informazioni geografiche per le connessioni remote.
* **Whitelisting**: Supporta eccezioni per indirizzi IP specifici per evitare notifiche da host amministrativi fidati.
* **Logging Locale**: Mantiene una traccia di controllo locale in `/var/log/alert_telegram.log` per ridondanza e debug.

---

## Disclaimer

**IMPORTANTE: LEGGERE PRIMA DELL'USO**
Questo software viene fornito "così com'è", senza garanzie di alcun tipo. L'autore non è responsabile per eventuali violazioni della sicurezza, fughe di dati o instabilità del sistema derivanti dall'uso di questo script.
* Questo strumento è destinato esclusivamente a scopi amministrativi e di monitoraggio.
* Assicurarsi di rispettare le normative locali sulla privacy (es. GDPR) relative al monitoraggio delle attività degli utenti.
* Proteggere il file dello script e il file di log con permessi appropriati per impedire l'accesso non autorizzato al Token del Bot Telegram.

---

## Installazione

### 1. Configurazione Bot Telegram
1. Crea un nuovo bot tramite [@BotFather](https://t.me/botfather) su Telegram e ottieni il tuo **API Token**.
2. Avvia una chat con il tuo bot e ottieni il tuo **Chat ID** (puoi usare [@IDBot](https://t.me/idbot) o il metodo `getUpdates` delle API di Telegram).
3. Apri il file `telegram-alert.sh` e compila le variabili `USERID` e `KEY`.

### 2. Distribuzione dello Script
1. Copia lo script nella seguente posizione:
   ```bash
   sudo nano /usr/local/bin/telegram-alert.sh
 ```
### 3. Impostazione permessi
1. Copia lo script nella seguente posizione:
   ```bash
   sudo chmod +x /usr/local/bin/telegram-alert.sh
  ```
### 4. Impostazione permessi per file di log
   ```bash
   sudo touch /var/log/alert_telegram.log
   sudo chmod 666 /var/log/alert_telegram.log
   ```
### 5.  Per attivare lo script per tutti i login basati su sessione, modifica la configurazione di common-session:
   ```bash
   sudo nano /etc/pam.d/common-session
```
  Aggiungendo la seguente riga alla fine del file:
   ```bash
   session optional pam_exec.so /usr/local/bin/telegram-alert.sh
```
