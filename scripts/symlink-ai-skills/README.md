# symlink-ai-skills.sh

Place this script in your `ai-toolkit` repo and configure a `.env` next to it (use `.env.example`).

## Setup
1. Copy `.env.example` to `.env` and edit values:
```bash
cp .env.example .env
```
2. Make the script executable:
```bash
chmod +x symlink-ai-skills.sh
```

## .env options
- `TARGET_DIRS` : comma- or colon-separated list of destination skill directories (e.g. `$HOME/.copilot/skills:~/.claude/skills`). If unset the script defaults to `$HOME/.copilot/skills`.
- `SKILLS_LIST_FILE` : path to a newline-separated file listing skill paths (preferred).
- `SKILLS_DIRS` : comma- or colon-separated list of skill source directories (alternate).

Additional per-component list files are supported. Provide newline-separated files and set their paths in `.env` or place next to the script:

- `INSTRUCTIONS_LIST_FILE` : list file for `instructions` directories
- `HOOKS_LIST_FILE` : list file for `hooks` directories
- `AGENTS_LIST_FILE` : list file for `agents` directories

Use the `-T` flag to select which components to include (comma-separated). Defaults to all: `skills,instructions,hooks,agents`.

Shared lists tip: list files may contain relative paths. Set `LIST_BASE_DIR` in your `.env` to a common base (defaults to `$HOME`) so lists can be shared between users without hardcoded absolute paths. Example list entries:

- Relative: `Code/VendorRepos/some-skill`  (resolved to `$LIST_BASE_DIR/Code/VendorRepos/some-skill`)
- Absolute: `/Users/alice/Code/some-skill`

Add `LIST_BASE_DIR` to your `.env` or pass it in the environment when running the script.

If both `SKILLS_LIST_FILE` and `SKILLS_DIRS` are set, `SKILLS_LIST_FILE` takes precedence. You may also pass a skills-list file override as a positional argument to the script.

## Generating a skills list
Quick ways to produce a `skill-list.txt` for your vendor repos:

- Basename list (edit to full paths afterwards):
```bash
ls -1 /Users/you/Code/VendorRepos > /path/to/skill-list.txt
# Edit the file to include full paths (or generate with the find command below)
```

- Full-path list (preferred):
```bash
find /Users/you/Code/VendorRepos -maxdepth 1 -mindepth 1 -type d -print > /path/to/skill-list.txt
```

- If you generated basenames and want full paths quickly:
```bash
sed -e 's#^#/Users/you/Code/VendorRepos/#' /path/to/skill-list.txt > /path/to/skill-list-full.txt
```

## Examples / Usage
Dry-run (shows what would be linked into multiple targets):
```bash
./symlink-ai-skills.sh -n -t ".copilot/skills:.claude/skills"
```

Create links:
```bash
./symlink-ai-skills.sh -t ".copilot/skills:.claude/skills"
```

Force overwrite existing targets:
```bash
./symlink-ai-skills.sh -f -t ".copilot/skills:.claude/skills"
```

Override `.env` location:
```bash
./symlink-ai-skills.sh -e /path/to/.env
```

Pass a skills-list file directly (overrides `.env` `SKILLS_LIST_FILE`):
```bash
./symlink-ai-skills.sh /path/to/skill-list.txt
```

## Notes
- After creating symlinks, restart any editor or extension that scans skills to pick up changes (for example, VS Code / Copilot).
- Using symlinks lets vendor repos stay up-to-date without copying files.
- Keep `.env` out of source control if it contains user-specific paths.


ls -1 /Users/charlesbrownroberts/Code/VendorRepos/superpowers/skills | tee -a /Users/charlesbrownroberts/Code/CGB37/ai-toolkit/scripts/symlink-ai-skills/skill-list.txt

ls -1 /Users/charlesbrownroberts/Code/VendorRepos/Anthropic/skills/skills | tee -a /Users/charlesbrownroberts/Code/CGB37/ai-toolkit/scripts/symlink-ai-skills/skill-list.txt