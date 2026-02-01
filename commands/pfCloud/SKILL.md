# PlanFlow Cloud

Manage PlanFlow cloud projects - list, link, unlink, and create.

## Usage

```bash
/pfCloud                    # List projects (default)
/pfCloud link               # Interactive project selection
/pfCloud link <id>          # Link to specific project
/pfCloud unlink             # Disconnect from cloud project
/pfCloud new                # Create from local plan
/pfCloud new "Name"         # Create with custom name
```

## Step 0: Load Configuration

```javascript
function getConfig() {
  const localConfigPath = "./.plan-config.json"
  let localConfig = {}
  if (fileExists(localConfigPath)) {
    try { localConfig = JSON.parse(readFile(localConfigPath)) } catch {}
  }

  const globalConfigPath = expandPath("~/.config/claude/plan-plugin-config.json")
  let globalConfig = {}
  if (fileExists(globalConfigPath)) {
    try { globalConfig = JSON.parse(readFile(globalConfigPath)) } catch {}
  }

  return { ...globalConfig, ...localConfig, _localConfig: localConfig, _globalConfig: globalConfig }
}

const config = getConfig()
const language = config.language || "en"
const cloudConfig = config.cloud || {}
const isAuthenticated = !!cloudConfig.apiToken
const currentProjectId = cloudConfig.projectId
const apiUrl = cloudConfig.apiUrl || "https://api.planflow.tools"

const t = JSON.parse(readFile(`locales/${language}.json`))
```

## Step 1: Parse Arguments

```javascript
const args = commandArgs.trim().split(/\s+/)
const action = args[0] || "list"  // list, link, unlink, new
const actionArg = args.slice(1).join(" ")  // project ID or name
```

## Step 2: Validate Authentication

If not authenticated:
```
❌ {t.commands.sync.notAuthenticated}

Run: /pfLogin
```

---

## ACTION: list (default)

List all cloud projects.

**API Call:**
```bash
curl -s \
  -H "Authorization: Bearer {TOKEN}" \
  "https://api.planflow.tools/projects"
```

**Output:**
```
📁 {t.commands.cloud.listProjects}

  ID        Name              Tasks    Progress
  ────────  ────────────────  ───────  ──────────
  abc123    E-commerce App    24/45    53%
  def456    Mobile API        12/18    67%
  ghi789    Dashboard         8/12     75%

  ✓ Current: abc123 (E-commerce App)

💡 Commands:
  /pfCloud link <id>    Link to a project
  /pfCloud unlink       Disconnect current
  /pfCloud new          Create new project
```

---

## ACTION: link

Link local directory to a cloud project.

**If no ID provided:**
Show project list and use AskUserQuestion to select:
```javascript
AskUserQuestion({
  questions: [{
    question: t.commands.cloud.selectProject,
    header: "Project",
    multiSelect: false,
    options: projects.map(p => ({
      label: p.name,
      description: `ID: ${p.id} | ${p.tasksDone}/${p.tasksTotal} tasks`
    }))
  }]
})
```

**Save to local config (`.plan-config.json`):**
```json
{
  "cloud": {
    "projectId": "selected-uuid"
  }
}
```

**Success:**
```
✅ {t.commands.cloud.linked}

  Project: E-commerce App
  ID: abc123

💡 Run /pfSync to sync your plan
```

---

## ACTION: unlink

Disconnect from current cloud project.

**Remove from local config:**
Remove `cloud.projectId` from `.plan-config.json`

**Output:**
```
✅ {t.commands.cloud.unlinked}

Local PROJECT_PLAN.md is now independent.
```

---

## ACTION: new

Create a new cloud project.

1. Check if PROJECT_PLAN.md exists
2. Extract project name from plan (or use argument)
3. Create project via API
4. Link to new project
5. Push current plan

**If no PROJECT_PLAN.md:**
```
❌ {t.commands.cloud.noPlan}

Run: /planNew to create a plan first.
```

**API Call:**
```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {TOKEN}" \
  -d '{"name": "Project Name"}' \
  "https://api.planflow.tools/projects"
```

**Success:**
```
✅ {t.commands.cloud.created}

  Project: My New Project
  ID: xyz789

📤 Pushing local plan to cloud...

✅ {t.commands.sync.pushSuccess}

💡 Your project is now synced!
```

## Error Handling

**Project not found:**
```
❌ Project not found: {id}

Run: /pfCloud to see available projects.
```

**Already linked:**
```
⚠️ Already linked to: {projectName}

Run: /pfCloud unlink first to switch projects.
```
