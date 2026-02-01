# PlanFlow Sync

Synchronize PROJECT_PLAN.md between local and PlanFlow cloud.

## Usage

```bash
/pfSync                     # Show sync status (default)
/pfSync push                # Push local → cloud
/pfSync push --force        # Overwrite cloud
/pfSync pull                # Pull cloud → local
/pfSync pull --force        # Overwrite local
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

  return { ...globalConfig, ...localConfig }
}

const config = getConfig()
const language = config.language || "en"
const cloudConfig = config.cloud || {}
const isAuthenticated = !!cloudConfig.apiToken
const projectId = cloudConfig.projectId
const apiUrl = cloudConfig.apiUrl || "https://api.planflow.tools"

const t = JSON.parse(readFile(`locales/${language}.json`))
```

## Step 1: Parse Arguments

```javascript
const args = commandArgs.trim().split(/\s+/)
const action = args[0] || "status"  // status, push, pull
const forceFlag = args.includes("--force")
```

## Step 2: Validate Prerequisites

**Not authenticated:**
```
❌ {t.commands.sync.notAuthenticated}

Run: /pfLogin
```

**Not linked to project:**
```
❌ {t.commands.sync.notLinked}

Run: /pfCloud link
```

---

## ACTION: status (default)

Show comparison between local and cloud:

```
📊 {t.commands.sync.status}

  {t.commands.sync.localFile} PROJECT_PLAN.md (modified 5 min ago)
  {t.commands.sync.cloudProject} My Project (synced 2 hours ago)
  {t.commands.sync.syncStatus} {t.commands.sync.localAhead}

  {t.commands.sync.changes}
    • 2 tasks completed locally
    • 1 task description changed

  💡 Run: /pfSync push
```

---

## ACTION: push

Push local PROJECT_PLAN.md to cloud.

1. Read PROJECT_PLAN.md
2. PUT to API
3. Update lastSyncedAt in config

**API Call:**
```bash
cat PROJECT_PLAN.md > /tmp/plan_content.txt
jq -n --rawfile content /tmp/plan_content.txt '{"plan": $content}' > /tmp/payload.json
curl -s -X PUT \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {TOKEN}" \
  -d @/tmp/payload.json \
  "https://api.planflow.tools/projects/{PROJECT_ID}/plan"
```

**Success:**
```
✅ {t.commands.sync.pushSuccess}

  {t.commands.sync.uploaded} PROJECT_PLAN.md
  {t.commands.sync.to} My Project
  {t.commands.sync.at} 2024-01-15 14:30:00
```

---

## ACTION: pull

Pull plan from cloud to local.

1. GET plan from API
2. Show diff if local exists (unless --force)
3. Write to PROJECT_PLAN.md

**API Call:**
```bash
curl -s \
  -H "Authorization: Bearer {TOKEN}" \
  "https://api.planflow.tools/projects/{PROJECT_ID}/plan"
```

**If local exists and differs (without --force):**
```
⚠️ {t.commands.sync.localChanges}

{t.commands.sync.diff}
  - Task T1.1: IN_PROGRESS → DONE (local)
  + Task T1.2: Added description (cloud)

{t.commands.sync.confirmPull}
```

Use AskUserQuestion to confirm.

**Success:**
```
✅ {t.commands.sync.pullSuccess}

  {t.commands.sync.downloaded} PROJECT_PLAN.md
  {t.commands.sync.from} My Project
  {t.commands.sync.at} 2024-01-15 14:30:00
```

## Error Handling

**No PROJECT_PLAN.md (for push):**
```
❌ {t.commands.sync.noPlan}

Run: /planNew to create a plan first.
```

**Network Error:**
```
❌ Network error. Please check your connection.
```
