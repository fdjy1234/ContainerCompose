# wiki.js (personal knowledge notebook)

This workspace runs **Wiki.js v2** with **PostgreSQL** using Docker Compose.

IMPORTANT: This repository is prepared for an AIR-GAP (offline) deployment and includes Traditional Chinese (繁體中文) localization.

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

## 2) AIR GAP (offline) deployment

This workspace can be deployed into an environment without direct internet access. Basic steps:

1. On an internet-connected machine, pull required images:

```bash
docker compose pull
```

2. Save images to a tar archive and transfer to the air-gapped host (USB / secure transfer):

```bash
docker image ls --format "{{.Repository}}:{{.Tag}}" | xargs -n1 docker save -o images.tar
```

3. On the target (air-gapped) host, load the images:

```bash
docker load -i images.tar
```

4. Start the stack on the air-gapped host:

```bash
docker compose up -d
```

Notes:
- Ensure image names/tags used in `docker-compose.yml` match the saved images.
- Alternatively run a local registry in the air-gapped network and push images there before starting the stack.

## 3) Backup / restore (PostgreSQL)

Scripts are in `scripts/`.

- Backup:
  ```bash
  ./scripts/backup.sh
  ```

- Restore (WARNING: overwrites DB):
  ```bash
  ./scripts/restore.sh path/to/backup.sql.gz
  ```

## 4) Localization (繁體中文)

This workspace includes Traditional Chinese translations under `wiki/data/sideload/`:

- `wiki/data/sideload/zh-tw.json` — 繁體中文語系檔
- `wiki/data/sideload/en.json`, `wiki/data/sideload/locales.json`

How to enable / import:

- You can import the `zh-tw.json` via the Wiki.js Admin UI (Internationalization / Languages) or place the file into the `wiki/data/sideload/` path before first start so it is available for initial import.
- After placing/importing the file, restart the Wiki.js container if needed.

## 5) Azure deployment (lowest-cost approach)

Recommended for a personal notebook: **Azure Linux VM + Docker Compose**.

- Pros: cheapest, simple, everything in one VM.
- Cons: you manage OS updates/backups.

See `azure/`.
