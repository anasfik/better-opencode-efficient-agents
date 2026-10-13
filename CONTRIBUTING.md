# Contributing

## Invariants

1. Keep exactly eight agents: one primary (`efficient/ship`) and seven
   subagents (`research`, `quality`, `ui-mobile`, `data`, `seo`, `opencode`, and
   `release-ops`).
2. Keep `efficient/ship` as the only workspace editor in this pack.
3. Keep arbitrary shell and execute access denied except for `ship` and
   `release-ops`; both must use `ask`, never `allow`.
4. Keep all seven specialists able to load skills. Skill access must not grant
   edit, shell, execute, or external-directory access.
5. Keep `release-ops` approval-gated and document that it must never run under
   auto-approval.
6. Preserve deny-first permission ordering, approval-gated reads of `*.env` and
   `*.env.*`, and allowed reads of `*.env.example`.
7. Keep the core provider-, framework-, and MCP-neutral. Use installed skills
   for changing specialization rather than expanding static prompts.
8. Do not add model pins, dependencies, credentials, personal paths, raw
   prompts, session IDs, or private history.

The `efficient/*` namespace supplements OpenCode's built-in agents. Do not
rename, replace, or weaken built-in roles as part of a pack change.

## Validate

```sh
./scripts/check.sh
./scripts/test-install.sh
git diff --check
```

`scripts/check.sh` validates the exact roster, one-primary/seven-subagent mode
split, deny-first and environment-file rules, model inheritance, skill access,
the edit/shell/execute safety matrix, shell syntax, and private-data patterns.
`scripts/test-install.sh` validates fresh install, namespace replacement,
backups, unrelated-agent preservation, concurrent locking, and interrupt
rollback.

For agent changes, install into a disposable Git repository, run
`opencode reload`, and confirm exactly the eight expected IDs appear in
`opencode debug agents`. Also inspect the full diff for credentials, personal
paths, session identifiers, raw prompts, or other private data; automated scans
are a guardrail, not proof.

Open a focused pull request explaining the observed problem, smallest fix, and
verification evidence. Do not mix unrelated refactors into the same change.
