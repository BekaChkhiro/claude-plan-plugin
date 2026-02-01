# Contributing to Plan Plugin

Thank you for considering contributing to the Plan Plugin! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This project follows a simple code of conduct:
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help make the project better for everyone

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, Claude Code version)
- Screenshots if applicable

### Suggesting Features

Feature suggestions are welcome! Please:
- Check existing issues first
- Describe the use case clearly
- Explain why it would be valuable
- Consider backward compatibility

### Improving Documentation

Documentation improvements are always appreciated:
- Fix typos or unclear explanations
- Add examples or clarifications
- Update outdated information
- Translate to other languages (future)

### Writing Code

Code contributions follow these areas:

#### 1. Commands
Location: `commands/*/SKILL.md`

Add new commands or improve existing ones:
- `/new` - Project creation wizard
- `/update` - Task management
- `/next` - Task recommendations
- `/export` - Export functionality

#### 2. Skills
Location: `skills/*/SKILL.md`

Add AI-powered skills:
- Codebase analysis
- Task breakdown
- Complexity estimation
- Custom skills for your needs

#### 3. Templates
Location: `templates/*.md`

Add new project type templates:
- Mobile app templates
- CLI tool templates
- Library/package templates
- Language-specific templates

## Development Setup

### Prerequisites

- Claude Code v1.0.33 or later
- Git
- Text editor (VS Code recommended)
- GitHub account

### Local Setup

1. **Fork and Clone**
   ```bash
   git clone git@github.com:YOUR_USERNAME/claude-plan-plugin.git
   cd claude-plan-plugin
   ```

2. **Test Locally**
   ```bash
   # Run Claude Code with your local plugin
   claude --plugin-dir ./claude-plan-plugin

   # Test commands
   /new
   /update T1.1 start
   /next
   ```

3. **Make Changes**
   - Edit files in your preferred editor
   - Follow the existing structure
   - Add documentation for new features

4. **Test Your Changes**
   - Restart Claude Code to reload plugin
   - Test all affected commands
   - Verify error handling

## Project Structure

```
plan-plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/                  # Slash commands
│   ├── new/SKILL.md          # /new
│   ├── update/SKILL.md       # /update
│   ├── next/SKILL.md         # /next
│   └── export/SKILL.md       # /export
├── skills/                    # AI skills
│   ├── analyze-codebase/
│   ├── suggest-breakdown/
│   └── estimate-complexity/
├── templates/                 # Project templates
│   ├── PROJECT_PLAN.template.md
│   ├── fullstack.template.md
│   ├── backend-api.template.md
│   ├── frontend-spa.template.md
│   └── sections/             # Template partials
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

## Coding Guidelines

### For SKILL.md Files

Skills are written in Markdown and contain instructions for Claude:

```markdown
# Skill Name

Brief description of what this skill does.

## Objective

Clear statement of the skill's purpose.

## Process

### Step 1: Do Something
Detailed instructions...

### Step 2: Do Another Thing
More instructions...

## Examples

Concrete examples of usage.

## Error Handling

How to handle common errors.
```

**Guidelines:**
- Write clear, actionable instructions
- Include examples for common scenarios
- Document error handling
- Add helpful user messages
- Consider edge cases

### For Templates

Templates use placeholder syntax:

```markdown
# {{PROJECT_NAME}}

**Description**: {{DESCRIPTION}}
```

**Guidelines:**
- Use `{{PLACEHOLDER}}` for variables
- Keep structure consistent
- Include helpful comments
- Provide sensible defaults
- Make it customizable

### Commit Messages

Follow conventional commits:

```
feat: add mobile app template
fix: correct progress calculation in /update
docs: improve README examples
refactor: simplify task parsing logic
test: add validation tests for templates
```

## Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] `/new` creates valid PROJECT_PLAN.md
- [ ] `/update` correctly updates tasks
- [ ] `/next` provides good recommendations
- [ ] `/export` generates valid output
- [ ] Templates render correctly
- [ ] Skills provide helpful guidance
- [ ] Error messages are clear
- [ ] Plugin loads without errors

### Test Different Scenarios

Test with:
- Different project types (full-stack, backend, frontend)
- Empty directories vs existing codebases
- Various tech stacks
- Edge cases (no tasks, all tasks done, blocked tasks)
- Invalid inputs

### Test Template Generation

```bash
# Test wizard
/new

# Answer questions for different project types
# Verify generated PROJECT_PLAN.md

# Check:
- Placeholders are filled
- Diagrams render in GitHub
- Progress tracking works
- Task numbering is correct
```

## Submitting Changes

### Pull Request Process

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow coding guidelines
   - Add documentation
   - Test thoroughly

3. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature"
   ```

4. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Fill in the PR template
   - Link related issues

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
How did you test this?

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tested locally
- [ ] No breaking changes (or documented)
```

### Review Process

- Maintainers will review your PR
- Address feedback promptly
- Update your branch if needed
- Once approved, it will be merged

## Questions?

- Open an issue for questions
- Join discussions
- Check existing docs first

## Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Plugin credits

Thank you for contributing! 🎉
