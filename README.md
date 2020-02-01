# Backup Scripts

* Various machines backup to a Borg Backup repo on `morgan` (RPi + USB HDD).
* `morgan` syncs the Borg repo to Backblaze B2.

## Schedules

    # casey - try every 2 hours (machine is off most of the time)
    0 */2 * * * bash -l -c "cd ~/backup-scripts; ./backup-casey-to-morgan.sh >> .log 2>&1"

    # chuck - run overnight
    0 2 * * *  bash -l -c "cd ~/backup-scripts; ./backup-chuck-to-morgan.sh >> .log 2>&1"

    # morgan - run overnight
    0 4 * * * bash -l -c "cd ~/backup-scripts; ./sync-morgan-to-b2.sh >> .log 2>&1"

