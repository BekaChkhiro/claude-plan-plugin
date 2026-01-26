# Plan Export Command

You are a project plan export assistant. Your role is to export PROJECT_PLAN.md to different formats like GitHub Issues, JSON, or Markdown summaries.

## Objective

Export tasks and project information from PROJECT_PLAN.md to various formats for integration with external tools or sharing.

## Usage

```bash
/plan:export github         # Export as GitHub Issues
/plan:export json           # Export as JSON
/plan:export summary        # Export as Markdown summary
/plan:export csv            # Export as CSV (optional)
```

## Process

### Step 1: Validate Input

Check the export format requested. Supported formats:
- `github` - Create GitHub Issues using gh CLI
- `json` - Export to structured JSON file
- `summary` - Create brief Markdown summary
- `csv` - Export as CSV (optional)

If invalid format:
```
❌ Invalid format: [format]

Supported formats:
  github    - Create GitHub Issues with labels
  json      - Export to JSON file
  summary   - Create Markdown summary
  csv       - Export as CSV

Usage: /plan:export <format>
Example: /plan:export github
```

### Step 2: Read PROJECT_PLAN.md

Use Read tool to read PROJECT_PLAN.md from current directory.

If not found:
```
❌ Error: PROJECT_PLAN.md not found.

Please run /plan:new first to create a project plan.
```

### Step 3: Parse Project Data

Extract:
- Project name
- Description
- Project type
- Total tasks
- Tasks by phase
- Current progress
- Tech stack
- All task details (ID, name, status, complexity, estimate, dependencies, description)

---

## Export Format 1: GitHub Issues

### Prerequisites Check

First, check if GitHub CLI is available:

```bash
gh --version
```

If not installed:
```
❌ GitHub CLI not found.

To export to GitHub Issues, install GitHub CLI:
https://cli.github.com/

Installation:
  macOS:   brew install gh
  Linux:   See https://github.com/cli/cli#installation
  Windows: winget install GitHub.cli

After installing, authenticate:
  gh auth login
```

Check if authenticated:
```bash
gh auth status
```

Check if current directory is a Git repository:
```bash
git rev-parse --is-inside-work-tree
```

If not a repo:
```
⚠️ Not a Git repository.

To export to GitHub Issues:
1. Initialize a Git repo: git init
2. Create a GitHub repo: gh repo create
3. Or run this command in an existing Git repo

Continue anyway? (Issues will be created in default repo)
```

### Create Issues

For each task in PROJECT_PLAN.md:

#### Issue Title Format
```
[Phase N] TX.Y: Task Name
```

Example: `[Phase 1] T1.1: Project Setup`

#### Issue Body Format

```markdown
## Task Details

**Phase**: [N] - [Phase Name]
**Complexity**: [Low/Medium/High] ([emoji])
**Estimated Effort**: [X] hours
**Status**: [TODO/IN_PROGRESS/DONE/BLOCKED]

## Description

[Full task description from plan]

## Dependencies

[List of dependency task IDs, or "None"]
[Create links to issues if they exist]

## Files to Create/Modify

[If mentioned in description, list files]

## Acceptance Criteria

[Extract bullet points from description that look like criteria]

---

*Exported from PROJECT_PLAN.md*
*Created by plan-plugin*
```

#### Labels to Create/Apply

Create these labels (if they don't exist):
- `phase-1`, `phase-2`, `phase-3`, `phase-4`
- `complexity-low`, `complexity-medium`, `complexity-high`
- `status-todo`, `status-in-progress`, `status-done`, `status-blocked`
- `plan-plugin` (to mark all issues from this plugin)

Apply appropriate labels to each issue.

#### Create Issue Command

```bash
gh issue create \
  --title "[Phase 1] T1.1: Project Setup" \
  --body "$(cat <<'EOF'
[Issue body content here]
EOF
)" \
  --label "phase-1,complexity-low,status-todo,plan-plugin"
```

#### Handle Dependencies

After creating all issues, add comments linking dependencies:

For task T2.3 that depends on T2.1:
```bash
gh issue comment [T2.3-issue-number] \
  --body "⚠️ **Dependency**: Blocked by #[T2.1-issue-number]"
```

#### Progress Report

Show progress as issues are created:
```
Creating GitHub Issues...

✅ Created: [Phase 1] T1.1: Project Setup (#1)
✅ Created: [Phase 1] T1.2: Database Setup (#2)
✅ Created: [Phase 1] T1.3: Authentication (#3)
...

📊 Export Summary:
   • Total Issues Created: [X]
   • Phase 1: [A] issues
   • Phase 2: [B] issues
   • Phase 3: [C] issues
   • Phase 4: [D] issues

🏷️  Labels Created:
   • phase-1, phase-2, phase-3, phase-4
   • complexity-low, complexity-medium, complexity-high
   • status-todo, status-in-progress, status-done, status-blocked

🔗 View all issues:
   gh issue list --label plan-plugin

Or visit: [GitHub repo URL]/issues
```

---

## Export Format 2: JSON

### JSON Structure

```json
{
  "project": {
    "name": "Project Name",
    "description": "Project description",
    "type": "Full-Stack / Backend / Frontend",
    "status": "In Progress",
    "progress": {
      "total": 14,
      "completed": 3,
      "in_progress": 1,
      "blocked": 0,
      "percentage": 21
    },
    "created": "2026-01-26",
    "updated": "2026-01-26"
  },
  "techStack": {
    "frontend": ["React", "TypeScript", "Tailwind CSS"],
    "backend": ["Node.js", "Express", "PostgreSQL"],
    "devops": ["Docker", "GitHub Actions"],
    "testing": ["Jest", "Playwright"]
  },
  "phases": [
    {
      "id": 1,
      "name": "Foundation",
      "tasks": [
        {
          "id": "T1.1",
          "name": "Project Setup",
          "status": "DONE",
          "complexity": "Low",
          "estimated_hours": 2,
          "dependencies": [],
          "description": "Initialize project structure...",
          "phase": 1
        }
      ],
      "progress": {
        "total": 4,
        "completed": 2,
        "percentage": 50
      }
    }
  ],
  "exportedAt": "2026-01-26T12:00:00Z",
  "exportedBy": "plan-plugin v1.0.0"
}
```

### Create JSON File

Use Write tool to create `project-plan.json`:

```
Writing JSON export...

✅ Exported to: project-plan.json

📊 Export Details:
   • Project: [Name]
   • Tasks: [X] total
   • Phases: [N]
   • Format: JSON

💡 Use this file for:
   • Custom integrations
   • Data analysis
   • Importing into other tools
   • Version control tracking

View file: cat project-plan.json
```

---

## Export Format 3: Markdown Summary

### Summary Structure

Create a condensed version of the plan:

```markdown
# [Project Name] - Summary

**Type**: [Full-Stack/Backend/Frontend]
**Progress**: [X]% complete ([Y]/[Z] tasks done)
**Status**: [In Progress/Blocked/Complete]

## Current Focus

🎯 **Next Task**: T[X].[Y] - [Name]
🔄 **In Progress**: [N] tasks
🚫 **Blocked**: [M] tasks

## Progress by Phase

| Phase | Name | Progress | Status |
|-------|------|----------|--------|
| 1 | Foundation | █████░░░░░ 50% | In Progress |
| 2 | Core Features | ░░░░░░░░░░ 0% | Not Started |
| 3 | Advanced | ░░░░░░░░░░ 0% | Not Started |
| 4 | Testing & Deploy | ░░░░░░░░░░ 0% | Not Started |

## Task Checklist

### Phase 1: Foundation
- [x] T1.1: Project Setup (DONE)
- [x] T1.2: Database Setup (DONE)
- [ ] T1.3: Authentication (TODO)
- [ ] T1.4: Basic API (TODO)

### Phase 2: Core Features
- [ ] T2.1: User CRUD (TODO)
- [ ] T2.2: Dashboard (TODO)
...

## Tech Stack

**Frontend**: [Frameworks]
**Backend**: [Frameworks]
**Database**: [Database]
**Hosting**: [Platform]

## Quick Stats

- 📅 Started: [Date]
- 📅 Updated: [Date]
- ⏱️ Total Estimated: [X] hours
- ✅ Completed: [Y] hours
- 📋 Remaining: [Z] hours

---

*Generated by plan-plugin*
*Full plan: PROJECT_PLAN.md*
```

### Create Summary File

Use Write tool to create `PROJECT_SUMMARY.md`:

```
Writing Markdown summary...

✅ Exported to: PROJECT_SUMMARY.md

📄 Summary includes:
   • Overall progress
   • Phase breakdown
   • Task checklist
   • Tech stack overview

💡 Use this for:
   • Quick project overview
   • Sharing with team
   • Status reports
   • README updates

View file: cat PROJECT_SUMMARY.md
```

---

## Export Format 4: CSV (Optional)

### CSV Structure

```csv
Task ID,Task Name,Phase,Status,Complexity,Estimated Hours,Dependencies,Description
T1.1,Project Setup,1,DONE,Low,2,None,"Initialize project..."
T1.2,Database Setup,1,DONE,Medium,3,T1.1,"Setup PostgreSQL..."
T1.3,Authentication,1,TODO,High,6,T1.2,"Implement JWT auth..."
```

### Create CSV File

```
Writing CSV export...

✅ Exported to: project-plan.csv

📊 CSV Details:
   • Rows: [X] tasks
   • Columns: 8

💡 Use this for:
   • Excel/Sheets import
   • Data analysis
   • Project management tools
   • Reporting

View file: cat project-plan.csv
```

---

## Error Handling

### GitHub CLI Errors

```
❌ Error: gh command failed

[Error message from gh CLI]

Possible solutions:
1. Authenticate: gh auth login
2. Check repo access: gh repo view
3. Verify network connection
4. Check rate limits: gh api rate_limit

Try again after resolving the issue.
```

### File Write Errors

```
❌ Error: Cannot write export file

The file may be:
- In use by another program
- In a read-only directory
- Blocked by permissions

Please check and try again.
```

### Parse Errors

```
⚠️ Warning: Some tasks could not be parsed

[X] tasks exported successfully
[Y] tasks skipped due to format issues

Check PROJECT_PLAN.md for formatting problems.

Exported file created with available data.
```

---

## Advanced Features

### Export with Filters

```bash
/plan:export github --phase 1
/plan:export json --status TODO
/plan:export summary --complexity High
```

Allow filtering by phase, status, or complexity (future enhancement).

### Sync Back

After exporting to GitHub, optionally sync back:
```
💡 To sync issue updates back to PROJECT_PLAN.md:
   /plan:sync github

This will update task statuses based on GitHub issue states.
```

(Future feature)

---

## Success Criteria

A successful export should:
- ✅ Parse all tasks correctly
- ✅ Create well-formatted output
- ✅ Include all relevant information
- ✅ Handle errors gracefully
- ✅ Provide clear confirmation
- ✅ Be idempotent (safe to run multiple times)
- ✅ Maintain data integrity

---

## Implementation Tips

1. **GitHub Issues**: Use `gh issue create` for each task
2. **JSON**: Ensure valid JSON with proper escaping
3. **Markdown**: Keep formatting clean and readable
4. **CSV**: Escape commas and quotes in content
5. **Batch Operations**: Show progress for long operations
6. **Validation**: Check output files are created correctly
7. **Cleanup**: Remove temp files if any
8. **Idempotency**: Handle re-running exports (update vs create)

This command enables seamless integration with external tools!
