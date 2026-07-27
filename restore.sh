#!/bin/sh
# Restore the git-controlled builds file over the live Deadlock save.
#
# Safe by construction:
#   - refuses to run while Steam is up (its cloud would re-clobber, and the
#     file is usually locked) -- override with FORCE=1 if you know better;
#   - validates the source first, so a corrupt repo file is never restored;
#   - stamps mtime to now, so Steam treats local as newest and uploads it.
#
# To restore an OLDER version: `git -C <repo> checkout <ref> -- cached_hero_builds.kv3`
# first, run this, then `git checkout HEAD -- cached_hero_builds.kv3` to reset.
set -eu

REPO="/home/bukzor/repo/github.com/bukzor/bukzor.deadlock-data"
SRC="$REPO/cached_hero_builds.kv3"
LIVE="/mnt/c/Program Files (x86)/Steam/userdata/37093539/1422450/remote/cfg/cached_hero_builds.kv3"
PY="/home/bukzor/claude/deadlock/.venv/bin/python"
TASKLIST="/mnt/c/Windows/System32/tasklist.exe"

die() { echo "restore: $*" >&2; exit 1; }

if [ "${FORCE:-0}" != "1" ] && "$TASKLIST" 2>/dev/null | grep -qi steam; then
    die "Steam is running. Exit it fully (tray icon -> Exit), then re-run. (FORCE=1 overrides.)"
fi

counts=$("$PY" "$REPO/validate.py" "$SRC") || die "source failed validation ($counts) -- refusing"

cp "$SRC" "$LIVE"
touch "$LIVE"
echo "restore: OK ($counts) -> live file. Now start Steam (no Deadlock yet) so it uploads the good copy."
