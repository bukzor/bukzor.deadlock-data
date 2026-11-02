# bukzor.deadlock-data

Version history of Deadlock's `cached_hero_builds.kv3` (hero builds), guarding
against the game/Steam cloud clobbering it with an empty or truncated save.

## Steps

Each is standalone; run any of them by hand (`.envrc` puts `bin/` on PATH).

| step                     | does                                                     |
| ------------------------ | -------------------------------------------------------- |
| `validate FILE`          | print `up=N fav=M`; non-zero if unparseable or empty     |
| `is-deadlock-running`    | exit 0 iff the game is running                           |
| `capture`                | live save -> repo copy, if valid and changed             |
| `commit`                 | commit the repo copy, if valid and changed               |
| `snapshot`               | `capture` + `commit` + push when ahead of upstream       |
| `restore [REF]`          | repo copy (or version at REF) -> live save, if valid and game is stopped |

Paths live in `lib/common.sh`. `DEBUG=1` traces any step.

## Service

`etc/service/deadlock-builds` runs `snapshot` every 2 minutes under runit,
logging to `~/deadlock-builds-recovery/snapshotter.log`. Install:
`sudo ln -s $PWD/etc/service/deadlock-builds /etc/service/`.
