---
title: Second Brain — Build Protocol
owner: Eric Diaz
type: resource
status: in-progress
updated: 2026-05-29
---

# Second Brain — Build Protocol
**Owner:** Eric Diaz
**Architecture:** Obsidian + Git backbone + VPS-hosted remote MCP (Claude read/write)
**Operating principle:** *"The plans of the diligent lead surely to abundance" (Prov. 21:5).* A second brain is stewardship of the mind — one clean ledger, faithfully tended.

---

## 0. The model in one picture
A vault is just a folder of `.md` files. That means the system is three independent layers:

```
   CAPTURE/EDIT          SYNC               AI ACCESS
   Obsidian (Mac)  ─┐                  ┌─ Claude Desktop (Mac, local)
   Obsidian (iPhone)─┼── Git repo ──────┼─ Claude mobile  (via VPS connector)
                     │   (one truth)    └─ Other models  (via VPS connector)
   Claude (writes) ─┘
```
Git is the single source of truth. Every device and the AI server all point at it.

> **Related:** [[Build-Session-2026-05-30|Build Session Log — 2026-05-30]] — verified config + runbook for what was actually deployed. · [[Hermes-Vault-Integration]] — VPS agent wiring.

---

## 1. Two-vault security model (do this first)
Read/write access on a public server is convenient and risky. Split confidential material out.

| Vault | Contents | Sync | AI access |
|---|---|---|---|
| **Brain** (general) | Ministry, ISF, dev notes, learning, leadership, journaling, reading, ideas | Git + VPS | Claude read/write everywhere (Mac + phone) |
| **Secure** (confidential) | Health/PHI (CAD records, labs), TPAPD-sensitive material, anything private | Mac-only (or private Git, NOT on VPS) | Claude **local only**, via Mac filesystem connector |

Rule: nothing confidential ever lands on the public VPS server. The phone + multi-model convenience applies to **Brain** only.

---

## 2. Folder structure (PARA + capture lanes)
Use inside the **Brain** vault:

```
/00-Map.md          ← home note / map of content (your dashboard)
/Inbox/             ← raw capture; phone dumps land here
/Claude-Drafts/     ← everything Claude writes lands here for your review
/Daily/             ← daily notes (YYYY-MM-DD)
/Projects/          ← active, time-bound (ISF features, TPAPD apps, KK2)
/Areas/             ← ongoing domains (Ministry, Leadership, Fitness, Marriage, Finances)
/Resources/         ← reference (Scripture, Study, Dev-Reference, Leadership-Library)
/Archive/           ← completed / inactive
/Templates/         ← note templates
```

**Write protocol (the conflict fix):** Claude only writes to `/Inbox` or `/Claude-Drafts`. *You* file into Projects/Areas during a daily review. This keeps an audit trail and prevents two writers fighting over the same file.

---

## PHASE 1 — Vault + Git backbone (Mac, today)
1. **Open your folder as a vault:** Obsidian → *Open folder as vault* → point at your existing Mac folder.
2. **Initialize Git** (Terminal, inside the vault):
   ```bash
   cd /path/to/your/vault
   git init
   ```
3. **Add `.gitignore`** (keep config so settings sync; drop machine-specific noise):
   ```
   .obsidian/workspace.json
   .obsidian/workspace-mobile.json
   .obsidian/cache
   .trash/
   .DS_Store
   ```
4. **Create the private repo** on GitHub (`kosdiaz-design/second-brain`), then:
   ```bash
   git remote add origin git@github.com:kosdiaz-design/second-brain.git
   git add -A && git commit -m "Initial vault" && git push -u origin main
   ```
5. **Install Obsidian Git plugin:** Settings → Community plugins → Browse → *Obsidian Git*. Configure:
   - Auto-commit every **10 min**
   - **Auto-push** on commit
   - **Auto-pull** on startup

✅ *Checkpoint:* edit a note on Mac, confirm it appears in GitHub.

---

## PHASE 2 — Mac AI access (free, local) + phone

### Mac (Claude Desktop, both vaults)
1. Open Claude Desktop → Settings → Connectors → enable the **Filesystem** connector.
2. Point it at the **Brain** vault folder. Add a **second** filesystem path for the **Secure** vault.
3. macOS may require **Full Disk Access** for Claude Desktop (System Settings → Privacy & Security).

Now Claude on Mac can read/write both vaults locally — Secure included, since it never leaves the machine.

### iPhone (Brain only)
1. Install **Obsidian** (iOS).
2. Clone the Brain repo onto the phone. Cleanest path: install **Working Copy**, clone the repo, then open it as a vault in Obsidian — or use the Obsidian Git plugin's clone command.
3. Set Obsidian Git on iOS to **pull on startup** and push via the ribbon/command.

> ⚠️ **Honest caveat:** iOS limits true background sync, so phone Git is "sync on open/close," not silent and continuous. This is fine — the phone's *AI* path doesn't depend on the phone's Git at all (see Phase 3). Phone Git only matters when you edit directly inside Obsidian mobile.

---

## PHASE 3 — VPS remote MCP server (the phone + multi-model unlock)
This is what lets Claude on your phone (and other models) reach the Brain. Custom connectors connect **from Anthropic's cloud**, so the server must be publicly reachable over HTTPS.

### 3a. Clone + keep fresh on hermes
```bash
ssh you@hermes.isf2717.com
git clone git@github.com:kosdiaz-design/second-brain.git /opt/second-brain
```
Cron — pull every 2 min, and push any AI writes back:
```bash
*/2 * * * * cd /opt/second-brain && git pull --rebase --autostash >/dev/null 2>&1
*/3 * * * * cd /opt/second-brain && git add -A && git diff --cached --quiet || (git commit -m "claude sync" && git push) >/dev/null 2>&1
```

### 3b. Run an Obsidian MCP server (Docker)
A community server built for read/write CRUD across notes (overwrite/append/prepend, batch read, search):
```bash
docker run -d --name obsidian-mcp \
  -v /opt/second-brain:/vault:rw \
  -p 3001:3000 \
  -e VAULT_PATH=/vault \
  ghcr.io/smith-and-web/obsidian-mcp-server:latest
```
*(Given your stack, you can also fork/self-build this for tighter control of the write lanes — restrict writes to `/Inbox` and `/Claude-Drafts`.)*

### 3c. Expose securely
- Reverse proxy with TLS (you already run Cloudflare DNS).
- **Add authentication** — this is read/write to your brain on the open internet. Use OAuth or a bearer-token gateway as the connector flow requires.
- **Allowlist Anthropic's published IP ranges** at your firewall/Cloudflare so only Anthropic's infrastructure can reach the endpoint. Do **not** put it behind Zero Trust/Access that would block the cloud connection.

### 3d. Connect in Claude
Claude (mobile **and** desktop) → Settings → Connectors → **Add custom connector** → paste your HTTPS URL → authenticate.

✅ *Checkpoint:* from your phone, ask Claude to "add a note to my Inbox." Confirm it appears in GitHub and on your Mac.

---

## Daily / weekly rhythm (the discipline layer)
- **Daily (2 min):** Clear `/Inbox` and `/Claude-Drafts` — file each item into Projects/Areas or delete.
- **Weekly (15 min):** Review active Projects; archive what's done; update `/00-Map.md`.
- **Capture anywhere:** phone → Inbox. Don't organize at capture time; organize at review time.

*Iron sharpens iron (Prov. 27:17) — a brain that's reviewed, not just filled, is the one that sharpens you.*

---

## Phased shipping order
1. **Today:** Phase 1 + Mac filesystem connector (Phase 2 Mac). You have a working AI second brain on the Mac in under an hour.
2. **This week:** Phone Obsidian + Git (Phase 2 iPhone).
3. **When ready:** VPS remote MCP (Phase 3) → phone + multi-model goes live.

Don't skip the order. Validate capture→retrieve on the Mac before building server infrastructure.

---

## Quick reference — what to keep where
| Material | Vault | Why |
|---|---|---|
| ISF / ministry / study notes | Brain | Safe, useful on phone |
| Dev notes, app architecture | Brain | Safe |
| Journaling, reading, ideas | Brain | Safe |
| Health / PHI / labs | **Secure** | Never on public server |
| TPAPD-sensitive material | **Secure** | Operational security |
| Passwords / keys / PII | Neither — use a password manager | Not a notes problem |
