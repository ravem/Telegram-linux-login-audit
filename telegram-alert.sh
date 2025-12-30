#!/bin/bash
# FILE /usr/local/bin/telegram-alert.sh

#################
# CONFIGURAZIONE TELEGRAM
#################
USERID="NNNNNNNN"
KEY="xxxxxxxxxx:xxxxxxxxxxxxx-xxxxxxx"
URL="https://api.telegram.org/bot${KEY}/sendMessage"

##############
# CONFIGURAZIONE ALERT
##############
# Escludi questi IP dalle notifiche (es. il tuo IP statico o localhost)
KNOWN_IPs="127.0.0.1 ::1"
LOG_FILE="/var/log/alert_telegram.log"
DATE="$(date "+%d %b %Y %H:%M:%S")"

# Ottiene l'IP del server in modo dinamico
SRV_IP=$(hostname -I | awk '{print $1}')

###############
# LOGICA PRINCIPALE
###############

# 1. Verifica se l'IP è nella whitelist
if [[ " ${KNOWN_IPs} " == *" ${PAM_RHOST} "* ]]; then
    exit 0
fi

# 2. Integrazione getent: recupera il nome reale (GECOS)
# getent passwd recupera la riga dell'utente, cut estrae il 5° campo (Nome Reale)
REAL_NAME=$(getent passwd "${PAM_USER}" | cut -d: -f5 | cut -d, -f1)
if [ -z "$REAL_NAME" ]; then
    DISPLAY_USER="${PAM_USER}"
else
    DISPLAY_USER="${REAL_NAME} (${PAM_USER})"
fi

# 3. Gestione tipo di evento (Apertura o Chiusura sessione)
if [ "${PAM_TYPE}" = "open_session" ]; then
    ACTION="ha effettuato l'accesso a"
    STATUS="🟢 LOGIN"
else
    ACTION="si è disconnesso da"
    STATUS="🔴 LOGOUT"
fi

# 4. Analisi IP Sorgente
USER_IP="${PAM_RHOST}"
if [ -z "$USER_IP" ] || [ "$USER_IP" = "::1" ]; then
    USER_IP="Locale/TTY"
    IP_INFO_LINK=""
else
    IP_INFO_LINK="🌐 [Info Geografica IP](https://ip-api.com/#${USER_IP})"
fi

# 5. Costruzione del Messaggio
TEXT="$STATUS
*Utente:* ${DISPLAY_USER}
*Azione:* $ACTION *${HOSTNAME}* ($SRV_IP)
*IP Sorgente:* ${USER_IP}
$IP_INFO_LINK
*Data:* ${DATE}
*Servizio:* ${PAM_SERVICE}
*TTY:* ${PAM_TTY}"

# 6. Log locale per debug
{
    echo "--- $DATE ---"
    echo "Event: $STATUS | User: $PAM_USER | IP: $USER_IP | Service: $PAM_SERVICE"
} >> ${LOG_FILE}

# 7. Invio asincrono a Telegram
# --max-time 10: evita di bloccare il login se Telegram non risponde
# & : esegue in background per non rallentare l'accesso dell'utente
curl -s --max-time 10 \
    -d "chat_id=${USERID}" \
    -d "text=${TEXT}" \
    -d "disable_web_page_preview=true" \
    -d "parse_mode=markdown" \
    "${URL}" > /dev/null 2>&1 &

exit 0