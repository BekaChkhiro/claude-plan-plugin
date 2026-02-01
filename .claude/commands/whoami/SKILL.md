# /whoami - Display Current User Info

Display information about the currently authenticated PlanFlow user and cloud statistics.

## Usage

```bash
/whoami
```

No arguments needed - displays current user information and cloud stats.

## What This Command Does

- Shows the currently authenticated user's name, email, and ID
- Displays the API endpoint and connection status
- Shows cloud statistics (project count, last sync)
- Verifies the stored credentials are still valid

## Prerequisites

- Must be logged in with `/login` first
- Internet connection (for fetching fresh stats)

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

---

## Step 1: Check Authentication

Before displaying user info, verify the user is authenticated.

**Pseudo-code:**
```javascript
function isAuthenticated(config) {
  return !!config.cloud?.apiToken
}

function getCredentials(config) {
  if (!config.cloud?.apiToken) return null

  return {
    apiToken: config.cloud.apiToken,
    userId: config.cloud.userId,
    userEmail: config.cloud.userEmail,
    userName: config.cloud.userName,
    tokenName: config.cloud.tokenName,
    apiUrl: config.cloud.apiUrl || "https://api.planflow.tools",
    projectId: config.cloud.projectId,
    lastSyncedAt: config.cloud.lastSyncedAt
  }
}

const credentials = getCredentials(config)

if (!credentials) {
  console.log(t.commands.whoami.notLoggedIn)
  console.log(t.commands.whoami.loginHint)
  return
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.apiToken` exists
2. If NOT authenticated, output:
   ```
   ❌ Not logged in to PlanFlow.
   Run /login to authenticate.
   ```
3. If authenticated, proceed to Step 2

**Translation keys for not logged in:**
- `t.commands.whoami.notLoggedIn`
- `t.commands.whoami.loginHint`

---

## Step 2: Fetch Fresh User Info from API

Make an API call to get up-to-date user information and statistics.

**Pseudo-code:**
```javascript
const apiUrl = credentials.apiUrl || "https://api.planflow.tools"
const token = credentials.apiToken

// Call GET /auth/me
const response = makeRequest("GET", "/auth/me", null, token)
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="$API_TOKEN"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  --connect-timeout 10 \
  --max-time 15 \
  -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "${API_URL}/auth/me")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Use Bash tool to make curl request:
   ```bash
   curl -s -w "\n%{http_code}" \
     --connect-timeout 10 \
     --max-time 15 \
     -X GET \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/auth/me"
   ```
2. Parse the response (last line = HTTP code, rest = JSON body)
3. Proceed to Step 3 based on result

---

## Step 3: Handle API Response

Process the response and display user information.

### Success Response (HTTP 200)

**Expected Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2026-01-01T00:00:00Z",
  "stats": {
    "projectCount": 5,
    "totalTasks": 127,
    "completedTasks": 89
  }
}
```

**Pseudo-code:**
```javascript
if (httpCode >= 200 && httpCode < 300) {
  const data = JSON.parse(body)

  // Use fresh data from API, fallback to stored credentials
  const userInfo = {
    name: data.name || credentials.userName,
    email: data.email || credentials.userEmail,
    userId: data.id || credentials.userId,
    stats: data.stats || null
  }

  displayUserInfo(userInfo, credentials, t)
}
```

### Error Response (HTTP 401)

Token is invalid or expired.

**Pseudo-code:**
```javascript
if (httpCode === 401) {
  console.log("❌ " + t.commands.whoami.notConnected)
  console.log("")
  console.log("Your stored token may have expired or been revoked.")
  console.log("Run /login to authenticate again.")
  return
}
```

### Network/Server Error

**Pseudo-code:**
```javascript
if (httpCode === 0 || httpCode >= 500) {
  // API unavailable - show stored credentials with warning
  console.log("⚠️ Cannot connect to PlanFlow API")
  console.log("Showing stored information (may be outdated):")
  console.log("")
  displayUserInfo(credentials, credentials, t, { offline: true })
}
```

**Instructions for Claude:**

Based on HTTP status code:

**If 200-299 (Success):**
- Parse JSON body
- Extract user info and stats
- Proceed to Step 4 to display

**If 401 (Unauthorized):**
```
❌ Not connected

Your stored token may have expired or been revoked.
Run /login to authenticate again.
```

**If 0 or 500+ (Network/Server Error):**
- Show warning about offline mode
- Display stored credentials with offline indicator
- Proceed to Step 4 with `offline: true`

---

## Step 4: Display User Information

Format and display the user information using translations.

**Pseudo-code:**
```javascript
function maskToken(token) {
  if (!token || token.length < 12) return "***"
  return token.substring(0, 8) + "..." + token.substring(token.length - 4)
}

function formatLastSync(timestamp) {
  if (!timestamp) return t.commands.sync.never

  const syncDate = new Date(timestamp)
  const now = new Date()
  const diffMs = now - syncDate
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMins / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffMins < 1) return "Just now"
  if (diffMins < 60) return `${diffMins} minutes ago`
  if (diffHours < 24) return `${diffHours} hours ago`
  if (diffDays === 1) return "Yesterday"
  return `${diffDays} days ago`
}

function displayUserInfo(userInfo, credentials, t, options = {}) {
  const statusIcon = options.offline ? t.commands.whoami.notConnected : t.commands.whoami.connected

  let output = t.commands.whoami.title + "\n\n"
  output += `  ${t.commands.whoami.name}     ${userInfo.name}\n`
  output += `  ${t.commands.whoami.email}    ${userInfo.email}\n`
  output += `  ${t.commands.whoami.userId}  ${userInfo.userId}\n`
  output += `  ${t.commands.whoami.apiUrl}  ${credentials.apiUrl}\n`
  output += `  ${t.commands.whoami.status}  ${statusIcon}\n`

  // Show masked token
  output += `  Token:    ${maskToken(credentials.apiToken)}\n`

  console.log(output)

  // Cloud stats (if available)
  if (userInfo.stats) {
    console.log(t.commands.whoami.cloudStats)
    console.log(`  ${t.commands.whoami.projects}   ${userInfo.stats.projectCount}`)
    console.log(`  Tasks:      ${userInfo.stats.completedTasks}/${userInfo.stats.totalTasks} completed`)
  }

  // Last sync info
  console.log(`  ${t.commands.whoami.lastSync} ${formatLastSync(credentials.lastSyncedAt)}`)

  // Current project link
  if (credentials.projectId) {
    console.log("")
    console.log(`📁 Linked Project: ${credentials.projectId}`)
  }
}
```

**Instructions for Claude:**

Output the user information in this format:

**English:**
```
👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-41d4-a716-446655440000
  API URL:  https://api.planflow.tools
  Status:   ✅ Connected
  Token:    pf_abc12...xyz9

📊 Cloud Stats:
  Projects:   5
  Tasks:      89/127 completed
  Last Sync:  2 hours ago

📁 Linked Project: abc123
```

**Georgian:**
```
👤 მიმდინარე მომხმარებელი

  სახელი:           John Doe
  ელ-ფოსტა:         john@example.com
  მომხმარებლის ID:  550e8400-e29b-41d4-a716-446655440000
  API URL:          https://api.planflow.tools
  სტატუსი:          ✅ დაკავშირებულია
  Token:            pf_abc12...xyz9

📊 Cloud სტატისტიკა:
  პროექტები:        5
  Tasks:            89/127 completed
  ბოლო სინქრონიზაცია: 2 საათის წინ

📁 დაკავშირებული პროექტი: abc123
```

**Translation keys:**
- Title: `t.commands.whoami.title`
- Name: `t.commands.whoami.name`
- Email: `t.commands.whoami.email`
- User ID: `t.commands.whoami.userId`
- API URL: `t.commands.whoami.apiUrl`
- Status: `t.commands.whoami.status`
- Connected: `t.commands.whoami.connected`
- Not Connected: `t.commands.whoami.notConnected`
- Cloud Stats: `t.commands.whoami.cloudStats`
- Projects: `t.commands.whoami.projects`
- Last Sync: `t.commands.whoami.lastSync`

---

## Error Handling

### Not Logged In

```
❌ Not logged in to PlanFlow.
Run /login to authenticate.
```

### Token Expired/Invalid

```
❌ Not connected

Your stored token may have expired or been revoked.

💡 Run /login to authenticate again.
```

### Network Error (Offline Mode)

```
⚠️ Cannot connect to PlanFlow API

Showing stored information (may be outdated):

👤 Current User

  Name:     John Doe
  Email:    john@example.com
  ...
  Status:   ❌ Not connected (offline)
```

### Config File Corrupted

```
❌ Error reading configuration

Your config file may be corrupted.
Try running /login again to restore credentials.
```

---

## Examples

### Example 1: Normal Usage (Authenticated & Connected)

```bash
$ /whoami
```

Output:
```
👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-41d4-a716-446655440000
  API URL:  https://api.planflow.tools
  Status:   ✅ Connected
  Token:    pf_abc12...xyz9

📊 Cloud Stats:
  Projects:   5
  Tasks:      89/127 completed
  Last Sync:  2 hours ago

📁 Linked Project: abc123
```

### Example 2: Not Logged In

```bash
$ /whoami
```

Output:
```
❌ Not logged in to PlanFlow.
Run /login to authenticate.
```

### Example 3: Token Expired

```bash
$ /whoami
```

Output:
```
❌ Not connected

Your stored token may have expired or been revoked.

💡 Run /login to authenticate again.
```

### Example 4: Offline Mode

```bash
$ /whoami
```

Output:
```
⚠️ Cannot connect to PlanFlow API

Showing stored information (may be outdated):

👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-...
  API URL:  https://api.planflow.tools
  Status:   ❌ Not connected (offline)
  Token:    pf_abc12...xyz9

📁 Linked Project: abc123
```

### Example 5: Georgian Language

```bash
$ /whoami
```

Output:
```
👤 მიმდინარე მომხმარებელი

  სახელი:           John Doe
  ელ-ფოსტა:         john@example.com
  მომხმარებლის ID:  550e8400-e29b-41d4-a716-446655440000
  API URL:          https://api.planflow.tools
  სტატუსი:          ✅ დაკავშირებულია
  Token:            pf_abc12...xyz9

📊 Cloud სტატისტიკა:
  პროექტები:   5
  Tasks:       89/127 completed
  ბოლო სინქრონიზაცია: 2 საათის წინ
```

### Example 6: No Project Linked

```bash
$ /whoami
```

Output:
```
👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-...
  API URL:  https://api.planflow.tools
  Status:   ✅ Connected
  Token:    pf_abc12...xyz9

📊 Cloud Stats:
  Projects:   5
  Tasks:      89/127 completed
  Last Sync:  Never

💡 Tip: Run /cloud link to link a cloud project
```

---

## Implementation Checklist

- [ ] Load translations (Step 0)
- [ ] Check authentication status
- [ ] Make API call to GET /auth/me
- [ ] Handle success response (200)
- [ ] Handle auth error (401)
- [ ] Handle network/server errors
- [ ] Display user info with translations
- [ ] Show cloud stats if available
- [ ] Show last sync time
- [ ] Show linked project if any
- [ ] Mask token in display

---

## Dependencies

This command uses:
- **skills/credentials/SKILL.md** - For reading stored credentials
- **skills/api-client/SKILL.md** - For making API requests

---

## Related Commands

- `/login` - Authenticate with PlanFlow
- `/logout` - Clear stored credentials
- `/sync` - Sync project with cloud
- `/cloud` - Manage cloud projects

---

## Security Notes

1. **Token Masking**: Always use `maskToken()` - never display the full token
2. **Stored Credentials**: Credentials are read from config file, not passed as arguments
3. **HTTPS Only**: All API communication uses HTTPS
4. **Offline Fallback**: When offline, only stored (local) info is shown, no sensitive operations

---

## Notes

- This command is useful for verifying which account you're logged in with
- The API call provides fresh statistics that may differ from stored values
- If offline, stored credentials are shown with a warning
- The command does not modify any files or settings
