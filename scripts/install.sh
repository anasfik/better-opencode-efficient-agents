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

mkdir -p "$agent_root"

# Serialize installers so two runs cannot nest a namespace inside the other.
tries=0
while ! mkdir "$lock" 2>/dev/null; do
  tries=$((tries + 1))
  [ "$tries" -le 5 ] || { echo "another install holds $lock; remove it if stale" >&2; exit 1; }
  sleep 1
done

cleanup() {
  # An uncommitted replacement must leave the previous namespace in place.
  if [ "$committed" -eq 0 ] && [ -e "$old" ] && [ ! -e "$destination" ]; then
    mv "$old" "$destination" 2>/dev/null || true
  fi
  [ ! -e "$staged" ] || rm -rf -- "$staged"
  [ ! -e "$old" ] || rm -rf -- "$old"
  rmdir "$lock" 2>/dev/null || true
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

if ! mv "$staged" "$destination"; then
  echo "installation failed; previous agents restored" >&2
  exit 1
fi

committed=1
[ ! -e "$old" ] || rm -rf -- "$old"

echo "installed: $destination"
[ -z "$backup" ] || echo "backup:    $backup"
echo "next:      opencode reload && opencode debug agents"
