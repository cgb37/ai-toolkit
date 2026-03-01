#!/usr/bin/env bash

################################################################################
# Bash Project Scaffold Generator
#
# Description:
#   Generates a complete, standardized bash project structure with best
#   practices, documentation, testing, logging, and release management.
#
# Usage:
#   ./create_bash_project.sh [PROJECT_NAME] [OPTIONS]
#
# Options:
#   -n, --name NAME        Project name (required if not first argument)
#   -d, --directory DIR    Output directory (default: current directory)
#   -o, --org ORG         GitHub organization/user (default: current user)
#   -p, --private         Create private repository (default: public)
#   -h, --help            Display this help message
#
# Examples:
#   ./create_bash_project.sh my-project
#   ./create_bash_project.sh --name my-tool --org my-company --private
#
# Author: Bash Project Scaffold Skill
# Version: 1.0.0
################################################################################

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

################################################################################
# Validation Functions
################################################################################

validate_project_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z0-9_-]+$ ]]; then
        log_error "Invalid project name. Use only lowercase letters, numbers, hyphens, and underscores."
        exit 1
    fi
}

################################################################################
# File Generation Functions
################################################################################

create_directory_structure() {
    local project_dir="$1"
    
    log_info "Creating directory structure..."
    
    mkdir -p "$project_dir"/{scripts/lib,docs,tests,logs}
    touch "$project_dir/logs/.gitkeep"
    
    log_success "Directory structure created"
}

generate_env_example() {
    local project_dir="$1"
    local project_name="$2"
    
    cat > "$project_dir/.env.example" <<'EOF'
# Project Configuration
PROJECT_NAME=my-project
PROJECT_VERSION=1.0.0
ENVIRONMENT=development

# Logging Configuration
LOG_LEVEL=INFO
LOG_DIR=./logs
LOG_MAX_SIZE=10485760  # 10MB in bytes
LOG_RETENTION_DAYS=14

# GitHub Configuration (for git_setup.sh)
GITHUB_ORG=your-org-or-username
GITHUB_REPO=your-repo-name
GITHUB_VISIBILITY=public  # public or private
GITHUB_TOKEN=  # Optional: gh CLI uses its own auth by default

# Script Paths (override if needed)
SCRIPT_DIR=./scripts
OUTPUT_DIR=./output
TEMP_DIR=/tmp

# Feature Flags
DEBUG_MODE=false
DRY_RUN=false
EOF

    # Create actual .env from example
    sed "s/my-project/$project_name/g" "$project_dir/.env.example" > "$project_dir/.env"
    
    log_success "Created .env.example and .env"
}

generate_gitignore() {
    local project_dir="$1"
    
    cat > "$project_dir/.gitignore" <<'EOF'
# Environment and Configuration
.env
.config

# Logs
logs/*.log
*.log

# Node modules
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Output and temporary files
output/
tmp/
temp/
*.tmp

# JetBrains IDEs
.idea/
*.iml
*.iws
*.ipr

# Visual Studio Code
.vscode/
*.code-workspace

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Linux
*~
.directory

# Backup files
*.bak
*.backup
*.swp
*.swo

# Release artifacts
dist/
build/
*.tar.gz
*.zip
EOF

    log_success "Created .gitignore"
}

generate_package_json() {
    local project_dir="$1"
    local project_name="$2"
    
    cat > "$project_dir/package.json" <<EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "A standardized bash script project",
  "scripts": {
    "start": "bash scripts/example_script.sh",
    "test": "bash tests/test_example.sh",
    "release": "release-it",
    "release:patch": "release-it patch",
    "release:minor": "release-it minor",
    "release:major": "release-it major",
    "release:dry": "release-it --dry-run"
  },
  "keywords": [
    "bash",
    "automation",
    "scripting"
  ],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@release-it/conventional-changelog": "^10.0.5",
    "release-it": "^19.2.4"
  }
}
EOF

    log_success "Created package.json"
}

generate_release_it_config() {
    local project_dir="$1"
    
    cat > "$project_dir/.release-it.json" <<'EOF'
{
  "git": {
    "commitMessage": "chore(release): ${version}",
    "tagName": "v${version}",
    "requireBranch": "main",
    "requireCleanWorkingDir": true
  },
  "github": {
    "release": true,
    "releaseName": "Release ${version}"
  },
  "npm": {
    "publish": false
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": {
        "name": "conventionalcommits"
      },
      "infile": "CHANGELOG.md"
    }
  }
}
EOF

    log_success "Created .release-it.json"
}

generate_logging_lib() {
    local project_dir="$1"
    
    cat > "$project_dir/scripts/lib/logging.sh" <<'EOF'
#!/usr/bin/env bash

################################################################################
# Logging Library
#
# Description:
#   Provides color-coded logging with levels, timestamps, and log rotation.
#   Source this file to use logging functions in your scripts.
#
# Usage:
#   source "$(dirname "$0")/lib/logging.sh"
#   log_info "Application started"
#   log_error "Something went wrong"
#
# Log Levels:
#   DEBUG, INFO, WARN, ERROR, CRITICAL
#
# Environment Variables:
#   LOG_LEVEL          - Minimum level to log (default: INFO)
#   LOG_DIR            - Directory for log files (default: ./logs)
#   LOG_MAX_SIZE       - Max size in bytes before rotation (default: 10485760)
#   LOG_RETENTION_DAYS - Days to keep old logs (default: 14)
################################################################################

# Color definitions
readonly LOG_COLOR_DEBUG='\033[0;36m'    # Cyan
readonly LOG_COLOR_INFO='\033[0;34m'     # Blue
readonly LOG_COLOR_WARN='\033[1;33m'     # Yellow
readonly LOG_COLOR_ERROR='\033[0;31m'    # Red
readonly LOG_COLOR_CRITICAL='\033[1;35m' # Magenta
readonly LOG_COLOR_RESET='\033[0m'

# Log level priority
declare -A LOG_LEVEL_PRIORITY=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [CRITICAL]=4
)

# Configuration (with defaults)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_DIR="${LOG_DIR:-./logs}"
LOG_MAX_SIZE="${LOG_MAX_SIZE:-10485760}"  # 10MB
LOG_RETENTION_DAYS="${LOG_RETENTION_DAYS:-14}"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Get current log file
get_log_file() {
    local script_name
    script_name="$(basename "$0" .sh)"
    echo "${LOG_DIR}/${script_name}.log"
}

# Check if log file needs rotation
rotate_log_if_needed() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    local file_size
    file_size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo 0)
    
    if [[ "$file_size" -ge "$LOG_MAX_SIZE" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$log_file" "${log_file}.${timestamp}"
        log_info "Log rotated: ${log_file}.${timestamp}"
    fi
}

# Clean old log files
clean_old_logs() {
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +"$LOG_RETENTION_DAYS" -delete 2>/dev/null || true
}

# Generic log function
_log() {
    local level="$1"
    local color="$2"
    shift 2
    local message="$*"
    
    # Check if we should log this level
    local current_priority="${LOG_LEVEL_PRIORITY[$LOG_LEVEL]:-1}"
    local message_priority="${LOG_LEVEL_PRIORITY[$level]:-1}"
    
    if [[ "$message_priority" -lt "$current_priority" ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local log_file
    log_file=$(get_log_file)
    
    # Rotate if needed
    rotate_log_if_needed "$log_file"
    
    # Console output (colored)
    echo -e "${color}[${level}]${LOG_COLOR_RESET} ${message}"
    
    # File output (no colors)
    echo "[${timestamp}] [${level}] ${message}" >> "$log_file"
    
    # Clean old logs periodically (only for ERROR and CRITICAL to avoid overhead)
    if [[ "$level" == "ERROR" ]] || [[ "$level" == "CRITICAL" ]]; then
        clean_old_logs
    fi
}

# Public logging functions
log_debug() {
    _log "DEBUG" "$LOG_COLOR_DEBUG" "$@"
}

log_info() {
    _log "INFO" "$LOG_COLOR_INFO" "$@"
}

log_warn() {
    _log "WARN" "$LOG_COLOR_WARN" "$@"
}

log_error() {
    _log "ERROR" "$LOG_COLOR_ERROR" "$@" >&2
}

log_critical() {
    _log "CRITICAL" "$LOG_COLOR_CRITICAL" "$@" >&2
}

# Export functions
export -f log_debug log_info log_warn log_error log_critical
EOF

    chmod +x "$project_dir/scripts/lib/logging.sh"
    log_success "Created scripts/lib/logging.sh"
}

generate_example_script() {
    local project_dir="$1"
    local project_name="$2"
    
    cat > "$project_dir/scripts/example_script.sh" <<'EOF'
#!/usr/bin/env bash

################################################################################
# Example Script
#
# Description:
#   Demonstrates the bash-project-scaffold features and best practices.
#   This script showcases:
#   - Description block with metadata
#   - Help output with usage examples
#   - Proper error handling with set -euo pipefail
#   - Color-coded logging using the logging library
#   - Environment variable usage (no hardcoded paths)
#   - Argument parsing
#   - Validation functions
#
# Usage:
#   ./example_script.sh [OPTIONS]
#
# Options:
#   -i, --input FILE      Input file to process
#   -o, --output FILE     Output file path
#   -v, --verbose         Enable verbose/debug output
#   -h, --help            Display this help message
#
# Examples:
#   ./example_script.sh --input data.txt --output result.txt
#   ./example_script.sh -i input.csv -o output.csv --verbose
#
# Environment Variables:
#   OUTPUT_DIR            Default output directory (default: ./output)
#   DEBUG_MODE            Enable debug mode (default: false)
#
# Author: Bash Project Scaffold
# Version: 1.0.0
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging library
# shellcheck source=lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

# Load environment variables if .env exists
if [[ -f "$SCRIPT_DIR/../.env" ]]; then
    # shellcheck source=../.env
    set -a
    source "$SCRIPT_DIR/../.env"
    set +a
fi

################################################################################
# Configuration
################################################################################

OUTPUT_DIR="${OUTPUT_DIR:-./output}"
DEBUG_MODE="${DEBUG_MODE:-false}"

# Script-specific defaults
INPUT_FILE=""
OUTPUT_FILE=""
VERBOSE=false

################################################################################
# Functions
################################################################################

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

validate_input_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log_error "Input file does not exist: $file"
        exit 1
    fi
    
    if [[ ! -r "$file" ]]; then
        log_error "Input file is not readable: $file"
        exit 1
    fi
    
    log_debug "Input file validated: $file"
}

process_file() {
    local input="$1"
    local output="$2"
    
    log_info "Processing file: $input"
    log_debug "Output will be written to: $output"
    
    # Ensure output directory exists
    local output_dir
    output_dir="$(dirname "$output")"
    mkdir -p "$output_dir"
    
    # Example processing: count lines, words, and characters
    local line_count word_count char_count
    line_count=$(wc -l < "$input")
    word_count=$(wc -w < "$input")
    char_count=$(wc -c < "$input")
    
    log_info "Statistics - Lines: $line_count, Words: $word_count, Characters: $char_count"
    
    # Write results to output file
    cat > "$output" <<RESULT
File Processing Report
======================
Input File: $input
Processed: $(date)

Statistics:
- Lines: $line_count
- Words: $word_count
- Characters: $char_count

This is an example output from the bash-project-scaffold skill.
RESULT

    log_success "Processing complete! Output written to: $output"
}

################################################################################
# Argument Parsing
################################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                INPUT_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

################################################################################
# Main Function
################################################################################

main() {
    log_info "Starting example_script.sh"
    log_debug "Debug mode: $DEBUG_MODE"
    
    # Validate required arguments
    if [[ -z "$INPUT_FILE" ]]; then
        log_error "Input file is required. Use --input FILE"
        show_help
    fi
    
    # Set default output if not provided
    if [[ -z "$OUTPUT_FILE" ]]; then
        OUTPUT_FILE="${OUTPUT_DIR}/result.txt"
        log_warn "No output file specified, using default: $OUTPUT_FILE"
    fi
    
    # Validate input file
    validate_input_file "$INPUT_FILE"
    
    # Process the file
    process_file "$INPUT_FILE" "$OUTPUT_FILE"
    
    log_success "Script completed successfully!"
}

################################################################################
# Entry Point
################################################################################

# Parse command-line arguments
parse_arguments "$@"

# Run main function
main
EOF

    chmod +x "$project_dir/scripts/example_script.sh"
    log_success "Created scripts/example_script.sh"
}

generate_git_setup_script() {
    local project_dir="$1"
    
    cat > "$project_dir/scripts/git_setup.sh" <<'EOF'
#!/usr/bin/env bash

################################################################################
# Git Repository Setup Script
#
# Description:
#   Automates GitHub repository creation using the GitHub CLI (gh).
#   Supports both interactive and automated modes.
#   Creates repo, initializes git, and pushes with conventional commit.
#
# Usage:
#   ./git_setup.sh [OPTIONS]
#
# Options:
#   -o, --org ORG         GitHub organization/user (default: from .env or current user)
#   -r, --repo REPO       Repository name (default: from .env or directory name)
#   -p, --private         Create private repository (default: public)
#   -i, --interactive     Interactive mode (prompts for values)
#   -h, --help            Display this help message
#
# Examples:
#   ./git_setup.sh --interactive
#   ./git_setup.sh --org mycompany --repo my-tool --private
#   ./git_setup.sh  # Uses .env configuration
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Git installed
#   - GITHUB_TOKEN or gh auth login completed
#
# Author: Bash Project Scaffold
# Version: 1.0.0
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source logging library
# shellcheck source=lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

# Load environment variables if .env exists
if [[ -f "$PROJECT_DIR/.env" ]]; then
    # shellcheck source=../.env
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

################################################################################
# Configuration
################################################################################

GITHUB_ORG="${GITHUB_ORG:-}"
GITHUB_REPO="${GITHUB_REPO:-}"
GITHUB_VISIBILITY="${GITHUB_VISIBILITY:-public}"
INTERACTIVE_MODE=false

################################################################################
# Functions
################################################################################

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

check_requirements() {
    log_info "Checking requirements..."
    
    # Check for git
    if ! command -v git &> /dev/null; then
        log_error "git is not installed. Please install git first."
        exit 1
    fi
    
    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed."
        log_error "Install from: https://cli.github.com/"
        exit 1
    fi
    
    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated."
        log_error "Run: gh auth login"
        exit 1
    fi
    
    log_success "All requirements met"
}

prompt_interactive() {
    log_info "Interactive mode - please provide repository details"
    
    # Get organization/user
    local default_org
    default_org=$(gh api user --jq '.login' 2>/dev/null || echo "")
    read -rp "GitHub organization/user [$default_org]: " GITHUB_ORG
    GITHUB_ORG="${GITHUB_ORG:-$default_org}"
    
    # Get repository name
    local default_repo
    default_repo=$(basename "$PROJECT_DIR")
    read -rp "Repository name [$default_repo]: " GITHUB_REPO
    GITHUB_REPO="${GITHUB_REPO:-$default_repo}"
    
    # Get visibility
    read -rp "Repository visibility (public/private) [public]: " GITHUB_VISIBILITY
    GITHUB_VISIBILITY="${GITHUB_VISIBILITY:-public}"
    
    log_info "Configuration:"
    log_info "  Organization: $GITHUB_ORG"
    log_info "  Repository: $GITHUB_REPO"
    log_info "  Visibility: $GITHUB_VISIBILITY"
    
    read -rp "Proceed with these settings? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_warn "Setup cancelled by user"
        exit 0
    fi
}

validate_config() {
    if [[ -z "$GITHUB_ORG" ]]; then
        GITHUB_ORG=$(gh api user --jq '.login' 2>/dev/null || echo "")
    fi
    
    if [[ -z "$GITHUB_REPO" ]]; then
        GITHUB_REPO=$(basename "$PROJECT_DIR")
    fi
    
    if [[ -z "$GITHUB_ORG" ]] || [[ -z "$GITHUB_REPO" ]]; then
        log_error "Repository organization and name are required."
        log_error "Use --interactive mode or set GITHUB_ORG and GITHUB_REPO in .env"
        exit 1
    fi
    
    # Validate visibility
    if [[ "$GITHUB_VISIBILITY" != "public" ]] && [[ "$GITHUB_VISIBILITY" != "private" ]]; then
        log_error "Invalid visibility: $GITHUB_VISIBILITY (must be 'public' or 'private')"
        exit 1
    fi
}

initialize_git() {
    log_info "Initializing git repository..."
    
    cd "$PROJECT_DIR"
    
    # Initialize git if not already initialized
    if [[ ! -d .git ]]; then
        git init -b main
        log_success "Git initialized with main branch"
    else
        log_info "Git already initialized"
    fi
    
    # Add all files
    git add .
    
    # Create initial commit with conventional format
    git commit -m "chore: initial commit - bash project scaffold" || log_info "Nothing to commit"
}

create_github_repo() {
    log_info "Creating GitHub repository: $GITHUB_ORG/$GITHUB_REPO"
    
    local visibility_flag
    if [[ "$GITHUB_VISIBILITY" == "private" ]]; then
        visibility_flag="--private"
    else
        visibility_flag="--public"
    fi
    
    # Create repository
    if gh repo create "$GITHUB_ORG/$GITHUB_REPO" $visibility_flag --source=. --remote=origin --push; then
        log_success "Repository created successfully!"
        log_info "Repository URL: https://github.com/$GITHUB_ORG/$GITHUB_REPO"
    else
        log_error "Failed to create repository"
        exit 1
    fi
}

################################################################################
# Argument Parsing
################################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--org)
                GITHUB_ORG="$2"
                shift 2
                ;;
            -r|--repo)
                GITHUB_REPO="$2"
                shift 2
                ;;
            -p|--private)
                GITHUB_VISIBILITY="private"
                shift
                ;;
            -i|--interactive)
                INTERACTIVE_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

################################################################################
# Main Function
################################################################################

main() {
    log_info "GitHub Repository Setup"
    log_info "Project directory: $PROJECT_DIR"
    
    # Check requirements
    check_requirements
    
    # Interactive mode
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        prompt_interactive
    fi
    
    # Validate configuration
    validate_config
    
    log_info "Setting up repository with:"
    log_info "  Organization: $GITHUB_ORG"
    log_info "  Repository: $GITHUB_REPO"
    log_info "  Visibility: $GITHUB_VISIBILITY"
    
    # Initialize git
    initialize_git
    
    # Create GitHub repository
    create_github_repo
    
    log_success "Git setup completed successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Make changes to your project"
    log_info "  2. git add <files>"
    log_info "  3. git commit -m 'feat: your feature description'"
    log_info "  4. git push"
}

################################################################################
# Entry Point
################################################################################

parse_arguments "$@"
main
EOF

    chmod +x "$project_dir/scripts/git_setup.sh"
    log_success "Created scripts/git_setup.sh"
}

generate_test_script() {
    local project_dir="$1"
    
    cat > "$project_dir/tests/test_example.sh" <<'EOF'
#!/usr/bin/env bash

################################################################################
# Example Test Script
#
# Description:
#   Basic test framework for bash scripts.
#   Tests the example_script.sh functionality.
#
# Usage:
#   ./test_example.sh
#
# Author: Bash Project Scaffold
# Version: 1.0.0
################################################################################

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get directories
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"
SCRIPT_DIR="$PROJECT_DIR/scripts"

################################################################################
# Test Framework Functions
################################################################################

setup() {
    # Create temp directory for tests
    TEST_TEMP_DIR=$(mktemp -d)
    
    # Create test input file
    echo "This is a test file" > "$TEST_TEMP_DIR/input.txt"
    echo "With multiple lines" >> "$TEST_TEMP_DIR/input.txt"
    echo "For testing purposes" >> "$TEST_TEMP_DIR/input.txt"
}

teardown() {
    # Clean up temp directory
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -f "$file" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} $message"
        echo "  Haystack: $haystack"
        echo "  Needle: $needle"
        return 1
    fi
}

################################################################################
# Test Cases
################################################################################

test_example_script_exists() {
    echo ""
    echo "Testing: example_script.sh exists and is executable"
    assert_file_exists "$SCRIPT_DIR/example_script.sh" "example_script.sh should exist"
    
    if [[ -x "$SCRIPT_DIR/example_script.sh" ]]; then
        echo -e "${GREEN}✓${NC} example_script.sh is executable"
    else
        echo -e "${RED}✗${NC} example_script.sh is not executable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

test_logging_lib_exists() {
    echo ""
    echo "Testing: logging library exists"
    assert_file_exists "$SCRIPT_DIR/lib/logging.sh" "logging.sh should exist"
}

test_example_script_help() {
    echo ""
    echo "Testing: example_script.sh --help"
    
    local help_output
    help_output=$("$SCRIPT_DIR/example_script.sh" --help 2>&1 || true)
    
    assert_contains "$help_output" "Usage:" "Help output should contain Usage"
    assert_contains "$help_output" "Options:" "Help output should contain Options"
}

test_example_script_processing() {
    echo ""
    echo "Testing: example_script.sh file processing"
    
    local output_file="$TEST_TEMP_DIR/output.txt"
    
    # Run script
    "$SCRIPT_DIR/example_script.sh" \
        --input "$TEST_TEMP_DIR/input.txt" \
        --output "$output_file" 2>&1 | head -n 5
    
    # Check output file was created
    assert_file_exists "$output_file" "Output file should be created"
    
    # Check output contains expected content
    if [[ -f "$output_file" ]]; then
        local output_content
        output_content=$(<"$output_file")
        assert_contains "$output_content" "File Processing Report" "Output should contain report header"
        assert_contains "$output_content" "Statistics:" "Output should contain statistics"
    fi
}

################################################################################
# Main Test Runner
################################################################################

run_all_tests() {
    echo "========================================"
    echo "Running Bash Project Scaffold Tests"
    echo "========================================"
    
    setup
    
    # Run all tests
    test_example_script_exists
    test_logging_lib_exists
    test_example_script_help
    test_example_script_processing
    
    teardown
    
    # Print summary
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Tests run: $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run tests
run_all_tests
EOF

    chmod +x "$project_dir/tests/test_example.sh"
    log_success "Created tests/test_example.sh"
}

generate_readme() {
    local project_dir="$1"
    local project_name="$2"
    
    cat > "$project_dir/README.md" <<EOF
# $project_name

> A standardized bash script project with best practices, testing, and automation

## Description

This project was generated using the **bash-project-scaffold** skill, which provides a complete, production-ready structure for bash script projects. It includes proper error handling, colored logging, git automation, release management, and comprehensive documentation.

## Features

- ✅ **Best Practice Scripts**: Snake_case naming, description blocks, help output, error handling
- ✅ **Advanced Logging**: Color-coded logging library with rotation (10MB limit, 14-day retention)
- ✅ **Git Automation**: Automated GitHub repository creation using gh CLI
- ✅ **Release Management**: Semantic versioning with release-it and conventional changelog
- ✅ **Testing Framework**: Example test structure with assertion helpers
- ✅ **No Hardcoded Paths**: All paths use environment variables for portability
- ✅ **Comprehensive Documentation**: README, cheatsheet, and inline docs

## Project Structure

\`\`\`
$project_name/
├── .env.example          # Environment configuration template
├── .env                  # Local environment configuration (git-ignored)
├── .gitignore           # Comprehensive gitignore (IDEs, OS, logs)
├── .release-it.json     # Release automation configuration
├── package.json         # NPM scripts and dependencies
├── README.md            # This file
├── scripts/
│   ├── example_script.sh    # Example script demonstrating features
│   ├── git_setup.sh         # GitHub repository setup automation
│   └── lib/
│       └── logging.sh       # Reusable logging library
├── docs/
│   └── CHEATSHEET.md       # Quick reference guide
├── tests/
│   └── test_example.sh     # Example test suite
└── logs/
    └── .gitkeep            # Log directory (git-tracked but empty)
\`\`\`

## Setup

### Prerequisites

- **Bash 4.0+** - Modern bash shell
- **Git** - Version control
- **GitHub CLI (gh)** - For repository automation (optional)
- **Node.js/npm** - For release management (optional)

### Installation

1. **Clone or create the repository**:
   \`\`\`bash
   # If not already in a git repository
   git clone <your-repo-url>
   cd $project_name
   \`\`\`

2. **Configure environment**:
   \`\`\`bash
   # Copy example environment file
   cp .env.example .env
   
   # Edit .env with your configuration
   vim .env  # or your preferred editor
   \`\`\`

3. **Install Node.js dependencies** (for release management):
   \`\`\`bash
   npm install
   \`\`\`

4. **Make scripts executable**:
   \`\`\`bash
   chmod +x scripts/*.sh
   chmod +x scripts/lib/*.sh
   chmod +x tests/*.sh
   \`\`\`

## Usage

### Running Scripts

**Example Script** - Demonstrates project features:
\`\`\`bash
# Basic usage
./scripts/example_script.sh --input data.txt --output result.txt

# With verbose logging
./scripts/example_script.sh -i input.csv -o output.csv --verbose

# View help
./scripts/example_script.sh --help
\`\`\`

**Git Setup** - Create GitHub repository:
\`\`\`bash
# Interactive mode (prompts for input)
./scripts/git_setup.sh --interactive

# Automated mode (uses .env configuration)
./scripts/git_setup.sh

# Custom configuration
./scripts/git_setup.sh --org mycompany --repo my-tool --private
\`\`\`

### Testing

Run the test suite:
\`\`\`bash
# Run all tests
npm test
# or
./tests/test_example.sh
\`\`\`

### Release Management

Create new releases with conventional changelog:
\`\`\`bash
# Patch release (1.0.0 -> 1.0.1)
npm run release:patch

# Minor release (1.0.0 -> 1.1.0)
npm run release:minor

# Major release (1.0.0 -> 2.0.0)
npm run release:major

# Dry run (test without creating release)
npm run release:dry
\`\`\`

## Environment Configuration

Edit \`.env\` to customize:

| Variable | Description | Default |
|----------|-------------|---------|
| \`PROJECT_NAME\` | Project identifier | $project_name |
| \`LOG_LEVEL\` | Logging level (DEBUG/INFO/WARN/ERROR/CRITICAL) | INFO |
| \`LOG_DIR\` | Log file directory | ./logs |
| \`LOG_MAX_SIZE\` | Max log file size before rotation (bytes) | 10485760 (10MB) |
| \`LOG_RETENTION_DAYS\` | Days to keep old log files | 14 |
| \`GITHUB_ORG\` | GitHub organization/username | - |
| \`GITHUB_REPO\` | Repository name | - |
| \`GITHUB_VISIBILITY\` | Repository visibility (public/private) | public |

## Logging

All scripts use the centralized logging library:

\`\`\`bash
# Source the logging library
source "\$(dirname "\$0")/lib/logging.sh"

# Use logging functions
log_debug "Detailed debug information"
log_info "General information"
log_warn "Warning messages"
log_error "Error messages"
log_critical "Critical failures"
\`\`\`

**Features**:
- Color-coded console output
- Automatic file logging with timestamps
- Log rotation at 10MB
- 14-day retention policy
- Configurable log levels

## Development

### Adding New Scripts

1. Create script in \`scripts/\` directory
2. Follow naming convention: \`do_something.sh\`
3. Include description block with metadata
4. Add help function with \`--help\` flag
5. Use \`set -euo pipefail\` for error handling
6. Source logging library for consistent output
7. Use environment variables (no hardcoded paths)
8. Make executable: \`chmod +x scripts/your_script.sh\`

### Best Practices

- **Error Handling**: Use \`set -euo pipefail\` at script start
- **Logging**: Always use logging library functions
- **Paths**: Never hardcode paths - use environment variables
- **Documentation**: Include description block and help output
- **Testing**: Add tests to \`tests/\` directory
- **Commits**: Use conventional commits (feat:, fix:, chore:, etc.)
- **Validation**: Validate inputs and provide helpful error messages

## Contributing

1. Create a feature branch: \`git checkout -b feat/my-feature\`
2. Make your changes following best practices
3. Add tests for new functionality
4. Commit using conventional commits: \`git commit -m "feat: add new feature"\`
5. Push and create a pull request

### Conventional Commit Format

\`\`\`
<type>(<scope>): <subject>

<body>

<footer>
\`\`\`

**Types**: feat, fix, docs, style, refactor, test, chore

## Troubleshooting

### GitHub CLI Authentication

\`\`\`bash
# Check authentication status
gh auth status

# Login to GitHub
gh auth login
\`\`\`

### Log Files Growing Too Large

Logs automatically rotate at 10MB and clean after 14 days. To adjust:
\`\`\`bash
# Edit .env
LOG_MAX_SIZE=5242880  # 5MB
LOG_RETENTION_DAYS=7   # 1 week
\`\`\`

### Script Permission Denied

\`\`\`bash
# Make all scripts executable
find scripts -name "*.sh" -exec chmod +x {} \;
find tests -name "*.sh" -exec chmod +x {} \;
\`\`\`

## License

MIT

## Support

For issues or questions:
- Check the [Cheatsheet](docs/CHEATSHEET.md) for quick reference
- Review example scripts for usage patterns
- Open an issue in the repository

---

Generated by **bash-project-scaffold** v1.0.0
EOF

    log_success "Created README.md"
}

generate_cheatsheet() {
    local project_dir="$1"
    local project_name="$2"
    
    cat > "$project_dir/docs/CHEATSHEET.md" <<EOF
# $project_name - Quick Reference Cheatsheet

## Common Commands

### Running Scripts

\`\`\`bash
# Example script with input/output
./scripts/example_script.sh -i input.txt -o output.txt

# Verbose/debug mode
./scripts/example_script.sh -i data.csv -o result.csv --verbose

# View help for any script
./scripts/example_script.sh --help
\`\`\`

### Git Operations

\`\`\`bash
# Setup GitHub repository (interactive)
./scripts/git_setup.sh --interactive

# Setup with specific configuration
./scripts/git_setup.sh --org myorg --repo myrepo --private

# Standard git workflow
git add .
git commit -m "feat: add new feature"
git push
\`\`\`

### Testing

\`\`\`bash
# Run all tests
npm test
# or
./tests/test_example.sh
\`\`\`

### Release Management

\`\`\`bash
# Create patch release (1.0.0 -> 1.0.1)
npm run release:patch

# Create minor release (1.0.0 -> 1.1.0)
npm run release:minor

# Create major release (1.0.0 -> 2.0.0)
npm run release:major

# Test release without publishing
npm run release:dry
\`\`\`

## Logging

### Using the Logging Library

\`\`\`bash
# Source logging in your script
source "\$(dirname "\$0")/lib/logging.sh"

# Log at different levels
log_debug "Detailed debugging info"
log_info "General information"
log_warn "Warning message"
log_error "Error occurred"
log_critical "Critical failure"
\`\`\`

### Log Levels

| Level | Use Case | Color |
|-------|----------|-------|
| DEBUG | Detailed debugging information | Cyan |
| INFO | General informational messages | Blue |
| WARN | Warning messages | Yellow |
| ERROR | Error messages | Red |
| CRITICAL | Critical failures | Magenta |

### Log Configuration

\`\`\`bash
# Set in .env file
LOG_LEVEL=INFO              # Minimum level to log
LOG_DIR=./logs              # Log directory
LOG_MAX_SIZE=10485760       # 10MB max file size
LOG_RETENTION_DAYS=14       # Keep logs for 2 weeks
\`\`\`

## Environment Variables

### Core Configuration

\`\`\`bash
PROJECT_NAME=my-project
PROJECT_VERSION=1.0.0
ENVIRONMENT=development
\`\`\`

### Logging

\`\`\`bash
LOG_LEVEL=INFO
LOG_DIR=./logs
LOG_MAX_SIZE=10485760
LOG_RETENTION_DAYS=14
\`\`\`

### GitHub

\`\`\`bash
GITHUB_ORG=your-org
GITHUB_REPO=your-repo
GITHUB_VISIBILITY=public
\`\`\`

### Paths

\`\`\`bash
SCRIPT_DIR=./scripts
OUTPUT_DIR=./output
TEMP_DIR=/tmp
\`\`\`

### Feature Flags

\`\`\`bash
DEBUG_MODE=false
DRY_RUN=false
\`\`\`

## Script Template

### Basic Script Structure

\`\`\`bash
#!/usr/bin/env bash

################################################################################
# Script Name
#
# Description:
#   What this script does
#
# Usage:
#   ./script_name.sh [OPTIONS]
#
# Options:
#   -h, --help    Display help
#
# Author: Your Name
# Version: 1.0.0
################################################################################

set -euo pipefail

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\$SCRIPT_DIR/lib/logging.sh"

# Load .env if exists
if [[ -f "\$SCRIPT_DIR/../.env" ]]; then
    set -a
    source "\$SCRIPT_DIR/../.env"
    set +a
fi

show_help() {
    grep '^#' "\$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

main() {
    log_info "Script started"
    # Your code here
    log_success "Script completed"
}

# Parse arguments
while [[ \$# -gt 0 ]]; do
    case \$1 in
        -h|--help) show_help ;;
        *) log_error "Unknown option: \$1"; exit 1 ;;
    esac
done

main
\`\`\`

## Conventional Commits

### Format

\`\`\`
<type>(<scope>): <subject>

<body>

<footer>
\`\`\`

### Types

| Type | Description |
|------|-------------|
| \`feat\` | New feature |
| \`fix\` | Bug fix |
| \`docs\` | Documentation changes |
| \`style\` | Code style changes (formatting) |
| \`refactor\` | Code refactoring |
| \`test\` | Adding or updating tests |
| \`chore\` | Maintenance tasks |
| \`perf\` | Performance improvements |
| \`ci\` | CI/CD changes |

### Examples

\`\`\`bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve logging rotation issue"
git commit -m "docs: update README with new examples"
git commit -m "chore: update dependencies"
\`\`\`

## Troubleshooting

### Common Issues

**Permission Denied**
\`\`\`bash
chmod +x scripts/*.sh tests/*.sh
\`\`\`

**GitHub CLI Not Authenticated**
\`\`\`bash
gh auth status
gh auth login
\`\`\`

**Logs Not Rotating**
\`\`\`bash
# Check log size
ls -lh logs/

# Manually trigger rotation
# (happens automatically at LOG_MAX_SIZE)
\`\`\`

**Environment Variables Not Loading**
\`\`\`bash
# Ensure .env exists
cp .env.example .env

# Check .env is sourced in script
source "\$SCRIPT_DIR/../.env"
\`\`\`

## File Locations

| Path | Description |
|------|-------------|
| \`scripts/\` | All executable scripts |
| \`scripts/lib/\` | Shared libraries (logging, etc.) |
| \`tests/\` | Test scripts |
| \`logs/\` | Log files (git-ignored) |
| \`docs/\` | Documentation |
| \`.env\` | Local configuration (git-ignored) |
| \`.env.example\` | Configuration template |

## Useful Aliases

Add to your \`~/.bashrc\` or \`~/.zshrc\`:

\`\`\`bash
# Project shortcuts
alias proj-run="./scripts/example_script.sh"
alias proj-test="npm test"
alias proj-release="npm run release:patch"

# Git shortcuts with conventional commits
alias gfeat="git commit -m 'feat: '"
alias gfix="git commit -m 'fix: '"
alias gdocs="git commit -m 'docs: '"
\`\`\`

## Quick Tips

1. **Always validate inputs** before processing
2. **Use logging library** for all output
3. **Never hardcode paths** - use env vars
4. **Follow conventional commits** for changelog
5. **Test before committing** with \`npm test\`
6. **Use --help flags** to see script usage
7. **Check logs** in \`logs/\` directory for debugging
8. **Keep .env updated** when adding new config

---

Generated by **bash-project-scaffold** v1.0.0
EOF

    log_success "Created docs/CHEATSHEET.md"
}

################################################################################
# Main Workflow
################################################################################

main() {
    local project_name=""
    local output_dir="."
    local github_org=""
    local private_repo=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                project_name="$2"
                shift 2
                ;;
            -d|--directory)
                output_dir="$2"
                shift 2
                ;;
            -o|--org)
                github_org="$2"
                shift 2
                ;;
            -p|--private)
                private_repo=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                if [[ -z "$project_name" ]]; then
                    project_name="$1"
                    shift
                else
                    log_error "Unknown option: $1"
                    exit 1
                fi
                ;;
        esac
    done
    
    # Validate project name
    if [[ -z "$project_name" ]]; then
        log_error "Project name is required"
        echo ""
        show_help
    fi
    
    validate_project_name "$project_name"
    
    # Create project directory
    local project_dir="$output_dir/$project_name"
    
    if [[ -d "$project_dir" ]]; then
        log_error "Directory already exists: $project_dir"
        exit 1
    fi
    
    log_info "Creating bash project: $project_name"
    log_info "Output directory: $project_dir"
    echo ""
    
    # Generate project structure
    create_directory_structure "$project_dir"
    generate_env_example "$project_dir" "$project_name"
    generate_gitignore "$project_dir"
    generate_package_json "$project_dir" "$project_name"
    generate_release_it_config "$project_dir"
    generate_logging_lib "$project_dir"
    generate_example_script "$project_dir" "$project_name"
    generate_git_setup_script "$project_dir"
    generate_test_script "$project_dir"
    generate_readme "$project_dir" "$project_name"
    generate_cheatsheet "$project_dir" "$project_name"
    
    echo ""
    log_success "Project created successfully!"
    echo ""
    log_info "Next steps:"
    log_info "  1. cd $project_dir"
    log_info "  2. Review and edit .env configuration"
    log_info "  3. npm install (for release management)"
    log_info "  4. ./scripts/git_setup.sh --interactive (to create GitHub repo)"
    log_info "  5. ./scripts/example_script.sh --help (to see example usage)"
    echo ""
    log_info "Documentation:"
    log_info "  - README: $project_dir/README.md"
    log_info "  - Cheatsheet: $project_dir/docs/CHEATSHEET.md"
    echo ""
}

# Run main function
main "$@"
EOF

    chmod +x "$project_dir/create_bash_project.sh"
    log_success "Created create_bash_project.sh"
}

# Execute the main script
main "$@"
