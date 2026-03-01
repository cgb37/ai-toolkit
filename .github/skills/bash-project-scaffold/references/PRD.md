# Bash Project Scaffold

A comprehensive skill for generating standardized, production-ready bash script projects with best practices, documentation, testing, logging, and automated release management.

## Description

This skill creates a complete bash project structure following industry best practices. It generates a fully-configured project with proper error handling, colored logging, git automation, release management, and comprehensive documentation. Perfect for teams that need consistency across bash script projects and want to follow professional development practices.

## Features

- **Standardized Structure**: Complete project layout with scripts, docs, tests, and config
- **Best Practice Scripts**: Snake_case naming with description blocks, help output, and error handling
- **Advanced Logging**: Color-coded logging library with rotation and retention policies
- **Git Automation**: Automated repository creation using GitHub CLI with conventional commits
- **Release Management**: Integrated release-it with conventional changelog
- **Comprehensive Documentation**: README, cheatsheet, and example scripts
- **Testing Framework**: Test structure with example tests
- **Configuration Management**: .env-based configuration with examples
- **No Hardcoded Paths**: Fully portable scripts using environment variables

## Usage Examples

### Basic Usage
```bash
# Create a new bash project scaffold
Create a new bash project called my-automation-tool

# Generate bash project for data processing
I need a bash project scaffold for processing log files

# Set up standardized bash script project
Generate a bash project structure with all best practices
```

### With Specific Requirements
```bash
# Create project with GitHub repo
Create bash project "api-monitor" and set up a private GitHub repo

# Generate project with custom organization
Build a bash project scaffold for my-company/deployment-scripts
```

## What Gets Generated

### Project Structure
```
project-name/
├── .env.example
├── .gitignore
├── package.json
├── README.md
├── scripts/
│   ├── example_script.sh
│   ├── git_setup.sh
│   └── lib/
│       └── logging.sh
├── docs/
│   └── CHEATSHEET.md
├── tests/
│   └── test_example.sh
└── logs/
    └── .gitkeep
```

### Key Components

- **Main Scripts**: Snake_case naming, description blocks, help output, error handling
- **Logging Library**: INFO, DEBUG, WARN, ERROR, CRITICAL levels with colors and rotation
- **Git Setup**: Automated GitHub repo creation with gh CLI
- **Release Automation**: npm scripts for patch/minor/major releases
- **Documentation**: Comprehensive README with setup, installation, and usage
- **Testing**: Test structure with example test scripts
- **Configuration**: .env with examples for secrets and settings

## Configuration

The skill generates projects with:
- 10MB log rotation limit
- 2-week log retention policy
- Conventional commit enforcement
- Main branch as default
- Support for both public and private repositories

## Requirements

Generated projects require:
- Bash 4.0+
- Git
- GitHub CLI (gh) for repository automation
- Node.js/npm for release management (optional)

## Best Practices Included

- No hardcoded paths (all via environment variables)
- Proper error handling and exit codes
- Color-coded console output for better UX
- Gitignore for common IDEs and OS files
- Conventional commits for changelog generation
- Semantic versioning via release-it
- Comprehensive inline documentation

## Version

1.0.0

## Tags

bash, scripting, automation, scaffold, template, best-practices, logging, git-automation, release-management, devops
