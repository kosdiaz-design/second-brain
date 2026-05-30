---
title: Second Brain System
type: project
status: active
started: 2026-05-29
target:
area: "[[Areas/Leadership/Leadership]]"
---

# Second Brain System

## Outcome
A working AI second brain: Obsidian + Git backbone, Mac local AI access, phone capture, and a secured remote MCP — with a confidential Secure vault that never leaves the Mac.

## Why it matters
Stewardship of the mind — one clean ledger, faithfully tended (Prov. 21:5). Capture anywhere, retrieve anywhere, without leaking what's confidential.

## Next actions
- [x] Clear stale `.git/HEAD.lock`, commit daily note (Mac terminal)
- [x] Create private GitHub repo `kosdiaz-design/second-brain` and push
- [ ] Install + configure Obsidian Git plugin (auto-commit 10m / push / pull)
- [ ] Enable Mac Claude Desktop Filesystem connector → Brain + Secure
- [ ] Open Secure folder as a separate vault in Obsidian
- [ ] Phone: install Obsidian, clone Brain repo (Working Copy)
- [ ] VPS: clone to /opt/second-brain, cron sync, Dockerized MCP, TLS + auth + IP allowlist

## Reference
- [[Resources/Second-Brain-Build-Protocol]]

## Log
- 2026-05-29 — Phase 1 built: PARA structure, map, templates, Git init, protocol saved. Secure vault scaffolded. Areas seeded.
- 2026-05-30 — Vault cleanup pass: removed stock Welcome.md + Hermes test artifact, repaired broken Area→Resource links, promoted v2 daily template, added 2026-05-30 daily note. Committed + pushed to GitHub (4f66de7) — Git backbone verified end to end (vault → Git → GitHub).
