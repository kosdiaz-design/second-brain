# Git Vault Sync Runbook

How this vault stays in sync across devices, and how to add the VPS as a reader.

## Current state (already live)

- **Vault:** `2nd Brain` (this folder is the Git repo root).
- **Plugin:** Obsidian Git, auto-committing on an interval (`vault backup: <timestamp>` commits).
- **Hub:** GitHub — `github.com/kosdiaz-design/second-brain.git` (`origin`, branch `main`).
- **Ignored:** `.obsidian/workspace.json`, `.obsidian/workspace-mobile.json`, `.obsidian/cache`, `.trash/`, `.DS_Store`.
- **Identity:** Eric Diaz / kosdiaz@gmail.com.

**Architecture:** GitHub is the hub. The Mac pushes; any other device pulls. The VPS does **not** need to reach the Mac, and iCloud is not involved.

```
  Mac (Obsidian Git) ──push──▶  GitHub (hub)  ◀──pull──  VPS clone
                                     ▲
                                     └──pull/push──  Mobile (optional)
```

---

## Add the VPS as a reader

The VPS just clones from GitHub and pulls on a schedule. Use a **read-only deploy key** so the VPS can't push and you're not putting an account-wide token on the box.

### 1. Generate a key on the VPS

```bash
ssh you@your-vps
ssh-keygen -t ed25519 -C "vps-second-brain-readonly" -f ~/.ssh/second_brain_deploy -N ""
cat ~/.ssh/second_brain_deploy.pub
```

### 2. Register it on GitHub

GitHub → the `second-brain` repo → **Settings → Deploy keys → Add deploy key** → paste the public key → leave **"Allow write access" unchecked** (read-only).

### 3. Tell SSH to use that key for this repo

Add to `~/.ssh/config` on the VPS:

```
Host github-secondbrain
  HostName github.com
  User git
  IdentityFile ~/.ssh/second_brain_deploy
  IdentitiesOnly yes
```

### 4. Clone

```bash
mkdir -p ~/vaults
git clone github-secondbrain:kosdiaz-design/second-brain.git ~/vaults/second-brain
```

### 5. Keep it current (cron)

```bash
crontab -e
# pull every 10 minutes:
*/10 * * * * cd ~/vaults/second-brain && git pull --ff-only >> ~/vaults/secondbrain-pull.log 2>&1
```

The VPS now has a live, read-only mirror for scripts, search, or static publishing — without ever touching iCloud or your Mac directly.

---

## Operating notes

- **Direction of truth:** edit on the Mac/mobile (which push); treat the VPS copy as read-only. If you ever need the VPS to contribute, switch the deploy key to write access and commit/push from there — but keep one writer-of-record to avoid conflicts.
- **Conflicts** are rare with frequent auto-backup. If one appears, resolve in the note (look for `<<<<<<<`), then commit. From a terminal: `git pull --rebase`, fix, `git add . && git rebase --continue && git push`.
- **Attachments:** Git history grows with every version of every binary. If the vault gets image/PDF-heavy, adopt Git LFS (`git lfs track "*.png" "*.pdf"`) or keep large media out of the repo.

## Stewardship / 3-2-1

GitHub + Mac + VPS clone already gives you healthy redundancy. To close the loop, add one independent backup that isn't tied to GitHub — e.g. a periodic `git bundle` or `restic` snapshot of the repo to object storage or an external drive. A second-brain you depend on deserves a copy that survives any single provider.
