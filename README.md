# Backup Scripts

* Various machines backup to a Borg Backup repo on `morgan` (RPi + USB HDD).
* `morgan` syncs the Borg repo to Backblaze B2.

## Schedules

    # casey
    10 */2 * * * bash -l -c "cd ~/backup-scripts; source .secrets; ./backup-casey-to-morgan.sh >> .log 2>&1"

    # chuck
    20 */2 * * *  bash -l -c "cd ~/backup-scripts; source .secrets; ./backup-kirito-to-morgan.sh >> .log 2>&1"

    # kirito
    20 1/2 * * *  bash -l -c "cd ~/backup-scripts; source .secrets; ./backup-chuck-to-morgan.sh >> .log 2>&1"

    # morgan
    30 */2 * * * bash -l -c "cd ~/backup-scripts; source .secrets; ./backup-archive-to-morgan.sh >> .log 2>&1"
    40 3 * * * bash -l -c "cd ~/backup-scripts; source .secrets; ./prune-morgan-backups.sh >> .log 2>&1"
    50 4 * * * bash -l -c "cd ~/backup-scripts; source .secrets; ./sync-morgan-to-b2.sh >> .log 2>&1"
    00 9 * * * bash -l -c "cd ~/backup-scripts; source .secrets; initnode; node ./send-backup-report.js >> .log 2>&1"
