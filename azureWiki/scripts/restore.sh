#!/usr/bin/env sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 path/to/backup.sql.gz" >&2
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f ./.env ]; then
  echo "Missing .env in project root" >&2
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1091
. ./.env

echo "Restoring database from: $BACKUP_FILE"

gzip -dc "$BACKUP_FILE" \
  | docker compose exec -T db sh -c "psql -U '$POSTGRES_USER' -d '$POSTGRES_DB'" 

echo "Done."