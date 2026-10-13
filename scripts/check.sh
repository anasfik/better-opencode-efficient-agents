#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
agents=$root/agents/efficient
roster='data opencode quality release-ops research seo ship ui-mobile'

fail() {
  echo "check failed: $*" >&2
  exit 1
}

[ -d "$agents" ] || fail "missing agents/efficient"

actual_count=0
for file in "$agents"/*.md; do
  [ -f "$file" ] || continue
  name=${file##*/}
  name=${name%.md}
  case " $roster " in
    *" $name "*) ;;
    *) fail "unexpected agent $name.md" ;;
  esac
  actual_count=$((actual_count + 1))
done
set -- $roster
[ "$actual_count" -eq "$#" ] || fail "expected $# agents, found $actual_count"

for name in $roster; do
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
[ "$primary" -eq 1 ] || fail "expected 1 primary agent, found $primary"
[ "$subagent" -eq 7 ] || fail "expected 7 subagents, found $subagent"

grep -q '^mode: primary$' "$agents/ship.md" || fail "ship must be primary"

if grep -R -n '^model:' "$agents"; then
  fail "agent definitions must inherit the active model"
fi

for name in $roster; do
  [ "$name" = ship ] && continue
  file=$agents/$name.md
  grep -A2 '^  - action: skill$' "$file" | grep -q '^    effect: allow$' || fail "$name must allow skills"
done

for action in edit shell execute; do
  exposed=
  for name in $roster; do
    if grep -q "^  - action: $action$" "$agents/$name.md"; then
      exposed="${exposed:+$exposed }$name"
    fi
  done
  case $action in
    edit) expected=ship ;;
    *) expected='release-ops ship' ;;
  esac
  [ "$exposed" = "$expected" ] || fail "$action exposed to '$exposed', expected '$expected'"
done

for action in edit skill; do
  if ! grep -A2 "^  - action: $action$" "$agents/ship.md" | grep -q '^    effect: allow$'; then
    fail "ship must allow $action"
  fi
done

for name in release-ops ship; do
  for action in shell execute; do
    grep -A2 "^  - action: $action$" "$agents/$name.md" | grep -q '^    effect: ask$' ||
      fail "$name $action must require approval"
  done
done

private_home='/'home'/[[:alnum:]_.-]+'
session_id='s''es_[[:alnum:]]+'
bearer='Bear''er[[:space:]]+[[:alnum:]_.-]+'
authorization='Authoriza''tion:[[:space:]]*[^<{]'
if git -C "$root" ls-files -z --cached --others --exclude-standard | \
  xargs -0 grep -I -E -n "($private_home|$session_id|$bearer|$authorization)"; then
  fail "private path, session identifier, or credential-like value found"
fi

for script in install.sh check.sh test-install.sh; do
  sh -n "$root/scripts/$script"
done

echo "ok: 8 portable agents, 1 primary, 7 subagents"
