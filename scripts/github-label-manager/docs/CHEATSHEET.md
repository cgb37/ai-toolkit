# github-label-manager - Quick Reference Cheatsheet

## Common Commands

### Running Scripts

```bash
# Create conventional commit labels
./scripts/github_label_manager.sh create --org myorg --repo myrepo

# List all labels in repository
./scripts/github_label_manager.sh list --org myorg --repo myrepo

# Update existing labels
./scripts/github_label_manager.sh update --org myorg --repo myrepo --dry-run

# Delete a specific label
./scripts/github_label_manager.sh delete feat --org myorg --repo myrepo

# View help for any script
./scripts/github_label_manager.sh --help
```

### Git Operations

```bash
# Setup GitHub repository (interactive)
./scripts/git_setup.sh --interactive

# Setup with specific configuration
./scripts/git_setup.sh --org myorg --repo myrepo --private

# Standard git workflow
git add .
git commit -m "feat: add new feature"
git push
```

### Testing

```bash
# Run all tests
npm test
# or
./tests/test_github_label_manager.sh
```

### Release Management

```bash
# Create patch release (1.0.0 -> 1.0.1)
npm run release:patch

# Create minor release (1.0.0 -> 1.1.0)
npm run release:minor

# Create major release (1.0.0 -> 2.0.0)
npm run release:major

# Test release without publishing
npm run release:dry
```

## Logging

### Using the Logging Library

```bash
# Source logging in your script
source "$(dirname "$0")/lib/logging.sh"

# Log at different levels
log_debug "Detailed debugging info"
log_info "General information"
log_warn "Warning message"
log_error "Error occurred"
log_critical "Critical failure"
```

### Log Levels

| Level | Use Case | Color |
|-------|----------|-------|
| DEBUG | Detailed debugging information | Cyan |
| INFO | General informational messages | Blue |
| WARN | Warning messages | Yellow |
| ERROR | Error messages | Red |
| CRITICAL | Critical failures | Magenta |

### Log Configuration

```bash
# Set in .env file
LOG_LEVEL=INFO              # Minimum level to log
LOG_DIR=./logs              # Log directory
LOG_MAX_SIZE=10485760       # 10MB max file size
LOG_RETENTION_DAYS=14       # Keep logs for 2 weeks
```

## Environment Variables

### Core Configuration

```bash
PROJECT_NAME=my-project
PROJECT_VERSION=1.0.0
ENVIRONMENT=development
```

### Logging

```bash
LOG_LEVEL=INFO
LOG_DIR=./logs
LOG_MAX_SIZE=10485760
LOG_RETENTION_DAYS=14
```

### GitHub

```bash
GITHUB_ORG=your-org
GITHUB_REPO=your-repo
GITHUB_VISIBILITY=public
```

### Paths

```bash
SCRIPT_DIR=./scripts
OUTPUT_DIR=./output
TEMP_DIR=/tmp
```

### Feature Flags

```bash
DEBUG_MODE=false
DRY_RUN=false
```

## Script Template

### Basic Script Structure

```bash
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logging.sh"

# Load .env if exists
if [[ -f "$SCRIPT_DIR/../.env" ]]; then
    set -a
    source "$SCRIPT_DIR/../.env"
    set +a
fi

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

main() {
    log_info "Script started"
    # Your code here
    log_success "Script completed"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

main
```

## Conventional Commits

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting) |
| `refactor` | Code refactoring |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |

### Examples

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve logging rotation issue"
git commit -m "docs: update README with new examples"
git commit -m "chore: update dependencies"
```

## Troubleshooting

### Common Issues

**Permission Denied**
```bash
chmod +x scripts/*.sh tests/*.sh
```

**GitHub CLI Not Authenticated**
```bash
gh auth status
gh auth login
```

**Logs Not Rotating**
```bash
# Check log size
ls -lh logs/

# Manually trigger rotation
# (happens automatically at LOG_MAX_SIZE)
```

**Environment Variables Not Loading**
```bash
# Ensure .env exists
cp .env.example .env

# Check .env is sourced in script
source "$SCRIPT_DIR/../.env"
```

## File Locations

| Path | Description |
|------|-------------|
| `scripts/` | All executable scripts |
| `scripts/lib/` | Shared libraries (logging, etc.) |
| `tests/` | Test scripts |
| `logs/` | Log files (git-ignored) |
| `docs/` | Documentation |
| `.env` | Local configuration (git-ignored) |
| `.env.example` | Configuration template |

## Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Project shortcuts
alias proj-run="./scripts/github_label_manager.sh"
alias proj-test="npm test"
alias proj-release="npm run release:patch"

# Git shortcuts with conventional commits
alias gfeat="git commit -m 'feat: '"
alias gfix="git commit -m 'fix: '"
alias gdocs="git commit -m 'docs: '"
```

## Quick Tips

1. **Always validate inputs** before processing
2. **Use logging library** for all output
3. **Never hardcode paths** - use env vars
4. **Follow conventional commits** for changelog
5. **Test before committing** with `npm test`
6. **Use --help flags** to see script usage
7. **Check logs** in `logs/` directory for debugging
8. **Keep .env updated** when adding new config

---

Generated by **bash-project-scaffold** v1.0.0
