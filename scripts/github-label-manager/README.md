# GitHub Label Manager

> Manage GitHub repository labels based on conventional commit conventions

## Description

This project provides a command-line tool for managing GitHub repository labels that follow conventional commit standards. It can create, update, delete, and list labels with predefined colors and descriptions for common commit types like `feat`, `fix`, `docs`, etc.

The project was generated using the **bash-project-scaffold** skill, providing a complete, production-ready structure with proper error handling, colored logging, git automation, and comprehensive documentation.

## Features

- ✅ **Conventional Commit Labels**: Predefined labels for all conventional commit types
- ✅ **GitHub API Integration**: Direct API calls to manage repository labels
- ✅ **CRUD Operations**: Create, update, delete, and list labels
- ✅ **Color Coding**: Hex colors for visual distinction
- ✅ **Dry Run Mode**: Test operations without making changes
- ✅ **Environment Configuration**: Secure token management
- ✅ **Best Practice Scripts**: Snake_case naming, description blocks, help output, error handling
- ✅ **Advanced Logging**: Color-coded logging library with rotation (10MB limit, 14-day retention)
- ✅ **Git Automation**: Automated GitHub repository creation using gh CLI
- ✅ **Release Management**: Semantic versioning with release-it and conventional changelog
- ✅ **Testing Framework**: Example test structure with assertion helpers
- ✅ **No Hardcoded Paths**: All paths use environment variables for portability
- ✅ **Comprehensive Documentation**: README, cheatsheet, and inline docs

## Conventional Commit Labels

The script manages the following labels with predefined colors and descriptions:

| Label | Color | Description |
|-------|-------|-------------|
| feat | `#00FF00` | A new feature |
| fix | `#FF0000` | A bug fix |
| docs | `#0000FF` | Documentation only changes |
| style | `#FFFFFF` | Changes that do not affect the meaning of the code |
| refactor | `#FFA500` | Code changes that neither fix a bug nor add a feature |
| test | `#FFFF00` | Adding missing tests or correcting existing tests |
| chore | `#808080` | Changes to the build process or auxiliary tools |
| perf | `#00FF00` | A code change that improves performance |
| ci | `#0000FF` | Changes to CI configuration files and scripts |
| build | `#808080` | Changes that affect the build system or external dependencies |
| revert | `#FFA500` | Reverts a previous commit |
| BREAKING CHANGE | `#FF0000` | Breaking changes |

## Project Structure

```
github-label-manager/
├── .env.example          # Environment configuration template
├── .env                  # Local environment configuration (git-ignored)
├── .gitignore           # Comprehensive gitignore (IDEs, OS, logs)
├── .release-it.json     # Release automation configuration
├── package.json         # NPM scripts and dependencies
├── README.md            # This file
├── scripts/
│   ├── github_label_manager.sh  # Main label management script
│   ├── git_setup.sh             # GitHub repository setup automation
│   └── lib/
│       └── logging.sh           # Reusable logging library
├── docs/
│   └── CHEATSHEET.md           # Quick reference guide
├── tests/
│   └── test_example.sh         # Example test suite
└── logs/
    └── .gitkeep                # Log directory (git-tracked but empty)
```

## Setup

### Prerequisites

- **Bash 4.0+** - Modern bash shell
- **Git** - Version control
- **GitHub CLI (gh)** - For repository automation (optional)
- **Node.js/npm** - For release management (optional)
- **jq** - JSON processor for API responses
- **curl** - HTTP client for GitHub API calls

### Installation

1. **Clone or create the repository**:
   ```bash
   # If not already in a git repository
   git clone <your-repo-url>
   cd github-label-manager
   ```

2. **Configure environment**:
   ```bash
   # Copy example environment file
   cp .env.example .env
   
   # Edit .env with your GitHub configuration
   vim .env  # or your preferred editor
   ```

3. **Install Node.js dependencies** (for release management):
   ```bash
   npm install
   ```

### Installation

1. **Clone or create the repository**:
   ```bash
   # If not already in a git repository
   git clone <your-repo-url>
   cd github-label-manager
   ```

2. **Configure environment**:
   ```bash
   # Copy example environment file
   cp .env.example .env
   
   # Edit .env with your configuration
   vim .env  # or your preferred editor
   ```

3. **Install Node.js dependencies** (for release management):
   ```bash
   npm install
   ```

4. **Make scripts executable**:
   ```bash
   chmod +x scripts/*.sh
   chmod +x scripts/lib/*.sh
   chmod +x tests/*.sh
   ```

## Usage

### Environment Configuration

Before using the script, configure your GitHub credentials:

```bash
# Edit .env file
vim .env

# Required variables:
GITHUB_ORG=your-organization-or-username
GITHUB_REPO=your-repository-name
GITHUB_TOKEN=your_github_personal_access_token
# or
GH_TOKEN=your_github_cli_token
```

### Commands

**Create Labels** - Add all conventional commit labels to your repository:
```bash
# Using environment variables
./scripts/github_label_manager.sh create

# Specifying org/repo explicitly
./scripts/github_label_manager.sh create --org myorg --repo myrepo

# Dry run to see what would be created
./scripts/github_label_manager.sh create --dry-run
```

**Update Labels** - Update existing labels with new colors/descriptions:
```bash
./scripts/github_label_manager.sh update --org myorg --repo myrepo
```

**Delete Labels** - Remove labels from your repository:
```bash
# Delete a specific label
./scripts/github_label_manager.sh delete feat --org myorg --repo myrepo

# Delete all conventional commit labels
./scripts/github_label_manager.sh delete --org myorg --repo myrepo
```

**List Labels** - Display all labels in the repository:
```bash
./scripts/github_label_manager.sh list --org myorg --repo myrepo
```

### Command Line Options

- `-o, --org ORG`: GitHub organization/user (can also set GITHUB_ORG)
- `-r, --repo REPO`: Repository name (can also set GITHUB_REPO)
- `-t, --token TOKEN`: GitHub token (can also set GITHUB_TOKEN or GH_TOKEN)
- `-d, --dry-run`: Show what would be done without making changes
- `-v, --verbose`: Enable verbose/debug output
- `-h, --help`: Display help message

### Examples

```bash
# Create labels for a specific repo
./scripts/github_label_manager.sh create --org mycompany --repo awesome-project

# List all labels with verbose output
./scripts/github_label_manager.sh list --org myorg --repo myrepo --verbose

# Update labels without making changes (dry run)
./scripts/github_label_manager.sh update --dry-run

# Delete the 'feat' label
./scripts/github_label_manager.sh delete feat --org myorg --repo myrepo
```
# Interactive mode (prompts for input)
./scripts/git_setup.sh --interactive

# Automated mode (uses .env configuration)
./scripts/git_setup.sh

# Custom configuration
./scripts/git_setup.sh --org mycompany --repo my-tool --private
```

### Testing

Run the test suite:
```bash
# Run all tests
npm test
# or
./tests/test_example.sh
```

### Release Management

Create new releases with conventional changelog:
```bash
# Patch release (1.0.0 -> 1.0.1)
npm run release:patch

# Minor release (1.0.0 -> 1.1.0)
npm run release:minor

# Major release (1.0.0 -> 2.0.0)
npm run release:major

# Dry run (test without creating release)
npm run release:dry
```

## Environment Configuration

Edit `.env` to customize:

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Project identifier | github-label-manager |
| `LOG_LEVEL` | Logging level (DEBUG/INFO/WARN/ERROR/CRITICAL) | INFO |
| `LOG_DIR` | Log file directory | ./logs |
| `LOG_MAX_SIZE` | Max log file size before rotation (bytes) | 10485760 (10MB) |
| `LOG_RETENTION_DAYS` | Days to keep old log files | 14 |
| `GITHUB_ORG` | GitHub organization/username | - |
| `GITHUB_REPO` | Repository name | - |
| `GITHUB_VISIBILITY` | Repository visibility (public/private) | public |

## Logging

All scripts use the centralized logging library:

```bash
# Source the logging library
source "$(dirname "$0")/lib/logging.sh"

# Use logging functions
log_debug "Detailed debug information"
log_info "General information"
log_warn "Warning messages"
log_error "Error messages"
log_critical "Critical failures"
```

**Features**:
- Color-coded console output
- Automatic file logging with timestamps
- Log rotation at 10MB
- 14-day retention policy
- Configurable log levels

## Development

### Adding New Scripts

1. Create script in `scripts/` directory
2. Follow naming convention: `do_something.sh`
3. Include description block with metadata
4. Add help function with `--help` flag
5. Use `set -euo pipefail` for error handling
6. Source logging library for consistent output
7. Use environment variables (no hardcoded paths)
8. Make executable: `chmod +x scripts/your_script.sh`

### Best Practices

- **Error Handling**: Use `set -euo pipefail` at script start
- **Logging**: Always use logging library functions
- **Paths**: Never hardcode paths - use environment variables
- **Documentation**: Include description block and help output
- **Testing**: Add tests to `tests/` directory
- **Commits**: Use conventional commits (feat:, fix:, chore:, etc.)
- **Validation**: Validate inputs and provide helpful error messages

## Contributing

1. Create a feature branch: `git checkout -b feat/my-feature`
2. Make your changes following best practices
3. Add tests for new functionality
4. Commit using conventional commits: `git commit -m "feat: add new feature"`
5. Push and create a pull request

### Conventional Commit Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: feat, fix, docs, style, refactor, test, chore

## Troubleshooting

### GitHub CLI Authentication

```bash
# Check authentication status
gh auth status

# Login to GitHub
gh auth login
```

### Log Files Growing Too Large

Logs automatically rotate at 10MB and clean after 14 days. To adjust:
```bash
# Edit .env
LOG_MAX_SIZE=5242880  # 5MB
LOG_RETENTION_DAYS=7   # 1 week
```

### Script Permission Denied

```bash
# Make all scripts executable
find scripts -name "*.sh" -exec chmod +x {} \;
find tests -name "*.sh" -exec chmod +x {} \;
```

## License

MIT

## Support

For issues or questions:
- Check the [Cheatsheet](docs/CHEATSHEET.md) for quick reference
- Review example scripts for usage patterns
- Open an issue in the repository

---

Generated by **bash-project-scaffold** v1.0.0
