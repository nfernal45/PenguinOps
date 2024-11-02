#!/bin/bash

set -euxo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")
BACKUP_DEST="/tmp/dest"
TARGET_DIRS="$*"
BACKUP_RETENTION_DAYS=3
DISK_USAGE_THRESHOLD=85

E_NOTFREESPACE=47 # Недостаточно свободного места для бэкапа
E_NOTDIR=59       # Такой директории нет
E_BADARGUMENT=88

[[ $# -gt 0 ]] || { echo "Нечего бэкапить" ; exit $E_BADARGUMENT ; }

# Проверка дискового пространства
DISK_USAGE=$(df "$BACKUP_DEST" | awk 'NR == 2{ print $5 }' | sed 's/%//g')
[[ ${DISK_USAGE} -lt ${DISK_USAGE_THRESHOLD} ]] || exit $E_NOTFREESPACE

create_backup()  
{
    for DIR in ${TARGET_DIRS}; do

        [[ ! -d "${DIR}" ]] && exit $E_NOTDIR

        TARGET_DIR="${DIR##*/}"
        BACKUP_DIR="${BACKUP_DEST}/${TARGET_DIR}-${CURRENT_DATE}"
        ARCHIVE_PATH="${BACKUP_DIR}/${TARGET_DIR}-${CURRENT_DATE}.tar.gz"
        LOG_PATH="${BACKUP_DIR}/logs/verbose.log"
        MD5_PATH="${BACKUP_DIR}/${TARGET_DIR}-${CURRENT_DATE}.md5"
        PURGE_DATE=$(date -d "-${BACKUP_RETENTION_DAYS} days" +"%Y-%m-%d")

        mkdir -p "${BACKUP_DIR}/logs"
        tar -v -czf "${ARCHIVE_PATH}" "${DIR}" > "${LOG_PATH}" && \
            md5sum "${ARCHIVE_PATH}" > "${MD5_PATH}"
        find "${BACKUP_DEST}" -type d -name "${TARGET_DIR}-${PURGE_DATE}" -exec rm -rf {} \;
    done
}

create_backup