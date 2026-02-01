# /sync - Sync PROJECT_PLAN.md with PlanFlow Cloud

Synchronize your local PROJECT_PLAN.md with PlanFlow cloud for backup, collaboration, and cross-device access.

## Usage

```bash
/sync                     # Show sync status (default)
/sync push                # Push local → cloud
/sync push --force        # Overwrite cloud version without conflict check
/sync pull                # Pull cloud → local
/sync pull --force        # Overwrite local version without confirmation
/sync status              # Show detailed sync status
```

## What This Command Does

- **push**: Upload local PROJECT_PLAN.md to cloud
- **pull**: Download cloud version to local
- **status**: Show sync status between local and cloud (T3.3)

## Prerequisites

- Authenticated with PlanFlow (`/login`)
- PROJECT_PLAN.md exists in current directory
- Project linked to cloud (`/cloud link`) or will prompt to create

---

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

Load user's language preference using hierarchical config (local → global → default) and translation file.

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
const lastSyncedAt = cloudConfig.lastSyncedAt || null

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
6. Extract cloud config: `apiToken`, `apiUrl`, `projectId`, `lastSyncedAt`

---

## Step 1: Parse Command Arguments

Determine which sync action to perform.

**Pseudo-code:**
```javascript
const args = parseArguments()  // Get arguments after "/sync"

// Determine action
let action = "status"  // Default action
if (args.includes("push")) {
  action = "push"
} else if (args.includes("pull")) {
  action = "pull"
} else if (args.includes("status")) {
  action = "status"
}

// Check for --force flag
const forceMode = args.includes("--force") || args.includes("-f")
```

**Instructions for Claude:**

Parse the command arguments:
- `/sync` → `action = "status"`
- `/sync push` → `action = "push"`
- `/sync push --force` → `action = "push"`, `forceMode = true`
- `/sync pull` → `action = "pull"`
- `/sync pull --force` → `action = "pull"`, `forceMode = true`
- `/sync status` → `action = "status"`

---

## Step 2: Check Authentication

Verify user is logged in before any sync operation.

**Pseudo-code:**
```javascript
function isAuthenticated(config) {
  return !!config.cloud?.apiToken
}

if (!isAuthenticated(config)) {
  console.log(t.commands.sync.notAuthenticated)
  console.log("")
  console.log("💡 Run: /login")
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.apiToken` exists
2. If not, show error:
   ```
   ❌ Not authenticated. Run /login first.

   💡 Run: /login
   ```
3. Stop execution if not authenticated

---

## Step 3: Check PROJECT_PLAN.md Exists

Verify local plan file exists before sync operations.

**Pseudo-code:**
```javascript
const planPath = "./PROJECT_PLAN.md"

if (!fileExists(planPath)) {
  console.log(t.commands.update.planNotFound)
  console.log("")
  console.log(t.commands.update.runPlanNew)
  return
}
```

**Instructions for Claude:**

1. Use Read tool to check if `PROJECT_PLAN.md` exists
2. If not found, show error:
   ```
   ❌ Error: PROJECT_PLAN.md not found in current directory.

   Please run /new first to create a project plan.
   ```
3. Stop execution if file doesn't exist

---

## Step 4: Route to Action Handler

Based on the action, execute the appropriate handler.

**Pseudo-code:**
```javascript
switch (action) {
  case "push":
    handlePush(config, planContent, forceMode, t)
    break
  case "pull":
    handlePull(config, forceMode, t)
    break
  case "status":
    handleStatus(config, planContent, t)
    break
}
```

---

# Push Action Handler

## Push Step 1: Check Project Link

Verify project is linked to cloud, or offer to create new project.

**Pseudo-code:**
```javascript
const projectId = config.cloud?.projectId

if (!projectId) {
  console.log(t.commands.sync.notLinked)
  console.log("")

  // Ask user what to do
  const response = AskUserQuestion({
    questions: [{
      question: "What would you like to do?",
      header: "No cloud project",
      options: [
        { label: "Create new cloud project", description: "Create a new project in PlanFlow and link it" },
        { label: "Link to existing project", description: "Connect to an existing cloud project" },
        { label: "Cancel", description: "Cancel sync operation" }
      ]
    }]
  })

  if (response === "Create new cloud project") {
    projectId = await createNewProject(config, planContent, t)
  } else if (response === "Link to existing project") {
    console.log("Run: /cloud link")
    return
  } else {
    return  // Cancel
  }
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.projectId` exists
2. If not linked, show error and ask user:
   ```
   ❌ Project not linked to cloud. Run /cloud link first.
   ```
3. Use AskUserQuestion with options:
   - "Create new cloud project" - Create and link new project
   - "Link to existing project" - Suggest running /cloud link
   - "Cancel" - Abort sync
4. If user chooses to create new project, proceed to create it (see Push Step 1a)
5. If user chooses to link existing, show hint and stop
6. If user cancels, stop

---

## Push Step 1a: Create New Cloud Project (if needed)

Create a new cloud project from the local plan.

**Pseudo-code:**
```javascript
async function createNewProject(config, planContent, t) {
  // Extract project name from plan
  const projectName = extractProjectName(planContent)

  console.log(t.commands.cloud.creating)

  // Make API request
  const response = makeRequest("POST", "/projects", {
    name: projectName,
    description: `Created from local PROJECT_PLAN.md`
  }, config.cloud.apiToken)

  if (response.ok) {
    const newProjectId = response.body.id

    // Save project link to local config
    saveProjectLink(newProjectId)

    console.log(t.commands.cloud.createSuccess)
    console.log(`  ${t.commands.cloud.projectName} ${projectName}`)
    console.log(`  ${t.commands.cloud.projectId} ${newProjectId}`)

    return newProjectId
  } else {
    // Handle error
    showApiError(response, t)
    return null
  }
}

function extractProjectName(planContent) {
  // Look for project name in plan
  // Usually in Overview section or first header
  const match = planContent.match(/\*\*Project:\*\*\s*(.+)/i)
    || planContent.match(/^#\s+(.+)/m)

  return match ? match[1].trim() : "My Project"
}
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

1. Extract project name from PROJECT_PLAN.md:
   - Look for `**Project:** Name` pattern
   - Or use first `# Header`
   - Default to "My Project" if not found

2. Make API POST request to create project:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     -d '{"name": "{PROJECT_NAME}"}' \
     "https://api.planflow.tools/projects"
   ```

3. If successful (201):
   - Extract project ID from response
   - Save to local config `./.plan-config.json`
   - Show success message

4. If error, show appropriate message and stop

---

## Push Step 2: Read Local Plan Content

Read the full PROJECT_PLAN.md content for upload.

**Pseudo-code:**
```javascript
const planContent = readFile("./PROJECT_PLAN.md")

// Calculate basic stats from content
const stats = calculatePlanStats(planContent)
// { totalTasks, completedTasks, progress }
```

**Instructions for Claude:**

1. Read full content of PROJECT_PLAN.md using Read tool
2. Store the content for API upload
3. Optionally parse to get task stats for display

---

## Push Step 3: Push to Cloud API

Upload plan content to cloud.

**Pseudo-code:**
```javascript
console.log(t.commands.sync.pushing)

const response = makeRequest("PUT", `/projects/${projectId}/plan`, {
  content: planContent
}, config.cloud.apiToken)

// Response structure:
// Success (200):
// {
//   "success": true,
//   "updatedAt": "2026-01-31T15:30:00Z",
//   "hash": "sha256:def456...",
//   "stats": { "totalTasks": 16, "completedTasks": 5, "progress": 31 }
// }
//
// Conflict (409):
// {
//   "error": "Plan has been modified on the server",
//   "code": "CONFLICT",
//   "serverHash": "sha256:xyz789...",
//   "serverUpdatedAt": "2026-01-31T15:00:00Z"
// }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"
PROJECT_ID="abc123"
PLAN_CONTENT="$PLAN_CONTENT"  # Escaped JSON string

# Escape content for JSON
ESCAPED_CONTENT=$(echo "$PLAN_CONTENT" | jq -Rs .)

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X PUT \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"content\": $ESCAPED_CONTENT}" \
  "${API_URL}/projects/${PROJECT_ID}/plan")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Show "Pushing local changes to cloud..." message

2. Make API PUT request:
   ```bash
   # First, escape the plan content for JSON
   # Then make the request
   curl -s -w "\n%{http_code}" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     -d '{"content": "{ESCAPED_PLAN_CONTENT}"}' \
     "https://api.planflow.tools/projects/{PROJECT_ID}/plan"
   ```

   **IMPORTANT**: The plan content must be properly escaped for JSON. Use a temporary file approach:
   ```bash
   # Write plan content to temp file
   cat PROJECT_PLAN.md > /tmp/plan_content.txt

   # Create JSON payload using jq
   jq -n --rawfile content /tmp/plan_content.txt '{"content": $content}' > /tmp/payload.json

   # Make request with payload file
   curl -s -w "\n%{http_code}" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     -d @/tmp/payload.json \
     "https://api.planflow.tools/projects/{PROJECT_ID}/plan"
   ```

3. Parse response and proceed to Push Step 4

---

## Push Step 4: Handle Push Response

Process the API response from push operation.

### Success Response (HTTP 200)

**Pseudo-code:**
```javascript
if (response.ok) {
  const data = response.body

  // Update lastSyncedAt in config
  updateLastSyncedAt(data.updatedAt)

  // Show success message
  console.log(t.commands.sync.pushSuccess)
  console.log("")
  console.log("📊 Sync Details:")
  console.log(`   ${t.commands.cloud.projectId} ${projectId}`)
  console.log(`   ${t.commands.sync.lastSyncedAt} ${formatDate(data.updatedAt)}`)
  console.log("")
  console.log("📈 Project Stats:")
  console.log(`   Total Tasks: ${data.stats.totalTasks}`)
  console.log(`   Completed: ${data.stats.completedTasks}`)
  console.log(`   Progress: ${data.stats.progress}%`)
}
```

**Instructions for Claude:**

1. If HTTP 200:
   - Parse JSON response
   - Update `lastSyncedAt` in config file
   - Show success message:

   ```
   ✅ Changes pushed to cloud!

   📊 Sync Details:
      ID: abc123
      Last synced: Just now

   📈 Project Stats:
      Total Tasks: 16
      Completed: 7
      Progress: 44%
   ```

### Conflict Response (HTTP 409)

**Pseudo-code:**
```javascript
if (response.status === 409) {
  if (forceMode) {
    // Force push - retry with force flag
    console.log("⚠️ Cloud version differs. Force pushing...")
    const forceResponse = makeRequest("PUT", `/projects/${projectId}/plan`, {
      content: planContent,
      force: true
    }, config.cloud.apiToken)

    // Handle force response...
  } else {
    // Show conflict and ask user
    console.log(t.commands.sync.conflict)
    console.log("")
    console.log(t.commands.sync.conflictDetails)
    console.log(`   Server updated: ${response.body.serverUpdatedAt}`)
    console.log("")

    const choice = AskUserQuestion({
      questions: [{
        question: t.commands.sync.conflictOptions,
        header: "Conflict",
        options: [
          { label: t.commands.sync.keepLocal, description: "Overwrite cloud with local version" },
          { label: t.commands.sync.keepCloud, description: "Discard local changes and use cloud version" },
          { label: "Cancel", description: "Cancel sync and resolve manually" }
        ]
      }]
    })

    if (choice === t.commands.sync.keepLocal) {
      // Force push
    } else if (choice === t.commands.sync.keepCloud) {
      // Pull instead
    }
  }
}
```

**Instructions for Claude:**

1. If HTTP 409 (Conflict):
   - If `--force` was specified, retry with force flag
   - Otherwise, show conflict message and ask user:

   ```
   ⚠️ Conflict detected!

   Both local and cloud have been modified since last sync.
      Server updated: 2026-01-31 15:00:00

   Choose how to resolve:
   ```

   Use AskUserQuestion with options:
   - "Keep local version" - Force push local
   - "Keep cloud version" - Pull cloud instead
   - "Cancel" - Stop and let user resolve

### Error Response

**Pseudo-code:**
```javascript
if (response.status === 401) {
  console.log(t.commands.sync.notAuthenticated)
  console.log("💡 Run: /login")
  return
}

if (response.status === 404) {
  console.log("❌ Project not found on cloud.")
  console.log("The linked project may have been deleted.")
  console.log("")
  console.log("💡 Run: /cloud link to link a different project")
  // Clear projectId from config
  return
}

if (response.status >= 500) {
  console.log("❌ Server error. Please try again later.")
  return
}
```

**Instructions for Claude:**

Handle various error codes:
- **401**: Token expired/invalid → suggest /login
- **404**: Project not found → suggest /cloud link
- **500+**: Server error → suggest retry later

---

## Push Step 5: Update Config

Save sync timestamp to config.

**Pseudo-code:**
```javascript
function updateLastSyncedAt(timestamp) {
  // Prefer updating local config if it has projectId
  const localPath = "./.plan-config.json"

  let config = {}
  if (fileExists(localPath)) {
    config = JSON.parse(readFile(localPath))
  }

  if (!config.cloud) {
    config.cloud = {}
  }

  config.cloud.lastSyncedAt = timestamp

  writeFile(localPath, JSON.stringify(config, null, 2))
}
```

**Instructions for Claude:**

1. Read current `./.plan-config.json`
2. Update `cloud.lastSyncedAt` with timestamp from response
3. Write back config file

---

# Status Action Handler (Default)

Show current sync status between local and cloud. This is the default action when running `/sync` without arguments.

---

## Status Step 1: Show Header

Display the sync status section header.

**Pseudo-code:**
```javascript
console.log(t.commands.sync.status)
console.log("")
```

**Instructions for Claude:**

Output:
```
📊 Sync Status
```

---

## Status Step 2: Get Local File Info

Get the modification time of the local PROJECT_PLAN.md file.

**Pseudo-code:**
```javascript
const localModified = getFileModifiedTime("./PROJECT_PLAN.md")
const localModifiedRelative = formatRelativeTime(localModified)
// e.g., "5 minutes ago", "2 hours ago", "yesterday"

console.log(`  ${t.commands.sync.localFile} PROJECT_PLAN.md (modified ${localModifiedRelative})`)
```

**Bash Implementation:**
```bash
# Get file modification time in human-readable format
# macOS:
MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "./PROJECT_PLAN.md")

# Linux:
# MODIFIED=$(stat -c "%y" "./PROJECT_PLAN.md" | cut -d'.' -f1)

# For relative time, calculate difference from now
NOW=$(date +%s)
FILE_TIME=$(stat -f "%m" "./PROJECT_PLAN.md")  # macOS
# FILE_TIME=$(stat -c "%Y" "./PROJECT_PLAN.md")  # Linux

DIFF=$((NOW - FILE_TIME))

if [ $DIFF -lt 60 ]; then
  RELATIVE="just now"
elif [ $DIFF -lt 3600 ]; then
  MINS=$((DIFF / 60))
  RELATIVE="${MINS} minute(s) ago"
elif [ $DIFF -lt 86400 ]; then
  HOURS=$((DIFF / 3600))
  RELATIVE="${HOURS} hour(s) ago"
else
  DAYS=$((DIFF / 86400))
  RELATIVE="${DAYS} day(s) ago"
fi

echo "  Local:   PROJECT_PLAN.md (modified ${RELATIVE})"
```

**Instructions for Claude:**

1. Use Bash to get the file modification time of PROJECT_PLAN.md
2. Calculate relative time (e.g., "5 minutes ago")
3. Show local file info:
   ```
     Local:   PROJECT_PLAN.md (modified 5 minutes ago)
   ```

---

## Status Step 3: Check Project Link

Check if the project is linked to a cloud project.

**Pseudo-code:**
```javascript
const projectId = config.cloud?.projectId

if (!projectId) {
  console.log(`  ${t.commands.sync.cloudProject} Not linked`)
  console.log(`  ${t.commands.sync.syncStatus} ❌ Not synced`)
  console.log("")
  console.log(t.commands.sync.notLinked)
  console.log("")
  console.log("💡 Run: /cloud link")
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.projectId` exists in the loaded config
2. If NOT linked, show:
   ```
     Cloud:   Not linked
     Status:  ❌ Not synced

   ❌ Project not linked to cloud. Run /cloud link first.

   💡 Run: /cloud link
   ```
3. Stop execution if not linked

---

## Status Step 4: Fetch Cloud Project Info

Get the cloud project details from the API.

**Pseudo-code:**
```javascript
const response = makeRequest("GET", `/projects/${projectId}`, null, config.cloud.apiToken)

// Response structure:
// Success (200):
// {
//   "id": "abc123",
//   "name": "My Project",
//   "updatedAt": "2026-01-31T15:30:00Z",
//   "stats": {
//     "totalTasks": 16,
//     "completedTasks": 9,
//     "progress": 56
//   }
// }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"
PROJECT_ID="abc123"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "${API_URL}/projects/${PROJECT_ID}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Make GET request to `/projects/{projectId}`:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X GET \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/projects/{PROJECT_ID}"
   ```

2. Parse the response and extract:
   - `name` - Project name
   - `updatedAt` - Last updated timestamp
   - `stats` - Task statistics (optional)

3. Handle errors:
   - **401**: Token expired → suggest /login
   - **404**: Project not found → suggest /cloud link
   - **500+**: Server error → suggest retry

---

## Status Step 5: Compare Timestamps and Show Status

Compare local file time, cloud update time, and last sync time to determine status.

**Pseudo-code:**
```javascript
const project = response.body
const cloudUpdatedAt = new Date(project.updatedAt)
const lastSyncedAt = config.cloud?.lastSyncedAt ? new Date(config.cloud.lastSyncedAt) : null

// Show cloud project info
console.log(`  ${t.commands.sync.cloudProject} ${project.name} (updated ${formatRelativeTime(cloudUpdatedAt)})`)

// Show last synced time
if (lastSyncedAt) {
  console.log(`  ${t.commands.sync.lastSyncedAt} ${formatRelativeTime(lastSyncedAt)}`)
} else {
  console.log(`  ${t.commands.sync.lastSyncedAt} ${t.commands.sync.never}`)
}

// Determine sync status
let status
let suggestion

if (!lastSyncedAt) {
  // Never synced
  status = "⚠️ Never synced"
  suggestion = t.commands.sync.runPush
} else if (localModified > lastSyncedAt && cloudUpdatedAt > lastSyncedAt) {
  // Both modified - conflict
  status = "⚠️ Conflict - both local and cloud modified"
  suggestion = "Review changes before syncing"
} else if (localModified > lastSyncedAt) {
  // Local is newer
  status = t.commands.sync.localAhead
  suggestion = t.commands.sync.runPush
} else if (cloudUpdatedAt > lastSyncedAt) {
  // Cloud is newer
  status = t.commands.sync.cloudAhead
  suggestion = t.commands.sync.runPull
} else {
  // Up to date
  status = t.commands.sync.upToDate
  suggestion = null
}

console.log(`  ${t.commands.sync.syncStatus} ${status}`)
console.log("")

if (suggestion) {
  console.log(suggestion)
}
```

**Instructions for Claude:**

1. Show cloud project info:
   ```
     Cloud:   My Project (updated 2 hours ago)
   ```

2. Show last sync time:
   ```
     Last synced: 3 hours ago
   ```
   Or if never synced:
   ```
     Last synced: Never
   ```

3. Determine and show status:

   **Case A: Up to date**
   ```
     Status:  ✅ Up to date
   ```

   **Case B: Local changes not synced**
   ```
     Status:  ⚠️ Local changes not synced

   Run /sync push to upload changes
   ```

   **Case C: Cloud has newer changes**
   ```
     Status:  ⚠️ Cloud has newer changes

   Run /sync pull to download changes
   ```

   **Case D: Never synced**
   ```
     Status:  ⚠️ Never synced

   Run /sync push to upload changes
   ```

   **Case E: Conflict (both modified)**
   ```
     Status:  ⚠️ Conflict - both local and cloud modified

   Review changes before syncing:
     /sync push --force  - Overwrite cloud with local
     /sync pull --force  - Overwrite local with cloud
   ```

---

## Status Step 6: Show Change Summary (Optional)

If there are pending changes, show a summary of what will be synced.

**Pseudo-code:**
```javascript
if (localModified > lastSyncedAt) {
  // Parse local plan to get current stats
  const localStats = parsePlanStats(planContent)

  // Compare with cloud stats if available
  if (project.stats) {
    const taskDiff = localStats.completedTasks - project.stats.completedTasks
    const progressDiff = localStats.progress - project.stats.progress

    if (taskDiff !== 0 || progressDiff !== 0) {
      console.log("")
      console.log(`  ${t.commands.sync.changes}`)

      if (taskDiff > 0) {
        console.log(`    ${t.commands.sync.tasksCompleted.replace("{count}", taskDiff)}`)
      } else if (taskDiff < 0) {
        console.log(`    - ${Math.abs(taskDiff)} tasks unmarked locally`)
      }

      if (progressDiff !== 0) {
        const sign = progressDiff > 0 ? "+" : ""
        console.log(`    ~ Progress: ${project.stats.progress}% → ${localStats.progress}% (${sign}${progressDiff}%)`)
      }
    }
  }
}
```

**Instructions for Claude:**

1. If local has changes, parse PROJECT_PLAN.md to get current stats
2. Compare with cloud stats (if returned by API)
3. Show summary of changes:
   ```
     Changes:
       + 2 tasks completed locally
       ~ Progress: 50% → 56% (+6%)
   ```

---

## Status Step 7: Show Project Stats (Optional)

Show current project statistics for context.

**Pseudo-code:**
```javascript
// Parse local plan stats
const stats = parsePlanStats(planContent)

console.log("")
console.log("📈 Project Stats:")
console.log(`   Total Tasks: ${stats.totalTasks}`)
console.log(`   Completed: ${stats.completedTasks}`)
console.log(`   In Progress: ${stats.inProgressTasks}`)
console.log(`   Progress: ${stats.progress}%`)
```

**Instructions for Claude:**

1. Parse PROJECT_PLAN.md to count:
   - Total tasks (count `#### T` headers)
   - Completed tasks (count `[x]` or `DONE` status)
   - In progress tasks (count `IN_PROGRESS` status)
   - Calculate progress percentage

2. Show stats:
   ```
   📈 Project Stats:
      Total Tasks: 16
      Completed: 9
      In Progress: 1
      Progress: 56%
   ```

---

## Complete Status Output Examples

### Example 1: Up to Date

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 10 minutes ago)
  Cloud:   PlanFlow Cloud Integration (updated 10 minutes ago)
  Last synced: 10 minutes ago
  Status:  ✅ Up to date

📈 Project Stats:
   Total Tasks: 16
   Completed: 9
   In Progress: 1
   Progress: 56%
```

### Example 2: Local Changes Pending

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   PlanFlow Cloud Integration (updated 2 hours ago)
  Last synced: 2 hours ago
  Status:  ⚠️ Local changes not synced

  Changes:
    + 2 tasks completed locally
    ~ Progress: 50% → 56% (+6%)

Run /sync push to upload changes

📈 Project Stats:
   Total Tasks: 16
   Completed: 9
   In Progress: 1
   Progress: 56%
```

### Example 3: Cloud Has Newer Changes

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 3 hours ago)
  Cloud:   PlanFlow Cloud Integration (updated 30 minutes ago)
  Last synced: 3 hours ago
  Status:  ⚠️ Cloud has newer changes

Run /sync pull to download changes

📈 Project Stats (local):
   Total Tasks: 16
   Completed: 7
   Progress: 44%
```

### Example 4: Not Linked

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   Not linked
  Status:  ❌ Not synced

❌ Project not linked to cloud. Run /cloud link first.

💡 Run: /cloud link
```

### Example 5: Never Synced (But Linked)

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   PlanFlow Cloud Integration (created just now)
  Last synced: Never
  Status:  ⚠️ Never synced

Run /sync push to upload changes

📈 Project Stats:
   Total Tasks: 16
   Completed: 9
   Progress: 56%
```

### Example 6: Conflict

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   PlanFlow Cloud Integration (updated 10 minutes ago)
  Last synced: 1 hour ago
  Status:  ⚠️ Conflict - both local and cloud modified

Both local and cloud have changes since last sync.

Review changes before syncing:
  /sync push --force  - Overwrite cloud with local
  /sync pull --force  - Overwrite local with cloud
```

### Example 7: Not Authenticated

```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   Unable to check (not authenticated)

❌ Not authenticated. Run /login first.

💡 Run: /login
```

### Example 8: Georgian Language

```
📊 სინქრონიზაციის სტატუსი

  ლოკალური:   PROJECT_PLAN.md (შეცვლილია 5 წუთის წინ)
  ქლაუდი:   PlanFlow Cloud Integration (სინქრონიზებული 2 საათის წინ)
  სტატუსი:  ⚠️ ლოკალური ცვლილებები არ არის სინქრონიზებული

  ცვლილებები:
    + 2 ამოცანა დასრულდა ლოკალურად

გაუშვით /sync push ცვლილებების ასატვირთად
```

---

## Translation Keys Reference

Use these translation keys for status output:

| Key | English | Usage |
|-----|---------|-------|
| `t.commands.sync.status` | "📊 Sync Status" | Header |
| `t.commands.sync.localFile` | "Local:" | Local file label |
| `t.commands.sync.cloudProject` | "Cloud:" | Cloud project label |
| `t.commands.sync.syncStatus` | "Status:" | Status label |
| `t.commands.sync.lastSyncedAt` | "Last synced:" | Last sync time label |
| `t.commands.sync.upToDate` | "✅ Up to date" | Status when synced |
| `t.commands.sync.localAhead` | "⚠️ Local changes not synced" | Status when local newer |
| `t.commands.sync.cloudAhead` | "⚠️ Cloud has newer changes" | Status when cloud newer |
| `t.commands.sync.never` | "Never" | When never synced |
| `t.commands.sync.changes` | "Changes:" | Changes section header |
| `t.commands.sync.tasksCompleted` | "+ {count} tasks completed locally" | Completed tasks |
| `t.commands.sync.runPush` | "Run /sync push to upload changes" | Push suggestion |
| `t.commands.sync.runPull` | "Run /sync pull to download changes" | Pull suggestion |
| `t.commands.sync.notLinked` | "❌ Project not linked to cloud. Run /cloud link first." | Not linked error |
| `t.commands.sync.notAuthenticated` | "❌ Not authenticated. Run /login first." | Auth error |

---

# Pull Action Handler

Pull cloud plan content to local PROJECT_PLAN.md.

## Pull Step 1: Check Project Link

Verify project is linked to cloud.

**Pseudo-code:**
```javascript
const projectId = config.cloud?.projectId

if (!projectId) {
  console.log(t.commands.sync.notLinked)
  console.log("")
  console.log("💡 Run: /cloud link")
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.projectId` exists
2. If not linked, show error:
   ```
   ❌ Project not linked to cloud. Run /cloud link first.

   💡 Run: /cloud link
   ```
3. Stop execution if not linked

---

## Pull Step 2: Fetch Cloud Plan

Get the plan content from cloud API.

**Pseudo-code:**
```javascript
console.log(t.commands.sync.pulling)

const response = makeRequest("GET", `/projects/${projectId}/plan`, null, config.cloud.apiToken)

// Response structure:
// Success (200):
// {
//   "content": "# Project Name\n\n## Overview\n...",
//   "updatedAt": "2026-01-31T15:30:00Z",
//   "hash": "sha256:abc123..."
// }
//
// Not Found (404):
// {
//   "error": "Project not found or no plan uploaded yet",
//   "code": "NOT_FOUND"
// }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"
PROJECT_ID="abc123"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "${API_URL}/projects/${PROJECT_ID}/plan")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Show "Pulling cloud changes to local..." message

2. Make API GET request:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X GET \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/projects/{PROJECT_ID}/plan"
   ```

3. Parse response and proceed to Pull Step 3

---

## Pull Step 3: Handle Pull Response

Process the API response from pull operation.

### Success Response (HTTP 200)

**Pseudo-code:**
```javascript
if (response.ok) {
  const cloudContent = response.body.content
  const cloudUpdatedAt = response.body.updatedAt

  // Check if local file exists
  const localExists = fileExists("./PROJECT_PLAN.md")

  if (localExists && !forceMode) {
    // Read local content for comparison
    const localContent = readFile("./PROJECT_PLAN.md")

    // Check if contents are different
    if (localContent !== cloudContent) {
      // Show warning and ask for confirmation
      console.log("⚠️ Local PROJECT_PLAN.md will be overwritten.")
      console.log("")
      console.log("📊 Comparison:")
      console.log(`   Local file modified: ${getFileModifiedTime("./PROJECT_PLAN.md")}`)
      console.log(`   Cloud version from: ${formatDate(cloudUpdatedAt)}`)
      console.log("")

      const choice = AskUserQuestion({
        questions: [{
          question: "How would you like to proceed?",
          header: "Overwrite",
          options: [
            { label: "Overwrite local", description: "Replace local file with cloud version" },
            { label: "Keep local", description: "Cancel pull and keep local version" },
            { label: "Show diff", description: "Show differences before deciding" }
          ]
        }]
      })

      if (choice === "Keep local") {
        console.log("Pull cancelled. Local file unchanged.")
        return
      }

      if (choice === "Show diff") {
        showDiff(localContent, cloudContent)
        // Ask again after showing diff
        const confirmChoice = AskUserQuestion({
          questions: [{
            question: "After reviewing the diff, how would you like to proceed?",
            header: "Confirm",
            options: [
              { label: "Overwrite local", description: "Replace with cloud version" },
              { label: "Keep local", description: "Cancel and keep local" }
            ]
          }]
        })

        if (confirmChoice === "Keep local") {
          console.log("Pull cancelled. Local file unchanged.")
          return
        }
      }
    } else {
      // Contents are the same
      console.log(t.commands.sync.noChanges)
      console.log("")
      console.log(t.commands.sync.upToDate)
      return
    }
  }

  // Write cloud content to local file
  writeFile("./PROJECT_PLAN.md", cloudContent)

  // Update lastSyncedAt in config
  updateLastSyncedAt(cloudUpdatedAt)

  // Show success
  console.log(t.commands.sync.pullSuccess)
  console.log("")
  console.log("📊 Sync Details:")
  console.log(`   ${t.commands.cloud.projectId} ${projectId}`)
  console.log(`   ${t.commands.sync.lastSyncedAt} ${formatDate(cloudUpdatedAt)}`)

  // Parse and show stats from pulled content
  const stats = parsePlanStats(cloudContent)
  if (stats) {
    console.log("")
    console.log("📈 Project Stats:")
    console.log(`   Total Tasks: ${stats.totalTasks}`)
    console.log(`   Completed: ${stats.completedTasks}`)
    console.log(`   Progress: ${stats.progress}%`)
  }
}
```

**Instructions for Claude:**

1. If HTTP 200:
   - Parse JSON response to get `content` and `updatedAt`
   - Check if local PROJECT_PLAN.md exists

2. If local exists and NOT force mode:
   - Read local content
   - Compare with cloud content
   - If different, ask user for confirmation using AskUserQuestion:
     - "Overwrite local" - proceed with writing
     - "Keep local" - cancel pull
     - "Show diff" - display differences first, then ask again

3. If force mode (`--force`) or user confirms:
   - Write cloud content to PROJECT_PLAN.md using Write tool
   - Update `lastSyncedAt` in config
   - Show success message:

   ```
   ✅ Changes pulled from cloud!

   📊 Sync Details:
      ID: abc123
      Last synced: Just now

   📈 Project Stats:
      Total Tasks: 16
      Completed: 8
      Progress: 50%
   ```

4. If contents are identical:
   ```
   No changes to sync.

   ✅ Up to date
   ```

### Not Found Response (HTTP 404)

**Pseudo-code:**
```javascript
if (response.status === 404) {
  console.log("❌ No plan found on cloud.")
  console.log("")
  console.log("This project may not have been synced yet.")
  console.log("")
  console.log("💡 Run: /sync push to upload your local plan")
  return
}
```

**Instructions for Claude:**

If HTTP 404:
```
❌ No plan found on cloud.

This project may not have been synced yet.

💡 Run: /sync push to upload your local plan
```

### Error Responses

**Pseudo-code:**
```javascript
if (response.status === 401) {
  console.log(t.commands.sync.notAuthenticated)
  console.log("💡 Run: /login")
  return
}

if (response.status >= 500) {
  console.log("❌ Server error. Please try again later.")
  return
}
```

**Instructions for Claude:**

Handle various error codes:
- **401**: Token expired/invalid → suggest /login
- **404**: No plan uploaded yet → suggest /sync push
- **500+**: Server error → suggest retry later

---

## Pull Step 4: Show Diff (Optional)

Display differences between local and cloud versions.

**Pseudo-code:**
```javascript
function showDiff(localContent, cloudContent) {
  console.log("📝 Differences between local and cloud:")
  console.log("─".repeat(60))

  // Simple line-by-line comparison
  const localLines = localContent.split("\n")
  const cloudLines = cloudContent.split("\n")

  // Show summary stats
  const localTaskCount = countTasks(localContent)
  const cloudTaskCount = countTasks(cloudContent)
  const localProgress = calculateProgress(localContent)
  const cloudProgress = calculateProgress(cloudContent)

  console.log("")
  console.log("📊 Summary:")
  console.log(`   Local:  ${localTaskCount} tasks, ${localProgress}% complete`)
  console.log(`   Cloud:  ${cloudTaskCount} tasks, ${cloudProgress}% complete`)
  console.log("")

  // Highlight key differences
  if (localProgress !== cloudProgress) {
    console.log(`   Progress difference: ${cloudProgress - localProgress > 0 ? '+' : ''}${cloudProgress - localProgress}%`)
  }

  console.log("─".repeat(60))
}
```

**Instructions for Claude:**

When user selects "Show diff":
1. Parse both local and cloud content
2. Calculate stats for both versions
3. Show summary comparison:
   ```
   📝 Differences between local and cloud:
   ────────────────────────────────────────────────────────────

   📊 Summary:
      Local:  16 tasks, 50% complete
      Cloud:  16 tasks, 56% complete

      Progress difference: +6%

   Key changes in cloud version:
      • T3.1 marked as DONE (was IN_PROGRESS)
      • T3.2 marked as IN_PROGRESS (was TODO)

   ────────────────────────────────────────────────────────────
   ```

---

## Pull Step 5: Update Config

Save sync timestamp to config after successful pull.

**Pseudo-code:**
```javascript
function updateLastSyncedAt(timestamp) {
  const localPath = "./.plan-config.json"

  let config = {}
  if (fileExists(localPath)) {
    config = JSON.parse(readFile(localPath))
  }

  if (!config.cloud) {
    config.cloud = {}
  }

  config.cloud.lastSyncedAt = timestamp

  writeFile(localPath, JSON.stringify(config, null, 2))
}
```

**Instructions for Claude:**

1. Read current `./.plan-config.json` (create if doesn't exist)
2. Update `cloud.lastSyncedAt` with timestamp from response
3. Write back config file using Write tool

---

## Error Handling

### Not Authenticated

```
❌ Not authenticated. Run /login first.

💡 Run: /login
```

### Project Not Found

```
❌ Error: PROJECT_PLAN.md not found in current directory.

Please run /new first to create a project plan.
```

### Not Linked

```
❌ Project not linked to cloud. Run /cloud link first.

💡 Run: /cloud link
```

### Network Error

```
❌ Cannot connect to PlanFlow API

Please check:
   • Your internet connection
   • PlanFlow service status

Try again in a few moments.
```

### Server Error

```
❌ Server error. Please try again later.

If the problem persists, check status.planflow.tools
```

---

## Examples

### Example 1: Push Local Changes

```bash
$ /sync push
```

Output:
```
🔄 Pushing local changes to cloud...

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 16
   Completed: 7
   Progress: 44%
```

### Example 2: Push with No Link (Create New)

```bash
$ /sync push
```

Output:
```
❌ Project not linked to cloud.

What would you like to do?
```

User selects "Create new cloud project"...

Output:
```
Creating cloud project...

✅ Cloud project created!
   Project: PlanFlow Cloud Integration
   ID: xyz789

🔄 Pushing local changes to cloud...

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: xyz789
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 16
   Completed: 7
   Progress: 44%
```

### Example 3: Force Push

```bash
$ /sync push --force
```

Output:
```
🔄 Pushing local changes to cloud...
⚠️ Force mode enabled - will overwrite cloud version

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now
```

### Example 4: Sync Status

```bash
$ /sync
```

Output:
```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 minutes ago)
  Cloud:   PlanFlow Cloud Integration (synced 2 hours ago)
  Status:  ⚠️ Local changes not synced

  Run /sync push to upload changes
```

### Example 5: Conflict Resolution

```bash
$ /sync push
```

Output:
```
🔄 Pushing local changes to cloud...

⚠️ Conflict detected!

Both local and cloud have been modified since last sync.
   Server updated: 2 hours ago

Choose how to resolve:
```

User selects "Keep local version"...

Output:
```
Force pushing local version...

✅ Changes pushed to cloud!
```

### Example 6: Not Authenticated

```bash
$ /sync push
```

Output:
```
❌ Not authenticated. Run /login first.

💡 Run: /login
```

### Example 7: Georgian Language

```bash
$ /sync push
```

Output (with Georgian translations):
```
🔄 ლოკალური ცვლილებების ატვირთვა ქლაუდში...

✅ ცვლილებები აიტვირთა ქლაუდში!

📊 სინქრონიზაციის დეტალები:
   ID: abc123
   ბოლო სინქრონიზაცია: ახლახან

📈 პროექტის სტატისტიკა:
   ამოცანები სულ: 16
   დასრულებული: 7
   პროგრესი: 44%
```

### Example 8: Pull Cloud Changes

```bash
$ /sync pull
```

Output:
```
🔄 Pulling cloud changes to local...

✅ Changes pulled from cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 16
   Completed: 9
   Progress: 56%
```

### Example 9: Pull with Local Changes (Confirmation)

```bash
$ /sync pull
```

Output:
```
🔄 Pulling cloud changes to local...

⚠️ Local PROJECT_PLAN.md will be overwritten.

📊 Comparison:
   Local file modified: 5 minutes ago
   Cloud version from: 2 hours ago

How would you like to proceed?
```

User selects "Show diff"...

Output:
```
📝 Differences between local and cloud:
────────────────────────────────────────────────────────────

📊 Summary:
   Local:  16 tasks, 50% complete
   Cloud:  16 tasks, 56% complete

   Progress difference: +6%

Key changes in cloud version:
   • T3.1 marked as DONE (was IN_PROGRESS)
   • T3.2 marked as IN_PROGRESS (was TODO)

────────────────────────────────────────────────────────────

After reviewing the diff, how would you like to proceed?
```

User selects "Overwrite local"...

Output:
```
✅ Changes pulled from cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now
```

### Example 10: Force Pull

```bash
$ /sync pull --force
```

Output:
```
🔄 Pulling cloud changes to local...
⚠️ Force mode enabled - will overwrite local version

✅ Changes pulled from cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 16
   Completed: 9
   Progress: 56%
```

### Example 11: Pull - No Cloud Plan

```bash
$ /sync pull
```

Output:
```
🔄 Pulling cloud changes to local...

❌ No plan found on cloud.

This project may not have been synced yet.

💡 Run: /sync push to upload your local plan
```

### Example 12: Pull - Already Up To Date

```bash
$ /sync pull
```

Output:
```
🔄 Pulling cloud changes to local...

No changes to sync.

✅ Up to date
```

---

## Testing

```bash
# === PUSH TESTS ===

# Test 1: Not authenticated
rm -f ~/.config/claude/plan-plugin-config.json
/sync push
# Should show "Not authenticated" error

# Test 2: No PROJECT_PLAN.md
rm -f PROJECT_PLAN.md
/sync push
# Should show "PROJECT_PLAN.md not found" error

# Test 3: Not linked
/login pf_valid_token
/sync push
# Should ask to create or link project

# Test 4: Create and push
# Select "Create new cloud project"
# Should create project and push

# Test 5: Push existing linked project
/sync push
# Should push successfully

# Test 6: Force push
/sync push --force
# Should push without conflict check

# === PULL TESTS ===

# Test 7: Pull not linked
/sync pull
# Should show "Not linked" error

# Test 8: Pull when cloud has no plan
/sync pull
# Should show "No plan found on cloud" error

# Test 9: Pull with confirmation
/sync pull
# Should show comparison and ask for confirmation

# Test 10: Pull with diff
# Select "Show diff"
# Should show differences then ask again

# Test 11: Pull force
/sync pull --force
# Should overwrite local without asking

# Test 12: Pull when already synced
/sync pull
# Should show "Up to date"

# === STATUS TESTS ===

# Test 13: Sync status
/sync
# Should show sync status

# Test 14: Sync status (explicit)
/sync status
# Should show detailed status
```

---

## Dependencies

This command uses:
- **skills/api-client/SKILL.md** - For making API requests
- **skills/credentials/SKILL.md** - For reading/updating credentials

---

## Related Commands

- `/login` - Authenticate with PlanFlow
- `/logout` - Clear credentials
- `/cloud` - Manage cloud projects
- `/cloud link` - Link to existing cloud project
- `/update` - Update task status (triggers auto-sync if enabled)

---

## Notes

- Push uploads the entire PROJECT_PLAN.md content to cloud
- Pull downloads cloud version and overwrites local PROJECT_PLAN.md
- Cloud parses the plan to extract tasks and progress
- Conflict detection is based on timestamps
- Force mode (`--force`) bypasses confirmation/conflict detection
- Auto-sync feature (T3.4) will call push automatically after /update
- Both push and pull update `lastSyncedAt` in local config
