# AI Toolkit

AI Toolkit is a small collection of shell scripts and utilities for developer productivity — tools for managing GitHub labels, creating symlinks for AI skills, generating slugs, and common logging helpers. The repository contains production-ready script patterns generated from the bash-project-scaffold.

Repository: git@github.com:cgb37/ai-toolkit.git

**Quick Links**
- Scripts directory: [scripts](scripts)
- Examples: [scripts/github-label-manager](scripts/github-label-manager), [scripts/slugify](scripts/slugify), [scripts/symlink-ai-skills](scripts/symlink-ai-skills)

**Goals**
- Provide reusable, well-documented bash utilities.
- Demonstrate scaffold patterns: logging, testing, env configuration, and release tooling.

**What's inside**
- `scripts/github-label-manager/` — Manage GitHub labels following conventional commits.
- `scripts/slugify/` — Small utility to convert strings into URL/file-safe slugs.
- `scripts/symlink-ai-skills/` — Create symlinks for local skill repositories into target skill folders.
- `scripts/base/logging/` — Centralized logging helpers used by other scripts.
- `tests/` — Example test scripts for verifying behavior.

**Skills & Agents**

This repository also includes conventions and example content for AI "skills" and agent configurations used by tooling and extensions.

- `.github/skills/` — Skill packages and templates. Each skill is a self-contained folder with a required `SKILL.md` (YAML frontmatter plus workflow/instructions) and optional subfolders:
	- `scripts/` — executable helpers for the skill
	- `references/` — larger docs or schemas loaded on-demand
	- `assets/` — templates or static files packaged with the skill
	Skills can be packaged as `.skill` (zip) files for distribution; follow the `SKILL.md` format and include examples and tests where appropriate.

- `.github/agents/` — Agent configuration and customization files. Use this folder to store agent instruction files, agent profiles, and related metadata used by local tooling or CI to run automated agents. Typical files include instruction fragments (`*.instructions.md`), agent manifests (`*.agent.md`), and prompt templates.

Guidelines for adding or updating skills/agents:
- Create or update `SKILL.md` with clear YAML frontmatter (`name`, `description`) and a concise usage workflow.
- Keep `SKILL.md` focused (<= 500 lines); move heavy reference material into `references/`.
- Add small executable scripts in `scripts/` and include basic tests in `tests/` where applicable.
- Avoid embedding secrets in `.env` or skill assets; provide `.env.example` when configuration is required.
- When changing agent instruction files, prefer small, testable edits and include notes about intended triggers or use-cases.

See `.github/skills/skill-creator/` for a template and packaging helpers used in this repo.

**Quick Start**
1. Clone the repo:

	git clone git@github.com:cgb37/ai-toolkit.git
	cd ai-toolkit

2. Make scripts executable:

	find scripts -name "*.sh" -exec chmod +x {} \;

3. Try a small example (slugify):

	./scripts/slugify/slugify.sh "Hello World"

4. See each tool's README for detailed setup and usage:

- `scripts/github-label-manager/README.md` — label management and examples
- `scripts/symlink-ai-skills/README.md` — symlink helper and .env options

**Testing**
- Many subprojects include lightweight bash tests; run them directly, for example:

  ./scripts/github-label-manager/tests/test_github_label_manager.sh

**Development notes**
- Use `set -euo pipefail` and the provided logging helpers for consistent behavior.
- Keep `.env` files out of source control; example env files are provided where needed.

**Contributing**
- Fork, branch, add tests, and open a PR. Use conventional commits (feat:, fix:, chore:, etc.).

License: MIT


