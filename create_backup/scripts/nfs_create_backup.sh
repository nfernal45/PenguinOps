#!/bin/bash

set -uxo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")
BACKUP_DEST="/backups/nfs"
ARCHIVE_NAME="nfs"
BACKUP_FULL_PATH="/${BACKUP_DEST}/${ARCHIVE_NAME}-${CURRENT_DATE}"
SOURCE_DIR="/nfs"
BACKUP_RETENTION_DAYS=3

# Проверяем, существует ли указанный каталог
if [ ! -d "${SOURCE_DIR}" ]; then
    exit 1
fi

# Создаем сжатый архив с датой создания в имени
mkdir -p "${BACKUP_FULL_PATH}/logs"

tar czfv "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.tar.gz" "${SOURCE_DIR}" > "$BACKUP_FULL_PATH"/logs/verbose.log && \
    md5sum "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.tar.gz" > "${BACKUP_FULL_PATH}/${ARCHIVE_NAME}-${CURRENT_DATE}.md5"

# Тут ищём по дате и удаляем старые бэкапы       
PURGE_DATE=$(date -d "-${BACKUP_RETENTION_DAYS} days" +"%Y-%m-%d")
find "/${BACKUP_DEST}" -type d -name "${ARCHIVE_NAME}-${PURGE_DATE}" -exec rm -rf {} \;
