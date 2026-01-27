# /plan:settings - Plugin Settings Management

Manage plan-plugin configuration including language preferences, default project types, and other settings.

## Usage

```bash
/plan:settings                      # Show current settings
/plan:settings language             # Change language preference (global)
/plan:settings language --local     # Change language for this project only
/plan:settings reset                # Reset global settings to defaults
/plan:settings reset --local        # Remove project-specific settings
```

## What This Command Does

- Displays current plugin configuration (both project and global)
- Allows users to change language (English, Georgian, Russian)
- Supports project-specific settings that override global settings
- Persists settings across sessions

## Configuration Hierarchy (v1.1.1+)

**Priority order:**
1. **Local Project Config** (`./.plan-config.json`) - Highest priority, project-specific
2. **Global User Config** (`~/.config/claude/plan-plugin-config.json`) - Fallback, user-wide
3. **Default** (`"en"`) - Final fallback

When you set language with `--local`, it only affects the current project. Without `--local`, it sets the global default for all projects.

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

1. Read config with hierarchical priority (local → global → default)
2. Load translation file
3. Store translations and config for use

Pseudo-code:
```javascript
// Read config with hierarchy: local → global → default
function getConfig() {
  // Try local config first (project-specific)
  const localConfigPath = "./.plan-config.json"

  if (fileExists(localConfigPath)) {
    try {
      const content = readFile(localConfigPath)
      const config = JSON.parse(content)
      config._source = "local"  // Mark where it came from
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
      config._source = "global"  // Mark where it came from
      return config
    } catch (error) {
      // Corrupted global config, use defaults
    }
  }

  // Fall back to defaults
  return {
    "language": "en",
    "_source": "default"
  }
}

const config = getConfig()
const language = config.language || "en"

// Also load both local and global configs for display
const localConfig = fileExists("./.plan-config.json")
  ? JSON.parse(readFile("./.plan-config.json"))
  : null

const globalConfig = fileExists(expandPath("~/.config/claude/plan-plugin-config.json"))
  ? JSON.parse(readFile(expandPath("~/.config/claude/plan-plugin-config.json")))
  : null

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))

// Now ready to use t.commands.settings.key
```

**Instructions for Claude:**

1. Try to read **local** config first:
   ```
   file_path: ./.plan-config.json
   ```
   - If exists and valid: Use this config, mark `_source = "local"`
   - If doesn't exist or corrupted: Continue to step 2

2. Try to read **global** config:
   ```
   file_path: ~/.config/claude/plan-plugin-config.json
   ```
   - If exists and valid: Use this config, mark `_source = "global"`
   - If doesn't exist or corrupted: Continue to step 3

3. Use **default** config:
   ```javascript
   { language: "en", _source: "default" }
   ```

4. Also load both configs separately for display purposes:
   - Read `./.plan-config.json` if exists → `localConfig`
   - Read `~/.config/claude/plan-plugin-config.json` if exists → `globalConfig`

5. Load translations:
   ```
   file_path: locales/{language}.json
   ```

Parse response and store as `t` variable for use throughout command.

## Step 1: Parse Command Arguments

Check what sub-command user requested and whether `--local` flag is present:

Pseudo-code:
```javascript
const args = parseArguments()  // Get arguments after "/plan:settings"

// Check for --local flag
const isLocal = args.includes("--local")

// Remove --local from args for action detection
const cleanArgs = args.filter(arg => arg !== "--local")

if (cleanArgs.length === 0) {
  // Show current settings
  action = "show"
} else if (cleanArgs[0] === "language") {
  // Change language
  action = "change-language"
  scope = isLocal ? "local" : "global"
} else if (cleanArgs[0] === "reset") {
  // Reset to defaults
  action = "reset"
  scope = isLocal ? "local" : "global"
} else {
  // Unknown command
  action = "help"
}
```

**Instructions for Claude:**

Determine which action based on user's command:
- `/plan:settings` → action = "show"
- `/plan:settings language` → action = "change-language", scope = "global"
- `/plan:settings language --local` → action = "change-language", scope = "local"
- `/plan:settings reset` → action = "reset", scope = "global"
- `/plan:settings reset --local` → action = "reset", scope = "local"
- `/plan:settings something-else` → action = "help"

## Step 2: Execute Action

### Action: "show" - Display Current Settings

Show current configuration to user, including both local and global configs.

Pseudo-code:
```javascript
const languageNames = {
  "en": "English",
  "ka": "ქართული (Georgian)",
  "ru": "Русский (Russian)"
}

const currentLanguageName = languageNames[config.language] || "English"

// Build output showing hierarchy
let output = `
⚙️ ${t.commands.settings.title}

📊 Active Configuration:
🌍 ${t.commands.settings.language}: ${currentLanguageName} (${config._source})
`

// Show local project config if exists
if (localConfig) {
  const localLangName = languageNames[localConfig.language] || "?"
  output += `\n📁 Project Settings (./.plan-config.json):
  🌍 ${t.commands.settings.language}: ${localLangName}
  📅 ${t.commands.settings.lastUsed}: ${localConfig.lastUsed || "N/A"}`
}

// Show global config if exists
if (globalConfig) {
  const globalLangName = languageNames[globalConfig.language] || "?"
  output += `\n\n🌐 Global Settings (~/.config/claude/plan-plugin-config.json):
  🌍 ${t.commands.settings.language}: ${globalLangName}
  📅 ${t.commands.settings.lastUsed}: ${globalConfig.lastUsed || "N/A"}`
}

// Show available commands
output += `\n\n${t.commands.settings.availableCommands}:
- /plan:settings language           # Change global language
- /plan:settings language --local   # Change project language
- /plan:settings reset              # Reset global settings
- /plan:settings reset --local      # Remove project settings
`

console.log(output)
```

**Instructions for Claude:**

Output to user with hierarchical display:

```
⚙️ Plan Plugin Settings

📊 Active Configuration:
🌍 Language: ქართული (Georgian) (local)

📁 Project Settings (./.plan-config.json):
  🌍 Language: ქართული
  📅 Last Used: 2026-01-27T15:30:00Z

🌐 Global Settings (~/.config/claude/plan-plugin-config.json):
  🌍 Language: English
  📅 Last Used: 2026-01-27T14:00:00Z

Available Commands:
- /plan:settings language           # Change global language
- /plan:settings language --local   # Change project language
- /plan:settings reset              # Reset global settings
- /plan:settings reset --local      # Remove project settings
```

Use the translation keys from `t.commands.settings.*` for all text.

Show:
1. Active config (the one being used, with source: local/global/default)
2. Local project config if it exists
3. Global config if it exists
4. Available commands with --local flag examples

**Then STOP. Do not proceed to other actions.**

---

### Action: "change-language" - Change Language Preference

Allow user to select a new language.

**Step 2.1:** Show language selection

Use AskUserQuestion to present language options.

Pseudo-code:
```javascript
const currentLang = config.language || "en"

AskUserQuestion({
  questions: [{
    question: t.commands.settings.selectLanguage,
    header: t.commands.settings.languageHeader,
    multiSelect: false,
    options: [
      {
        label: t.commands.settings.englishOption + (currentLang === "en" ? " ✓" : ""),
        description: t.commands.settings.englishDesc
      },
      {
        label: t.commands.settings.georgianOption + (currentLang === "ka" ? " ✓" : ""),
        description: t.commands.settings.georgianDesc
      },
      {
        label: t.commands.settings.russianOption + (currentLang === "ru" ? " ✓" : ""),
        description: t.commands.settings.russianDesc
      }
    ]
  }]
})
```

**Instructions for Claude:**

Use AskUserQuestion tool:
- question: Use `t.commands.settings.selectLanguage`
- header: Use `t.commands.settings.languageHeader`
- options: 3 language options with labels and descriptions from translations
- Mark current language with ✓ checkmark

Example:
```
Select your preferred language:

○ English
  Use English for all plugin interactions

● ქართული (Georgian) ✓
  გამოიყენე ქართული ყველა ურთიერთქმედებისთვის

○ Русский (Russian)
  Использовать русский язык
```

**Step 2.2:** Map user selection to language code

After user selects an option, map it to language code.

Pseudo-code:
```javascript
const userSelection = getUserAnswer()  // e.g., "ქართული (Georgian)"

let newLanguage = "en"  // Default

if (userSelection.includes("English")) {
  newLanguage = "en"
} else if (userSelection.includes("Georgian") || userSelection.includes("ქართული")) {
  newLanguage = "ka"
} else if (userSelection.includes("Russian") || userSelection.includes("Русский")) {
  newLanguage = "ru"
}
```

**Instructions for Claude:**

Based on user's selection, determine new language code:
- If selection contains "English" → newLanguage = "en"
- If selection contains "Georgian" or "ქართული" → newLanguage = "ka"
- If selection contains "Russian" or "Русский" → newLanguage = "ru"

**Step 2.3:** Save new language to config

Update config file with new language preference. Save to local or global based on `scope`.

Pseudo-code:
```javascript
// Determine which config to update
let configToUpdate = {}
let configPath = ""

if (scope === "local") {
  // Project-specific config
  configPath = "./.plan-config.json"

  // Read existing local config if exists
  if (fileExists(configPath)) {
    try {
      configToUpdate = JSON.parse(readFile(configPath))
    } catch (error) {
      configToUpdate = {}
    }
  }
} else {
  // Global config
  configPath = expandPath("~/.config/claude/plan-plugin-config.json")

  // Ensure config directory exists
  const configDir = expandPath("~/.config/claude")
  if (!directoryExists(configDir)) {
    createDirectory(configDir)
  }

  // Read existing global config if exists
  if (fileExists(configPath)) {
    try {
      configToUpdate = JSON.parse(readFile(configPath))
    } catch (error) {
      configToUpdate = {}
    }
  }
}

// Update config
const oldLanguage = configToUpdate.language || config.language || "en"
configToUpdate.language = newLanguage
configToUpdate.lastUsed = new Date().toISOString()

// Write config file
const configJSON = JSON.stringify(configToUpdate, null, 2)
writeFile(configPath, configJSON)
```

**Instructions for Claude:**

1. Determine config path based on scope:
   - If scope is "local": `configPath = "./.plan-config.json"`
   - If scope is "global": `configPath = "~/.config/claude/plan-plugin-config.json"`

2. For global config only, ensure directory exists:
   Use Bash tool:
   ```bash
   mkdir -p ~/.config/claude
   ```

3. Read existing config at that path (if exists):
   Use Read tool on the appropriate path
   - If exists: Parse JSON and update it
   - If doesn't exist: Start with empty object

4. Update config object:
   ```javascript
   configToUpdate.language = newLanguage
   configToUpdate.lastUsed = new Date().toISOString()
   ```

5. Write config file:
   Use Write tool with the appropriate path:
   ```
   file_path: {configPath}  # Either ./.plan-config.json or ~/.config/claude/plan-plugin-config.json
   content: {
     "language": "ka",
     "lastUsed": "2026-01-27T15:30:00Z"
   }
   ```

   **IMPORTANT:** Preserve any existing fields in config! Only update `language` and `lastUsed`.

**Step 2.4:** Reload translations in new language

Load the new translation file to show success message in new language.

Pseudo-code:
```javascript
// Reload translations in new language
const newTranslationPath = `locales/${newLanguage}.json`
const t_new = JSON.parse(readFile(newTranslationPath))

// Get language names for output
const languageNames = {
  "en": { "en": "English", "ka": "English", "ru": "English" },
  "ka": { "en": "ქართული", "ka": "ქართული", "ru": "Грузинский" },
  "ru": { "en": "Russian", "ka": "რუსული", "ru": "Русский" }
}

const fromLangName = languageNames[oldLanguage][newLanguage]
const toLangName = languageNames[newLanguage][newLanguage]
```

**Instructions for Claude:**

Use Read tool to load new translation file:
```
file_path: locales/{newLanguage}.json
```

Parse and store as `t_new` (the new translations).

**Step 2.5:** Show success message in new language

Display confirmation using the NEW language translations, including scope information.

Pseudo-code:
```javascript
const languageNames = {
  "en": "English",
  "ka": "ქართული",
  "ru": "Русский"
}

const fromName = languageNames[oldLanguage]
const toName = languageNames[newLanguage]

const scopeIcon = scope === "local" ? "📁" : "🌐"
const scopeText = scope === "local"
  ? t_new.commands.settings.projectScope
  : t_new.commands.settings.globalScope

const output = `
${t_new.commands.settings.settingsUpdated}

${scopeIcon} ${scopeText}

${t_new.commands.settings.languageChanged
  .replace("{from}", fromName)
  .replace("{to}", toName)}

${t_new.commands.settings.newLanguageUsedFor}
${t_new.commands.settings.commandOutputs}
${t_new.commands.settings.wizardQuestions}
${t_new.commands.settings.generatedPlans}

${t_new.commands.settings.tryIt}
`

console.log(output)
```

**Instructions for Claude:**

Output success message using `t_new` (new language translations):

For **local** scope:
```
✅ Settings updated!

📁 Project-specific settings saved

Language changed: English → ქართული

The new language will be used for:
• All command outputs in this project
• Wizard questions in this project
• Generated PROJECT_PLAN.md files in this project

Try it: /plan:new
```

For **global** scope:
```
✅ Settings updated!

🌐 Global settings saved

Language changed: English → ქართული

The new language will be used for:
• All command outputs (in projects without local config)
• Wizard questions
• Generated PROJECT_PLAN.md files

Try it: /plan:new
```

**IMPORTANT:**
- Use the NEW language translations (t_new), not the old ones (t).
- Show the language change as: `{fromLanguage} → {toLanguage}` using native language names.
- Include scope indicator (📁 for local, 🌐 for global)
- Clarify that local settings only affect current project, global affects all projects

**Then STOP. Action complete.**

---

### Action: "reset" - Reset to Defaults

Reset configuration to default values. Handles both local and global scopes.

**Step 2.1:** Confirm with user (optional)

You may want to confirm before resetting.

**Step 2.2:** Reset config based on scope

Pseudo-code:
```javascript
if (scope === "local") {
  // Remove local config file
  const localConfigPath = "./.plan-config.json"

  if (fileExists(localConfigPath)) {
    deleteFile(localConfigPath)

    // Reload config to get effective language (will fall back to global or default)
    const newConfig = getConfig()  // Uses hierarchy
    const newLanguage = newConfig.language || "en"

    // Load translations for new effective language
    const t_new = JSON.parse(readFile(`locales/${newLanguage}.json`))

    console.log(`
      ${t_new.commands.settings.settingsUpdated}

      📁 ${t_new.commands.settings.projectSettingsRemoved}

      ${t_new.commands.settings.nowUsing}: ${newConfig._source === "global" ? "🌐 Global settings" : "⚙️ Default (English)"}
    `)
  } else {
    console.log(`ℹ️ No project-specific settings found`)
  }
} else {
  // Reset global config to defaults
  const defaultConfig = {
    "language": "en",
    "lastUsed": new Date().toISOString()
  }

  // Ensure directory exists
  const configDir = expandPath("~/.config/claude")
  if (!directoryExists(configDir)) {
    createDirectory(configDir)
  }

  // Write default config
  const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
  writeFile(configPath, JSON.stringify(defaultConfig, null, 2))

  // Reload English translations
  const t_en = JSON.parse(readFile("locales/en.json"))

  console.log(`
    ${t_en.commands.settings.settingsUpdated}

    🌐 ${t_en.commands.settings.globalSettingsReset}

    Reset to defaults:
    🌍 Language: English
  `)
}
```

**Instructions for Claude:**

For **local** scope (`--local` flag):

1. Check if `./.plan-config.json` exists:
   Use Read tool to check

2. If exists, remove it:
   Use Bash tool: `rm ./.plan-config.json`

3. Re-read config with hierarchy to see what's now active:
   - Try local (will be gone)
   - Fall back to global or default

4. Show success message in the new effective language:
   ```
   ✅ Settings updated!

   📁 Project-specific settings removed

   Now using: 🌐 Global settings (ქართული)
   ```
   or
   ```
   ✅ Settings updated!

   📁 Project-specific settings removed

   Now using: ⚙️ Default (English)
   ```

For **global** scope (no flag):

1. Create default config object:
   ```json
   {
     "language": "en",
     "lastUsed": "2026-01-27T15:30:00Z"
   }
   ```

2. Ensure directory exists:
   Use Bash tool: `mkdir -p ~/.config/claude`

3. Write default config:
   Use Write tool: `~/.config/claude/plan-plugin-config.json`

4. Load English translations:
   Use Read tool: `locales/en.json`

5. Show success message:
   ```
   ✅ Settings updated!

   🌐 Global settings reset to defaults

   Reset to defaults:
   🌍 Language: English
   ```

**Then STOP. Action complete.**

---

### Action: "help" - Show Usage Help

User entered unknown command, show help.

Pseudo-code:
```javascript
console.log(`
${t.commands.settings.usage}

${t.commands.settings.availableCommands}
- ${t.commands.settings.changeLanguage}
- ${t.commands.settings.reset}
`)
```

**Instructions for Claude:**

Output:
```
Usage: /plan:settings <command>

Available Commands:
- /plan:settings language    - Change language
- /plan:settings reset       - Reset to defaults
```

Use translation keys for all text.

**Then STOP.**

## Error Handling

### Config File Corrupted

If config file exists but has invalid JSON:

```javascript
try {
  const content = readFile(configPath)
  config = JSON.parse(content)
} catch (error) {
  // Corrupted, use defaults but show warning
  config = { language: "en" }

  console.log("⚠️ Warning: Config file was corrupted, using defaults")
}
```

### Translation File Missing

If translation file doesn't exist for selected language:

```javascript
const translationPath = `locales/${language}.json`

if (!fileExists(translationPath)) {
  // Fall back to English
  language = "en"
  translationPath = "locales/en.json"

  console.log(`⚠️ Warning: Translation file not found, using English`)
}
```

### Can't Write Config

If config directory is not writable:

```javascript
try {
  writeFile(configPath, configJSON)
} catch (error) {
  console.log(`⚠️ Warning: Couldn't save settings
Settings will apply for this session only`)
}
```

## Examples

### Example 1: Show Settings (Hierarchical)

```bash
$ /plan:settings
```

Output:
```
⚙️ Plan Plugin Settings

📊 Active Configuration:
🌍 Language: ქართული (Georgian) (local)

📁 Project Settings (./.plan-config.json):
  🌍 Language: ქართული
  📅 Last Used: 2026-01-27T15:30:00Z

🌐 Global Settings (~/.config/claude/plan-plugin-config.json):
  🌍 Language: English
  📅 Last Used: 2026-01-27T14:00:00Z

Available Commands:
- /plan:settings language           # Change global language
- /plan:settings language --local   # Change project language
- /plan:settings reset              # Reset global settings
- /plan:settings reset --local      # Remove project settings
```

### Example 2: Change to Georgian (Global)

```bash
$ /plan:settings language
```

User selects: ქართული (Georgian)

Output (in Georgian):
```
✅ პარამეტრები განახლდა!

🌐 გლობალური პარამეტრები შენახულია

ენა შეიცვალა: English → ქართული

ახალი ენა გამოყენებული იქნება:
• ყველა ბრძანების შედეგებისთვის (პროექტებში რომლებსაც არ აქვთ ლოკალური კონფიგი)
• Wizard-ის კითხვებისთვის
• გენერირებული PROJECT_PLAN.md ფაილებისთვის

სცადეთ: /plan:new
```

### Example 3: Change to Georgian (Project-Specific)

```bash
$ /plan:settings language --local
```

User selects: ქართული (Georgian)

Output (in Georgian):
```
✅ პარამეტრები განახლდა!

📁 პროექტ-სპეციფიკური პარამეტრები შენახულია

ენა შეიცვალა: English → ქართული

ახალი ენა გამოყენებული იქნება:
• ყველა ბრძანების შედეგებისთვის ამ პროექტში
• Wizard-ის კითხვებისთვის ამ პროექტში
• გენერირებული PROJECT_PLAN.md ფაილებისთვის ამ პროექტში

სცადეთ: /plan:new
```

### Example 4: Reset Global Settings

```bash
$ /plan:settings reset
```

Output:
```
✅ Settings updated!

🌐 Global settings reset to defaults

Reset to defaults:
🌍 Language: English
```

### Example 5: Remove Project Settings

```bash
$ /plan:settings reset --local
```

Output (if project had Georgian, now falls back to global English):
```
✅ Settings updated!

📁 Project-specific settings removed

Now using: 🌐 Global settings (English)
```

## Testing

Test cases to verify settings command with hierarchical config:

```bash
# Test 1: Show settings (no configs exist)
rm -f ./.plan-config.json ~/.config/claude/plan-plugin-config.json
/plan:settings
# Should show default (English)

# Test 2: Set global language to Georgian
/plan:settings language
# Select Georgian
# Should show success in Georgian, global scope

# Test 3: Verify global config saved
cat ~/.config/claude/plan-plugin-config.json
# Should show: {"language":"ka",...}

# Test 4: Show settings (global only)
/plan:settings
# Should show Georgian as active (global source)

# Test 5: Set project-specific language to English
/plan:settings language --local
# Select English
# Should show success in English, local scope

# Test 6: Verify local config saved
cat ./.plan-config.json
# Should show: {"language":"en",...}

# Test 7: Show settings (local overrides global)
/plan:settings
# Should show English as active (local source)
# Should show both local (English) and global (Georgian)

# Test 8: Remove project settings
/plan:settings reset --local
# Should remove ./.plan-config.json
# Should show now using global (Georgian)

# Test 9: Verify local config removed
ls ./.plan-config.json
# Should not exist

# Test 10: Show settings (global active again)
/plan:settings
# Should show Georgian as active (global source)

# Test 11: Reset global settings
/plan:settings reset
# Should reset global to English

# Test 12: Verify global reset
cat ~/.config/claude/plan-plugin-config.json
# Should show: {"language":"en",...}

# Test 13: Corrupted local config
echo 'invalid json' > ./.plan-config.json
/plan:settings
# Should fall back to global, show warning

# Test 14: Corrupted global config (no local)
rm ./.plan-config.json
echo 'invalid json' > ~/.config/claude/plan-plugin-config.json
/plan:settings
# Should fall back to default (English), show warning

# Test 15: Help (unknown command)
/plan:settings unknown
# Should show usage help
```

## Notes

- **Config file locations** (v1.1.1+):
  - **Local**: `./.plan-config.json` (project-specific, highest priority)
  - **Global**: `~/.config/claude/plan-plugin-config.json` (user-wide fallback)
- **Hierarchical priority**: Local → Global → Default ("en")
- **Supported languages**: English (en), Georgian (ka), Russian (ru)
- Settings persist across sessions
- All other commands automatically use the selected language from hierarchy
- Use `--local` flag to set project-specific settings
- Without `--local`, settings apply globally to all projects
- Changing language updates all future command outputs, wizard questions, and generated plans
- Translation files are in `locales/{lang}.json`

## Future Enhancements

Possible additions in future versions:

- Default project type preference
- Theme preferences (if applicable)
- Auto-save settings
- Import/export settings
- Team/shared settings
