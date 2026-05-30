# Git Vault Sync Runbook

How this vault stays synchronized across the Mac and the VPS, how the automated sync works, and how to recover it.

## Architecture (current, live)

GitHub is the hub. Two writers push and pull through it.

```
  Mac (Obsidian Git)  ──push/pull──▶  GitHub  ◀──pull/push──  VPS /opt/second-brain
   auto-backup commits        kosdiaz-design/second-brain        cron sync every 5 min
                                                                 (hermes / openclaw write here)
```

- **Hub:** `git@github.com:kosdiaz-design/second-brain.git`, branch `main` (SSH, read-write).
- **Mac:** vault at `…/2nd Brain`. Obsidian Git plugin auto-commits + pushes on an interval.
- **VPS:** `srv1695768` (187.77.206.171), vault cloned at `/opt/second-brain`. hermes/openclaw write notes here; a cron job commits, rebases onto GitHub, and pushes.
- **Both sides are writers.** GitHub `main` is the single source of truth they converge on.

---

## VPS sync job

**Script:** `/opt/second-brain-sync.sh` — commit local changes → rebase onto `origin/main` → push.
**Schedule:** cron, every 5 minutes: `*/5 * * * * /opt/second-brain-sync.sh`
**Log:** `/var/log/second-brain-sync.log`
**Identity:** commits authored as `hermes-vps <hermes@srv1695768.local>`.

Logic:
1. `flock` guard prevents overlapping runs.
2. If the working tree is dirty (hermes/openclaw wrote notes), stage all and commit `vps autosync: <timestamp>`.
3. `git fetch` + `git rebase origin/main` — replays local commits on top of the Mac's, keeping history linear.
4. `git push origin main`.

**Conflict policy:** a true conflict (both sides edited the *same* note region between syncs) makes the rebase abort. The script logs `rebase conflict — aborting, manual review needed` and **stops pushing**. Local hermes commits stay intact in `/opt/second-brain`; nothing is overwritten. Resolve manually:

```bash
cd /opt/second-brain
git status                       # see conflicted files
git rebase origin/main           # re-enter; fix <<<<<<< markers in each file
git add -A && git rebase --continue
git push origin main
```

Conflicts are rare because the Mac and hermes typically touch different notes.

---

## VPS backup job (immutable snapshots)

GitHub plus two live clones gives redundancy, but every live copy can receive a bad push (e.g. an accidental mass delete propagating everywhere). Defense: nightly **immutable** Git bundles that a bad push cannot alter.

**Script:** `/opt/second-brain-backup.sh` — full-history `git bundle`, verified, rotated.
**Schedule:** cron, nightly 04:30 UTC: `30 4 * * * /opt/second-brain-backup.sh`
**Store:** `/opt/backups/second-brain/second-brain-<timestamp>.bundle` (keeps newest 14).
**Log:** `/var/log/second-brain-backup.log`

**Restore from a bundle:**

```bash
git clone /opt/backups/second-brain/second-brain-YYYYMMDD-HHMMSS.bundle restored-vault
```

**Optional offsite upgrade (true 3-2-1):** mirror `/opt/backups/second-brain/` off the box with `rclone` to object storage (Backblaze B2 / S3), or switch to `restic` with a remote repository. This protects against losing the VPS itself.

---

## Health checks

```bash
# VPS: is sync current and healthy?
cd /opt/second-brain && git fetch && git status -sb && tail -n 15 /var/log/second-brain-sync.log

# VPS: are cron jobs installed?
crontab -l | grep second-brain

# VPS: latest backups present?
ls -1t /opt/backups/second-brain/ | head
```

A `git push` that reports "Everything up-to-date" or succeeds with `exit=0` means auth and sync are healthy. If a push ever fails with an SSH/permission error under cron, root's GitHub key needs a passphrase cron can't supply — replace it with a dedicated passphraseless deploy key.

---

## Stewardship / 3-2-1 scorecard

| Copy | Location | Type |
|---|---|---|
| Mac vault | local disk | live working copy |
| GitHub | cloud hub | live remote |
| VPS `/opt/second-brain` | VPS disk | live working copy |
| VPS bundles | `/opt/backups` | immutable snapshots (14 days) |

Three live copies plus immutable history. The one remaining hardening step is moving the bundles **off** the VPS so no single machine or provider is a single point of failure. A second-brain you depend on deserves that last copy — build it once, and years of work stay protected.
