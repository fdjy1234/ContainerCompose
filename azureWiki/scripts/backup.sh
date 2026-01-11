#!/usr/bin/env sh
set -eu

if [ ! -f ./.env ]; then
  echo "Missing .env in project root" >&2
  exit 1
fi

# shellcheck disable=SC1091
. ./.env

TS=$(date -u +"%Y%m%dT%H%M%SZ")
OUT_DIR="./backups"
OUT_FILE="$OUT_DIR/wikijs-$TS.sql.gz"

mkdir -p "$OUT_DIR"

echo "Backing up database to: $OUT_FILE"

docker compose exec -T db sh -c "pg_dump -U '$POSTGRES_USER' '$POSTGRES_DB'" \
  | gzip -9 > "$OUT_FILE"

echo "Done."