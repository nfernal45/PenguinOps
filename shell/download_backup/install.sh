#!/bin/bash

set -euo pipefail

SCRIPT_NAME="temp"
SCRIPT_FILE="${SCRIPT_NAME}"
SERVICE_NAME="${SCRIPT_FILE}"
SERVICE_PATH="/etc/systemd/system"
NEW_EXEC_START_PATH="$(pwd)/scripts/${SCRIPT_FILE}.sh"
# DEST_DIR="/BACKUPS"

# if [ ! -d "${DEST_DIR}" ]; then
#     echo "Целевая директория не существует"
#     exit 1
# fi

mv --update=none "$(pwd)"/systemctl/*.service "$(pwd)/systemctl/${SERVICE_NAME}.service"
mv --update=none "$(pwd)"/systemctl/*.timer "$(pwd)/systemctl/${SERVICE_NAME}.timer"
mv --update=none "$(pwd)"/scripts/*.sh "$(pwd)/scripts/${SCRIPT_FILE}.sh"

if [ -e "${SERVICE_PATH}/${SERVICE_NAME}.timer" ]; then
    systemctl stop ${SERVICE_NAME}.timer
    systemctl disable ${SERVICE_NAME}.timer
fi

if [ -e "${SERVICE_PATH}/${SERVICE_NAME}.service" ]; then
    systemctl stop ${SERVICE_NAME}.service
    rm -f "${SERVICE_PATH}/${SERVICE_NAME}.service"
fi

sed -i "s|ExecStart=.*|ExecStart=${NEW_EXEC_START_PATH}|" "$(pwd)/systemctl/${SERVICE_NAME}.service"
sed -i "s|Unit=.*|Unit=${SERVICE_NAME}.service|" "$(pwd)/systemctl/${SERVICE_NAME}.timer"
sed -i "s|Description=.*|Description=${SCRIPT_NAME}_timer|" "$(pwd)/systemctl/${SERVICE_NAME}.timer"
sed -i "s|Description=.*|Description=${SCRIPT_NAME}_service|" "$(pwd)/systemctl/${SERVICE_NAME}.service"

ln -s "$(pwd)"/systemctl/${SERVICE_NAME}.service ${SERVICE_PATH}/${SERVICE_NAME}.service
ln -s "$(pwd)"/systemctl/${SERVICE_NAME}.timer ${SERVICE_PATH}/${SERVICE_NAME}.timer

systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.timer

if systemctl start ${SERVICE_NAME}.timer; then
    echo "Таймер ${SERVICE_NAME}.timer создан и добавлен в автозагрузку"
else
    echo "Ошибка при создании таймера ${SERVICE_NAME}.timer"
fi
