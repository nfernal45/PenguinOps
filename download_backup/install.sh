#!/bin/bash

set -euo pipefail

SCRIPT_NAME="nfs"
SCRIPT_FILE="${SCRIPT_NAME}_download.sh"
SERVICE_NAME="${SCRIPT_NAME}_download"
SERVICE_PATH="/etc/systemd/system"
NEW_EXEC_START_PATH="$(pwd)/scripts/${SCRIPT_FILE}"

mv "$(pwd)/systemctl/temp.service" "$(pwd)/systemctl/${SERVICE_NAME}.service" 
mv "$(pwd)/systemctl/temp.timer" "$(pwd)/systemctl/${SERVICE_NAME}.timer" 

if [ -e "${SERVICE_PATH}/${SERVICE_NAME}.timer" ]; then
    systemctl stop ${SERVICE_NAME}.timer
    systemctl disable ${SERVICE_NAME}.timer
fi


if [ -e "${SERVICE_PATH}/${SERVICE_NAME}.service" ]; then
    systemctl stop ${SERVICE_NAME}.service
    rm -f "${SERVICE_PATH}/${SERVICE_NAME}.service"
fi

sed -i "s|ExecStart=/bin/bash .*|ExecStart=${NEW_EXEC_START_PATH}|" "$(pwd)/systemctl/${SERVICE_NAME}.service"
sed -i "s|Unit= .*|${SERVICE_NAME}.service|" "$(pwd)/systemctl/${SERVICE_NAME}.timer"
sed -i "s|Description= .*|${SCRIPT_NAME}_timer|" "$(pwd)/systemctl/${SERVICE_NAME}.timer"
sed -i "s|Description= .*|${SCRIPT_NAME}_service|" "$(pwd)/systemctl/${SERVICE_NAME}.service"

ln -s "$(pwd)"/systemctl/${SERVICE_NAME}.service ${SERVICE_PATH}/${SERVICE_NAME}.service
ln -s "$(pwd)"/systemctl/${SERVICE_NAME}.timer ${SERVICE_PATH}/${SERVICE_NAME}.timer

# Перезагрузка демона systemd и запускаем таймер
systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.timer


# Проверка успешного выполнения команд
if systemctl start ${SERVICE_NAME}.timer; then
    echo "Таймер ${SERVICE_NAME}.timer создан и добавлен в автозагрузку"
else
    echo "Ошибка при создании таймера ${SERVICE_NAME}.timer"
fi