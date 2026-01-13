# Mattermost - Local Docker Compose

Prerequisites:
- Docker Desktop running on Windows
- `docker compose` available (Docker Desktop includes it)

Quick start (PowerShell):

```powershell
cd C:\Users\fdjy1\Mattermost
# create persistent volume folders
New-Item -ItemType Directory -Path .\volumes\postgres -Force | Out-Null
New-Item -ItemType Directory -Path .\volumes\app\mattermost -Force | Out-Null

# start services
docker compose up -d

# view logs for the app
docker compose logs -f app
```

Open http://localhost:8065 in your browser to complete the Mattermost initial setup.

Notes:
- DB image: **postgres:17-alpine** (upgraded). If you selected a fresh upgrade, the old DB volume was removed and a new empty database was created.
- Default DB password is set in `.env` as `POSTGRES_PASSWORD`; change it before production use.
- Data is persisted under the `volumes` directory.

Upgrade options:
- Fresh (no data preserved):

```powershell
# Stop, remove old DB data, then start with Postgres 17
docker compose down
Remove-Item -Recurse -Force .\volumes\postgres
docker compose up -d
```

- Preserve data (dump & restore):

```powershell
# Dump (run on current Postgres container)
docker compose exec db pg_dump -U mmuser mattermost > mattermost_dump.sql
# Start Postgres 17 (same container name), then restore
docker compose down
# (edit docker-compose.yml to postgres:17-alpine if not already)
docker compose up -d
docker compose exec -T db psql -U mmuser -d mattermost < mattermost_dump.sql
```

Shutdown commands:

```powershell
docker compose down
```

Remove volumes as well (data lost):

```powershell
docker compose down -v
```
