#!/usr/bin/env bash
# link-copilot-skills.sh
# Symlink skill dirs/files into the Copilot skills directory using .env configuration.
set -euo pipefail

DRY_RUN=0
FORCE=0
ENV_FILE=""

usage() {
  cat <<EOF
Usage: $0 [-n] [-f] [-e envfile] [skills_list_file_override]
  -n  dry-run
  -f  force overwrite existing targets
  -e  path to .env (defaults to .env next to this script)
If a positional skills_list_file_override is provided, it overrides any SKILLS_LIST_FILE from .env.
EOF
  exit 2
}

while getopts "nfe:" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    f) FORCE=1 ;;
    e) ENV_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${ENV_FILE:=$SCRIPT_DIR/.env}"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "Warning: env file not found at $ENV_FILE; using defaults or CLI overrides."
fi

: "${COPILOT_SKILLS_DEST:=$HOME/.copilot/skills}"
: "${SKILLS_LIST_FILE:=""}"
: "${SKILLS_DIRS:=""}"

OVERRIDE_LIST=""
if [ $# -ge 1 ]; then
  OVERRIDE_LIST="$1"
fi

# Helper to trim whitespace
_trim() { printf '%s' "$1" | awk '{$1=$1;print}'; }

# Build SKILLS array
SKILLS=()
if [ -n "$OVERRIDE_LIST" ]; then
  if [ ! -f "$OVERRIDE_LIST" ]; then
    echo "Override list file not found: $OVERRIDE_LIST" >&2
    exit 1
  fi
  SKILLS=()
  while IFS= read -r line; do
    SKILLS+=("$line")
  done < <(grep -v '^\s*$' "$OVERRIDE_LIST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
elif [ -n "$SKILLS_LIST_FILE" ] && [ -f "$SKILLS_LIST_FILE" ]; then
  SKILLS=()
  while IFS= read -r line; do
    SKILLS+=("$line")
  done < <(grep -v '^\s*$' "$SKILLS_LIST_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
elif [ -n "$SKILLS_DIRS" ]; then
  # accept comma or colon separated lists
  normalized="${SKILLS_DIRS//,/\:}"
  IFS=':' read -r -a raw <<< "$normalized"
  for item in "${raw[@]}"; do
    item="$(_trim "$item")"
    [ -n "$item" ] && SKILLS+=("$item")
  done
else
  echo "No skills defined. Set SKILLS_LIST_FILE or SKILLS_DIRS in $ENV_FILE, or pass a list file override." >&2
  exit 1
fi

mkdir -p "$COPILOT_SKILLS_DEST"
echo "Destination: $COPILOT_SKILLS_DEST"

for src in "${SKILLS[@]}"; do
  src="${src%/}"
  [ -z "${src// }" ] && continue
  # Expand leading ~
  src="${src/#\~/$HOME}"

  if [ ! -e "$src" ]; then
    echo "Source not found, skipping: $src"
    continue
  fi

  name="$(basename "$src")"
  tgt="$COPILOT_SKILLS_DEST/$name"

  if [ -L "$tgt" ]; then
    current="$(readlink "$tgt")"
    if [ "$current" = "$src" ]; then
      echo "OK (exists): $tgt -> $current"
      continue
    else
      if [ "$FORCE" -eq 1 ]; then
        echo "Replacing symlink $tgt (was -> $current) with -> $src"
        [ "$DRY_RUN" -eq 0 ] && rm "$tgt"
      else
        echo "Conflict (symlink points to $current). Use -f to replace: $tgt"
        continue
      fi
    fi
  elif [ -e "$tgt" ]; then
    if [ "$FORCE" -eq 1 ]; then
      echo "Removing existing file/dir $tgt (force) and creating symlink -> $src"
      [ "$DRY_RUN" -eq 0 ] && rm -rf "$tgt"
    else
      echo "Target exists (not symlink): $tgt. Use -f to overwrite."
      continue
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY-RUN: ln -s \"$src\" \"$tgt\""
  else
    ln -s "$src" "$tgt"
    echo "Linked: $tgt -> $src"
  fi
done