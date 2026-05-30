#!/usr/bin/env bash
set -uo pipefail
VAULT="/opt/second-brain"; BUNDLES="/opt/backups/second-brain"
SYNC_LOG="/var/log/second-brain-sync.log"; REMOTE="gdrive:second-brain-backups"
NOTE="$VAULT/Resources/Backup-Health.md"; CONF="/root/.config/rclone/rclone.conf"
NOW=$(date -u +%s); problems=()

last_sync=$(grep "sync ok" "$SYNC_LOG" 2>/dev/null | tail -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z')
if [ -n "$last_sync" ]; then
  age=$(( (NOW - $(date -u -d "$last_sync" +%s)) / 60 ))
  if [ "$age" -le 60 ]; then sync_status="OK (${age}m ago)"; else sync_status="STALE (${age}m ago)"; problems+=("sync ${age}m stale"); fi
else sync_status="NO LOG"; problems+=("no sync log"); fi

newest=$(ls -1t "$BUNDLES"/*.bundle 2>/dev/null | head -1); bcount=$(ls -1 "$BUNDLES"/*.bundle 2>/dev/null | wc -l)
if [ -n "$newest" ]; then
  bage=$(( (NOW - $(stat -c %Y "$newest")) / 3600 ))
  if [ "$bage" -le 26 ]; then backup_status="OK (${bage}h old, ${bcount} kept)"; else backup_status="STALE (${bage}h old)"; problems+=("backup ${bage}h old"); fi
else backup_status="NONE"; problems+=("no bundles"); fi

rcount=$(rclone --config "$CONF" lsf "$REMOTE" 2>/dev/null | grep -c '\.bundle$'); rcount=${rcount:-0}
if [ "$rcount" -gt 0 ]; then
  if [ "$rcount" -ge "${bcount:-0}" ]; then offsite_status="OK (${rcount} in Drive)"; else offsite_status="BEHIND (${rcount} vs ${bcount})"; problems+=("offsite behind"); fi
else offsite_status="UNREACHABLE"; problems+=("offsite unreachable"); fi

if [ "${#problems[@]}" -eq 0 ]; then summary="ALL HEALTHY"; else summary="ISSUES: ${problems[*]}"; fi
cat > "$NOTE" <<EOF
# Backup Health

_Last checked: $(date -u +"%Y-%m-%d %H:%M UTC")_

**Status:** $summary

| Component | State |
|---|---|
| Git sync (5-min) | $sync_status |
| Local bundles | $backup_status |
| Offsite (Drive) | $offsite_status |
EOF

if [ "${#problems[@]}" -gt 0 ]; then
  ENVF="/opt/hermes/.hermes/profiles/iron_coach/.env"
  TOK=$(grep -E '^TELEGRAM_BOT_TOKEN=' "$ENVF" 2>/dev/null | cut -d= -f2- | tr -d "\"' ")
  CHAT=$(grep -E '^TELEGRAM_HOME_CHANNEL=' "$ENVF" 2>/dev/null | cut -d= -f2- | tr -d "\"' ")
  if [ -n "$TOK" ] && [ -n "$CHAT" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TOK}/sendMessage" --data-urlencode "chat_id=${CHAT}" --data-urlencode "text=Vault backup health: ${problems[*]}" >/dev/null
  fi
fi
echo "healthcheck: $summary"
