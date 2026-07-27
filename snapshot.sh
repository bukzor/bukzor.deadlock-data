#!/bin/sh
# Snapshot the live Deadlock hero-builds file into this git repo, but ONLY when
# it parses as valid KV3 with >0 builds. A crash-truncated/empty file fails the
# gate and is skipped -- so corruption can never overwrite known-good history.
#
# Run once (default) or via the runit service in /etc/service/deadlock-builds.
set -eu

LIVE="/mnt/c/Program Files (x86)/Steam/userdata/37093539/1422450/remote/cfg/cached_hero_builds.kv3"
REPO="/home/bukzor/repo/github.com/bukzor/bukzor.deadlock-data"
DEST="$REPO/cached_hero_builds.kv3"
PY="/home/bukzor/claude/deadlock/.venv/bin/python"

log() { printf '%s %s\n' "$(date -Is)" "$*"; }

[ -f "$LIVE" ] || { log "SKIP: live file missing"; exit 0; }

# Validate + count. Non-zero exit => invalid/truncated => do not touch history.
counts=$("$PY" "$REPO/validate.py" "$LIVE") || { log "SKIP (gate failed): $counts"; exit 0; }

# Unchanged? stay quiet, no empty commits.
if [ -f "$DEST" ] && cmp -s "$LIVE" "$DEST"; then
    exit 0
fi

cp "$LIVE" "$DEST"
git -C "$REPO" add cached_hero_builds.kv3
# Belt-and-suspenders: if the staged bytes match HEAD anyway, don't error out.
git -C "$REPO" diff --cached --quiet cached_hero_builds.kv3 && exit 0
git -C "$REPO" commit -q -m "builds snapshot $(date -Is) ($counts)

Auto-captured by the runit snapshotter (validate-gated).

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
log "COMMITTED: $counts"

if GIT_SSH_COMMAND="ssh -o BatchMode=yes" git -C "$REPO" push -q origin main 2>/dev/null; then
    log "pushed"
else
    log "push failed (safe: committed locally)"
fi
