#!/bin/sh
# Regression tests for ordered permission validation. POSIX sh, temp dirs only.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT HUP INT TERM
repo=$work/repo
mkdir -p "$repo"
cp -R "$root/agents" "$repo/agents"
cp -R "$root/scripts" "$repo/scripts"
git -C "$repo" init -q
git -C "$repo" add agents scripts/check.sh

fail() {
  echo "test failed: $*" >&2
  exit 1
}

rejects() {
  label=$1
  if "$repo/scripts/check.sh" >/dev/null 2>&1; then
    fail "$label was accepted"
  fi
  cp "$root/agents/efficient/data.md" "$repo/agents/efficient/data.md"
  echo "ok: $label rejected"
}

"$repo/scripts/check.sh" >/dev/null || fail "baseline rejected"

sed '15s/ask/allow/' "$repo/agents/efficient/data.md" > "$work/data.md"
mv "$work/data.md" "$repo/agents/efficient/data.md"
rejects "wrong env effect"

{
  sed -n '1,12p' "$repo/agents/efficient/data.md"
  sed -n '16,18p' "$repo/agents/efficient/data.md"
  sed -n '13,15p' "$repo/agents/efficient/data.md"
  sed -n '19,$p' "$repo/agents/efficient/data.md"
} > "$work/data.md"
mv "$work/data.md" "$repo/agents/efficient/data.md"
rejects "reordered env rules"

{
  sed -n '1,6p' "$repo/agents/efficient/data.md"
  sed -n '10,12p' "$repo/agents/efficient/data.md"
  sed -n '7,9p' "$repo/agents/efficient/data.md"
  sed -n '13,$p' "$repo/agents/efficient/data.md"
} > "$work/data.md"
mv "$work/data.md" "$repo/agents/efficient/data.md"
rejects "reordered deny-all rule"

sed '31i\
  - action: external_directory\
    resource: "*"\
    effect: ask' "$repo/agents/efficient/data.md" > "$work/data.md"
mv "$work/data.md" "$repo/agents/efficient/data.md"
rejects "external directory on read-only specialist"

printf '/%s/%s\n' home private-user > "$repo/leak.txt"
git -C "$repo" add leak.txt
rejects "private path"

echo "ok: check.sh ordered permission regressions"
