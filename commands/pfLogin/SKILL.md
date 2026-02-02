---
name: pfLogin
description: PlanFlow Login
---

# PlanFlow Login

Authenticate with PlanFlow project management service.

**IMPORTANT:** This is ONLY for PlanFlow (planflow.tools) - NOT for Claude or Claude Code authentication.

## Usage

```bash
/pfLogin                    # Interactive - prompts for token
/pfLogin pf_abc123...       # Direct token input
```

## Step 0: Load Configuration

```javascript
function getConfig() {
  const localConfigPath = "./.plan-config.json"
  if (fileExists(localConfigPath)) {
    try {
      return JSON.parse(readFile(localConfigPath))
    } catch (error) {}
  }
  const globalConfigPath = expandPath("~/.config/claude/plan-plugin-config.json")
  if (fileExists(globalConfigPath)) {
    try {
      return JSON.parse(readFile(globalConfigPath))
    } catch (error) {}
  }
  return { "language": "en" }
}

const config = getConfig()
const language = config.language || "en"
const cloudConfig = config.cloud || {}
const isAuthenticated = !!cloudConfig.apiToken
const apiUrl = cloudConfig.apiUrl || "https://api.planflow.tools"

const t = JSON.parse(readFile(`locales/${language}.json`))
```

## Step 1: Check Current Auth Status

If already authenticated, show message and exit:
```
⚠️ Already logged in as {email}

To switch accounts, run /pfLogout first.
```

## Step 2: Get Token

If token provided as argument, use it.
Otherwise, ask user:
```
{t.commands.login.enterToken}

Get your token at: https://planflow.tools/settings/api-tokens
```

## Step 3: Validate Token

**API Call:**
```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {TOKEN}" \
  "https://api.planflow.tools/api-tokens/verify"
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": {
      "name": "My CLI Token"
    }
  }
}
```

## Step 4: Save Credentials

Save to global config (`~/.config/claude/plan-plugin-config.json`):
```json
{
  "language": "en",
  "cloud": {
    "apiUrl": "https://api.planflow.tools",
    "apiToken": "pf_xxx...",
    "userId": "uuid",
    "userEmail": "user@example.com"
  }
}
```

## Step 5: Show Success

```
✅ {t.commands.login.success}

  {t.commands.login.user} John Doe
  {t.commands.login.email} user@example.com
  {t.commands.login.token} My CLI Token

{t.commands.login.nowYouCan}
  • /pfSyncPush - Push local to cloud
  • /pfSyncPull - Pull from cloud
  • /pfCloudList - List your projects
```

## Error Handling

**Invalid Token:**
```
❌ {t.commands.login.invalidToken}

Get a new token at: https://planflow.tools/settings/api-tokens
```

**Network Error:**
```
❌ Network error. Please check your connection.
```
