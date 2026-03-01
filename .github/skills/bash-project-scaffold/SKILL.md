---
name: bash-project-scaffold
description: A comprehensive skill for generating standardized, production-ready bash script projects with best practices, documentation, testing, logging, and automated release management. Use when users want to create new bash projects with professional structure, logging, git automation, and release management.
---

# Bash Project Scaffold

Generate standardized, production-ready bash script projects with best practices, documentation, testing, logging, and automated release management.

## Overview

This skill creates complete bash project structures following industry best practices. It generates fully-configured projects with proper error handling, colored logging, git automation, release management, and comprehensive documentation. Perfect for teams needing consistency across bash script projects.

## Usage

Run the scaffold script to create a new bash project:

```bash
./scripts/create_bash_project.sh [PROJECT_NAME] [OPTIONS]
```

### Options
- `-n, --name NAME`: Project name (required if not first argument)
- `-d, --directory DIR`: Output directory (default: current directory)
- `-o, --org ORG`: GitHub organization/user (default: current user)
- `-p, --private`: Create private repository (default: public)
- `-h, --help`: Display help message

### Examples
```bash
# Basic usage
./scripts/create_bash_project.sh my-project

# With GitHub repo
./scripts/create_bash_project.sh --name my-tool --org my-company --private
```

## What Gets Generated

The script creates a complete project structure with:

- **Scripts**: Snake_case naming with description blocks, help output, error handling
- **Logging Library**: Color-coded logging with rotation and retention
- **Git Automation**: Automated repository creation using GitHub CLI
- **Release Management**: Integrated release-it with conventional changelog
- **Documentation**: Comprehensive README, cheatsheet, example scripts
- **Testing**: Test structure with example tests
- **Configuration**: .env-based configuration with examples

## Project Structure

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

## Requirements

Generated projects require:
- Bash 4.0+
- Git
- GitHub CLI (gh) for repository automation
- Node.js/npm for release management (optional)

## Best Practices Included

- No hardcoded paths (environment variables)
- Proper error handling and exit codes
- Color-coded console output
- Gitignore for common IDEs and OS files
- Conventional commits for changelog generation
- Semantic versioning via release-it

## References

See [references/PRD.md](references/PRD.md) for detailed product requirements and features.
