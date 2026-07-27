#!/usr/bin/env python
"""Validate a Deadlock cached_hero_builds.kv3 file.

Prints "up=N fav=M" and exits 0 when the file parses as KV3 and holds at least
one Unpublished or Favorite build. Otherwise prints why and exits non-zero.

This is the gate that stops a crash-truncated/empty file from being snapshotted
over known-good history.
"""

import sys
from typing import Any, cast

import keyvalues3 as kv3


def main(path: str) -> int:
    try:
        v = kv3.read(path)
    except Exception as e:
        print(f"INVALID: {e}")
        return 3
    d = cast("dict[str, Any]", v.value if hasattr(v, "value") else v)
    up = len(d.get("Unpublished") or [])
    fav = len(d.get("Favorites") or [])
    if up + fav <= 0:
        print(f"EMPTY up={up} fav={fav}")
        return 2
    print(f"up={up} fav={fav}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
