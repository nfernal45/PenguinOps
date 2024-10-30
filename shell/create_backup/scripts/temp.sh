#!/bin/bash

set -uxo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")
BACKUP_DEST="./dest"
TARGET_DIRS="$*"
BACKUP_RETENTION_DAYS=3
DISK_USAGE_THRESHOLD=85

E_NOTFREESPACE=47 # Недостаточно свободного места для бэкапа
E_NOTDIR=59 # Такой директории нет

if [ $# -lt 1 ]
then
  echo "Нечего бэкапить"
  exit $E_NOTDIR
fi

# Проверка дискового пространства
DISK_USAGE=$(df / | grep $BACKUP_DEST | awk '{ print $5 }' | sed 's/%//g')
if [ ${DISK_USAGE} -gt ${DISK_USAGE_THRESHOLD} ]; then
    exit $E_NOTFREESPACE
fi

create_backup()  
{

    for DIR in $TARGET_DIRS
    do
        if [ ! -d "${DIR}" ]; then
            exit 1
        fi

        TARGET_DIR="${DIR##*/}"
        BACKUP_FULL_PATH="${BACKUP_DEST}/${TARGET_DIR}-${CURRENT_DATE}"
        ARCHIVE_NAME_FULL="${BACKUP_DEST}/${TARGET_DIR}-${CURRENT_DATE}.tar.gz"

        mkdir -p "${BACKUP_FULL_PATH}/logs"
        tar czfv "$ARCHIVE_NAME_FULL" "${DIR}" > "$BACKUP_FULL_PATH"/logs/verbose.log && \
            md5sum "$ARCHIVE_NAME_FULL" > "$BACKUP_FULL_PATH.md5"

        PURGE_DATE=$(date -d "-${BACKUP_RETENTION_DAYS} days" +"%Y-%m-%d")
        find "${BACKUP_DEST}" -type d -name "${ARCHIVE_NAME}-${PURGE_DATE}" -exec rm -rf {} \;
    done
}

create_backup