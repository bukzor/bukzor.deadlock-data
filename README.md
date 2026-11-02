# bukzor.deadlock-data

Version history of Deadlock's `cached_hero_builds.kv3` (hero builds), guarding
against the game/Steam cloud clobbering it with an empty or truncated save.

## Steps

Each is standalone; run any of them by hand (`.envrc` puts `bin/` and `.venv/bin/`
on PATH; `uv sync` installs `dlbuilds-validate` there).

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
| `dlbuilds-restore [FILE]`   | if game is stopped: `dlbuilds-cp` FILE (default: repo copy) -> live save, then touch it |
| `dlbuilds-restore-ref REF`  | `dlbuilds-restore` the version at git REF             |

Paths live in `lib/common.sh`; `DLBUILDS_LIVE=FILE` stands in for the live save (e.g. to try a step safely). `DEBUG=1` traces any step.

## Service

`etc/service/deadlock-builds` runs `dlbuilds-snapshot` every 2 minutes under runit,
logging to `~/deadlock-builds-recovery/snapshotter.log`. It runs from its own
clone, so its commits and rebases never race work in a checkout you use; deploy
changes by pushing (each pass pulls). Install:

    git clone git@github.com:bukzor/bukzor.deadlock-data ~/.local/share/bukzor.deadlock-data
    sudo ln -sfn ~/.local/share/bukzor.deadlock-data/etc/service/deadlock-builds /etc/service/deadlock-builds
