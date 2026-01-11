# Azure deployment (VM + Docker Compose)

This is the lowest-cost, simplest way to host a personal Wiki.js.

## Steps

1) Create a Linux VM (Ubuntu) with cloud-init to install Docker.

2) Upload this project to the VM at `/opt/wikijs`.

3) On the VM:
- Copy `.env.example` to `.env`
- Set `DOMAIN`, `ADMIN_EMAIL`, and strong `POSTGRES_PASSWORD`
- Run `docker compose --profile proxy up -d`

## Notes
- Open inbound ports 80/443 in NSG.
- Use SSH keys (recommended).
- Backups: run `scripts/backup.sh` and copy `backups/` off the VM.
