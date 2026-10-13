# Better OpenCode Efficient Agents

**Dev-friendly pack:** eight namespaced OpenCode V2 agents—one primary workspace
mutator (`efficient/ship`) and seven focused subagents. No model pins, framework
dependencies, or vendor lock-in. Tested against OpenCode v2.0.25.

Quick links: [Prompt install](#prompt-install) · [Validate](#validate) · [Agents](#agents) · [Usage analysis](docs/usage-analysis.md)

---

## At a glance

| What | How |
|---|---|
| **Install and activate** | Paste the three-line [installation prompt](#prompt-install) into OpenCode |
| **Try them** | `opencode run --agent efficient/ship "Inspect this repo and propose the smallest verified change."` |
| **Check before use** | `./scripts/check.sh` and `./scripts/test-install.sh` |

---

## Why this exists

A read-only, anonymized analysis refreshed on October 13, 2026 covered 164
sessions: 92 roots and 72 children across 14 projects. Testing or verification
appeared in 57 roots, review or audit in 45, implementation in 44, and operations
or deployment in 37. Of 53 roots that requested verification, 13 lacked
recognizable command evidence; 13 of all 92 roots lacked a final parent
conclusion. Missing targets or resources caused 47 of 126 failed V2 tool calls.

The smallest response is to discover before acting, keep one implementation
owner, use narrow specialists, verify explicitly, and finish with evidence.
These aggregate results describe role fit, not the effectiveness of this pack.
See [`docs/usage-analysis.md`](docs/usage-analysis.md) for the complete counts,
method, and heuristic limits.

---

## Agents

| Agent | Mode | Scope |
|---|---|---|
| `efficient/ship` | primary | Implements, integrates, verifies, and reports; sole editor in this pack |
| `efficient/research` | subagent | Code paths, current documentation, patterns, and bounded evidence |
| `efficient/quality` | subagent | Correctness, security, regressions, tests, and release readiness |
| `efficient/ui-mobile` | subagent | Web/mobile UX, accessibility, responsive behavior, and native conventions |
| `efficient/data` | subagent | Schemas, migrations, APIs, transactions, privacy, and rollback safety |
| `efficient/seo` | subagent | Crawlability, metadata, schema, performance, content, and visibility |
| `efficient/opencode` | subagent | OpenCode agents, skills, tools, permissions, configuration, and integrations |
| `efficient/release-ops` | subagent | Approval-gated artifacts, deployments, remote changes, and rollback checks |

Specialists are skill-first: each loads the narrowest applicable installed
skill, then applies its focused instructions. The pack does not bundle skills or
pretend an unavailable integration exists.

These namespaced roles supplement OpenCode's built-in `build`, `plan`, `general`,
and `explore` agents; they do not remove or redefine them. Keep using built-ins
for general-purpose work. Choose an `efficient/*` role when its tighter scope
and permission boundary fit the task. Within this pack, `ship` owns workspace
changes and parent synthesis; specialists return evidence rather than edits.

### Permission boundaries

All agents start with deny-all, preserve approval prompts for `*.env` and
`*.env.*`, allow `*.env.example`, and inherit the active model.

| Agent class | Edit | Shell / execute | Skills | External directory |
|---|---|---|---|---|
| `efficient/ship` | allow | ask | allow | ask |
| Six read-only specialists | deny | deny | allow | deny |
| `efficient/release-ops` | deny | ask | allow | ask |

The six read-only specialists are `research`, `quality`, `ui-mobile`, `data`,
`seo`, and `opencode`. Some may fetch public sources where their scope requires
it, but none can edit or run arbitrary commands.

> **Do not use `efficient/release-ops` under auto-approval.** Its shell,
> provider, deployment, publishing, and other remote mutations must remain
> individually approval-gated.

---

## Prompt install

Copy and paste these three lines into OpenCode:

```text
Install and configure the OpenCode V2 agent pack from https://github.com/anasfik/better-opencode-efficient-agents globally for my user.
Clone or update the repository, run its checks and `./scripts/install.sh --global`, and preserve unrelated agents plus any backup the installer creates.
Run `opencode reload` and `opencode debug agents`, verify all eight `efficient/*` agents are available, then report what changed and any failed check.
```

---

## Validate

```sh
./scripts/check.sh        # exact roster, modes, permissions, model inheritance, privacy, syntax
./scripts/test-install.sh # install, upgrade, backup, namespace preservation, locking, rollback
opencode reload
opencode debug agents
opencode run --agent efficient/ship \
  "Inspect this repo and propose the smallest verified change."
```

---

## Safety model

- Only `efficient/ship` can edit workspace files.
- Only `ship` and `release-ops` expose shell or execute; both default to `ask`.
  Choose **Allow once** when prompted, never save broad approval patterns, and
  never use auto-approval for `release-ops`.
- Every specialist can load applicable skills without gaining edit access.
- Release, deploy, publish, promote, destructive, account, and production
  actions require confirmation immediately before the mutation.
- The parent owns synthesis, checks, and the final conclusion. Child success is
  not parent completion.
- This repository must contain no credentials, session IDs, personal paths, raw
  prompts, or model pins.

---

## Compatibility

OpenCode V2 has no agent package registry. This repository uses namespaced
Markdown agents (`.opencode/agents/<namespace>/*.md`), producing IDs such as
`efficient/ship`. It works with any compatible OpenCode V2 CLI; v2.0.25 is the
tested version.

---

## What's not in the core pack

- Framework, platform, and vendor expertise belongs in installed skills and
  integrations, loaded only when relevant.
- Vendor-specific APIs belong in their MCP or integration, not a default agent.
- Session-history mining stays private; public packs should contain only
  anonymous aggregate evidence.

---

## License

MIT. Security reports: follow [`SECURITY.md`](SECURITY.md). Contributions:
[`CONTRIBUTING.md`](CONTRIBUTING.md).
