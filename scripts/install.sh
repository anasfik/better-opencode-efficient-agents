#!/bin/sh
set -eu

usage() {
  echo "usage: $0 --global | --project PATH" >&2
  exit 2
}

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_dir=$root/agents/efficient

case ${1-} in
  --global)
    [ "$#" -eq 1 ] || usage
    agent_root=${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents
    backup_root=${XDG_STATE_HOME:-$HOME/.local/state}/better-opencode-efficient-agents/backups
    ;;
  --project)
    [ "$#" -eq 2 ] || usage
    project=$(CDPATH= cd -- "$2" && pwd)
    agent_root=$project/.opencode/agents
    backup_root=$project/.opencode/backups/better-opencode-efficient-agents
    ;;
  *) usage ;;
esac

[ -d "$source_dir" ] || { echo "missing source agents: $source_dir" >&2; exit 1; }

destination=$agent_root/efficient
lock=$agent_root/.efficient.lock
staged=$agent_root/.efficient.new.$$
old=$agent_root/.efficient.old.$$
backup=
committed=0
replacement_started=0

mkdir -p "$agent_root"

# Serialize installers so two runs cannot nest a namespace inside the other.
tries=0
while ! mkdir "$lock" 2>/dev/null; do
  tries=$((tries + 1))
  [ "$tries" -le 5 ] || { echo "another install holds $lock; remove it if stale" >&2; exit 1; }
  sleep 1
done

cleanup() {
  status=$?
  trap - EXIT
  # A signal can arrive after the new namespace was moved into place but before
  # the commit flag was set. Remove that uncommitted copy and restore the old one.
  if [ "$committed" -eq 0 ] && [ "$replacement_started" -eq 1 ]; then
    [ ! -e "$destination" ] || rm -rf -- "$destination"
    if [ -e "$old" ] && ! mv "$old" "$destination"; then
      echo "could not restore previous agents from $old" >&2
      status=1
    fi
  fi
  [ ! -e "$staged" ] || rm -rf -- "$staged"
  if [ "$committed" -eq 1 ]; then
    [ ! -e "$old" ] || rm -rf -- "$old"
  fi
  rmdir "$lock" 2>/dev/null || true
  exit "$status"
}

interrupted() {
  echo "install interrupted; previous agents restored if replaced" >&2
  exit 130
}

trap cleanup EXIT
trap interrupted HUP INT TERM

cp -R "$source_dir" "$staged"

if [ -e "$destination" ]; then
  stamp=$(date +%Y%m%d-%H%M%S)
  backup=$backup_root/$stamp-$$
  mkdir -p "$backup_root"
  cp -R "$destination" "$backup"
  mv "$destination" "$old"
fi

replacement_started=1
if ! mv "$staged" "$destination"; then
  echo "installation failed; previous agents restored" >&2
  exit 1
fi

committed=1
[ ! -e "$old" ] || rm -rf -- "$old"

echo "installed: $destination"
[ -z "$backup" ] || echo "backup:    $backup"
echo "next:      opencode reload && opencode debug agents"
