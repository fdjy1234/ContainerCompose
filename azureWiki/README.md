# wiki.js (personal knowledge notebook)

This workspace runs **Wiki.js v2** with **PostgreSQL** using Docker Compose.

## 1) Local run (quick)

1. Install Docker Desktop.
2. Create `.env`:
   - Copy `.env.example` to `.env`
   - Set `POSTGRES_PASSWORD` (strong)

Start:

```bash
docker compose up -d
```

Open:
- http://localhost:3000 (setup wizard)

## 1b) HTTPS reverse proxy (recommended for Azure VM)

1. Set `DOMAIN` (a real public hostname) and optionally `ADMIN_EMAIL` in `.env`.
2. Start the proxy profile:

```bash
docker compose --profile proxy up -d
```

Open:
- https://<DOMAIN>

## 2) Backup / restore (PostgreSQL)

Scripts are in `scripts/`.

- Backup:
  ```bash
  ./scripts/backup.sh
  ```

- Restore (WARNING: overwrites DB):
  ```bash
  ./scripts/restore.sh path/to/backup.sql.gz
  ```

## 3) Azure deployment (lowest-cost approach)

Recommended for a personal notebook: **Azure Linux VM + Docker Compose**.

- Pros: cheapest, simple, everything in one VM.
- Cons: you manage OS updates/backups.

See `azure/`.
