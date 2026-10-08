#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
agents=$root/agents/efficient
expected='architect code-review data-audit docs-scout explorer product-owner release ship ui-review verify'

fail() {
  echo "check failed: $*" >&2
  exit 1
}

[ -d "$agents" ] || fail "missing agents/efficient"

count=$(find "$agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
[ "$count" -eq 10 ] || fail "expected 10 agents, found $count"

for name in $expected; do
  file=$agents/$name.md
  [ -f "$file" ] || fail "missing $name.md"
  [ "$(sed -n '1p' "$file")" = '---' ] || fail "$name.md has no frontmatter"
  grep -q '^description:' "$file" || fail "$name.md has no description"
  grep -q '^permissions:' "$file" || fail "$name.md has no permissions"
  grep -q 'action: "\*"' "$file" || fail "$name.md has no deny-first policy"
  # Keep the OpenCode default .env prompts; a wildcard read allow would erase them.
  grep -q 'resource: "\*\.env"' "$file" || fail "$name.md does not ask before reading *.env"
  grep -q 'resource: "\*\.env\.\*"' "$file" || fail "$name.md does not ask before reading *.env.*"
  grep -q 'resource: "\*\.env\.example"' "$file" || fail "$name.md does not allow *.env.example"
done

primary=$(grep -l '^mode: primary$' "$agents"/*.md | wc -l | tr -d ' ')
subagent=$(grep -l '^mode: subagent$' "$agents"/*.md | wc -l | tr -d ' ')
[ "$primary" -eq 2 ] || fail "expected 2 primary agents, found $primary"
[ "$subagent" -eq 8 ] || fail "expected 8 subagents, found $subagent"

grep -q '^mode: primary$' "$agents/ship.md" || fail "ship must be primary"
grep -q '^mode: primary$' "$agents/architect.md" || fail "architect must be primary"

if grep -R -n '^model:' "$agents"; then
  fail "agent definitions must inherit the active model"
fi

edit_files=$(grep -l 'action: edit' "$agents"/*.md || true)
[ "$edit_files" = "$agents/ship.md" ] || fail "ship must be the only workspace mutator"

if grep -R -A2 'action: shell' "$agents"/*.md | grep -q 'effect: allow'; then
  fail "shell must require approval"
fi

if grep -R -E -n '(/home/[[:alnum:]_.-]+|ses_[[:alnum:]]+|Bearer[[:space:]]+[[:alnum:]_.-]+|Authorization:[[:space:]]*[^<{])' \
  "$root/README.md" "$root/docs" "$root/agents"; then
  fail "private path, session identifier, or credential-like value found"
fi

for script in install.sh check.sh test-install.sh; do
  sh -n "$root/scripts/$script"
done

echo "ok: 10 portable agents, 2 primary, 8 subagents"
