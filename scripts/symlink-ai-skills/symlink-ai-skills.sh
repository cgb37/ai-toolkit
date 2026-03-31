#!/usr/bin/env bash
# symlink-ai-skills.sh
# Symlink skill dirs/files into one or more AI-skills directories (Copilot, Claude, etc.)
set -euo pipefail

DRY_RUN=0
FORCE=0
ENV_FILE=""
TARGETS=""
TYPES_SELECTED=""

usage() {
  cat <<EOF
Usage: $0 [-n] [-f] [-e envfile] [-t target_list] [skills_list_file_override]
  -n  dry-run
  -f  force overwrite existing targets
  -e  path to .env (defaults to .env next to this script)
  -t  comma or colon separated list of target skill directories (defaults to \$HOME/.copilot/skills or TARGET_DIRS in .env)
  -T  comma-separated list of components to include: skills,instructions,hooks,agents (defaults: all)
If a positional skills_list_file_override is provided, it overrides any SKILLS_LIST_FILE from .env.
Example: -t ".copilot/skills:.claude/skills"
EOF
  exit 2
}

while getopts "nfe:t:T:" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    f) FORCE=1 ;;
    e) ENV_FILE="$OPTARG" ;;
    t) TARGETS="$OPTARG" ;;
    T) TYPES_SELECTED="$OPTARG" ;;
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
: "${INSTRUCTIONS_LIST_FILE:=""}"
: "${HOOKS_LIST_FILE:=""}"
: "${AGENTS_LIST_FILE:=""}"
: "${SKILLS_TARGET_DIRS:=""}"
: "${INSTRUCTIONS_TARGET_DIRS:=""}"
: "${HOOKS_TARGET_DIRS:=""}"
: "${AGENTS_TARGET_DIRS:=""}"

# Base directory to resolve relative entries in list files. Defaults to $HOME.
: "${LIST_BASE_DIR:=$HOME}"

OVERRIDE_LIST=""
if [ $# -ge 1 ]; then
  OVERRIDE_LIST="$1"
fi

# Helper to trim whitespace
_trim() { printf '%s' "$1" | awk '{$1=$1;print}'; }

# Determine which components to include
# Use a space-separated list for portability with older bash (macOS)
# Valid components: skills, instructions, hooks, agents
COMPONENTS_ENABLED=""
if [ -z "$TYPES_SELECTED" ]; then
  COMPONENTS_ENABLED="skills instructions hooks agents"
else
  # normalize commas to spaces
  normalized_types="${TYPES_SELECTED//,/ }"
  parts=()
  for p in $normalized_types; do
    p="$(_trim "$p")"
    case "$p" in
      skills|instructions|hooks|agents)
        parts+=("$p") ;;
      *) echo "Unknown component: $p" >&2; exit 1 ;;
    esac
  done
  COMPONENTS_ENABLED="${parts[*]}"
fi

enabled() {
  local want="$1"
  for c in $COMPONENTS_ENABLED; do
    if [ "$c" = "$want" ]; then
      return 0
    fi
  done
  return 1
}

# Build SKILLS array (sources)
SKILLS=()
read_list_file() {
  local listfile="$1"
  local comp="$2" # component: skills|instructions|hooks|agents
  if [ -n "$listfile" ] && [ -f "$listfile" ]; then
    while IFS= read -r line; do
      # Trim
      line="$(printf '%s' "$line" | awk '{$1=$1;print}')"
      # Skip empty or commented lines
      case "$line" in
        ''|\#*) continue ;;
      esac
      # Expand ~
      if [[ "$line" == ~* ]]; then
        line="${line/#\~/$HOME}"
      fi
      # If not absolute path, prefix with LIST_BASE_DIR
      if [[ "$line" != /* ]]; then
        base="${LIST_BASE_DIR/#\~/$HOME}"
        # Remove leading ./ if present
        line="${line#./}"
        line="$base/${line%/}"
      fi
      case "$comp" in
        skills) SKILLS_ITEMS+=("$line") ;;
        instructions) INSTRUCTIONS_ITEMS+=("$line") ;;
        hooks) HOOKS_ITEMS+=("$line") ;;
        agents) AGENTS_ITEMS+=("$line") ;;
      esac
    done < <(grep -v '^\s*$' "$listfile" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  fi
}

# Load lists for enabled components. Positional override only applies to 'skills' list.
SKILLS_ITEMS=()
INSTRUCTIONS_ITEMS=()
HOOKS_ITEMS=()
AGENTS_ITEMS=()

if [ -n "$OVERRIDE_LIST" ]; then
  if [ ! -f "$OVERRIDE_LIST" ]; then
    echo "Override list file not found: $OVERRIDE_LIST" >&2
    exit 1
  fi
  # positional override applies to skills list only
  read_list_file "$OVERRIDE_LIST" skills
else
  if enabled skills; then
    read_list_file "$SKILLS_LIST_FILE" skills
    if [ -n "$SKILLS_DIRS" ]; then
      normalized="${SKILLS_DIRS//,/:}"
      IFS=':' read -r -a raw <<< "$normalized"
      for item in "${raw[@]}"; do
        item="$(_trim "$item")"
        [ -n "$item" ] && SKILLS_ITEMS+=("$item")
      done
    fi
  fi
  if enabled instructions; then
    read_list_file "$INSTRUCTIONS_LIST_FILE" instructions
  fi
  if enabled hooks; then
    read_list_file "$HOOKS_LIST_FILE" hooks
  fi
  if enabled agents; then
    read_list_file "$AGENTS_LIST_FILE" agents
  fi
fi

if [ ${#SKILLS_ITEMS[@]} -eq 0 ] && [ ${#INSTRUCTIONS_ITEMS[@]} -eq 0 ] && [ ${#HOOKS_ITEMS[@]} -eq 0 ] && [ ${#AGENTS_ITEMS[@]} -eq 0 ]; then
  echo "No items defined for selected components. Check your list files or SKILLS_DIRS." >&2
  exit 1
fi

get_targets_for_component() {
  local comp="$1"
  local targets_arg=""
  local envvar=""
  case "$comp" in
    skills) envvar="SKILLS_TARGET_DIRS" ;;
    instructions) envvar="INSTRUCTIONS_TARGET_DIRS" ;;
    hooks) envvar="HOOKS_TARGET_DIRS" ;;
    agents) envvar="AGENTS_TARGET_DIRS" ;;
    *) envvar="TARGET_DIRS" ;;
  esac

  # component-specific env var takes precedence
  targets_arg="${!envvar:-}"
  # If not set, fall back to CLI -t override
  if [ -z "$targets_arg" ]; then
    targets_arg="$TARGETS"
  fi
  # If still not set, fall back to global TARGET_DIRS
  if [ -z "$targets_arg" ]; then
    targets_arg="$TARGET_DIRS"
  fi
  # If still not set, default
  if [ -z "$targets_arg" ]; then
    targets_arg="$HOME/.copilot/skills"
  fi

  # Normalize separators to : then split
  local normalized="${targets_arg//,/:}"
  IFS=':' read -r -a rawT <<< "$normalized"
  local out=()
  for item in "${rawT[@]}"; do
    item="$(_trim "$item")"
    [ -n "$item" ] && out+=("$item")
  done
  printf '%s\n' "${out[@]}"
}

link_item_to_targets() {
  local src="$1"
  shift
  local targets=("$@")
  for target in "${targets[@]}"; do
    # Expand ~ and make relative paths go under $HOME
    target="${target/#\~/$HOME}"
    if [ "${target:0:1}" != "/" ]; then
      target="$HOME/${target#./}"
    fi
    mkdir -p "$target"
    echo "Destination: $target"

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
}

# Iterate enabled components and link their items to their targets
for comp in skills instructions hooks agents; do
  if ! enabled "$comp"; then
    continue
  fi
  # select items array
  case "$comp" in
    skills) items=("${SKILLS_ITEMS[@]:-}") ;;
    instructions) items=("${INSTRUCTIONS_ITEMS[@]:-}") ;;
    hooks) items=("${HOOKS_ITEMS[@]:-}") ;;
    agents) items=("${AGENTS_ITEMS[@]:-}") ;;
  esac
  if [ ${#items[@]} -eq 0 ]; then
    continue
  fi
  # get targets for this component
  comp_targets=()
  while IFS= read -r line; do
    [ -n "$line" ] && comp_targets+=("$line")
  done < <(get_targets_for_component "$comp")
  if [ ${#comp_targets[@]} -eq 0 ]; then
    continue
  fi
  for src in "${items[@]}"; do
    link_item_to_targets "$src" "${comp_targets[@]}"
  done
done
