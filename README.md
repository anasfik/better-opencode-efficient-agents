# Better OpenCode Efficient Agents

[![CI](https://github.com/anasfik/better-opencode-efficient-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/anasfik/better-opencode-efficient-agents/actions/workflows/ci.yml)

A provider-neutral OpenCode V2 agent pack for everyday software delivery. It
turns recurring workflow failures into ten small roles with one workspace
mutator, bounded delegation, explicit verification, and approval-gated remote
actions.

Tested with OpenCode `v2.0.25`.

## Why this pack exists

An anonymized, read-only analysis of 846 OpenCode sessions found that missing
targets and stale edits caused 42.7% of tool errors, while 54 of 150 sessions
that requested verification showed no check evidence. The pack therefore makes
fresh discovery, narrow edits, root-level checks, and a final conclusion part
of the normal flow. See [`docs/usage-analysis.md`](docs/usage-analysis.md).

## Agents

| ID | Mode | Purpose |
|---|---|---|
| `efficient/ship` | primary | Sole workspace mutator and delivery integrator |
| `efficient/architect` | primary | Read-only implementation planning and risk analysis |
| `efficient/explorer` | subagent | Path discovery, caller tracing, and root-cause evidence |
| `efficient/docs-scout` | subagent | Current official documentation and version research |
| `efficient/verify` | subagent | Tests, runtime checks, logs, and health evidence |
| `efficient/code-review` | subagent | Correctness, security, regression, and data-loss review |
| `efficient/ui-review` | subagent | Conditional UI, accessibility, responsive, RTL, and web review |
| `efficient/data-audit` | subagent | Schema, migration, transaction, API, and backup review |
| `efficient/release` | subagent | Approval-gated artifact, deployment, and release operations |
| `efficient/product-owner` | subagent | Scope, acceptance criteria, QA, and stakeholder summaries |

Agent definitions omit `model`, so they inherit the active session model. The
core pack requires no framework CLI, plugin, MCP server, or provider.

## Install

Clone the pack once:

```sh
git clone https://github.com/anasfik/better-opencode-efficient-agents.git
cd better-opencode-efficient-agents
```

Project-local installation is recommended for teams:

```sh
./scripts/install.sh --project /path/to/project
cd /path/to/project
opencode reload
opencode debug agents
```

Global installation:

```sh
./scripts/install.sh --global
opencode reload
opencode debug agents
```

Run the same command to upgrade. Existing `efficient/` files are copied to a
timestamped backup outside the agent discovery directory before replacement.
Unrelated agents and OpenCode configuration are never changed.

Installs are serialized with a lock in the agent directory, and an interrupted
or failed replacement restores the previous agents. If a stale lock remains
after a crash, remove `.efficient.lock` inside the agent directory.

This pack does not change `default_agent`. Select `efficient/ship` in OpenCode,
or set it yourself after reviewing the agent.

## Validate

```sh
./scripts/check.sh
./scripts/test-install.sh
opencode reload
opencode debug agents
opencode run --agent efficient/architect \
  "Inspect this repository and produce a read-only implementation plan."
```

`check.sh` validates the agent definitions and scans the published files for
private paths, session identifiers, and credential-shaped values.
`test-install.sh` exercises fresh install, upgrade backup, unrelated-agent
preservation, concurrent installers, and interrupted-install rollback in
temporary directories.

## Safety model

- Only `efficient/ship` has the edit tool enabled. Read-only roles have no edit
  tool, although their approval-gated shell can still touch the filesystem.
- Every agent keeps the OpenCode default prompt before reading `.env` files.
- Shell and external operations require approval.
- Release and tracker mutations require confirmation immediately before use.
- Read-only roles deny all actions first, then allow only required inspection.
- The parent agent owns synthesis, checks, and the final conclusion.
- No raw session history, credentials, personal paths, or model pins ship here.

## Compatibility

OpenCode V2 has no official agent package registry. This repository uses the
documented namespaced Markdown layout and copy-based installation:

- [Agents](https://opencode.ai/v2/docs/agents/)
- [Permissions](https://opencode.ai/v2/docs/permissions/)
- [Tools](https://opencode.ai/v2/docs/tools/)
- [Instructions](https://opencode.ai/v2/docs/instructions/)

## License

MIT

Security reports should follow [`SECURITY.md`](SECURITY.md). Contributions are
welcome under [`CONTRIBUTING.md`](CONTRIBUTING.md).
