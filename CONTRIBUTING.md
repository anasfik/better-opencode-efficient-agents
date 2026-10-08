# Contributing

## Before opening a change

1. Keep the core pack provider-, framework-, and MCP-neutral.
2. Preserve exactly one workspace mutator: `efficient/ship`.
3. Do not add model pins, credentials, personal paths, raw prompts, session IDs,
   or private history.
4. Keep `.env` reads approval-gated and remote mutations explicit.

## Validate

```sh
./scripts/check.sh
./scripts/test-install.sh
git diff --check
```

For agent changes, install into a disposable Git repository and confirm all ten
IDs appear in `opencode debug agents` after `opencode reload`.

Open a focused pull request explaining the observed problem, smallest fix, and
verification evidence. Do not mix unrelated refactors into the same change.
