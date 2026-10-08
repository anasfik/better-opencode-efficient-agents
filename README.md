# Better OpenCode Efficient Agents

[![CI](https://github.com/anasfik/better-opencode-efficient-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/anasfik/better-opencode-efficient-agents/actions/workflows/ci.yml)

**Dev-friendly pack:** 10 namespaced OpenCode V2 agents — one workspace mutator (`efficient/ship`), 8 read-only audit/subagent roles, plus an evidence-backed planning primary (`efficient/architect`). Zero model pins (inherit your session), zero framework dependencies, zero vendor lock-in. Tested against OpenCode v2.0.25.

Quick links: [Install](#install) · [Validate](#validate) · [Agents](#agents) · [Usage analysis](docs/usage-analysis.md)

---

## At a glance

| What | How |
|---|---|
| **Copy agents into OpenCode** | Run the quoted prompt below, or `./scripts/install.sh --global` / `--project` |
| **Make them active** | `opencode reload` then `opencode debug agents` — all 10 `efficient/*` IDs should list |
| **Try them** | `opencode run --agent efficient/architect "Inspect this repo and produce a read-only plan."` |
| **Check before use** | `./scripts/check.sh` + `./scripts/test-install.sh` |

---

## Why this exists

This isn't a framework or starter — it's a discipline. The pack came from a read-only analysis of **846 OpenCode sessions** (270 root, 576 child): 42.7% of tool errors came from missing targets or stale edit context; 54 of 150 verification-requesting sessions showed no evidenced check; 40 finished with no root-level conclusion. The design is the smallest response: **discover paths first, edit narrowly, re-read after child work, verify explicitly, and finish with evidence not just tool output**.

See [`docs/usage-analysis.md`](docs/usage-analysis.md) for aggregate statistics and the mapping from observed failures to agent roles.

---

## Agents

```
efficient/ship         primary   sole workspace mutator; integrates and reports
efficient/architect     primary   read-only plans, risks, reversible slices
efficient/explorer     subagent  path discovery + caller tracing + root-cause evidence
efficient/docs-scout    subagent  installed-version docs + official sources
efficient/verify       subagent  tests / logs / health evidence
efficient/code-review  subagent  correctness, regression, safety, data loss
efficient/ui-review    subagent  rendered UI / a11y / responsive / RTL / web meta
efficient/data-audit   subagent  schema / migration / transaction / backup review
efficient/release      subagent  build / sign / deploy / rollback (approval required)
efficient/product-owner subagent  scope / acceptance / QA / stakeholder update
```

Every agent uses `deny` first, then allows only what's required. Only `ship` gets `edit`. All others deny writes by default; `shell` and `external_directory` ask, not allow.

---

## Install to your OpenCode config (copy / configure)

Copy this repo's `agents/efficient/` folder into your OpenCode agents folder so the 10 IDs become available globally.

> **OpenCode prompt — copy/paste into your session:**
>
> ```
> "Install agents of this repo to opencode config folder and set agents on it."
> ```
>
> That instructs the agent to copy `agents/efficient/` into `~/.config/opencode/agents/efficient/` (creating `efficient/*` agent IDs in your config folder) and configure that folder so OpenCode discovers them — equivalent to `mkdir -p ~/.config/opencode/agents/efficient/` and copying the `.md` files into it, then running `opencode reload`.

Or use the install script from this repo (project-local or global):

```sh
git clone https://github.com/anasfik/better-opencode-efficient-agents.git
cd better-opencode-efficient-agents
# Project-local (recommended for teams):
./scripts/install.sh --project /path/to/project
# Global (every project gets the same agents):
./scripts/install.sh --global
```

Upgrade: rerun the same command; it copies to a timestamped backup, swaps atomically with a lock, and restores if interrupted.

After either method: `opencode reload` then `opencode debug agents` — confirm all 10 `efficient/*` IDs appear.

---

## Validate

```sh
./scripts/check.sh        # checks 10 agents, 2 primary / 8 subagent, deny-first, .env prompts, no model pins, privacy scan
./scripts/test-install.sh # fresh install, upgrade, unrelated preservation, concurrent lock, interrupt rollback
opencode reload
opencode debug agents
opencode run --agent efficient/architect \
  "Inspect this repo and produce a read-only implementation plan."
```

---

## Safety model

- Only `efficient/ship` has `edit`; every agent keeps `deny-all` first.
- Every agent keeps OpenCode's built-in `*.env` / `*.env.*` prompts; `*.env.example` is allowed.
- Shell / external-directory: `ask`; release/deploy/promote: confirmation required immediately before use.
- Read-only roles deny changes by default. No agent asserts "only edit tool matters" — the permission matrix is the guard.
- Parent owns synthesis, checks, and final conclusion. Child success is not parent completion.
- Nothing in this repo: credentials, session IDs, personal paths, raw prompts, model pins.

---

## Compatibility

OpenCode V2 has no agent package registry. This repo uses the documented namespaced Markdown convention (`.opencode/agents/<ns>/*.md` → agent IDs `<ns>/<name>`). Works with any V2-compatible CLI (`opencode v2.0.25` tested).

---

## What's not in the core pack (optional extensions, not needed for daily delivery)

- Flutter / Cloudflare / App-Store / store-release workflows → add `flutter-audit`/`flutter-ship`, `cf-deploy`, `release-ops` only when that stack is active.
- Vendor-specific APIs (Reqistry, Quickmail, AdGuard, Lovable, Nostr) → use the relevant MCP / integration, not a default agent.
- Session history mining → keep private; do not include session DB access in a public pack.

---

## License

MIT. Security reports: Follow [`SECURITY.md`](SECURITY.md). Contributions: [`CONTRIBUTING.md`](CONTRIBUTING.md).
