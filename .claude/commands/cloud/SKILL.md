# /cloud - Manage PlanFlow Cloud Projects

Manage your PlanFlow cloud projects - list, link, unlink, and create projects from the CLI.

## Usage

```bash
/cloud                    # List all projects (default)
/cloud list               # List all projects
/cloud link               # Interactive - select project to link
/cloud link <project-id>  # Link to specific project
/cloud unlink             # Unlink current project from cloud
/cloud new                # Create new cloud project from local plan
/cloud new "Project Name" # Create with custom name
```

## What This Command Does

- **list**: Display all your cloud projects with stats
- **link**: Connect local PROJECT_PLAN.md to a cloud project
- **unlink**: Disconnect local project from cloud
- **new**: Create a new cloud project and optionally sync

## Prerequisites

- Authenticated with PlanFlow (`/login`)
- For `new`: PROJECT_PLAN.md exists in current directory

---

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

Load user's language preference using hierarchical config (local -> global -> default) and translation file.

**Pseudo-code:**
```javascript
// Read config with hierarchy (v1.1.1+)
function getConfig() {
  // Try local config first
  if (fileExists("./.plan-config.json")) {
    try {
      return JSON.parse(readFile("./.plan-config.json"))
    } catch (error) {}
  }

  // Fall back to global config
  const globalPath = expandPath("~/.config/claude/plan-plugin-config.json")
  if (fileExists(globalPath)) {
    try {
      return JSON.parse(readFile(globalPath))
    } catch (error) {}
  }

  // Fall back to defaults
  return { "language": "en" }
}

const config = getConfig()
const language = config.language || "en"

// Cloud config
const cloudConfig = config.cloud || {}
const apiToken = cloudConfig.apiToken || null
const apiUrl = cloudConfig.apiUrl || "https://api.planflow.tools"
const projectId = cloudConfig.projectId || null

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))
```

**Instructions for Claude:**

1. Try to read `./.plan-config.json` (local, highest priority)
2. If not found/corrupted, try `~/.config/claude/plan-plugin-config.json` (global)
3. If not found/corrupted, use default: `language = "en"`
4. Use Read tool: `locales/{language}.json`
5. Store as `t` variable for translations
6. Extract cloud config: `apiToken`, `apiUrl`, `projectId`

---

## Step 1: Parse Command Arguments

Determine which cloud action to perform.

**Pseudo-code:**
```javascript
const args = parseArguments()  // Get arguments after "/cloud"

// Determine action
let action = "list"  // Default action
if (args.length === 0) {
  action = "list"
} else if (args[0] === "list") {
  action = "list"
} else if (args[0] === "link") {
  action = "link"
  targetProjectId = args[1] || null  // Optional project ID
} else if (args[0] === "unlink") {
  action = "unlink"
} else if (args[0] === "new") {
  action = "new"
  customName = args.slice(1).join(" ") || null  // Optional custom name
}
```

**Instructions for Claude:**

Parse the command arguments:
- `/cloud` -> `action = "list"`
- `/cloud list` -> `action = "list"`
- `/cloud link` -> `action = "link"`, `targetProjectId = null`
- `/cloud link abc123` -> `action = "link"`, `targetProjectId = "abc123"`
- `/cloud unlink` -> `action = "unlink"`
- `/cloud new` -> `action = "new"`, `customName = null`
- `/cloud new "My Project"` -> `action = "new"`, `customName = "My Project"`

---

## Step 2: Check Authentication

Verify user is logged in before any cloud operation.

**Pseudo-code:**
```javascript
function isAuthenticated(config) {
  return !!config.cloud?.apiToken
}

if (!isAuthenticated(config)) {
  console.log(t.commands.sync.notAuthenticated)
  console.log("")
  console.log("Run: /login")
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.apiToken` exists
2. If not, show error:
   ```
   Not authenticated. Run /login first.

   Run: /login
   ```
3. Stop execution if not authenticated

---

## Step 3: Route to Action Handler

Based on the action, execute the appropriate handler.

**Pseudo-code:**
```javascript
switch (action) {
  case "list":
    handleList(config, t)
    break
  case "link":
    handleLink(config, targetProjectId, t)
    break
  case "unlink":
    handleUnlink(config, t)
    break
  case "new":
    handleNew(config, customName, t)
    break
}
```

---

# List Action Handler (Default)

## List Step 1: Fetch Projects from API

Get all projects for the authenticated user.

**Pseudo-code:**
```javascript
const response = makeRequest("GET", "/projects", null, config.cloud.apiToken)

// Response structure:
// Success (200):
// {
//   "projects": [
//     {
//       "id": "abc123",
//       "name": "E-commerce App",
//       "createdAt": "2026-01-10T00:00:00Z",
//       "updatedAt": "2026-01-31T12:00:00Z",
//       "stats": {
//         "totalTasks": 45,
//         "completedTasks": 24,
//         "progress": 53
//       }
//     },
//     ...
//   ],
//   "total": 5
// }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "${API_URL}/projects")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Make GET request to `/projects`:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X GET \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/projects"
   ```

2. Parse the response and extract projects array

3. Handle errors:
   - **401**: Token expired -> suggest /login
   - **500+**: Server error -> suggest retry

---

## List Step 2: Display Projects Table

Format and display the projects list.

**Pseudo-code:**
```javascript
const projects = response.body.projects
const currentProjectId = config.cloud?.projectId

if (projects.length === 0) {
  console.log(t.commands.cloud.listProjects)
  console.log("")
  console.log(t.commands.cloud.noProjects)
  console.log(t.commands.cloud.createFirst)
  return
}

console.log(t.commands.cloud.listProjects)
console.log("")

// Table header
console.log(`  ${t.commands.cloud.tableId.padEnd(10)}${t.commands.cloud.tableName.padEnd(20)}${t.commands.cloud.tableTasks.padEnd(10)}${t.commands.cloud.tableProgress.padEnd(12)}${t.commands.cloud.tableUpdated}`)
console.log(`  ${"─".repeat(10)}${"─".repeat(20)}${"─".repeat(10)}${"─".repeat(12)}${"─".repeat(15)}`)

// Table rows
for (const project of projects) {
  const id = project.id.substring(0, 8)
  const name = project.name.substring(0, 18).padEnd(18)
  const tasks = `${project.stats.completedTasks}/${project.stats.totalTasks}`.padEnd(8)
  const progress = project.stats.progress === 100
    ? `${project.stats.progress}% `.padEnd(10)
    : `${project.stats.progress}%`.padEnd(10)
  const updated = formatRelativeTime(project.updatedAt)
  const current = project.id === currentProjectId ? " 📍" : ""

  console.log(`  ${id.padEnd(10)}${name}  ${tasks}${progress}${updated}${current}`)
}

// Show current project indicator
if (currentProjectId) {
  const currentProject = projects.find(p => p.id === currentProjectId)
  if (currentProject) {
    console.log("")
    console.log(`  ${t.commands.cloud.currentProject} ${currentProject.name}`)
  }
}

// Show available commands
console.log("")
console.log(`  ${t.commands.cloud.commands}`)
console.log(`    ${t.commands.cloud.linkCommand}`)
console.log(`    ${t.commands.cloud.unlinkCommand}`)
console.log(`    ${t.commands.cloud.newCommand}`)
```

**Instructions for Claude:**

1. If no projects, show:
   ```
   Your Cloud Projects

   No cloud projects found.
   Create your first project with /cloud new
   ```

2. If projects exist, show table:
   ```
   Your Cloud Projects

     ID        Name                Tasks     Progress    Last Updated
     ────────  ──────────────────  ────────  ──────────  ────────────────
     abc123    E-commerce App      24/45     53%         2 hours ago
     def456    Mobile API          12/18     67%         Yesterday
     ghi789    Dashboard           8/8       100%        Last week

     Current: E-commerce App

     Commands:
       /cloud link <id>     - Link local project
       /cloud unlink        - Unlink current project
       /cloud new           - Create cloud project
   ```

3. Mark current linked project with (indicator or highlight)

---

## List Step 3: Format Helper Functions

Helper functions for formatting output.

**Pseudo-code:**
```javascript
function formatRelativeTime(isoString) {
  const date = new Date(isoString)
  const now = new Date()
  const diffMs = now - date
  const diffSecs = Math.floor(diffMs / 1000)
  const diffMins = Math.floor(diffSecs / 60)
  const diffHours = Math.floor(diffMins / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffSecs < 60) return "just now"
  if (diffMins < 60) return `${diffMins} min ago`
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
  if (diffDays === 1) return "Yesterday"
  if (diffDays < 7) return `${diffDays} days ago`
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} week${Math.floor(diffDays / 7) > 1 ? 's' : ''} ago`
  return date.toLocaleDateString()
}

function formatProgress(progress) {
  if (progress === 100) return "100%"
  return `${progress}%`
}
```

---

# Link Action Handler

## Link Step 1: Check for Target Project ID

Determine if we need to show selection or link directly.

**Pseudo-code:**
```javascript
if (!targetProjectId) {
  // No project ID provided - show interactive selection
  // First, fetch projects list
  const response = makeRequest("GET", "/projects", null, config.cloud.apiToken)

  if (!response.ok) {
    showError(response)
    return
  }

  const projects = response.body.projects

  if (projects.length === 0) {
    console.log(t.commands.cloud.noProjects)
    console.log(t.commands.cloud.createFirst)
    return
  }

  // Show selection
  console.log(t.commands.cloud.selectProject)
  console.log("")

  const options = projects.map(p => ({
    label: `${p.name} (${p.id.substring(0, 8)})`,
    description: `${p.stats.completedTasks}/${p.stats.totalTasks} tasks, ${p.stats.progress}% complete`
  }))

  const selection = AskUserQuestion({
    questions: [{
      question: "Which project do you want to link?",
      header: "Link Project",
      options: options
    }]
  })

  // Extract project ID from selection
  const selectedProject = projects.find(p =>
    selection.includes(p.name) || selection.includes(p.id.substring(0, 8))
  )

  if (!selectedProject) {
    console.log("No project selected.")
    return
  }

  targetProjectId = selectedProject.id
}
```

**Instructions for Claude:**

1. If no project ID provided in arguments:
   - Fetch projects list from API
   - Use AskUserQuestion to let user select
   - Extract selected project ID

2. If project ID provided, use it directly

---

## Link Step 2: Verify Project Exists

Check that the target project exists and user has access.

**Pseudo-code:**
```javascript
const response = makeRequest("GET", `/projects/${targetProjectId}`, null, config.cloud.apiToken)

if (response.status === 404) {
  console.log(`Project '${targetProjectId}' not found.`)
  console.log("")
  console.log("Run /cloud list to see available projects.")
  return
}

if (!response.ok) {
  showError(response)
  return
}

const project = response.body
```

**Instructions for Claude:**

1. Make GET request to verify project exists:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X GET \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/projects/{PROJECT_ID}"
   ```

2. If 404, show error and suggest /cloud list
3. If success, proceed to save link

---

## Link Step 3: Save Project Link

Save the project ID to local config.

**Pseudo-code:**
```javascript
function saveProjectLink(projectId, projectName) {
  const localPath = "./.plan-config.json"

  // Read existing config or create new
  let existingConfig = {}
  if (fileExists(localPath)) {
    try {
      existingConfig = JSON.parse(readFile(localPath))
    } catch (error) {
      existingConfig = {}
    }
  }

  // Update cloud section with project link
  if (!existingConfig.cloud) {
    existingConfig.cloud = {}
  }

  existingConfig.cloud.projectId = projectId
  existingConfig.cloud.projectName = projectName
  existingConfig.cloud.linkedAt = new Date().toISOString()

  // Write back
  writeFile(localPath, JSON.stringify(existingConfig, null, 2))
}

saveProjectLink(targetProjectId, project.name)
```

**Instructions for Claude:**

1. Read `./.plan-config.json` (create if doesn't exist)
2. Update `cloud.projectId` and `cloud.projectName`
3. Add `cloud.linkedAt` timestamp
4. Write back to file

---

## Link Step 4: Show Success

Display confirmation of successful link.

**Pseudo-code:**
```javascript
console.log(t.commands.cloud.linkSuccess)
console.log("")
console.log(t.commands.cloud.linkDetails)
console.log(`  ${t.commands.cloud.projectName} ${project.name}`)
console.log(`  ${t.commands.cloud.projectId} ${project.id}`)
console.log("")
console.log(`${t.commands.cloud.syncNow}`)
```

**Instructions for Claude:**

Output:
```
Project linked successfully!

Local PROJECT_PLAN.md is now linked to:
  Project: E-commerce App
  ID: abc123

Run /sync push to upload your plan.
```

---

# Unlink Action Handler

## Unlink Step 1: Check If Linked

Verify a project is currently linked.

**Pseudo-code:**
```javascript
const currentProjectId = config.cloud?.projectId

if (!currentProjectId) {
  console.log(t.commands.cloud.notLinked)
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.projectId` exists
2. If not, show:
   ```
   No project currently linked.
   ```

---

## Unlink Step 2: Remove Link from Config

Clear the project link from config.

**Pseudo-code:**
```javascript
function removeProjectLink() {
  const localPath = "./.plan-config.json"

  if (!fileExists(localPath)) {
    return
  }

  let existingConfig = JSON.parse(readFile(localPath))

  // Remove project link fields
  if (existingConfig.cloud) {
    delete existingConfig.cloud.projectId
    delete existingConfig.cloud.projectName
    delete existingConfig.cloud.linkedAt
    delete existingConfig.cloud.lastSyncedAt
  }

  writeFile(localPath, JSON.stringify(existingConfig, null, 2))
}

const projectName = config.cloud?.projectName || currentProjectId
removeProjectLink()
```

**Instructions for Claude:**

1. Read `./.plan-config.json`
2. Remove `cloud.projectId`, `cloud.projectName`, `cloud.linkedAt`, `cloud.lastSyncedAt`
3. Write back to file

---

## Unlink Step 3: Show Success

Display confirmation of successful unlink.

**Pseudo-code:**
```javascript
console.log(t.commands.cloud.unlinkSuccess)
console.log("")
console.log(t.commands.cloud.unlinkDetails)
```

**Instructions for Claude:**

Output:
```
Project unlinked.

Local project is no longer linked to cloud.
```

---

# New Action Handler

## New Step 1: Check PROJECT_PLAN.md Exists

Verify local plan file exists before creating cloud project.

**Pseudo-code:**
```javascript
const planPath = "./PROJECT_PLAN.md"

if (!fileExists(planPath)) {
  console.log(t.commands.update.planNotFound)
  console.log("")
  console.log(t.commands.update.runPlanNew)
  return
}

const planContent = readFile(planPath)
```

**Instructions for Claude:**

1. Check if `PROJECT_PLAN.md` exists
2. If not, show error:
   ```
   Error: PROJECT_PLAN.md not found in current directory.

   Please run /new first to create a project plan.
   ```

---

## New Step 2: Determine Project Name

Extract or use provided project name.

**Pseudo-code:**
```javascript
function extractProjectName(planContent) {
  // Look for project name in plan
  // Usually in Overview section: **Project:** Name
  const match = planContent.match(/\*\*Project:\*\*\s*(.+)/i)
  if (match) return match[1].trim()

  // Or first # header
  const headerMatch = planContent.match(/^#\s+(.+)/m)
  if (headerMatch) return headerMatch[1].trim()

  return "My Project"
}

const projectName = customName || extractProjectName(planContent)
```

**Instructions for Claude:**

1. If `customName` was provided in arguments, use it
2. Otherwise, extract from PROJECT_PLAN.md:
   - Look for `**Project:** Name` pattern
   - Or use first `# Header`
3. Default to "My Project" if nothing found

---

## New Step 3: Create Cloud Project

Call API to create new project.

**Pseudo-code:**
```javascript
console.log(t.commands.cloud.creating)

const response = makeRequest("POST", "/projects", {
  name: projectName,
  description: `Created from local PROJECT_PLAN.md`
}, config.cloud.apiToken)

// Response structure:
// Success (201):
// {
//   "id": "ghi789",
//   "name": "My New Project",
//   "createdAt": "2026-01-31T15:00:00Z",
//   ...
// }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"
PROJECT_NAME="My Project"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"name\": \"$PROJECT_NAME\"}" \
  "${API_URL}/projects")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Show "Creating cloud project..." message
2. Make POST request to create project:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     -d '{"name": "{PROJECT_NAME}"}' \
     "https://api.planflow.tools/projects"
   ```

3. Handle response (201 = success)

---

## New Step 4: Save Link and Show Success

Save new project link and display success.

**Pseudo-code:**
```javascript
if (response.ok) {
  const newProject = response.body

  // Save project link
  saveProjectLink(newProject.id, newProject.name)

  // Show success
  console.log(t.commands.cloud.createSuccess)
  console.log("")
  console.log(`  ${t.commands.cloud.projectName} ${newProject.name}`)
  console.log(`  ${t.commands.cloud.projectId} ${newProject.id}`)
  console.log("")
  console.log(t.commands.cloud.syncNow)
} else {
  showError(response)
}
```

**Instructions for Claude:**

1. If successful (201):
   - Extract project ID from response
   - Save to local config (same as Link Step 3)
   - Show success:
     ```
     Cloud project created!

       Project: My Project
       ID: ghi789

     Run /sync push to upload your plan.
     ```

2. If error, show appropriate message

---

## Error Handling

### Not Authenticated

```
Not authenticated. Run /login first.

Run: /login
```

### Project Not Found

```
Project 'abc123' not found.

Run /cloud list to see available projects.
```

### Network Error

```
Cannot connect to PlanFlow API

Please check:
   Your internet connection
   PlanFlow service status

Try again in a few moments.
```

### Server Error

```
Server error. Please try again later.
```

---

## Examples

### Example 1: List Projects (Default)

```bash
$ /cloud
```

Output:
```
Your Cloud Projects

  ID        Name                Tasks     Progress    Last Updated
  ────────  ──────────────────  ────────  ──────────  ────────────────
  abc123    E-commerce App      24/45     53%         2 hours ago
  def456    Mobile API          12/18     67%         Yesterday
  ghi789    Dashboard           8/8       100%        Last week

  Current: E-commerce App

  Commands:
    /cloud link <id>     - Link local project
    /cloud unlink        - Unlink current project
    /cloud new           - Create cloud project
```

### Example 2: Link to Project (Interactive)

```bash
$ /cloud link
```

Output:
```
Select a project to link:
```

User selects "E-commerce App (abc123)"...

Output:
```
Project linked successfully!

Local PROJECT_PLAN.md is now linked to:
  Project: E-commerce App
  ID: abc123

Run /sync push to upload your plan.
```

### Example 3: Link to Specific Project

```bash
$ /cloud link def456
```

Output:
```
Project linked successfully!

Local PROJECT_PLAN.md is now linked to:
  Project: Mobile API
  ID: def456

Run /sync push to upload your plan.
```

### Example 4: Unlink Project

```bash
$ /cloud unlink
```

Output:
```
Project unlinked.

Local project is no longer linked to cloud.
```

### Example 5: Create New Cloud Project

```bash
$ /cloud new
```

Output:
```
Creating cloud project...

Cloud project created!

  Project: PlanFlow Cloud Integration
  ID: xyz789

Run /sync push to upload your plan.
```

### Example 6: Create with Custom Name

```bash
$ /cloud new "My Awesome App"
```

Output:
```
Creating cloud project...

Cloud project created!

  Project: My Awesome App
  ID: abc456

Run /sync push to upload your plan.
```

### Example 7: No Projects

```bash
$ /cloud
```

Output:
```
Your Cloud Projects

No cloud projects found.
Create your first project with /cloud new
```

### Example 8: Not Authenticated

```bash
$ /cloud
```

Output:
```
Not authenticated. Run /login first.

Run: /login
```

### Example 9: Georgian Language

```bash
$ /cloud
```

Output (with Georgian translations):
```
Your Cloud Projects

  ID        Name                Tasks     Progress    Last Updated
  ────────  ──────────────────  ────────  ──────────  ────────────────
  abc123    E-commerce App      24/45     53%         2 საათის წინ
  def456    Mobile API          12/18     67%         გუშინ

  მიმდინარე: E-commerce App

  ბრძანებები:
    /cloud link <id>     - ლოკალური პროექტის დაკავშირება
    /cloud unlink        - მიმდინარე პროექტის გათიშვა
    /cloud new           - ახალი ქლაუდ პროექტის შექმნა
```

---

## Testing

```bash
# Test 1: Not authenticated
rm -f ~/.config/claude/plan-plugin-config.json
/cloud
# Should show "Not authenticated" error

# Test 2: List projects (authenticated)
/login pf_valid_token
/cloud
# Should show project list

# Test 3: List with no projects
/cloud
# Should show "No cloud projects found"

# Test 4: Link interactive
/cloud link
# Should show selection prompt

# Test 5: Link specific ID
/cloud link abc123
# Should link and show success

# Test 6: Link invalid ID
/cloud link invalid123
# Should show "Project not found"

# Test 7: Unlink
/cloud unlink
# Should unlink and show success

# Test 8: Unlink when not linked
/cloud unlink
# Should show "No project currently linked"

# Test 9: Create new project
/cloud new
# Should create project from PROJECT_PLAN.md

# Test 10: Create with custom name
/cloud new "Test Project"
# Should create project with custom name

# Test 11: Create without PROJECT_PLAN.md
rm -f PROJECT_PLAN.md
/cloud new
# Should show "PROJECT_PLAN.md not found"

# Test 12: Georgian language
/settings language
# Select Georgian
/cloud
# Messages should be in Georgian
```

---

## Translation Keys Reference

| Key | English | Usage |
|-----|---------|-------|
| `t.commands.cloud.title` | "Cloud Projects" | Title |
| `t.commands.cloud.listProjects` | "Your Cloud Projects" | List header |
| `t.commands.cloud.noProjects` | "No cloud projects found." | Empty state |
| `t.commands.cloud.createFirst` | "Create your first project with /cloud new" | Empty hint |
| `t.commands.cloud.selectProject` | "Select a project to link:" | Link prompt |
| `t.commands.cloud.linkSuccess` | "Project linked successfully!" | Link success |
| `t.commands.cloud.linkDetails` | "Local PROJECT_PLAN.md is now linked to:" | Link details |
| `t.commands.cloud.unlinkSuccess` | "Project unlinked." | Unlink success |
| `t.commands.cloud.unlinkDetails` | "Local project is no longer linked to cloud." | Unlink details |
| `t.commands.cloud.notLinked` | "No project currently linked." | Not linked |
| `t.commands.cloud.currentProject` | "Current:" | Current indicator |
| `t.commands.cloud.commands` | "Commands:" | Commands header |
| `t.commands.cloud.linkCommand` | "/cloud link <id> - Link local project" | Link hint |
| `t.commands.cloud.unlinkCommand` | "/cloud unlink - Unlink current project" | Unlink hint |
| `t.commands.cloud.newCommand` | "/cloud new - Create cloud project" | New hint |
| `t.commands.cloud.creating` | "Creating cloud project..." | Creating message |
| `t.commands.cloud.createSuccess` | "Cloud project created!" | Create success |
| `t.commands.cloud.projectName` | "Project:" | Project name label |
| `t.commands.cloud.projectId` | "ID:" | Project ID label |
| `t.commands.cloud.syncNow` | "Run /sync push to upload your plan." | Sync suggestion |
| `t.commands.cloud.tableId` | "ID" | Table header |
| `t.commands.cloud.tableName` | "Name" | Table header |
| `t.commands.cloud.tableTasks` | "Tasks" | Table header |
| `t.commands.cloud.tableProgress` | "Progress" | Table header |
| `t.commands.cloud.tableUpdated` | "Last Updated" | Table header |

---

## Dependencies

This command uses:
- **skills/api-client/SKILL.md** - For making API requests
- **skills/credentials/SKILL.md** - For reading credentials

---

## Related Commands

- `/login` - Authenticate with PlanFlow
- `/logout` - Clear credentials
- `/sync` - Sync project with cloud
- `/whoami` - Show current user info

---

## Notes

- `/cloud` defaults to `/cloud list`
- Project links are stored in `./.plan-config.json` (project-specific)
- Creating a new project automatically links it
- Unlinking doesn't delete the cloud project, just removes local association
- Use `/sync` after linking to synchronize content
