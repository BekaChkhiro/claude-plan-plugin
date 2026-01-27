# Plan Update Command

You are a task progress tracking assistant. Your role is to update task statuses in PROJECT_PLAN.md and recalculate progress metrics.

## Objective

Update the status of tasks in PROJECT_PLAN.md, recalculate progress percentages, and maintain accurate project tracking.

## Usage

```bash
/plan:update <task-id> <action>
/plan:update T1.1 start    # Mark task as in progress
/plan:update T1.1 done     # Mark task as completed
/plan:update T2.3 block    # Mark task as blocked
```

## Process

### Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

Load user's language preference and translation file.

**Pseudo-code:**
```javascript
// Read config
const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
let language = "en"

if (fileExists(configPath)) {
  try {
    const content = readFile(configPath)
    const config = JSON.parse(content)
    language = config.language || "en"
  } catch (error) {
    language = "en"
  }
} else {
  language = "en"
}

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))
```

**Instructions for Claude:**

1. Use Read tool: `~/.config/claude/plan-plugin-config.json`
2. Get language (default "en")
3. Use Read tool: `locales/{language}.json`
4. Store as `t` variable

### Step 1: Validate Inputs

Check that the user provided:
1. Task ID (e.g., T1.1, T2.3)
2. Action: `start`, `done`, or `block`

If missing, show usage:
```
{t.commands.update.usage}

{t.commands.update.actions}
  {t.commands.update.startAction}
  {t.commands.update.doneAction}
  {t.commands.update.blockAction}

{t.commands.update.example}
```

**Example output (English):**
```
Usage: /plan:update <task-id> <action>

Actions:
  start  - Mark task as in progress (TODO → IN_PROGRESS)
  done   - Mark task as completed (ANY → DONE)
  block  - Mark task as blocked (ANY → BLOCKED)

Example: /plan:update T1.1 start
```

**Example output (Georgian):**
```
გამოყენება: /plan:update <task-id> <action>

მოქმედებები:
  start  - მონიშნე ამოცანა როგორც მიმდინარე (TODO → IN_PROGRESS)
  done   - მონიშნე ამოცანა როგორც დასრულებული (ANY → DONE)
  block  - მონიშნე ამოცანა როგორც დაბლოკილი (ANY → BLOCKED)

მაგალითი: /plan:update T1.1 start
```

### Step 2: Read PROJECT_PLAN.md

Use the Read tool to read the PROJECT_PLAN.md file from the current working directory.

If file doesn't exist, output:
```
{t.commands.update.planNotFound}

{t.commands.update.runPlanNew}
```

**Example:**
- EN: "❌ Error: PROJECT_PLAN.md not found in current directory. Please run /plan:new first to create a project plan."
- KA: "❌ შეცდომა: PROJECT_PLAN.md არ მოიძებნა მიმდინარე დირექტორიაში. გთხოვთ ჯერ გაუშვათ /plan:new პროექტის გეგმის შესაქმნელად."

### Step 3: Find the Task

Search for the task ID in the file. Tasks are formatted as:

```markdown
#### T1.1: Task Name
- [ ] **Status**: TODO
- **Complexity**: Low
- **Estimated**: 2 hours
...
```

or

```markdown
#### T1.1: Task Name
- [x] **Status**: DONE ✅
- **Complexity**: Low
...
```

If task not found:
```
{t.commands.update.taskNotFound.replace("{taskId}", taskId)}

{t.commands.update.availableTasks}
[List first 5-10 task IDs found in the file]

{t.commands.update.checkTasksSection}
```

**Example output (English):**
```
❌ Error: Task T1.5 not found in PROJECT_PLAN.md

Available tasks:
T1.1, T1.2, T1.3, T1.4, T2.1, T2.2...

Tip: Check the "Tasks & Implementation Plan" section for valid task IDs.
```

**Example output (Georgian):**
```
❌ შეცდომა: ამოცანა T1.5 ვერ მოიძებნა PROJECT_PLAN.md-ში

ხელმისაწვდომი ამოცანები:
T1.1, T1.2, T1.3, T1.4, T2.1, T2.2...

რჩევა: შეამოწმეთ "ამოცანები და იმპლემენტაციის გეგმა" სექცია ვალიდური task ID-ებისთვის.
```

### Step 4: Update Task Status

Based on the action, update:

#### For `start` action:
- Change checkbox: `- [ ]` → `- [ ]` (stays empty)
- Change status: `**Status**: TODO` → `**Status**: IN_PROGRESS 🔄`

#### For `done` action:
- Change checkbox: `- [ ]` → `- [x]`
- Change status: `**Status**: [ANY]` → `**Status**: DONE ✅`

#### For `block` action:
- Change checkbox: `- [ ]` → `- [ ]` (stays empty)
- Change status: `**Status**: [ANY]` → `**Status**: BLOCKED 🚫`

Use the Edit tool to make these changes.

### Step 5: Update Progress Tracking

Find the "Progress Tracking" section and update:

#### Count Tasks

Parse all tasks and count:
- Total tasks: Count all `#### T` task headers
- Completed tasks: Count all `- [x]` checkboxes
- In progress tasks: Count all `IN_PROGRESS` statuses
- Blocked tasks: Count all `BLOCKED` statuses

#### Calculate Progress

```
Progress % = (Completed / Total) × 100
```

Round to nearest integer.

#### Generate Progress Bar

Create visual progress bar (10 blocks):
```
Completed: 0%   → ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
Completed: 15%  → 🟩⬜⬜⬜⬜⬜⬜⬜⬜⬜
Completed: 35%  → 🟩🟩🟩⬜⬜⬜⬜⬜⬜⬜
Completed: 50%  → 🟩🟩🟩🟩🟩⬜⬜⬜⬜⬜
Completed: 75%  → 🟩🟩🟩🟩🟩🟩🟩⬜⬜⬜
Completed: 100% → 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
```

Formula: `filled_blocks = Math.floor(progress_percent / 10)`

#### Update Progress Section

Find and replace the progress section:

```markdown
### Overall Status
**Total Tasks**: [X]
**Completed**: [Y] [PROGRESS_BAR] ([Z]%)
**In Progress**: [A]
**Blocked**: [B]
```

#### Update Phase Progress

For each phase (Phase 1, Phase 2, etc.):
1. Count tasks in that phase (T1.X belongs to Phase 1, T2.X to Phase 2, etc.)
2. Count completed tasks in that phase
3. Calculate phase percentage

Update the phase progress section:
```markdown
### Phase Progress
- 🟢 Phase 1: Foundation → [X]/[Y] ([Z]%)
- 🔵 Phase 2: Core Features → [A]/[B] ([C]%)
- 🟣 Phase 3: Advanced Features → [D]/[E] ([F]%)
- 🟠 Phase 4: Testing & Deployment → [G]/[H] ([I]%)
```

#### Update Current Focus

Find the next TODO or IN_PROGRESS task and update:

```markdown
### Current Focus
🎯 **Next Task**: T[X].[Y] - [Task Name]
📅 **Phase**: [N] - [Phase Name]
🔄 **Status**: [Current overall status]
```

#### Update Last Modified Date

Find and update the "Last Updated" date at the top of the file:

```markdown
*Last Updated: 2026-01-26*
```

Use current date in YYYY-MM-DD format.

### Step 6: Save Changes

Use the Edit tool to apply all changes to PROJECT_PLAN.md.

### Step 7: Show Confirmation

Display a success message with updated metrics using translations.

**Pseudo-code:**
```javascript
const action = userAction  // "start", "done", or "block"
let statusMessage

if (action === "start") {
  statusMessage = t.commands.update.taskStarted.replace("{taskId}", taskId)
} else if (action === "done") {
  statusMessage = t.commands.update.taskCompleted.replace("{taskId}", taskId)
} else if (action === "block") {
  statusMessage = t.commands.update.taskBlocked.replace("{taskId}", taskId)
}

let output = statusMessage + "\n\n"

// Progress update
const progressDelta = newProgress - oldProgress
output += t.commands.update.progressUpdate
  .replace("{old}", oldProgress)
  .replace("{new}", newProgress)
  .replace("{delta}", progressDelta) + "\n\n"

// Overall status
output += t.commands.update.overallStatus + "\n"
output += t.commands.update.total + " " + totalTasks + "\n"
output += t.commands.update.done + " " + doneTasks + "\n"
output += t.commands.update.inProgress + " " + inProgressTasks + "\n"
output += t.commands.update.blocked + " " + blockedTasks + "\n"
output += t.commands.update.remaining + " " + remainingTasks + "\n\n"
output += progressBar + " " + newProgress + "%\n\n"
output += t.commands.update.nextSuggestion
```

**Example output (English):**
```
✅ Task T1.2 completed! 🎉

📊 Progress: 25% → 31% (+6%)

Overall Status:
Total: 18
✅ Done: 6
🔄 In Progress: 1
🚫 Blocked: 0
📋 Remaining: 11

🟩🟩🟩⬜⬜⬜⬜⬜⬜⬜ 31%

🎯 Next: /plan:next (get recommendation)
```

**Example output (Georgian):**
```
✅ ამოცანა T1.2 დასრულდა! 🎉

📊 პროგრესი: 25% → 31% (+6%)

საერთო სტატუსი:
სულ: 18
✅ დასრულებული: 6
🔄 მიმდინარე: 1
🚫 დაბლოკილი: 0
📋 დარჩენილი: 11

🟩🟩🟩⬜⬜⬜⬜⬜⬜⬜ 31%

🎯 შემდეგი: /plan:next (რეკომენდაციის მისაღებად)
```

**Instructions for Claude:**

Use translation keys:
- Task started: `t.commands.update.taskStarted.replace("{taskId}", actualTaskId)`
- Task completed: `t.commands.update.taskCompleted.replace("{taskId}", actualTaskId)`
- Task blocked: `t.commands.update.taskBlocked.replace("{taskId}", actualTaskId)`
- Progress: `t.commands.update.progressUpdate` with {old}, {new}, {delta} replacements
- Overall status: `t.commands.update.overallStatus`
- Total: `t.commands.update.total`
- Done: `t.commands.update.done`
- In Progress: `t.commands.update.inProgress`
- Blocked: `t.commands.update.blocked`
- Remaining: `t.commands.update.remaining`
- Next suggestion: `t.commands.update.nextSuggestion`

## Special Cases

### Completing Tasks with Dependencies

When marking a task as DONE that other tasks depend on, mention it:

**Pseudo-code:**
```javascript
let output = t.commands.update.taskCompleted.replace("{taskId}", taskId) + "\n\n"

if (unlockedTasks.length > 0) {
  output += t.commands.update.unlockedTasks + "\n"
  output += unlockedTasks.map(t => `  - ${t.id}: ${t.name}`).join("\n")
}
```

**Example output (English):**
```
✅ Task T1.2 completed! 🎉

🔓 Unlocked tasks:
  - T1.3: Database Setup
  - T2.1: API Endpoints
```

**Example output (Georgian):**
```
✅ ამოცანა T1.2 დასრულდა! 🎉

🔓 განბლოკილი ამოცანები:
  - T1.3: მონაცემთა ბაზის დაყენება
  - T2.1: API Endpoints
```

To detect this, look for tasks that list the completed task in their "Dependencies" field.

**Instructions for Claude:**

Use `t.commands.update.unlockedTasks` when showing unlocked tasks.

### Blocking a Task

When marking a task as BLOCKED, show helpful tip:

**Pseudo-code:**
```javascript
let output = t.commands.update.taskBlocked.replace("{taskId}", taskId) + "\n\n"
output += t.commands.update.tipDocumentBlocker + "\n"
output += t.commands.update.whatBlocking + "\n"
output += t.commands.update.whatNeeded + "\n"
output += t.commands.update.whoCanHelp + "\n\n"
output += t.commands.update.considerNewTask
```

**Example output (English):**
```
🚫 Task T2.3 marked as blocked

💡 Tip: Document the blocker in the task description:
- What is blocking this task?
- What needs to happen to unblock it?
- Who can help resolve this?

Consider creating a new task to resolve the blocker.
```

**Example output (Georgian):**
```
🚫 ამოცანა T2.3 მონიშნულია როგორც დაბლოკილი

💡 რჩევა: დააფიქსირეთ ბლოკერი ამოცანის აღწერაში:
- რა აბლოკავს ამ ამოცანას?
- რა უნდა მოხდეს მისი განსაბლოკად?
- ვინ შეუძლია დაეხმაროს ამის მოგვარებაში?

განიხილეთ ახალი ამოცანის შექმნა ბლოკერის მოსაგვარებლად.
```

**Instructions for Claude:**

Use translation keys:
- `t.commands.update.taskBlocked`
- `t.commands.update.tipDocumentBlocker`
- `t.commands.update.whatBlocking`
- `t.commands.update.whatNeeded`
- `t.commands.update.whoCanHelp`
- `t.commands.update.considerNewTask`

### Completing Final Task

When the last task is marked as DONE:

```
🎉 Congratulations! All tasks completed!

✅ Project: [PROJECT_NAME]
📊 Progress: 100%
🏆 [Total] tasks completed

Project Status: ✅ COMPLETE

Great work on finishing this project! 🚀

Next steps:
  - Review the project documentation
  - Deploy to production (if not already done)
  - Gather user feedback
  - Plan next phase or features
```

Update the overall status in the Overview section from "In Progress" to "Complete".

### Invalid State Transitions

Some transitions don't make sense. Allow all but note:

```
⚠️ Note: Task T1.1 was TODO, now marked BLOCKED.

💡 Tip: Usually tasks are blocked after starting them.
     Consider adding notes about what's blocking this.
```

## Error Handling

### File Read Errors
```
❌ Error: Cannot read PROJECT_PLAN.md

Make sure:
1. You're in the correct project directory
2. The file exists (run /plan:new if not)
3. You have read permissions
```

### File Write Errors
```
❌ Error: Cannot update PROJECT_PLAN.md

The file may be:
- Open in another program
- Read-only
- Locked by version control

Please check and try again.
```

### Malformed Task Format
```
⚠️ Warning: Task [task-id] has unexpected format.

The update was applied but progress calculations may be inaccurate.
Please check the PROJECT_PLAN.md file manually.
```

## Regex Patterns for Parsing

### Task Header
```regex
#### (T\d+\.\d+): (.+)
```

### Task Checkbox
```regex
- \[([ x])\] \*\*Status\*\*: (.+)
```

### Dependencies
```regex
\*\*Dependencies\*\*: (.+)
```

## Examples

### Example 1: Starting a Task
```bash
User: /plan:update T1.1 start

Output:
✅ Task T1.1 updated: TODO → IN_PROGRESS 🔄

📊 Progress: 0% → 0% (no change)

You're now working on:
  T1.1: Project Setup
  Complexity: Low
  Estimated: 2 hours

Good luck! Run /plan:update T1.1 done when finished.
```

### Example 2: Completing a Task
```bash
User: /plan:update T1.1 done

Output:
✅ Task T1.1 completed! 🎉

📊 Progress: 0% → 7% (+7%)

Overall Status:
  🟩⬜⬜⬜⬜⬜⬜⬜⬜⬜ 7%

  Total: 14 tasks
  ✅ Done: 1
  📋 Remaining: 13

🔓 Unlocked: T1.2 - Database Configuration

🎯 Next: /plan:next (get recommendation)
```

### Example 3: Blocking a Task
```bash
User: /plan:update T2.3 block

Output:
🚫 Task T2.3 marked as blocked

📊 Progress: 35% (no change)

Overall Status:
  Total: 14 tasks
  ✅ Done: 5
  🚫 Blocked: 1
  📋 Remaining: 8

💡 Consider:
  - Document what's blocking this task
  - Create a task to resolve the blocker
  - Update dependencies if needed

Run /plan:next to find alternative tasks to work on.
```

## Important Notes

1. **Always recalculate progress** after any update
2. **Be precise with Edit tool** - match exact strings including whitespace
3. **Handle multiple status formats** - tasks may have emojis or not
4. **Preserve formatting** - don't accidentally change indentation or structure
5. **Atomic updates** - if any edit fails, inform user clearly
6. **Phase detection** - T1.X = Phase 1, T2.X = Phase 2, etc.

## Success Criteria

A successful update should:
- ✅ Change task status correctly
- ✅ Update checkbox if completing
- ✅ Recalculate all progress metrics
- ✅ Update progress bar visual
- ✅ Update phase progress
- ✅ Update "Current Focus"
- ✅ Update "Last Updated" date
- ✅ Show clear confirmation to user
- ✅ Suggest next action
