# Config System Guide

როგორ წავიკითხოთ და ჩავწეროთ user configuration SKILL.md ფაილებში.

## 📍 Config File Locations

### Hierarchical Config System (v1.1.1+)

The plugin supports **two levels** of configuration:

1. **Local Project Config** (highest priority)
   ```
   ./.plan-config.json
   ```
   - Project-specific settings
   - Overrides global config
   - Only affects current project

2. **Global User Config** (fallback)
   ```
   ~/.config/claude/plan-plugin-config.json
   ```
   - User-wide default settings
   - Used when no local config exists
   - Affects all projects

3. **Default** (final fallback)
   ```json
   { "language": "en" }
   ```

### Priority Order

```
Local (./.plan-config.json)
  ↓ (if not found)
Global (~/.config/claude/plan-plugin-config.json)
  ↓ (if not found)
Default (en)
```

## 📝 Config File Structure

### Basic Config (v1.1.1)

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27T12:00:00Z"
}
```

### Extended Config with Cloud (v1.2.0+)

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27T12:00:00Z",
  "cloud": {
    "apiUrl": "https://api.planflow.tools",
    "apiToken": "pf_xxx...",
    "projectId": "uuid-of-linked-project",
    "userId": "uuid",
    "userEmail": "user@example.com",
    "autoSync": false,
    "storageMode": "hybrid",
    "lastSyncedAt": null
  }
}
```

### Storage Mode Configuration (v1.3.0+)

The `storageMode` option controls how the plugin handles data synchronization:

```json
{
  "cloud": {
    "storageMode": "hybrid"
  }
}
```

#### Available Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `local` | PROJECT_PLAN.md only, no auto-sync | Offline work, no cloud needed |
| `cloud` | Cloud is source of truth, local is cache | Team collaboration, always online |
| `hybrid` | Both local and cloud, with smart merge | Best of both worlds (default for authenticated users) |

#### Mode Behaviors

**`local` Mode:**
- All changes saved to PROJECT_PLAN.md only
- No automatic cloud synchronization
- Manual sync still available via `/sync push` and `/sync pull`
- Best for offline work or when cloud is not needed

**`cloud` Mode:**
- Cloud is the authoritative source
- Local PROJECT_PLAN.md acts as a cache
- Every `/update` immediately syncs with cloud
- If cloud is unavailable, operations may fail
- Best for teams requiring real-time collaboration

**`hybrid` Mode (Default):**
- Both local and cloud are kept in sync
- Smart merge algorithm handles concurrent changes
- Local changes work offline, sync when online
- Conflicts are detected and user is prompted to resolve
- Best for most users who want flexibility

#### Default Behavior

- **Not authenticated**: Defaults to `local` mode
- **Authenticated without explicit setting**: Defaults to `hybrid` mode
- **Explicit setting**: Uses the configured mode

### Cloud Config Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `cloud.apiUrl` | string | `"https://api.planflow.tools"` | API base URL |
| `cloud.apiToken` | string | `null` | User's API token (pf_xxx...) |
| `cloud.projectId` | string | `null` | Linked cloud project UUID |
| `cloud.userId` | string | `null` | User's UUID from API |
| `cloud.userEmail` | string | `null` | User's email from API |
| `cloud.autoSync` | boolean | `false` | Auto-sync on /update |
| `cloud.storageMode` | string | `"hybrid"` | Storage mode: "local", "cloud", or "hybrid" (v1.3.0+) |
| `cloud.lastSyncedAt` | string | `null` | ISO 8601 timestamp of last sync |

## 🔍 Reading Config (Hierarchical)

### Pseudo-Code for SKILL.md (v1.1.1+)

```markdown
## Reading User Configuration with Priority

To get user preferences with hierarchical fallback:

1. Check for **local** config: `./.plan-config.json` (project-specific)
2. If not found, check **global** config: `~/.config/claude/plan-plugin-config.json`
3. If not found, use **defaults**

Default configuration:
\`\`\`json
{
  "language": "en",
  "defaultProjectType": "fullstack"
}
\`\`\`

Example pseudo-code (hierarchical):
\`\`\`javascript
function getConfig() {
  // Try local config first (project-specific)
  const localConfigPath = "./.plan-config.json"

  if (fileExists(localConfigPath)) {
    try {
      const content = readFile(localConfigPath)
      const config = JSON.parse(content)
      config._source = "local"  // Mark source
      return config
    } catch (error) {
      // Corrupted local config, try global
    }
  }

  // Fall back to global config
  const globalConfigPath = expandPath("~/.config/claude/plan-plugin-config.json")

  if (fileExists(globalConfigPath)) {
    try {
      const content = readFile(globalConfigPath)
      const config = JSON.parse(content)
      config._source = "global"  // Mark source
      return config
    } catch (error) {
      // Corrupted global config, use defaults
    }
  }

  // Fall back to defaults
  return {
    "language": "en",
    "defaultProjectType": "fullstack",
    "_source": "default"
  }
}

const config = getConfig()
const userLanguage = config.language  // "ka" or "en"
const configSource = config._source    // "local", "global", or "default"

// Cloud config (v1.2.0+)
const cloudConfig = config.cloud || {}
const isAuthenticated = !!cloudConfig.apiToken
const apiUrl = cloudConfig.apiUrl || "https://api.planflow.tools"
const autoSync = cloudConfig.autoSync || false

// Storage mode (v1.3.0+)
// Defaults: "local" if not authenticated, "hybrid" if authenticated
const storageMode = cloudConfig.storageMode || (isAuthenticated ? "hybrid" : "local")
\`\`\`
```

### Instructions for Claude

```markdown
When you need to know user's language preference:

**Step 1:** Use the Read tool to read config file:

\`\`\`
Read tool:
  file_path: ~/.config/claude/plan-plugin-config.json
\`\`\`

**Step 2:** Parse the JSON response

If file exists:
\`\`\`json
{
  "language": "ka",
  ...
}
\`\`\`

Use the language value.

If file doesn't exist:
Use default language: "en"

**Step 3:** Store language for use

\`\`\`
language = "ka"  // from config
\`\`\`
```

## ✏️ Writing Config

### Creating/Updating Config

```markdown
## Updating User Configuration

To save user preferences:

**Step 1:** Read current config (if exists)

**Step 2:** Update desired fields

**Step 3:** Write back to file

Example for changing language:

\`\`\`javascript
// Read current config
const config = getConfig() // { "language": "en", ... }

// Update language
config.language = "ka"
config.lastUsed = new Date().toISOString()

// Write back
const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
writeFile(configPath, JSON.stringify(config, null, 2))
\`\`\`

**Important:** Always preserve existing fields!
```

### Instructions for Claude - Saving Config

```markdown
When user changes settings (e.g., /settings language):

**Step 1:** Read current config

Use Read tool:
\`\`\`
file_path: ~/.config/claude/plan-plugin-config.json
\`\`\`

If doesn't exist, start with defaults:
\`\`\`json
{
  "language": "en"
}
\`\`\`

**Step 2:** Update the desired field

User selected Georgian:
\`\`\`json
{
  "language": "ka",
  "lastUsed": "2026-01-27T12:00:00Z"
}
\`\`\`

**Step 3:** Write updated config

Use Write tool:
\`\`\`
file_path: ~/.config/claude/plan-plugin-config.json
content: {
  "language": "ka",
  "lastUsed": "2026-01-27T12:00:00Z"
}
\`\`\`

**Step 4:** Confirm to user

Show success message using new language!
```

## 🔧 Config Fields

### Available Fields (v1.1.1)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `language` | string | `"en"` | UI language code (en, ka, ru) |
| `defaultProjectType` | string | `"fullstack"` | Default project type for wizard |
| `lastUsed` | string | current date | Last time plugin was used (ISO 8601) |

### Cloud Fields (v1.2.0+)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `cloud` | object | `{}` | Cloud integration settings |
| `cloud.apiUrl` | string | `"https://api.planflow.tools"` | API endpoint base URL |
| `cloud.apiToken` | string | `null` | API token for authentication |
| `cloud.projectId` | string | `null` | UUID of linked cloud project |
| `cloud.userId` | string | `null` | User's UUID (from /auth/me) |
| `cloud.userEmail` | string | `null` | User's email (from /auth/me) |
| `cloud.autoSync` | boolean | `false` | Auto-sync on task updates |
| `cloud.storageMode` | string | `"hybrid"` | Storage mode: "local" \| "cloud" \| "hybrid" (v1.3.0+) |
| `cloud.lastSyncedAt` | string | `null` | Last sync timestamp (ISO 8601) |

### Future Fields (v1.3+)

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27T12:00:00Z",
  "cloud": { ... },
  "theme": "dark",                    // Future
  "autoSave": true,                   // Future
  "notifications": true               // Future
}
```

## 📂 Directory Creation

Config ფაილის შესაქმნელად:

```markdown
## Ensuring Config Directory Exists

Before writing config:

**Step 1:** Check if directory exists

\`\`\`bash
~/.config/claude/
\`\`\`

**Step 2:** Create if needed

Use Bash tool:
\`\`\`bash
mkdir -p ~/.config/claude
\`\`\`

**Step 3:** Write config file

Now safe to write:
\`\`\`
~/.config/claude/plan-plugin-config.json
\`\`\`
```

## 🎯 Complete Example - Language Change

```markdown
## Complete Flow: User Changes Language to Georgian

User runs: /settings language
User selects: ქართული (Georgian)

**Step 1:** Create directory (if needed)
\`\`\`bash
mkdir -p ~/.config/claude
\`\`\`

**Step 2:** Read existing config (if any)
\`\`\`
Read: ~/.config/claude/plan-plugin-config.json
\`\`\`

Result: File not found (first time) OR existing config

**Step 3:** Update config
\`\`\`json
{
  "language": "ka",
  "lastUsed": "2026-01-27T12:00:00Z"
}
\`\`\`

**Step 4:** Write config
\`\`\`
Write: ~/.config/claude/plan-plugin-config.json
Content: { "language": "ka", "lastUsed": "..." }
\`\`\`

**Step 5:** Confirm in Georgian
\`\`\`
✅ პარამეტრები განახლდა!
ენა შეიცვალა: English → ქართული
\`\`\`
```

## ⚠️ Error Handling

```markdown
## Handling Config Errors

**If config file is corrupted:**

Try to parse JSON:
\`\`\`javascript
try {
  config = JSON.parse(content)
} catch (error) {
  // Corrupted, use defaults
  config = { "language": "en" }
  // Optionally warn user
  console.log("⚠️ Config file was corrupted, using defaults")
}
\`\`\`

**If can't write config:**

Inform user but continue:
\`\`\`
⚠️ Warning: Couldn't save settings
Settings will apply for this session only
\`\`\`

**If directory doesn't exist and can't create:**

\`\`\`
⚠️ Warning: Config directory not accessible
Using default settings
\`\`\`
```

## ☁️ Cloud Config Operations (v1.2.0+)

### Checking Authentication Status

```javascript
function isAuthenticated(config) {
  return !!(config.cloud && config.cloud.apiToken)
}

function getCloudConfig(config) {
  return {
    apiUrl: config.cloud?.apiUrl || "https://api.planflow.tools",
    apiToken: config.cloud?.apiToken || null,
    projectId: config.cloud?.projectId || null,
    userId: config.cloud?.userId || null,
    userEmail: config.cloud?.userEmail || null,
    autoSync: config.cloud?.autoSync || false,
    lastSyncedAt: config.cloud?.lastSyncedAt || null
  }
}
```

### Saving Cloud Credentials

After successful login, save credentials:

```javascript
function saveCloudCredentials(config, credentials, scope = "global") {
  // Ensure cloud object exists
  config.cloud = config.cloud || {}

  // Update cloud settings
  config.cloud.apiToken = credentials.token
  config.cloud.userId = credentials.userId
  config.cloud.userEmail = credentials.email
  config.cloud.apiUrl = credentials.apiUrl || "https://api.planflow.tools"

  // Save to appropriate config file
  const configPath = scope === "local"
    ? "./.plan-config.json"
    : expandPath("~/.config/claude/plan-plugin-config.json")

  writeFile(configPath, JSON.stringify(config, null, 2))
}
```

### Clearing Cloud Credentials (Logout)

```javascript
function clearCloudCredentials(config, scope = "global") {
  if (config.cloud) {
    // Remove sensitive data
    delete config.cloud.apiToken
    delete config.cloud.userId
    delete config.cloud.userEmail
    delete config.cloud.projectId
    config.cloud.lastSyncedAt = null
  }

  // Save updated config
  const configPath = scope === "local"
    ? "./.plan-config.json"
    : expandPath("~/.config/claude/plan-plugin-config.json")

  writeFile(configPath, JSON.stringify(config, null, 2))
}
```

### Linking to Cloud Project

```javascript
function linkCloudProject(config, projectId) {
  config.cloud = config.cloud || {}
  config.cloud.projectId = projectId

  // Always save to local config (project-specific)
  writeFile("./.plan-config.json", JSON.stringify(config, null, 2))
}
```

### Updating Sync Timestamp

```javascript
function updateSyncTimestamp(config) {
  config.cloud = config.cloud || {}
  config.cloud.lastSyncedAt = new Date().toISOString()

  // Save to local config
  writeFile("./.plan-config.json", JSON.stringify(config, null, 2))
}
```

### Getting Storage Mode (v1.3.0+)

```javascript
function getStorageMode(config) {
  const cloudConfig = config.cloud || {}
  const isAuthenticated = !!cloudConfig.apiToken

  // If explicitly set, use that
  if (cloudConfig.storageMode) {
    return cloudConfig.storageMode
  }

  // Default based on authentication status
  return isAuthenticated ? "hybrid" : "local"
}

// Usage
const mode = getStorageMode(config)
// Returns: "local" | "cloud" | "hybrid"
```

### Setting Storage Mode (v1.3.0+)

```javascript
function setStorageMode(config, mode, scope = "local") {
  // Validate mode
  const validModes = ["local", "cloud", "hybrid"]
  if (!validModes.includes(mode)) {
    throw new Error(`Invalid storage mode: ${mode}. Use: ${validModes.join(", ")}`)
  }

  // Check authentication for cloud modes
  const isAuthenticated = !!(config.cloud && config.cloud.apiToken)
  if ((mode === "cloud" || mode === "hybrid") && !isAuthenticated) {
    throw new Error("Cloud modes require authentication. Run /login first.")
  }

  // Ensure cloud object exists
  config.cloud = config.cloud || {}
  config.cloud.storageMode = mode

  // Save to appropriate config file
  const configPath = scope === "local"
    ? "./.plan-config.json"
    : expandPath("~/.config/claude/plan-plugin-config.json")

  writeFile(configPath, JSON.stringify(config, null, 2))

  return mode
}

// Usage
setStorageMode(config, "hybrid", "local")
```

### Storage Mode Behavior Check (v1.3.0+)

```javascript
function shouldSyncToCloud(config) {
  const mode = getStorageMode(config)
  const cloudConfig = config.cloud || {}

  switch (mode) {
    case "local":
      return false  // Never auto-sync
    case "cloud":
      return true   // Always sync immediately
    case "hybrid":
      return cloudConfig.autoSync === true  // Sync if autoSync enabled
    default:
      return false
  }
}

function shouldPullBeforePush(config) {
  const mode = getStorageMode(config)
  return mode === "hybrid"  // Only hybrid mode does smart merge
}

function isCloudRequired(config) {
  const mode = getStorageMode(config)
  return mode === "cloud"  // Only cloud mode requires connectivity
}
```

## 💡 Best Practices

1. **Always use defaults** if config doesn't exist
2. **Preserve existing fields** when updating
3. **Create directory** before writing
4. **Handle JSON parsing errors** gracefully
5. **Update `lastUsed`** whenever writing config
6. **Use ISO 8601** for timestamps
7. **Store apiToken in global config** (user-wide authentication)
8. **Store projectId in local config** (project-specific linking)
9. **Never log or display full apiToken** (security)

## 🧪 Testing Config System

```bash
# Test 1: Read non-existent config
# Should return defaults

# Test 2: Write config
# Should create file with correct JSON

# Test 3: Read config
# Should return saved values

# Test 4: Update config
# Should preserve existing fields

# Test 5: Corrupted config
# Should fall back to defaults
```

---

**სრული მაგალითი კოდში იხილეთ commands/settings/SKILL.md**
