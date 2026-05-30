---
title: Hermes ↔ Vault Integration
type: reference
status: draft
updated: 2026-05-29
tags: [hermes, vault, infra, second-brain]
---

# Hermes ↔ Vault Integration

> *"The plans of the diligent lead surely to abundance."* — Proverbs 21:5
> How the Hermes agent on the VPS is wired to the Brain vault — and the guardrails that keep it in its lane.

## What's done (verified 2026-05-29)
- **Vault on the box:** Brain cloned to `/opt/second-brain` on hermes (srv1695768), via a GitHub **deploy key** scoped to this one repo (`/root/.ssh/second_brain_deploy`, SSH config maps github.com → that key).
- **Git identity:** commits attribute to `Hermes Agent <hermes@isf2717.com>`.
- **Lane backstop:** `.git/hooks/pre-commit` rejects any staged file outside `Inbox/` or `*-Drafts/`. Verified — a forbidden file was BLOCKED, a `Hermes-Drafts/` file passed and pushed.
- **Model path:** provider switched from OpenRouter→**Anthropic**, model **claude-haiku-4-5**, API-key auth. (The earlier silent `EXIT: 0` empties were the OpenRouter/anthropic-string mismatch.)
- **File access:** built-in `file` toolset is enabled; `hermes -z` read the vault and summarized `00-Map.md` correctly (22 md files).

## Sync
- VPS cron (`/root/sb-sync.sh`, every 2 min): pull --rebase --autostash, then commit+push any lane writes.
- Mac: Obsidian Git auto-commits (~10 min). Confirm pull-on-startup so Hermes' writes land in the working tree.

## Standing rules
- **Brain only — never Secure.** No PHI / TPAPD-sensitive material on this public box, ever.
- **Writes confined to `Inbox/` and `*-Drafts/`.** Hook enforces it regardless of agent behavior. Hermes uses `Hermes-Drafts/`.
- **Capture lanes, not the journal.** Hermes feeds the daily note via Inbox; Eric folds it in at review. The agent feeds the front door; it doesn't walk through it.

## OPEN — hardening before cron goes live (do not skip)
- [ ] **Run Hermes as a non-root user** that owns `/opt/second-brain` (least privilege on a public box).
- [ ] **Scope vault tooling to the vault** — filesystem MCP server locked to `/opt/second-brain` so tools can't read `~/.hermes/.env` / `auth.json`.
- [ ] **Restrict high-power tools** (`terminal`, `code_execution`, `browser`) on any profile that touches untrusted web content — prompt-injection blast radius.
- [ ] **Dedicated vault profile** (`scribe` / rebuilt `iron_coach`) with lane rules in its system prompt; leave `default` general.
- [ ] **Dedicated, capped Anthropic key** for this box — not the production ISF key. Revocable in isolation.

## Quick reference
| Thing | Value |
|---|---|
| Host | srv1695768 / hermes.isf2717.com |
| Vault path (VPS) | `/opt/second-brain` |
| Deploy key | `/root/.ssh/second_brain_deploy` |
| Write lanes | `Inbox/`, `*-Drafts/` |
| Provider / model | Anthropic / claude-haiku-4-5 |

> *Iron sharpens iron (Prov. 27:17) — guard the gates before you fill the house.*
