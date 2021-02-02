# Backup Scripts

> See also: [Building Your Own Linux Cloud Backup System](https://medium.com/@mormesher/building-your-own-linux-cloud-backup-system-75750f47d550).

- Various machines backup to a Borg Backup repo on `tatsu` (tiny home server).
- `tatsu` syncs the Borg repo to Backblaze B2.

## Schedules

- More-than-daily jobs happen at 10-minute offsets on even-numbered hours.
- Daily jobs happen at the start of odd-numbered hours.

```
# casey
10 */2 * * * bash -l -c "~/backup-scripts/backup-casey-to-borg.sh >> .log 2>&1"

# chuck
20 */2 * * *  bash -l -c "~/backup-scripts/backup-chuck-to-borg.sh >> .log 2>&1"

# kirito
00 1 * * *  bash -l -c "~/backup-scripts/backup-kirito-to-borg.sh >> .log 2>&1"

# tatsu
30 */2 * * * bash -l -c "~/backup-scripts/backup-archive-to-borg.sh >> .log 2>&1"
00 3 * * * bash -l -c "~/backup-scripts/prune-borg-backups.sh >> .log 2>&1"
00 5 * * * bash -l -c "~/backup-scripts/sync-borg-to-b2.sh >> .log 2>&1"
00 7 * * * bash -l -c "~/backup-scripts/send-backup-report.sh >> .log 2>&1"
```
