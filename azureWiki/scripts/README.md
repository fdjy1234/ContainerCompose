# Scripts

- `backup.sh`: dumps PostgreSQL from the `db` service into `./backups/*.sql.gz`
- `restore.sh`: restores a `*.sql.gz` into the running `db` service (overwrites existing DB contents)
