# Config System Guide

როგორ წავიკითხოთ და ჩავწეროთ user configuration SKILL.md ფაილებში.

## 📍 Config File Location

```
~/.config/claude/plan-plugin-config.json
```

## 📝 Config File Structure

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27T12:00:00Z"
}
```

## 🔍 Reading Config

### Pseudo-Code for SKILL.md

```markdown
## Reading User Configuration

To get user preferences:

1. Check if config file exists at: ~/.config/claude/plan-plugin-config.json
2. If exists, read and parse JSON
3. If not exists, use defaults

Default configuration:
\`\`\`json
{
  "language": "en",
  "defaultProjectType": "fullstack"
}
\`\`\`

Example pseudo-code:
\`\`\`javascript
function getConfig() {
  const configPath = expandPath("~/.config/claude/plan-plugin-config.json")

  if (fileExists(configPath)) {
    const content = readFile(configPath)
    return JSON.parse(content)
  } else {
    // Return defaults
    return {
      "language": "en",
      "defaultProjectType": "fullstack"
    }
  }
}

const config = getConfig()
const userLanguage = config.language // "ka" or "en"
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
When user changes settings (e.g., /plan:settings language):

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

### Available Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `language` | string | `"en"` | UI language code (en, ka, ru) |
| `defaultProjectType` | string | `"fullstack"` | Default project type for wizard |
| `lastUsed` | string | current date | Last time plugin was used (ISO 8601) |

### Future Fields (v1.2+)

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27T12:00:00Z",
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

User runs: /plan:settings language
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

## 💡 Best Practices

1. **Always use defaults** if config doesn't exist
2. **Preserve existing fields** when updating
3. **Create directory** before writing
4. **Handle JSON parsing errors** gracefully
5. **Update `lastUsed`** whenever writing config
6. **Use ISO 8601** for timestamps

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
