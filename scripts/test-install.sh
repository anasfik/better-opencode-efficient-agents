#!/bin/sh
# Regression tests for scripts/install.sh. POSIX sh, temp dirs only, no network.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
install=$root/scripts/install.sh
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT HUP INT TERM

fail() {
  echo "test failed: $*" >&2
  exit 1
}

ok() {
  echo "ok: $1"
}

count_agents() {
  find "$1" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' '
}

leftovers() {
  find "$1" -maxdepth 1 -name '.efficient.*' | grep -q .
}

# 1. Fresh project install produces exactly the ten agent definitions.
fresh=$work/fresh
mkdir -p "$fresh"
"$install" --project "$fresh" >/dev/null
target=$fresh/.opencode/agents/efficient
[ -d "$target" ] || fail "fresh install produced no namespace"
[ "$(count_agents "$target")" -eq 10 ] || fail "fresh install agent count"
leftovers "$fresh/.opencode/agents" && fail "fresh install left staging files"
ok "fresh project install"

# 2. Upgrade backs up local edits, drops them, and keeps unrelated agents.
printf 'x\n' > "$fresh/.opencode/agents/unrelated.md"
printf 'local\n' > "$target/LOCAL-MARKER"
"$install" --project "$fresh" >/dev/null
[ ! -e "$target/LOCAL-MARKER" ] || fail "stale local marker survived upgrade"
[ "$(count_agents "$target")" -eq 10 ] || fail "upgrade agent count"
[ -f "$fresh/.opencode/agents/unrelated.md" ] || fail "unrelated agent removed"
backups=$fresh/.opencode/backups/better-opencode-efficient-agents
find "$backups" -name LOCAL-MARKER | grep -q . || fail "upgrade kept no backup"
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
[ "$(count_agents "$ctarget/efficient")" -eq 10 ] || fail "concurrent agent count"
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
  *.efficient.new.*) sleep 3; exit 1 ;;
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
[ -e "$itarget" ] && fail "upgrade never started replacing the namespace"
kill -TERM "$pid" 2>/dev/null || true
if wait "$pid" 2>/dev/null; then
  fail "interrupted installer exited 0"
fi
[ -f "$itarget/OLD-MARKER" ] || fail "previous agents not restored"
[ "$(count_agents "$itarget")" -eq 10 ] || fail "restored agent count"
leftovers "$interrupted/.opencode/agents" && fail "interrupted install left staging files"
ok "interrupt rolls back and exits nonzero"

echo "ok: install.sh regressions"
