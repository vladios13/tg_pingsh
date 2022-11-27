#!/bin/bash

# t.me/vladios13blog
#        _           _ _           _ _____ 
# __   _| | __ _  __| (_) ___  ___/ |___ / 
# \ \ / / |/ _` |/ _` | |/ _ \/ __| | |_ \ 
#  \ V /| | (_| | (_| | | (_) \__ \ |___) |
#   \_/ |_|\__,_|\__,_|_|\___/|___/_|____/ 


# Создаем файл, где будем хранить статус пинга
if [[ -f '/var/log/status_ping.log' ]]; then
    echo "Файл доступен"
else
# записываем 
    echo "connected" > /var/log/status_ping.log
fi


# ПЕРЕМЕННЫЕ
status="$(cat /var/log/status_ping.log)"                    # LOGS
logfile=/var/log/pingrouter.log                             # LOGS
IP="1.1.1.1"                                                # IP
CHAT_ID=""                                                  # ID-чата куда отправляем сообщение
TOKEN=""                                                    # токен бота, берем у @BotFather
count_c="3"                                                 # количество попыток
URL="https://api.telegram.org/bot$TOKEN/sendMessage"        # API

result=$(ping -c $count_c $IP 2<&1| grep -icE 'unknown|expired|unreachable|time out|100% packet loss')

# Если пинга нет, то меняем статус и отправляем msg в Telegram
if [[ "$result" != 0 && "$status" = connected ]]; then
date "+%Y.%m.%d %H:%M:%S Не доступно" | tee -a "${logfile}"
echo 'disconnected' > /var/log/status_ping.log
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="❌ $IP: нет доступа"
exit 0

# Если адрес стал доступен, то меняем статус и отправляем msg в Telegram
elif [[ "$result" = 0 && "$status" = disconnected ]]; then
date "+%Y.%m.%d %H:%M:%S Доступно" | tee -a "${logfile}"
echo 'connected' > /var/log/status_ping.log
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="✅ $IP: доступен"
exit 0

# В других случаях ничего не делаем
else
exit 0
fi
