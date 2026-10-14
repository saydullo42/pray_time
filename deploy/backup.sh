#!/bin/sh
# Dumps the database to ./data/backups and keeps the last 14 days.
# Run from the project folder, e.g. daily from cron:
#   0 3 * * * cd /opt/praytime && ./deploy/backup.sh >> data/backups/backup.log 2>&1
set -e
cd "$(dirname "$0")/.."
mkdir -p data/backups
file="data/backups/db-$(date +%F-%H%M).sql.gz"
docker compose exec -T db pg_dump -U praytime praytime | gzip > "$file"
echo "$(date -Is) wrote $file ($(du -h "$file" | cut -f1))"
find data/backups -name 'db-*.sql.gz' -mtime +14 -delete
