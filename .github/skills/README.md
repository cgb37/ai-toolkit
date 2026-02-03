# Skills Directory

This directory contains skill definitions for AI assistants working on this project. Skills define specialized capabilities, tools, and knowledge domains that AI assistants can use to help with development tasks.

## Available Skills

### Core Skills
- **anthropic-skill-creator**: Create and manage skill definitions for the team
- **code-reviewer**: Perform code reviews and suggest improvements
- **test-engineer**: Write and maintain tests
- **documentation-writer**: Create and update documentation
- **debugger**: Debug issues and investigate bugs

## Skill Format

Skills are defined in YAML format with the following structure:

```yaml
name: skill-name
description: Brief description of what the skill does
version: 1.0.0
author: Team or individual who created the skill
capabilities:
  - Capability 1
  - Capability 2
tools:
  - tool1
  - tool2
instructions: |
  Detailed instructions on how to use this skill
```

## Using Skills

AI assistants can reference these skills to understand how to best help with specific tasks. Each skill provides context, tools, and guidelines for a particular domain.

## Adding New Skills

1. Create a new YAML file in this directory
2. Follow the skill format above
3. Test the skill with an AI assistant
4. Submit a pull request with your new skill
