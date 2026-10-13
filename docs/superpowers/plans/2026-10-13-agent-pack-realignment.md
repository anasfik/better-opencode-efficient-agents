# Agent Pack Realignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the generic ten-agent pack with a smaller roster aligned to the user's observed coding, review, UI/mobile, data, SEO, operations, and OpenCode workflows.

**Architecture:** Keep one custom primary, `efficient/ship`, as the sole workspace mutator and parent synthesizer. Replace overlapping planning, exploration, documentation, verification, and product roles with seven focused read-only or approval-gated subagents: `research`, `quality`, `ui-mobile`, `data`, `seo`, `opencode`, and `release-ops`.

**Tech Stack:** OpenCode V2 Markdown agents, POSIX shell installer/tests, Markdown documentation.

**Spec:** `docs/usage-analysis.md`

## Global Constraints

- No model pins, dependencies, secrets, personal paths, raw prompts, or session identifiers.
- Only `efficient/ship` may edit workspace files.
- Read-only agents deny arbitrary shell and execute access; operational access is explicit and approval-gated.
- Every specialist can load applicable skills and returns evidence, checks, and untested risks.
- Keep installation atomic, backed up, concurrency-safe, and reversible.

## Review Focus

- Auto-approval must not turn a nominally read-only agent into a shell-based mutator; `scripts/check.sh` must reject shell or execute grants outside `release-ops` and `ship`.
- Namespace upgrades must remove obsolete old agents while preserving unrelated namespaces; `scripts/test-install.sh` must cover this.
- Agent discovery must yield exactly the intended eight IDs after installation; validator and installer tests must derive from one roster source.
- UI, data, SEO, and OpenCode agents must be able to load skills while remaining unable to edit.
- Release operations must remain blocked behind explicit approval and warn against `--auto`.

---

### Task 1: Define the tailored eight-agent roster

**Files:**
- Modify: `agents/efficient/ship.md`
- Create: `agents/efficient/research.md`
- Create: `agents/efficient/quality.md`
- Create: `agents/efficient/ui-mobile.md`
- Create: `agents/efficient/data.md`
- Create: `agents/efficient/seo.md`
- Create: `agents/efficient/opencode.md`
- Create: `agents/efficient/release-ops.md`
- Delete: superseded agent Markdown files

**Interfaces:**
- Consumes: OpenCode V2 agent frontmatter and installed skills.
- Produces: one primary ID and seven subagent IDs under `efficient/*`.

- [ ] Write validator expectations for the exact roster and permission classes before changing agents.
- [ ] Run `./scripts/check.sh` and confirm it fails against the old roster.
- [ ] Implement the eight minimal agent definitions and remove superseded definitions.
- [ ] Run `./scripts/check.sh` and confirm all roster and safety assertions pass.

### Task 2: Make validation roster-driven and safety-focused

**Files:**
- Modify: `scripts/check.sh`
- Modify: `scripts/test-install.sh`

**Interfaces:**
- Consumes: `agents/efficient/*.md`.
- Produces: deterministic checks for roster, modes, model inheritance, mutation boundaries, skill access, env privacy, shell syntax, install replacement, backups, locking, and rollback.

- [ ] Replace duplicated ten-agent/count assumptions with the exact eight-agent roster.
- [ ] Add checks that only `ship` permits edits, only `ship` and `release-ops` expose shell/execute, and every specialist allows skills.
- [ ] Add an upgrade fixture containing obsolete namespace files and assert replacement removes them while backup preserves them.
- [ ] Run `./scripts/check.sh` and `./scripts/test-install.sh` to confirm both pass.

### Task 3: Refresh evidence and user-facing documentation

**Files:**
- Modify: `docs/usage-analysis.md`
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`

**Interfaces:**
- Consumes: anonymized session analysis and final agent roster.
- Produces: current rationale, install/use guidance, permission table, and contribution invariants.

- [ ] Replace stale corpus statistics with the current anonymized 164-session analysis and label its date and heuristic limits.
- [ ] Document the eight agents, built-in-role boundaries, skill-first specialization, and `release-ops` auto-approval warning.
- [ ] Update contribution and validation guidance to match one primary, seven subagents, and the new safety matrix.
- [ ] Remove the nonexistent CI badge rather than adding unrelated CI scope.
- [ ] Run repository checks plus `git diff --check` and inspect the final diff for private data.
