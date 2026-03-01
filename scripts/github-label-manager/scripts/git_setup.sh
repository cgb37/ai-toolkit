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
