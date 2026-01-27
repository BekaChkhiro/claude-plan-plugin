# /plan:settings - Plugin Settings Management

Manage plan-plugin configuration including language preferences, default project types, and other settings.

## Usage

```bash
/plan:settings              # Show current settings
/plan:settings language     # Change language preference
/plan:settings reset        # Reset to defaults
```

## What This Command Does

- Displays current plugin configuration
- Allows users to change language (English, Georgian, Russian)
- Saves preferences to ~/.config/claude/plan-plugin-config.json
- Persists settings across sessions

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

1. Read config to get current language preference
2. Load translation file
3. Store translations for use

Pseudo-code:
```javascript
// Read config
const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
let language = "en"
let config = { language: "en" }

if (fileExists(configPath)) {
  try {
    const content = readFile(configPath)
    config = JSON.parse(content)
    language = config.language || "en"
  } catch (error) {
    // Corrupted config, use defaults
    language = "en"
    config = { language: "en" }
  }
} else {
  // Config doesn't exist, use defaults
  config = { language: "en" }
}

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))

// Now ready to use t.commands.settings.key
```

**Instructions for Claude:**

Use Read tool to read config:
```
file_path: ~/.config/claude/plan-plugin-config.json
```

- If file exists: Parse JSON, get language (default "en" if corrupted)
- If file doesn't exist: Use default language "en"

Use Read tool to load translations:
```
file_path: locales/{language}.json
```

Parse response and store as `t` variable for use throughout command.

## Step 1: Parse Command Arguments

Check what sub-command user requested:

Pseudo-code:
```javascript
const args = parseArguments()  // Get arguments after "/plan:settings"

if (args.length === 0) {
  // Show current settings
  action = "show"
} else if (args[0] === "language") {
  // Change language
  action = "change-language"
} else if (args[0] === "reset") {
  // Reset to defaults
  action = "reset"
} else {
  // Unknown command
  action = "help"
}
```

**Instructions for Claude:**

Determine which action based on user's command:
- `/plan:settings` → action = "show"
- `/plan:settings language` → action = "change-language"
- `/plan:settings reset` → action = "reset"
- `/plan:settings something-else` → action = "help"

## Step 2: Execute Action

### Action: "show" - Display Current Settings

Show current configuration to user.

Pseudo-code:
```javascript
const languageNames = {
  "en": "English",
  "ka": "ქართული (Georgian)",
  "ru": "Русский (Russian)"
}

const currentLanguageName = languageNames[config.language] || "English"

const output = `
${t.commands.settings.title}

${t.commands.settings.currentConfig}
${t.commands.settings.language} ${currentLanguageName}
${t.commands.settings.lastUsed} ${config.lastUsed || "N/A"}

${t.commands.settings.availableCommands}
- ${t.commands.settings.changeLanguage}
- ${t.commands.settings.reset}
`

console.log(output)
```

**Instructions for Claude:**

Output to user:
```
⚙️ Plan Plugin Settings

Current Configuration:
🌍 Language: {language_name}
📅 Last Used: {last_used_date}

Available Commands:
- /plan:settings language    - Change language
- /plan:settings reset       - Reset to defaults
```

Use the translation keys from `t.commands.settings.*` for all text.

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

Update config file with new language preference.

Pseudo-code:
```javascript
// Update config object
const oldLanguage = config.language || "en"
config.language = newLanguage
config.lastUsed = new Date().toISOString()

// Ensure config directory exists
const configDir = expandPath("~/.config/claude")
if (!directoryExists(configDir)) {
  createDirectory(configDir)
}

// Write config file
const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
const configJSON = JSON.stringify(config, null, 2)
writeFile(configPath, configJSON)
```

**Instructions for Claude:**

1. Update config object:
   ```javascript
   config.language = newLanguage
   config.lastUsed = new Date().toISOString()
   ```

2. Ensure directory exists:
   Use Bash tool:
   ```bash
   mkdir -p ~/.config/claude
   ```

3. Write config file:
   Use Write tool:
   ```
   file_path: ~/.config/claude/plan-plugin-config.json
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

Display confirmation using the NEW language translations.

Pseudo-code:
```javascript
const languageNames = {
  "en": "English",
  "ka": "ქართული",
  "ru": "Русский"
}

const fromName = languageNames[oldLanguage]
const toName = languageNames[newLanguage]

const output = `
${t_new.commands.settings.settingsUpdated}

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

```
✅ Settings updated!

Language changed: English → ქართული

The new language will be used for:
• All command outputs
• Wizard questions
• Generated PROJECT_PLAN.md files

Try it: /plan:new
```

**IMPORTANT:** Use the NEW language translations (t_new), not the old ones (t).

Show the language change as: `{fromLanguage} → {toLanguage}` using native language names.

**Then STOP. Action complete.**

---

### Action: "reset" - Reset to Defaults

Reset configuration to default values.

**Step 2.1:** Confirm with user (optional)

You may want to confirm before resetting.

**Step 2.2:** Reset config

Pseudo-code:
```javascript
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

console.log(`${t_en.commands.settings.settingsUpdated}\n\nReset to defaults:\n🌍 Language: English`)
```

**Instructions for Claude:**

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
   Use Write tool with above content

4. Load English translations:
   Use Read tool: `locales/en.json`

5. Show success message:
   ```
   ✅ Settings updated!

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

### Example 1: Show Settings

```bash
$ /plan:settings
```

Output:
```
⚙️ Plan Plugin Settings

Current Configuration:
🌍 Language: English
📅 Last Used: 2026-01-27T14:30:00Z

Available Commands:
- /plan:settings language    - Change language
- /plan:settings reset       - Reset to defaults
```

### Example 2: Change to Georgian

```bash
$ /plan:settings language
```

User selects: ქართული (Georgian)

Output (in Georgian):
```
✅ პარამეტრები განახლდა!

ენა შეიცვალა: English → ქართული

ახალი ენა გამოყენებული იქნება:
• ყველა ბრძანების შედეგებისთვის
• Wizard-ის კითხვებისთვის
• გენერირებული PROJECT_PLAN.md ფაილებისთვის

სცადეთ: /plan:new
```

### Example 3: Reset to Defaults

```bash
$ /plan:settings reset
```

Output:
```
✅ Settings updated!

Reset to defaults:
🌍 Language: English
```

## Testing

Test cases to verify settings command:

```bash
# Test 1: Show settings (no config exists)
rm ~/.config/claude/plan-plugin-config.json
/plan:settings
# Should show English, default values

# Test 2: Change to Georgian
/plan:settings language
# Select Georgian
# Should show success in Georgian

# Test 3: Verify saved
cat ~/.config/claude/plan-plugin-config.json
# Should show: {"language":"ka",...}

# Test 4: Show settings (config exists)
/plan:settings
# Should show Georgian as current language

# Test 5: Change back to English
/plan:settings language
# Select English
# Should show success in English

# Test 6: Reset
/plan:settings reset
# Should reset to English

# Test 7: Verify reset
cat ~/.config/claude/plan-plugin-config.json
# Should show: {"language":"en",...}

# Test 8: Corrupted config
echo 'invalid json' > ~/.config/claude/plan-plugin-config.json
/plan:settings
# Should show warning and use defaults

# Test 9: Help (unknown command)
/plan:settings unknown
# Should show usage help
```

## Notes

- Config file location: `~/.config/claude/plan-plugin-config.json`
- Supports languages: English (en), Georgian (ka), Russian (ru)
- Settings persist across sessions
- All other commands will automatically use the selected language
- Changing language updates all future command outputs, wizard questions, and generated plans
- Translation files are in `locales/{lang}.json`

## Future Enhancements

Possible additions in future versions:

- Default project type preference
- Theme preferences (if applicable)
- Auto-save settings
- Import/export settings
- Team/shared settings
