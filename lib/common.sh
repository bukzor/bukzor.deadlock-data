# Sourced by bin/*: shared paths, error trap, logging.
# shellcheck shell=bash disable=SC2034  # vars are used by the sourcing script
shopt -s failglob
export DEBUG="${DEBUG:-0}"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILDS_REL=cached_hero_builds.kv3
BUILDS="$REPO/$BUILDS_REL"
LIVE="${DLBUILDS_LIVE:-/mnt/c/Program Files (x86)/Steam/userdata/37093539/1422450/remote/cfg/cached_hero_builds.kv3}"
# Steps call each other by name; `uv sync` installs dlbuilds-validate to .venv/bin.
PATH="$REPO/bin:$REPO/.venv/bin:$PATH"

log() { printf '%s %s: %s\n' "$(date -Is)" "${0##*/}" "$*" >&2; }

onerror() {
  error="$?"
  log "ERROR($error): $BASH_COMMAND"
  exit "$error"
}
trap onerror ERR

if (( DEBUG > 0 )); then
  set -x
fi
