#!/usr/bin/env bash
# symlink-ai-skills.sh
# Symlink skill dirs/files into one or more AI-skills directories (Copilot, Claude, etc.)
set -euo pipefail

DRY_RUN=0
FORCE=0
ENV_FILE=""
TARGETS=""

usage() {
  cat <<EOF
Usage: $0 [-n] [-f] [-e envfile] [-t target_list] [skills_list_file_override]
  -n  dry-run
  -f  force overwrite existing targets
  -e  path to .env (defaults to .env next to this script)
  -t  comma or colon separated list of target skill directories (defaults to \$HOME/.copilot/skills or TARGET_DIRS in .env)
If a positional skills_list_file_override is provided, it overrides any SKILLS_LIST_FILE from .env.
Example: -t ".copilot/skills:.claude/skills"
EOF
  exit 2
}

while getopts "nfe:t:" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    f) FORCE=1 ;;
    e) ENV_FILE="$OPTARG" ;;
    t) TARGETS="$OPTARG" ;;
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

: "${SKILLS_LIST_FILE:=""}"
: "${SKILLS_DIRS:=""}"
: "${TARGET_DIRS:=""}"

OVERRIDE_LIST=""
if [ $# -ge 1 ]; then
  OVERRIDE_LIST="$1"
fi

# Helper to trim whitespace
_trim() { printf '%s' "$1" | awk '{$1=$1;print}'; }

# Build SKILLS array (sources)
SKILLS=()
if [ -n "$OVERRIDE_LIST" ]; then
  if [ ! -f "$OVERRIDE_LIST" ]; then
    echo "Override list file not found: $OVERRIDE_LIST" >&2
    exit 1
  fi
  while IFS= read -r line; do
    SKILLS+=("$line")
  done < <(grep -v '^\s*$' "$OVERRIDE_LIST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
elif [ -n "$SKILLS_LIST_FILE" ] && [ -f "$SKILLS_LIST_FILE" ]; then
  while IFS= read -r line; do
    SKILLS+=("$line")
  done < <(grep -v '^\s*$' "$SKILLS_LIST_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
elif [ -n "$SKILLS_DIRS" ]; then
  normalized="${SKILLS_DIRS//,/:}"
  IFS=':' read -r -a raw <<< "$normalized"
  for item in "${raw[@]}"; do
    item="$(_trim "$item")"
    [ -n "$item" ] && SKILLS+=("$item")
  done
else
  echo "No skills defined. Set SKILLS_LIST_FILE or SKILLS_DIRS in $ENV_FILE, or pass a list file override." >&2
  exit 1
fi

# Build TARGETS array (destinations)
TARGETS_ARRAY=()
if [ -n "$TARGETS" ]; then
  normalized="${TARGETS//,/:}"
  IFS=':' read -r -a rawT <<< "$normalized"
  for item in "${rawT[@]}"; do
    item="$(_trim "$item")"
    [ -n "$item" ] && TARGETS_ARRAY+=("$item")
  done
elif [ -n "$TARGET_DIRS" ]; then
  normalized="${TARGET_DIRS//,/:}"
  IFS=':' read -r -a rawT <<< "$normalized"
  for item in "${rawT[@]}"; do
    item="$(_trim "$item")"
    [ -n "$item" ] && TARGETS_ARRAY+=("$item")
  done
else
  # Default to Copilot skills directory for backward compatibility
  TARGETS_ARRAY=("$HOME/.copilot/skills")
fi

for target in "${TARGETS_ARRAY[@]}"; do
  # Expand ~ and make relative paths go under $HOME
  target="${target/#\~/$HOME}"
  if [ "${target:0:1}" != "/" ]; then
    target="$HOME/${target#./}"
  fi
  mkdir -p "$target"
  echo "Destination: $target"

  for src in "${SKILLS[@]}"; do
    src="${src%/}"
    [ -z "${src// }" ] && continue
    src="${src/#\~/$HOME}"

    if [ ! -e "$src" ]; then
      echo "Source not found, skipping: $src"
      continue
    fi

    name="$(basename "$src")"
    tgt="$target/$name"

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
done
