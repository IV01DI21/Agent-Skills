#!/usr/bin/env bash
# Installs every skill in ./skills into the user-scope Claude Code skills folder.
# Usage: bash install.sh [target-dir]   (default: ~/.claude/skills)
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
dest="${1:-$HOME/.claude/skills}"

[ -d "$src" ] || { echo "skills folder not found: $src" >&2; exit 1; }
mkdir -p "$dest"

count=0
for dir in "$src"/*/; do
  name="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || { echo "skip $name (no SKILL.md)"; continue; }
  rm -rf "${dest:?}/$name"
  cp -R "$dir" "$dest/$name"
  echo "installed $name"
  count=$((count + 1))
done

echo "$count skills installed to $dest - restart Claude Code to load them."
