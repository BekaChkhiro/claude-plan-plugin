# Plugin Validation Checklist

Use this checklist to validate that the plan-plugin is working correctly before release.

## Pre-Flight Checks

### Plugin Structure
- [x] `.claude-plugin/plugin.json` exists and is valid JSON
- [x] All command directories exist (new, update, next, export)
- [x] All skill directories exist (analyze-codebase, suggest-breakdown, estimate-complexity)
- [x] All templates exist and are properly formatted
- [x] README.md is complete and accurate
- [x] CHANGELOG.md documents all features
- [x] CONTRIBUTING.md provides clear guidelines
- [x] LICENSE file is present

### File Integrity
- [x] No placeholder text like "TODO" or "TBD" in released files
- [x] All SKILL.md files have complete instructions
- [x] All templates have proper placeholders ({{VARIABLE}})
- [x] Examples are complete and demonstrate features
- [x] No broken links in documentation

## Functional Testing

### Test 1: Plugin Loading
```bash
cd /path/to/plan-plugin
claude --plugin-dir .
```

**Expected**:
- [ ] Plugin loads without errors
- [ ] Commands are available: `/new`, `/update`, `/next`, `/export`
- [ ] No warnings or error messages

**Actual Result**:
```
[Record results here]
```

---

### Test 2: `/new` - Full-Stack Project

```bash
/new
```

**Test Scenario**: Create a full-stack task management app

**Input Responses**:
- Project Name: "TestApp"
- Project Type: "Full-Stack Web App"
- Description: "A test application for validation"
- Frontend: "React"
- Backend: "Express"
- Database: "PostgreSQL"
- Hosting: "Vercel + Railway"
- Features: ["User auth", "Task management", "Real-time updates"]

**Expected**:
- [ ] Wizard asks appropriate questions
- [ ] Questions are context-aware
- [ ] PROJECT_PLAN.md is created
- [ ] File contains all sections (Overview, Architecture, Tech Stack, Tasks, etc.)
- [ ] Mermaid diagrams are properly formatted
- [ ] Tasks are numbered correctly (T1.1, T1.2, etc.)
- [ ] Progress tracking section is initialized
- [ ] Placeholders are replaced with actual values
- [ ] No {{PLACEHOLDER}} text remains

**Validation Commands**:
```bash
# Check file was created
ls -la PROJECT_PLAN.md

# Verify content structure
grep "## Overview" PROJECT_PLAN.md
grep "## Architecture" PROJECT_PLAN.md
grep "## Tech Stack" PROJECT_PLAN.md
grep "## Tasks" PROJECT_PLAN.md

# Check for unreplaced placeholders
grep "{{" PROJECT_PLAN.md  # Should return nothing

# Verify task format
grep "#### T1.1:" PROJECT_PLAN.md
grep "- \[ \]" PROJECT_PLAN.md
```

**Actual Result**:
```
[Record results here]
```

---

### Test 3: `/new` - Backend API Project

```bash
# Clean up previous test
rm PROJECT_PLAN.md

/new
```

**Test Scenario**: Create a backend API

**Input Responses**:
- Project Name: "TestAPI"
- Project Type: "Backend API"
- Description: "REST API for testing"
- Framework: "NestJS"
- Database: "PostgreSQL"
- API Style: "REST"

**Expected**:
- [ ] Backend-specific template is used
- [ ] API endpoints section included
- [ ] Backend-focused architecture diagram
- [ ] Appropriate tech stack sections
- [ ] No frontend-specific sections

**Actual Result**:
```
[Record results here]
```

---

### Test 4: `/update` - Task Management

Using the PROJECT_PLAN.md from Test 2 or 3:

```bash
# Start a task
/update T1.1 start
```

**Expected**:
- [ ] Task status changes to IN_PROGRESS
- [ ] Confirmation message shown
- [ ] Progress section updated
- [ ] "In Progress" count incremented
- [ ] "Current Focus" section updated

**Validation**:
```bash
grep "IN_PROGRESS" PROJECT_PLAN.md
grep "In Progress: 1" PROJECT_PLAN.md
```

```bash
# Complete the task
/update T1.1 done
```

**Expected**:
- [ ] Task checkbox marked [x]
- [ ] Status changes to DONE ✅
- [ ] Progress percentage increased
- [ ] Progress bar updated
- [ ] Completed count incremented
- [ ] Success message with progress shown

**Validation**:
```bash
grep "- \[x\]" PROJECT_PLAN.md
grep "DONE ✅" PROJECT_PLAN.md
```

```bash
# Block a task
/update T2.1 block
```

**Expected**:
- [ ] Status changes to BLOCKED
- [ ] Blocked count updated
- [ ] Helpful message about documenting blocker

**Actual Result**:
```
[Record results here]
```

---

### Test 5: `/next` - Task Recommendation

```bash
/next
```

**Expected**:
- [ ] Analyzes PROJECT_PLAN.md
- [ ] Recommends a logical next task
- [ ] Provides reasoning for recommendation
- [ ] Shows task details (complexity, estimate, etc.)
- [ ] Suggests command to start task
- [ ] Offers alternative tasks
- [ ] Handles "no available tasks" gracefully
- [ ] Handles "all tasks done" scenario

**Test Scenarios**:

**Scenario A: Normal Progress**
- Some tasks done, some remaining
- Expected: Recommends next logical task

**Scenario B: Tasks In Progress**
- Multiple tasks marked IN_PROGRESS
- Expected: Suggests finishing in-progress tasks first

**Scenario C: Blocked Dependencies**
- All available tasks depend on incomplete tasks
- Expected: Shows what's blocking and suggests alternatives

**Scenario D: All Complete**
- All tasks marked DONE
- Expected: Congratulatory message, suggests next steps

**Actual Result**:
```
[Record results here]
```

---

### Test 6: `/export` - JSON Export

```bash
/export json
```

**Expected**:
- [ ] Creates `project-plan.json` file
- [ ] JSON is valid (can be parsed)
- [ ] Contains all project data
- [ ] Includes all tasks with correct structure
- [ ] Progress data is accurate
- [ ] Tech stack information included

**Validation**:
```bash
# Check file exists
ls -la project-plan.json

# Validate JSON
cat project-plan.json | python -m json.tool

# Or with Node.js
node -e "console.log(JSON.parse(require('fs').readFileSync('project-plan.json')))"
```

**Actual Result**:
```
[Record results here]
```

---

### Test 7: `/export` - Markdown Summary

```bash
/export summary
```

**Expected**:
- [ ] Creates `PROJECT_SUMMARY.md` file
- [ ] Contains concise project overview
- [ ] Shows phase progress table
- [ ] Lists tasks with checkboxes
- [ ] Includes tech stack summary
- [ ] Proper markdown formatting

**Validation**:
```bash
ls -la PROJECT_SUMMARY.md
cat PROJECT_SUMMARY.md
```

**Actual Result**:
```
[Record results here]
```

---

### Test 8: `/export` - GitHub Issues (Optional)

**Prerequisites**: `gh` CLI installed and authenticated

```bash
# Check gh CLI
gh --version
gh auth status

/export github
```

**Expected**:
- [ ] Checks for gh CLI availability
- [ ] Creates GitHub issues for each task
- [ ] Applies appropriate labels
- [ ] Issue titles follow format: `[Phase N] TX.Y: Task Name`
- [ ] Issue bodies contain task details
- [ ] Shows progress report
- [ ] Links to created issues

**Note**: Only test if you have a test repository available!

**Actual Result**:
```
[Record results here]
```

---

## Error Handling Tests

### Test 9: Invalid Commands

```bash
# Missing arguments
/update

# Invalid task ID
/update T99.99 start

# Invalid action
/update T1.1 invalid_action

# Export invalid format
/export invalid_format
```

**Expected**:
- [ ] Clear error messages
- [ ] Usage examples shown
- [ ] No crashes or stack traces
- [ ] Helpful suggestions provided

**Actual Result**:
```
[Record results here]
```

---

### Test 10: Missing Files

```bash
# Remove PROJECT_PLAN.md
rm PROJECT_PLAN.md

# Try commands
/update T1.1 start
/next
/export json
```

**Expected**:
- [ ] Clear "file not found" message
- [ ] Suggests running `/new` first
- [ ] No crashes

**Actual Result**:
```
[Record results here]
```

---

## Template Validation

### Test 11: Template Placeholders

Check each template has proper placeholders:

```bash
cd templates

# Check for placeholders
grep -n "{{" *.md
grep -n "{{" sections/*.md
```

**Expected**:
- [ ] All variables use `{{VARIABLE}}` syntax
- [ ] No typos in placeholder names
- [ ] Consistent naming conventions
- [ ] No unreplaced placeholders

**Actual Result**:
```
[Record results here]
```

---

### Test 12: Template Rendering

Manually test that templates render correctly:

```bash
# Create plans with each template type
/new  # Choose Full-Stack
/new  # Choose Backend API
/new  # Choose Frontend SPA
```

**Expected**:
- [ ] Each template generates valid markdown
- [ ] Mermaid diagrams are properly formatted
- [ ] No syntax errors
- [ ] All sections present
- [ ] Appropriate for project type

**Actual Result**:
```
[Record results here]
```

---

## Documentation Validation

### Test 13: Documentation Accuracy

- [ ] README examples work as described
- [ ] Installation instructions are correct
- [ ] Command examples are accurate
- [ ] Links in docs are not broken
- [ ] Examples in `examples/` directory are valid
- [ ] CONTRIBUTING.md instructions are clear
- [ ] CHANGELOG.md is up to date

**Check Links**:
```bash
# Find all markdown links
grep -r "\](.*)" *.md

# Verify each link exists
```

**Actual Result**:
```
[Record results here]
```

---

## Performance Tests

### Test 14: Large Projects

Create a plan with many tasks:

```bash
/new
# Create project with 50+ tasks
```

**Expected**:
- [ ] Commands complete in reasonable time (< 5 seconds)
- [ ] Progress calculations are accurate
- [ ] File operations don't fail
- [ ] No performance degradation

**Actual Result**:
```
[Record results here]
```

---

## Final Checks

### Pre-Release Checklist

- [ ] All functional tests pass
- [ ] No critical bugs found
- [ ] Documentation is complete
- [ ] Examples are accurate
- [ ] Version number is correct in all files
- [ ] Git repository is clean
- [ ] CHANGELOG.md is updated
- [ ] README badges are accurate (if any)
- [ ] License is correct

### Ready for Release?

- [ ] **YES** - All tests pass, documentation complete
- [ ] **NO** - Issues found (document below)

**Issues Found**:
```
[List any issues that need fixing before release]
```

---

## Testing Notes

**Tested By**: [Your name]
**Date**: [Test date]
**Claude Code Version**: [Version]
**OS**: [Operating system]
**Test Duration**: [How long testing took]

**Overall Assessment**:
```
[Your overall assessment of the plugin quality]
```

**Recommended Actions**:
```
[Any fixes or improvements needed before release]
```

---

*Use this checklist to ensure plugin quality before each release*
