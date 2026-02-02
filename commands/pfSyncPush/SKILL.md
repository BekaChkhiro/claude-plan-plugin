---
name: pfSyncPush
description: Push local PROJECT_PLAN.md to PlanFlow cloud
---

# PlanFlow Sync Push

Push local PROJECT_PLAN.md to PlanFlow cloud.

## Usage

```bash
/pfSyncPush                 # Push local → cloud
/pfSyncPush --force         # Overwrite cloud without confirmation
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

Run: /pfCloudLink
```

## Step 3: Push to Cloud

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

## Error Handling

**No PROJECT_PLAN.md:**
```
❌ {t.commands.sync.noPlan}

Run: /planNew to create a plan first.
```

**Network Error:**
```
❌ Network error. Please check your connection.
```
