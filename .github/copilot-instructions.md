# AI Toolkit - Copilot Instructions

## Project Overview
This is an AI toolkit for creating modular "skills" that extend AI agents' capabilities. Skills are self-contained packages with specialized knowledge, workflows, and tools.

## Architecture
- **Skills Directory**: `.github/skills/` contains all skill definitions
- **Skill Structure**: Each skill has `SKILL.md` (required) + optional `scripts/`, `references/`, `assets/`
- **Progressive Disclosure**: Metadata → SKILL.md body → bundled resources (loaded on-demand)
- **Packaging**: Skills are packaged into `.skill` files (zip archives) for distribution

## Core Workflows

### Creating a New Skill
```bash
# Initialize skill template
.github/skills/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>

# Edit SKILL.md with YAML frontmatter (name, description) and markdown instructions
# Add scripts/, references/, assets/ as needed

# Package and validate
.github/skills/skill-creator/scripts/package_skill.py <path/to/skill-folder>
```

### Skill Structure Patterns
- **Workflow-Based**: Sequential processes (e.g., "Step 1 → Step 2 → Step 3")
- **Task-Based**: Tool collections (e.g., "Quick Start → Task A → Task B")
- **Reference/Guidelines**: Standards/specifications
- **Capabilities-Based**: Integrated systems

## Key Conventions

### SKILL.md Format
```yaml
---
name: skill-name
description: [What it does + WHEN to use it - specific triggers, scenarios, file types]
---

# Skill Title

[Imperative instructions using infinitive form]
```

### Output Patterns
- Use templates for consistent output (strict for APIs, flexible for reports)
- Provide input/output examples for quality-dependent tasks
- Follow established patterns from `references/output-patterns.md`

### Workflow Patterns
- Break complex tasks into sequential steps
- Use conditional logic for branching workflows
- Reference bundled resources explicitly: `See [filename](filename)`

## Development Guidelines

### Context Management
- Keep SKILL.md under 500 lines; move details to references/
- Only essential procedural knowledge in SKILL.md
- Use references/ for detailed docs, schemas, examples
- Scripts/ for deterministic, reusable code
- Assets/ for output templates (not loaded into context)

### Validation
- Run `quick_validate.py` during development
- Package validates automatically before creating .skill file
- Test scripts by actually running them

### Examples from Codebase
- **Skill-Creator**: Uses workflow patterns for 6-step skill creation process
- **Output Patterns**: Template structures with strict/flexible guidance
- **Workflow Patterns**: Sequential and conditional logic examples

## Integration Points
- Scripts execute without loading into context window
- References loaded only when AI agents determine they're needed
- Assets used in final output but not read into context
- Skills can reference external APIs, file formats, or domain knowledge

## File Organization
```
.github/skills/
├── skill-name/
│   ├── SKILL.md (required)
│   ├── scripts/ (optional - executable code)
│   ├── references/ (optional - docs loaded as needed)
│   └── assets/ (optional - output templates)
```