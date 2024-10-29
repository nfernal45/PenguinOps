#!/bin/bash

set -uxo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")
BACKUP_DEST="./dest"
SOURCE_DIRS="$*"
BACKUP_RETENTION_DAYS=3

if [ $# -lt 1 ]
then
  echo "Нечего бэкапить"
  exit 1
fi

create_backup()  
{

    for DIR in $SOURCE_DIRS
    do
        if [ ! -d "${DIR}" ]; then
            exit 1
        fi

        ARCHIVE_NAME="${DIR##*/}"
        BACKUP_FULL_PATH="${BACKUP_DEST}/${ARCHIVE_NAME}-${CURRENT_DATE}"

        mkdir -p "${BACKUP_FULL_PATH}/logs"
        tar czfv "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.tar.gz" "${DIR}" > "$BACKUP_FULL_PATH"/logs/verbose.log && \
            md5sum "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.tar.gz" > "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.md5"

        PURGE_DATE=$(date -d "-${BACKUP_RETENTION_DAYS} days" +"%Y-%m-%d")
        find "${BACKUP_DEST}" -type d -name "${ARCHIVE_NAME}-${PURGE_DATE}" -exec rm -rf {} \;
    done
}

create_backup