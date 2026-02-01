# /logout - PlanFlow Cloud Logout

Clear stored credentials and disconnect from PlanFlow cloud.

## Usage

```bash
/logout           # Clear credentials from all configs
/logout --local   # Only clear local project config
/logout --global  # Only clear global config
```

## What This Command Does

- Removes stored API token and user info from config files
- Clears credentials from local and/or global config based on scope
- Preserves other settings (language, projectId, autoSync, etc.)
- Disconnects from PlanFlow cloud

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

## Step 1: Parse Command Arguments

Check for scope flags to determine which config(s) to clear.

**Pseudo-code:**
```javascript
const args = parseArguments()  // Get arguments after "/logout"

// Check for scope flags
const isLocal = args.includes("--local")
const isGlobal = args.includes("--global")

// Determine scope
let scope
if (isLocal && !isGlobal) {
  scope = "local"
} else if (isGlobal && !isLocal) {
  scope = "global"
} else {
  scope = "all"  // Default: clear both
}
```

**Instructions for Claude:**

Parse the command arguments:
- `/logout` -> `scope = "all"` (clear both local and global)
- `/logout --local` -> `scope = "local"` (only local config)
- `/logout --global` -> `scope = "global"` (only global config)

---

## Step 2: Check Current Authentication Status

Before clearing, check if there are any credentials to clear.

**Pseudo-code:**
```javascript
function isAuthenticated(config) {
  return !!config.cloud?.apiToken
}

function getCredentialSources() {
  const sources = []

  // Check local
  const localPath = "./.plan-config.json"
  if (fileExists(localPath)) {
    try {
      const localConfig = JSON.parse(readFile(localPath))
      if (localConfig.cloud?.apiToken) {
        sources.push({ scope: "local", path: localPath, email: localConfig.cloud.userEmail })
      }
    } catch (error) {}
  }

  // Check global
  const globalPath = expandPath("~/.config/claude/plan-plugin-config.json")
  if (fileExists(globalPath)) {
    try {
      const globalConfig = JSON.parse(readFile(globalPath))
      if (globalConfig.cloud?.apiToken) {
        sources.push({ scope: "global", path: globalPath, email: globalConfig.cloud.userEmail })
      }
    } catch (error) {}
  }

  return sources
}

const sources = getCredentialSources()

// Filter by scope if specified
const relevantSources = scope === "all"
  ? sources
  : sources.filter(s => s.scope === scope)

if (relevantSources.length === 0) {
  console.log(t.commands.logout.notLoggedIn)
  return
}
```

**Instructions for Claude:**

1. Read both config files to check for stored credentials
2. Check if `cloud.apiToken` exists in each
3. Based on the specified scope, determine if there are credentials to clear
4. If no credentials found in the relevant scope, show:
   ```
   ⚠️ You are not currently logged in.
   ```
   (Use `t.commands.logout.notLoggedIn`)
5. If credentials exist, proceed to Step 3

---

## Step 3: Clear Credentials

Remove authentication fields from the relevant config file(s).

**Fields to remove:**
- `apiToken`
- `userId`
- `userEmail`
- `userName`
- `tokenName`
- `savedAt`

**Fields to preserve:**
- `language`
- `apiUrl`
- `projectId`
- `lastSyncedAt`
- `autoSync`

**Pseudo-code:**
```javascript
function clearCredentials(configPath) {
  if (!fileExists(configPath)) {
    return { success: false, reason: "not_found" }
  }

  try {
    const config = JSON.parse(readFile(configPath))

    // Only clear if there's something to clear
    if (!config.cloud?.apiToken) {
      return { success: false, reason: "no_credentials" }
    }

    // Remove auth fields, preserve others
    if (config.cloud) {
      delete config.cloud.apiToken
      delete config.cloud.userId
      delete config.cloud.userEmail
      delete config.cloud.userName
      delete config.cloud.tokenName
      delete config.cloud.savedAt
    }

    // Write back
    writeFile(configPath, JSON.stringify(config, null, 2))

    return { success: true }
  } catch (error) {
    return { success: false, reason: "error", error: error.message }
  }
}

const results = []

// Clear local if needed
if (scope === "local" || scope === "all") {
  const localPath = "./.plan-config.json"
  const result = clearCredentials(localPath)
  if (result.success) {
    results.push({ scope: "local", path: localPath })
  }
}

// Clear global if needed
if (scope === "global" || scope === "all") {
  const globalPath = expandPath("~/.config/claude/plan-plugin-config.json")
  const result = clearCredentials(globalPath)
  if (result.success) {
    results.push({ scope: "global", path: globalPath })
  }
}
```

**Instructions for Claude:**

1. For each relevant config file (based on scope):
   a. Read the file using Read tool
   b. Parse JSON content
   c. Remove the authentication fields from `cloud` section
   d. Preserve non-auth fields (language, projectId, autoSync, etc.)
   e. Write updated config using Write tool

2. Track which configs were successfully cleared

---

## Step 4: Show Success Message

Display confirmation with details about what was cleared.

**Pseudo-code:**
```javascript
console.log(t.commands.logout.success)
console.log("")

for (const result of results) {
  const scopeText = result.scope === "local"
    ? t.commands.logout.local
    : t.commands.logout.global

  console.log(t.commands.logout.cleared.replace("{scope}", scopeText))
}
```

**Instructions for Claude:**

Output success message using translations:

**English output:**
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from global config.
```

**Georgian output:**
```
✅ წარმატებით გამოხვედით PlanFlow-დან.

კრედენციალები წაიშალა გლობალური კონფიგურაციიდან.
```

**For multiple configs cleared (scope = "all"):**
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from local config.
Credentials cleared from global config.
```

**Translation keys to use:**
- Success message: `t.commands.logout.success`
- Cleared message: `t.commands.logout.cleared` (with `{scope}` replacement)
- Local scope text: `t.commands.logout.local`
- Global scope text: `t.commands.logout.global`

---

## Examples

### Example 1: Standard Logout (Clear All)

```bash
$ /logout
```

Output:
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from global config.
```

### Example 2: Logout with Local and Global Credentials

```bash
$ /logout
```

Output:
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from local config.
Credentials cleared from global config.
```

### Example 3: Clear Only Local Config

```bash
$ /logout --local
```

Output:
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from local config.
```

### Example 4: Clear Only Global Config

```bash
$ /logout --global
```

Output:
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from global config.
```

### Example 5: Not Logged In

```bash
$ /logout
```

Output:
```
⚠️ You are not currently logged in.
```

### Example 6: Georgian Language

```bash
$ /logout
```

Output:
```
✅ წარმატებით გამოხვედით PlanFlow-დან.

კრედენციალები წაიშალა გლობალური კონფიგურაციიდან.
```

### Example 7: Local Credentials Only, Clearing Local

```bash
$ /logout --local
```

Output:
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from local config.
```

### Example 8: Only Global Credentials, Trying to Clear Local

```bash
$ /logout --local
```

Output:
```
⚠️ You are not currently logged in.
```

(No local credentials exist)

---

## Config File Structure

### Before Logout

```json
{
  "language": "en",
  "cloud": {
    "apiUrl": "https://api.planflow.tools",
    "apiToken": "pf_abc123xyz789",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "userEmail": "john@example.com",
    "userName": "John Doe",
    "tokenName": "My CLI Token",
    "savedAt": "2026-01-31T15:00:00Z",
    "projectId": "proj_abc123",
    "lastSyncedAt": "2026-01-31T16:00:00Z",
    "autoSync": false
  }
}
```

### After Logout

```json
{
  "language": "en",
  "cloud": {
    "apiUrl": "https://api.planflow.tools",
    "projectId": "proj_abc123",
    "lastSyncedAt": "2026-01-31T16:00:00Z",
    "autoSync": false
  }
}
```

Note: `projectId`, `lastSyncedAt`, and `autoSync` are preserved.

---

## Error Handling

### File Permission Error

If unable to write to config file:

```
⚠️ Warning: Could not clear credentials from {path}

Please check file permissions and try again.
```

### Corrupted Config File

If JSON parsing fails:

```
⚠️ Warning: Config file appears corrupted: {path}

Credentials may not have been fully cleared.
Please manually check or delete the file.
```

---

## Security Considerations

1. **Complete Removal**: Credentials are deleted from config, not just cleared to empty strings

2. **No Lingering Data**: All auth-related fields are removed (token, userId, email, name)

3. **Preserved Settings**: Non-sensitive settings (language, projectId) are preserved

4. **Clear Confirmation**: User receives confirmation that logout was successful

---

## Dependencies

This command uses:
- **skills/credentials/SKILL.md** - For credential management patterns

---

## Related Commands

- `/login` - Authenticate with PlanFlow
- `/whoami` - Check current authentication status
- `/sync` - Sync with cloud (requires auth)
- `/cloud` - Manage cloud projects (requires auth)

---

## Notes

- Default behavior clears credentials from ALL config files (local and global)
- Use `--local` or `--global` to target specific config
- Project link (`projectId`) is preserved - use `/cloud unlink` to remove it
- After logout, cloud commands will require re-authentication
