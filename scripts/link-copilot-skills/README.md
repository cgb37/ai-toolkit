# link-copilot-skills.sh

Place this script in your `ai-toolkit` repo and configure a `.env` next to it (use `.env.example`).

## Setup
1. Copy `.env.example` to `.env` and edit values:
```bash
cp .env.example .env
```
2. Make the script executable:
```bash
chmod +x link-copilot-skills.sh
```

## .env options
- `COPILOT_SKILLS_DEST` : destination directory (default `$HOME/.copilot/skills`).
- `SKILLS_LIST_FILE` : path to a newline-separated file listing skill paths (preferred).
- `SKILLS_DIRS` : comma- or colon-separated list of skill paths (alternate).

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
Dry-run (shows what would be linked):
```bash
./link-copilot-skills.sh -n
```

Create links:
```bash
./link-copilot-skills.sh
```

Force overwrite existing targets:
```bash
./link-copilot-skills.sh -f
```

Override `.env` location:
```bash
./link-copilot-skills.sh -e /path/to/.env
```

Pass a skills-list file directly (overrides `.env` `SKILLS_LIST_FILE`):
```bash
./link-copilot-skills.sh /path/to/skill-list.txt
```

## Notes
- After creating symlinks, restart VS Code to ensure the Copilot extension rescans skills.
- Using symlinks lets vendor repos stay up-to-date without copying files.
- Keep `.env` out of source control if it contains user-specific paths.


ls -1 /Users/charlesbrownroberts/Code/VendorRepos/superpowers/skills | tee -a /Users/charlesbrownroberts/Code/CGB37/ai-toolkit/scripts/link-copilot-skills/skill-list.txt

ls -1 /Users/charlesbrownroberts/Code/VendorRepos/Anthropic/skills/skills | tee -a /Users/charlesbrownroberts/Code/CGB37/ai-toolkit/scripts/link-copilot-skills/skill-list.txt