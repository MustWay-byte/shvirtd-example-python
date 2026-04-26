#!/bin/bash
set -e

BACKUP_DIR="/opt/backup"
NETWORK="shvirtd-example-python_backend"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

# Загружаем секреты из защищённого файла
if [ -f "$BACKUP_DIR/.env.backup" ]; then
    source "$BACKUP_DIR/.env.backup"
else
    echo "ERROR: .env.backup not found in $BACKUP_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Запускаем mysqldump из образа mysql:8
docker run --rm \
    --network="$NETWORK" \
    -v "$BACKUP_DIR":/backup \
    --entrypoint mysqldump \
    mysql:8 \
    -h db \
    -u root \
    -p"$MYSQL_ROOT_PASSWORD" \
    "$MYSQL_DATABASE" \
    --result-file="/backup/$(basename "$BACKUP_FILE")"

echo "Backup created: $BACKUP_FILE"
