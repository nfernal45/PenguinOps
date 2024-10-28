#!/bin/bash

set -euxo pipefail

REMOTE_IP_ADDR="192.168.88.15"
SSH_LOGIN="user"
REMOTE_SOURCE_DIR="backups/nfs"
BACKUP_DEST="backup/nfs"
BACKUP_RETENTION_DAYS=30
ARCHIVE_NAME="nfs"
CURRENT_DATE=$(date +"%Y-%m-%d")

# Проверяем существование директории для бэкапов и создаем ее при необходимости
mkdir -p "/$BACKUP_DEST"

# Копируем архив


# Проверяем успешность создания архива
if scp -r "$SSH_LOGIN"@"$REMOTE_IP_ADDR":/"$REMOTE_SOURCE_DIR"/"$ARCHIVE_NAME"-"$CURRENT_DATE" /"$BACKUP_DEST"/; then

    # Исправляем путь запуска скрипта в файле service
    sed -i "s!/$REMOTE_SOURCE_DIR/!/$BACKUP_DEST/!" /"$BACKUP_DEST"/"$ARCHIVE_NAME-$CURRENT_DATE"/"$ARCHIVE_NAME-$CURRENT_DATE".md5

    # Проверяем существование файла для проверки целостности
    if [ -e /"$BACKUP_DEST"/"$ARCHIVE_NAME"-"$CURRENT_DATE"/"$ARCHIVE_NAME-$CURRENT_DATE".md5 ]; then     
        

        # Проверяем целостность архива
        if md5sum --quiet -c /"$BACKUP_DEST"/"$ARCHIVE_NAME"-"$CURRENT_DATE"/"$ARCHIVE_NAME-$CURRENT_DATE".md5; then       
            echo "$CURRENT_DATE arhive Check OK!" >> /$BACKUP_DEST/$ARCHIVE_NAME-"$CURRENT_DATE"/check.log

            # Удаляем старые бэкапы по дате    
            DATE_BEFORE=$(date -d "-$BACKUP_RETENTION_DAYS days" +"%Y-%m-%d")
            find /"$BACKUP_DEST" -type d -name "$ARCHIVE_NAME-$DATE_BEFORE" -exec rm -r {} \;
        else
            echo "$CURRENT_DATE arhive Check is NOT OK!" >> /"$BACKUP_DEST"/"$ARCHIVE_NAME-$CURRENT_DATE"/check.log
            exit 1
        fi
    else
        echo "$CURRENT_DATE check file not found" >> /"$BACKUP_DEST"/"$ARCHIVE_NAME-$CURRENT_DATE"/check.log
    fi
else
    echo "Произошла ошибка при скачивании архива $CURRENT_DATE"
    exit 1
fi