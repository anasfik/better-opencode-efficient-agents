#!/bin/sh
# Regression tests for scripts/install.sh. POSIX sh, temp dirs only, no network.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
install=$root/scripts/install.sh
roster='data opencode quality release-ops research seo ship ui-mobile'
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT HUP INT TERM

fail() {
  echo "test failed: $*" >&2
  exit 1
}

ok() {
  echo "ok: $1"
}

assert_roster() {
  directory=$1
  label=$2
  actual_count=0
  for file in "$directory"/*.md; do
    [ -f "$file" ] || continue
    name=${file##*/}
    name=${name%.md}
    case " $roster " in
      *" $name "*) ;;
      *) fail "$label has unexpected agent $name.md" ;;
    esac
    actual_count=$((actual_count + 1))
  done
  set -- $roster
  [ "$actual_count" -eq "$#" ] || fail "$label expected $# agents, found $actual_count"
  for name in $roster; do
    [ -f "$directory/$name.md" ] || fail "$label missing $name.md"
  done
}

leftovers() {
  for path in "$1"/.efficient.*; do
    [ -e "$path" ] && return 0
  done
  return 1
}

# 1. Fresh project install produces exactly the expected agent definitions.
fresh=$work/fresh
mkdir -p "$fresh"
"$install" --project "$fresh" >/dev/null
target=$fresh/.opencode/agents/efficient
[ -d "$target" ] || fail "fresh install produced no namespace"
assert_roster "$target" "fresh install"
leftovers "$fresh/.opencode/agents" && fail "fresh install left staging files"
ok "fresh project install"

# 2. Upgrade backs up local edits, drops them, and keeps unrelated agents.
printf 'x\n' > "$fresh/.opencode/agents/unrelated.md"
printf 'local\n' > "$target/LOCAL-MARKER"
printf 'obsolete architect\n' > "$target/architect.md"
printf 'obsolete verifier\n' > "$target/verify.md"
"$install" --project "$fresh" >/dev/null
[ ! -e "$target/LOCAL-MARKER" ] || fail "stale local marker survived upgrade"
assert_roster "$target" "upgrade"
[ ! -e "$target/architect.md" ] || fail "obsolete architect survived upgrade"
[ ! -e "$target/verify.md" ] || fail "obsolete verifier survived upgrade"
[ -f "$fresh/.opencode/agents/unrelated.md" ] || fail "unrelated agent removed"
backups=$fresh/.opencode/backups/better-opencode-efficient-agents
find "$backups" -name LOCAL-MARKER | grep -q . || fail "upgrade kept no backup"
find "$backups" -name architect.md -exec grep -l '^obsolete architect$' {} \; | grep -q . ||
  fail "backup lost obsolete architect"
find "$backups" -name verify.md -exec grep -l '^obsolete verifier$' {} \; | grep -q . ||
  fail "backup lost obsolete verifier"
leftovers "$fresh/.opencode/agents" && fail "upgrade left staging files"
ok "upgrade backup and unrelated agent preserved"

# 3. Global install honors XDG overrides.
global=$work/global
mkdir -p "$global/home"
HOME=$global/home XDG_CONFIG_HOME=$global/config XDG_STATE_HOME=$global/state \
  "$install" --global >/dev/null
[ -f "$global/config/opencode/agents/efficient/ship.md" ] || fail "global install"
ok "global install"

# 4. Concurrent installers serialize and never nest a namespace.
concurrent=$work/concurrent
mkdir -p "$concurrent"
"$install" --project "$concurrent" >/dev/null 2>&1 &
first=$!
"$install" --project "$concurrent" >/dev/null 2>&1 &
second=$!
wait "$first" || fail "first concurrent install failed"
wait "$second" || fail "second concurrent install failed"
ctarget=$concurrent/.opencode/agents
assert_roster "$ctarget/efficient" "concurrent install"
[ -d "$ctarget/efficient/efficient" ] && fail "concurrent install nested a namespace"
leftovers "$ctarget" && fail "concurrent install left staging files"
ok "concurrent installs serialize"

# 5. Interrupting an upgrade restores the previous namespace and exits nonzero.
interrupted=$work/interrupted
mkdir -p "$interrupted"
"$install" --project "$interrupted" >/dev/null
itarget=$interrupted/.opencode/agents/efficient
printf 'old\n' > "$itarget/OLD-MARKER"
bindir=$work/bin
mkdir -p "$bindir"
real_mv=$(command -v mv)
cat > "$bindir/mv" <<EOF
#!/bin/sh
case "\$1" in
  *.efficient.new.*)
    "$real_mv" "\$@"
    kill -TERM "\$PPID"
    sleep 2
    exit 143
    ;;
esac
exec "$real_mv" "\$@"
EOF
chmod +x "$bindir/mv"
PATH=$bindir:$PATH "$install" --project "$interrupted" >/dev/null 2>&1 &
pid=$!
waited=0
while [ -e "$itarget" ] && [ "$waited" -lt 10 ]; do
  sleep 1
  waited=$((waited + 1))
done
if wait "$pid" 2>/dev/null; then
  fail "interrupted installer exited 0"
fi
[ -f "$itarget/OLD-MARKER" ] || fail "previous agents not restored"
assert_roster "$itarget" "restored install"
leftovers "$interrupted/.opencode/agents" && fail "interrupted install left staging files"
ok "interrupt rolls back and exits nonzero"

echo "ok: install.sh regressions"
