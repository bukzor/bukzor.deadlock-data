# bukzor.deadlock-data

Version history of Deadlock's `cached_hero_builds.kv3` (hero builds), guarding
against the game/Steam cloud clobbering it with an empty or truncated save.

## Steps

Each is standalone; run any of them by hand (`.envrc` puts `bin/` on PATH).

| step                        | does                                                  |
| --------------------------- | ----------------------------------------------------- |
| `dlbuilds-ls`               | list live save and repo copy paths, one per line      |
| `dlbuilds-stat FILE...`     | per file: size, mtime, build counts, identical copies |
| `dlbuilds-validate FILE`    | print `up=N fav=M`; non-zero if unparseable or empty  |
| `dlbuilds-game-running`     | exit 0 iff the game is running                        |
| `dlbuilds-cp SRC DST`       | copy SRC over DST, if SRC is valid and they differ    |
| `dlbuilds-capture`          | `dlbuilds-cp` live save -> repo copy                  |
| `dlbuilds-commit`           | commit the repo copy, if valid and changed            |
| `dlbuilds-push`             | pull --rebase (local wins conflicts), then push       |
| `dlbuilds-snapshot`         | capture + commit + push                               |
| `dlbuilds-restore [REF]`    | if game is stopped: `dlbuilds-cp` repo copy (or version at REF) -> live save, then touch it |

Paths live in `lib/common.sh`. `DEBUG=1` traces any step.

## Service

`etc/service/deadlock-builds` runs `dlbuilds-snapshot` every 2 minutes under runit,
logging to `~/deadlock-builds-recovery/snapshotter.log`. Install:
`sudo ln -s $PWD/etc/service/deadlock-builds /etc/service/`.
