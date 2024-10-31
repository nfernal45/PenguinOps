#!/bin/bash

set -euxo pipefail

REMOTE_IP_ADDR="192.168.88.15"
SSH_LOGIN="user"
REMOTE_SOURCE_DIR="/backups/nfs"
BACKUP_DEST="/backup/nfs"
BACKUP_RETENTION_DAYS=30
ARCHIVE_NAME="nfs"
BACKUP_FILE="$ARCHIVE_NAME"-"$CURRENT_DATE"
BACKUP_FILE_PATH="$BACKUP_DEST"/"$BACKUP_FILE"
CURRENT_DATE=$(date +"%Y-%m-%d")
DISK_USAGE_THRESHOLD=85

E_NOTFREESPACE=47 # Недостаточно свободного места для бэкапа
E_NOTCREATEDIR=25
E_CHECKFILE=44
E_DOWNLOAD=21

mkdir -p "$BACKUP_DEST" || exit $E_NOTCREATEDIR

# Проверка дискового пространства
DISK_USAGE=$(df / | grep $BACKUP_DEST | awk '{ print $5 }' | sed 's/%//g')
[[ ${DISK_USAGE} -gt ${DISK_USAGE_THRESHOLD} ]] || exit $E_NOTFREESPACE

# Проверяем успешность создания архива
if scp -r "$SSH_LOGIN"@"$REMOTE_IP_ADDR":"$REMOTE_SOURCE_DIR"/"$BACKUP_FILE" /"$BACKUP_DEST"/; then

    # Исправляем путь запуска скрипта в файле service
    sed -i "s!$REMOTE_SOURCE_DIR/!/$BACKUP_DEST/!" "$BACKUP_FILE_PATH"/"$BACKUP_FILE".md5

    # Проверяем существование файла для проверки целостности
    if [ -e "$BACKUP_FILE_PATH/$BACKUP_FILE.md5" ]; then     
        
        # Проверяем целостность архива
        if md5sum --quiet -c "$BACKUP_DEST/$BACKUP_FILE/$BACKUP_FILE.md5"; then       
            echo "$CURRENT_DATE arhive Check OK!" >> "$BACKUP_DEST/$ARCHIVE_NAME-$CURRENT_DATE/check.log"

            # Удаляем старые бэкапы по дате    
            DATE_BEFORE=$(date -d "-$BACKUP_RETENTION_DAYS days +%Y-%m-%d")
            find "$BACKUP_DEST" -type d -name "$ARCHIVE_NAME-$DATE_BEFORE" -exec rm -r {} \;
        fi
    else
        echo "$CURRENT_DATE check file not found" >> "$BACKUP_FILE_PATH"/check.log
        exit $E_CHECKFILE
    fi
else
    exit $E_DOWNLOAD
fi