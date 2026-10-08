# Anonymized OpenCode usage analysis

## Method

The source database was opened read-only. Complete structured messages were
classified without inspecting authentication data. The current in-progress
conversation tree was excluded. This repository contains only aggregate
statistics and paraphrased lessons—no prompts, responses, session identifiers,
personal paths, or database exports.

The historical corpus contained 846 sessions from April through October 2026:

- 270 root sessions
- 576 child sessions
- 216 roots done, 15 partial, 38 failed, and 1 empty
- 515 children done and 61 failed

Global statistics below cover that complete corpus. A separate recent-session
sample was used only to confirm that short model probes should not be treated
as representative workflow sessions.

## Workload

| Theme | Root sessions |
|---|---:|
| Implementation | 57.0% |
| Review or audit | 54.1% |
| OpenCode or agents | 49.3% |
| Git or repositories | 43.0% |
| UI or design | 42.2% |
| API or data administration | 40.4% |
| Testing or verification | 37.0% |
| Debugging or fixes | 36.7% |
| Operations or deployment | 35.2% |
| Research, planning, or product | 32.6% |

Implementation and review overlap heavily, so the pack keeps one implementer
and independent read-only gates instead of creating several competing owners.

## Outcomes and delegation

- Root completion rate: 80.0%.
- Child completion rate: 89.4%.
- 79 of 270 roots delegated work.
- Delegated roots produced 72 done and 7 partial outcomes. This is an
  association, not proof that delegation caused success.
- Median root tool use was 32.5 calls; p90 was 672.
- High-fan-out partial sessions reached dozens of children and thousands of
  tool calls.

The resulting rule is bounded delegation: launch at most three independent
children in one batch, integrate their findings, and only then decide whether
another batch is justified.

## Verification gap

Explicit verification was requested in 150 roots, but 54 contained no evidenced
check. Forty roots also lacked a final parent conclusion even when tools or
children completed successfully.

Every primary agent therefore ends with:

1. changed files or an explicit no-change statement,
2. commands or checks run and their results,
3. residual risks, blockers, or manual steps.

Tool completion and child completion are evidence, not task completion.

## Failure concentration

Across 65,333 tool calls, 1,219 failed (1.87%). The largest groups were:

- missing targets or resources: 317,
- stale edit context: 204,
- invalid input or schema: 126,
- cancelled or interrupted work: 110,
- remote server errors: 68.

Missing resources plus stale edits caused 42.7% of tool failures. The smallest
prevention is to discover paths first, inspect callers, re-read immediately
before editing, and apply a narrow patch.

Remote API creation and update failures were more concentrated than local file
operations. Release, deployment, tracker, and other remote mutations therefore
remain approval-gated and separate from normal implementation.

## Design mapping

| Observed need | Pack response |
|---|---|
| Frequent implementation | `efficient/ship` is the sole workspace mutator |
| Missing paths and stale edits | `efficient/explorer` plus mandatory fresh reads |
| Missing check evidence | `efficient/verify` and root-level reporting |
| Review and security demand | `efficient/code-review` |
| Version-sensitive external APIs | `efficient/docs-scout` |
| Visual and accessibility work | `efficient/ui-review` |
| Data and API administration | `efficient/data-audit` |
| Git, deployment, and release work | `efficient/release` with approval boundaries |
| Product ambiguity and QA | `efficient/product-owner` |
| Cross-cutting planning | `efficient/architect` |

Framework and vendor specialists belong in optional packs. The core must still
load and give a precise blocker when no external integration is installed.
