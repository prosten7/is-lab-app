#!/usr/bin/env bash
set -euo pipefail

STACK_DIR=/home/deployer/deploy/is-stack
BACKUP_DIR=/opt/backups/mssql
KEEP=5

source "$STACK_DIR/.env"
export GODEBUG=x509negativeserial=1

IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" is-mssql)
NAME="IsLabDb_$(date +%Y%m%d_%H%M%S).bak"

sqlcmd -S "$IP,1433" -U sa -P "$SA_PASSWORD" -C \
  -Q "BACKUP DATABASE IsLabDb TO DISK = N'/var/opt/mssql/backup/$NAME' WITH INIT, COMPRESSION;"

ls -1t "$BACKUP_DIR"/IsLabDb_*.bak 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r old; do
    echo "удаляю устаревшую копию: $(basename "$old")"
    rm -f "$old"
done

echo "хранится копий: $(ls -1 "$BACKUP_DIR"/IsLabDb_*.bak 2>/dev/null | wc -l) (политика: последние $KEEP)"
