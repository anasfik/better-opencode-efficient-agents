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
  if ! problem=$(awk -v name="$name" '
    function value(line) {
      sub(/^[^:]*:[[:space:]]*/, "", line)
      if (line ~ /^".*"$/) line = substr(line, 2, length(line) - 2)
      return line
    }
    function error(message) {
      print name ".md " message
      bad = 1
    }
    function finish_rule() {
      if (current_action == "") return
      if (current_resource == "" || current_effect == "") {
        error("has an incomplete permission rule")
      }
      count++
      action[count] = current_action
      resource[count] = current_resource
      effect[count] = current_effect
      current_action = current_resource = current_effect = ""
    }
    function exact_action(target, expected_count, expected_effect,    found, i) {
      found = 0
      for (i = 1; i <= count; i++) {
        if (action[i] != target) continue
        found++
        if (resource[i] != "*" || effect[i] != expected_effect) {
          error("must use only " target " / * / " expected_effect)
        }
      }
      if (found != expected_count) {
        error("has " found " explicit " target " rules; expected " expected_count)
      }
    }
    /^permissions:$/ { in_permissions = 1; next }
    in_permissions && /^---$/ { finish_rule(); in_permissions = 0; next }
    in_permissions && /^  - action: / {
      finish_rule()
      current_action = value($0)
      next
    }
    in_permissions && /^    resource: / { current_resource = value($0); next }
    in_permissions && /^    effect: / { current_effect = value($0); next }
    END {
      finish_rule()
      if (count == 0) error("has no permission rules")
      if (action[1] != "*" || resource[1] != "*" || effect[1] != "deny") {
        error("must start with * / * / deny")
      }

      read_count = 0
      for (i = 1; i <= count; i++) {
        if (action[i] != "read") continue
        read_count++
        if (read_count == 1 && (resource[i] != "*" || effect[i] != "allow"))
          error("read rule 1 must be * / allow")
        if (read_count == 2 && (resource[i] != "*.env" || effect[i] != "ask"))
          error("read rule 2 must be *.env / ask")
        if (read_count == 3 && (resource[i] != "*.env.*" || effect[i] != "ask"))
          error("read rule 3 must be *.env.* / ask")
        if (read_count == 4 && (resource[i] != "*.env.example" || effect[i] != "allow"))
          error("read rule 4 must be *.env.example / allow")
      }
      if (read_count != 4) error("must have exactly four ordered read rules")

      exact_action("edit", name == "ship" ? 1 : 0, "allow")
      operational = name == "ship" || name == "release-ops"
      exact_action("shell", operational ? 1 : 0, "ask")
      exact_action("execute", operational ? 1 : 0, "ask")
      exact_action("external_directory", operational ? 1 : 0, "ask")
      exact_action("skill", 1, "allow")
      exit bad
    }
  ' "$file"); then
    fail "$problem"
  fi
done

primary=$(grep -l '^mode: primary$' "$agents"/*.md | wc -l | tr -d ' ')
subagent=$(grep -l '^mode: subagent$' "$agents"/*.md | wc -l | tr -d ' ')
[ "$primary" -eq 1 ] || fail "expected 1 primary agent, found $primary"
[ "$subagent" -eq 7 ] || fail "expected 7 subagents, found $subagent"

grep -q '^mode: primary$' "$agents/ship.md" || fail "ship must be primary"

for name in $roster; do
  if grep -n '^model:' "$agents/$name.md"; then
    fail "agent definitions must inherit the active model"
  fi
done

private_home='/'home'/[[:alnum:]_.-]+'
session_id='s''es_[[:alnum:]]+'
bearer='Bear''er[[:space:]]+[[:alnum:]_.-]+'
authorization='Authoriza''tion:[[:space:]]*[^<{]'
privacy_matches=$(
  git -C "$root" ls-files --cached --others --exclude-standard |
    while IFS= read -r relative; do
      [ -f "$root/$relative" ] || continue
      matches=$(grep -E -n "($private_home|$session_id|$bearer|$authorization)" "$root/$relative" || :)
      [ -z "$matches" ] || printf '%s:%s\n' "$relative" "$matches"
    done
)
if [ -n "$privacy_matches" ]; then
  printf '%s\n' "$privacy_matches"
  fail "private path, session identifier, or credential-like value found"
fi

for script in install.sh check.sh test-check.sh test-install.sh; do
  sh -n "$root/scripts/$script"
done

echo "ok: 8 portable agents, 1 primary, 7 subagents"
