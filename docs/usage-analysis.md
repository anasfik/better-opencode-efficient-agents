# Anonymized OpenCode usage analysis

## Method and limits

This analysis was refreshed on October 13, 2026. It covers 164 completed or
current-history sessions after excluding the active root tree: 92 roots and 72
children across 14 projects. Legacy rows duplicated in V2 tables were not
double-counted.

The source data was read-only. This repository contains only aggregate counts
and paraphrased conclusions—no prompts, responses, session identifiers,
personal paths, authentication data, or database exports.

Theme classification, verification detection, and conclusion detection are
heuristic. Themes overlap, so their percentages do not sum to 100%. The three
busiest projects account for 70 of 92 roots, and this sample is not
representative of every OpenCode user. No `efficient/*` agent appeared in the
analyzed metadata; these results inform role fit, not this pack's effectiveness.

## Workload

| Overlapping root theme | Roots | Share of 92 roots |
|---|---:|---:|
| Testing or verification | 57 | 62.0% |
| Review or audit | 45 | 48.9% |
| Implementation | 44 | 47.8% |
| Git or repositories | 44 | 47.8% |
| Operations or deployment | 37 | 40.2% |
| API or data administration | 36 | 39.1% |
| OpenCode or agents | 35 | 38.0% |
| Research, planning, or product | 31 | 33.7% |
| Debugging or fixes | 25 | 27.2% |
| UI or design | 24 | 26.1% |
| SEO or content | 17 | 18.5% |

Stack signals appeared in 31 OpenCode roots, 16 SEO or marketing roots, 14 web
JavaScript/TypeScript roots, 11 Cloudflare or edge roots, 11 data or Postgres
roots, 9 Flutter or mobile roots, and 2 Python roots. These signals overlap and
describe this sample, not market share.

The mix supports one implementation owner plus focused quality, research,
interface, data, SEO, OpenCode, and operational help. Framework and vendor
knowledge changes too quickly to duplicate in static agent prompts, so each
specialist loads the narrowest applicable installed skill first.

## Delegation and completion

- 14 of 92 roots delegated and created 72 children.
- Six roots exceeded three children; maximum fan-out was 21.
- Of 74 subagent or task calls, 34 used `general`, 12 used `explore`, and 28
  used SEO specialists.
- Root tool-use median was 36.5 calls, p90 was 169, and the maximum was 1,481.
  Twenty-two roots used at least 100 calls and three used at least 500.
- 13 of 92 roots lacked a final parent conclusion.
- Verification was requested in 53 roots; 13 lacked recognizable command
  evidence.

The pack therefore keeps delegation bounded and leaves synthesis, final checks,
and the conclusion with `efficient/ship`. Child output and tool completion are
evidence, not task completion.

## Tool failures

Across 8,591 V2 tool calls, 126 failed (1.47%):

| Failure class | Calls |
|---|---:|
| Missing targets or resources | 47 |
| Cancelled or interrupted | 36 |
| Permission or authentication | 17 |
| Remote or network | 5 |
| Stale edit context | 3 |
| Invalid input | 1 |
| Other | 17 |

Missing targets were the largest class. Agents should discover files and
resources before acting, inspect affected callers, and re-read targets before a
narrow edit. Permission and remote failures support keeping operational actions
explicitly approval-gated rather than granting broad shell or provider access.

## Design mapping

| Observed need | Pack response |
|---|---|
| Implementation and parent conclusions | `efficient/ship` is the one primary and sole editor in this pack |
| Code paths, current docs, and bounded evidence | `efficient/research` |
| Verification, review, security, and regressions | `efficient/quality` |
| Web/mobile UX and accessibility | `efficient/ui-mobile` |
| Schemas, migrations, APIs, privacy, and rollback | `efficient/data` |
| Search visibility and content | `efficient/seo` |
| OpenCode configuration and integrations | `efficient/opencode` |
| Releases, deployment, and remote operations | `efficient/release-ops`, with per-action approval |

The seven specialists do not edit workspace files. `release-ops` can request
shell, execute, and external-directory access because its work may require
operational tools, but every such use remains approval-gated. Never use
`release-ops` with auto-approval.

These namespaced agents supplement rather than replace OpenCode's built-in
`build`, `plan`, `general`, and `explore` roles. Built-ins remain available for
general-purpose workflows; use the `efficient/*` roles when their narrower
scope, skill-first instructions, and permission boundaries fit the task.
