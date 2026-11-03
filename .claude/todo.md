---
managed-by: Skill(llm-subtask)
---

- [ ] `dlbuilds-snapshot`: a capture refusal (invalid live save, or `/mnt/c`
      unmounted) ends the pass, skipping commit+push -- so a previously failed
      push stays stuck exactly while the live save is bad. Likely fix:
      `dlbuilds-capture || : "refusal must not block push: $?"`.
- [ ] shellcheck `bin/*` and `etc/service/*/run` (not installed on this host).
- [ ] `sudo rm -r trash/supervise` -- root-owned runit state left from when the
      service ran in this checkout (it now runs from
      `~/.local/share/bukzor.deadlock-data`; see README).
