# i18n System Guide

როგორ გამოვიყენოთ translations SKILL.md ფაილებში.

## 📍 Translation Files Location

```
locales/
├── en.json    # English translations
├── ka.json    # Georgian translations
└── ru.json    # Russian translations (future)
```

## 📝 Translation File Structure

```json
{
  "meta": {
    "language": "English",
    "code": "en",
    "version": "1.0.0"
  },

  "common": {
    "success": "✅ Success!",
    "error": "❌ Error:"
  },

  "commands": {
    "new": {
      "welcome": "📋 Welcome to Plan Creation Wizard!",
      "taskCompleted": "✅ Task {taskId} completed!"
    }
  },

  "wizard": { ... },
  "templates": { ... }
}
```

## 🔍 Loading Translations in SKILL.md

### Step-by-Step Instructions

```markdown
## Step 0: Load User Language & Translations

Before showing ANY output to user, you MUST:

1. Read user config to get language preference
2. Load appropriate translation file
3. Use translations for all user-facing text

**Pseudo-code:**

\`\`\`javascript
// Step 1: Read config
const configPath = expandPath("~/.config/claude/plan-plugin-config.json")
let config = { language: "en" }  // Default

if (fileExists(configPath)) {
  try {
    const content = readFile(configPath)
    config = JSON.parse(content)
  } catch (error) {
    // Corrupted config, use defaults
    config = { language: "en" }
  }
}

const userLanguage = config.language || "en"

// Step 2: Load translations
const translationPath = `locales/${userLanguage}.json`
const t = JSON.parse(readFile(translationPath))

// Step 3: Use translations
console.log(t.commands.new.welcome)
// EN: "📋 Welcome to Plan Creation Wizard!"
// KA: "📋 მოგესალმებით გეგმის შექმნის Wizard-ში!"
\`\`\`
```

### Instructions for Claude

```markdown
When executing this SKILL.md command:

**CRITICAL: Step 0 comes FIRST, before any other steps!**

**Step 0:** Load translations

Use Read tool to read config:
\`\`\`
file_path: ~/.config/claude/plan-plugin-config.json
\`\`\`

Parse JSON response to get language (default: "en" if file doesn't exist)

Use Read tool to read translations:
\`\`\`
file_path: locales/{language}.json
\`\`\`

Store the translations object as `t` for use throughout the command.

**Step 1:** (Your actual command logic starts here)

Now use `t.commands.commandName.key` for all output...
```

## 🎯 Using Translation Keys

### Basic Usage

Translation keys follow this pattern:

```
t.common.{key}                    # Shared strings
t.commands.{commandName}.{key}    # Command-specific
t.wizard.{key}                    # Wizard questions
t.templates.{key}                 # Template text
```

### Examples

```javascript
// Common strings
t.common.success         // "✅ Success!"
t.common.error           // "❌ Error:"
t.common.yes             // "Yes"
t.common.no              // "No"

// Command outputs
t.commands.new.welcome   // "📋 Welcome to Plan Creation Wizard!"
t.commands.next.title    // "🎯 Recommended Next Task"
t.commands.update.usage  // "Usage: /plan:update <task-id> <action>"

// Wizard
t.wizard.projectTypes.fullstack     // "Full-Stack Web App"
t.wizard.projectTypes.fullstackDesc // "Complete web application..."

// Templates
t.templates.sections.overview       // "Overview"
t.templates.complexity.high         // "High"
t.templates.status.inProgress       // "IN_PROGRESS"
```

## 🔧 Parameter Replacement

### Translation Strings with Placeholders

```json
{
  "taskCompleted": "✅ Task {taskId} completed! 🎉",
  "progressUpdate": "📊 Progress: {old}% → {new}% (+{delta}%)",
  "totalTasks": "📊 Total Tasks: {count}"
}
```

### How to Replace Parameters

**Pseudo-code:**

```javascript
// Single parameter
let message = t.commands.update.taskCompleted
message = message.replace("{taskId}", "T1.1")
// Result: "✅ Task T1.1 completed! 🎉"

// Multiple parameters
let progress = t.commands.update.progressUpdate
progress = progress.replace("{old}", "40")
         .replace("{new}", "50")
         .replace("{delta}", "10")
// Result: "📊 Progress: 40% → 50% (+10%)"

// With variables
const taskCount = 18
let summary = t.commands.new.totalTasks.replace("{count}", taskCount)
// Result: "📊 Total Tasks: 18"
```

### Instructions for Claude

```markdown
When you need to show a message with dynamic data:

**Step X:** Build message with parameters

Get translation string:
\`\`\`javascript
let message = t.commands.update.taskCompleted
\`\`\`

Replace placeholders:
\`\`\`javascript
message = message.replace("{taskId}", actualTaskId)
\`\`\`

Output to user:
\`\`\`
✅ Task T1.1 completed! 🎉
\`\`\`
```

## 📋 Complete Example: /plan:new Command

```markdown
# /plan:new - Create New Project Plan (i18n version)

## Step 0: Load Translations

**CRITICAL: Do this FIRST!**

Use Read tool:
\`\`\`
file_path: ~/.config/claude/plan-plugin-config.json
\`\`\`

If file exists, parse JSON and get language:
\`\`\`javascript
const config = JSON.parse(fileContent)
const language = config.language || "en"
\`\`\`

If file doesn't exist, use default:
\`\`\`javascript
const language = "en"
\`\`\`

Use Read tool to load translations:
\`\`\`
file_path: locales/{language}.json
\`\`\`

Parse and store as `t`:
\`\`\`javascript
const t = JSON.parse(translationContent)
\`\`\`

## Step 1: Welcome Message

Output to user:
\`\`\`
{t.commands.new.welcome}

{t.commands.new.intro}

{t.commands.new.whatYouGet}

{t.commands.new.letsStart}
\`\`\`

## Step 2: Ask Questions

Use AskUserQuestion with translated text:

\`\`\`javascript
AskUserQuestion({
  questions: [{
    question: t.commands.new.projectName,
    // User sees: "What's your project name?" (EN)
    // User sees: "რა სახელი ექნება თქვენს პროექტს?" (KA)
    header: "Project",
    options: [...]
  }]
})
\`\`\`

## Step 3: Generate Plan

Show progress:
\`\`\`
{t.commands.new.generating}
\`\`\`

## Step 4: Success Message

Build success output:
\`\`\`javascript
const taskCount = 18
const phaseCount = 4

let output = t.commands.new.success + "\n\n"
output += t.commands.new.fileCreated + "\n"
output += t.commands.new.totalTasks.replace("{count}", taskCount) + "\n"
output += t.commands.new.phases.replace("{count}", phaseCount) + "\n\n"
output += t.commands.new.nextSteps + "\n"
output += "- " + t.commands.new.reviewPlan + "\n"
output += "- " + t.commands.new.getNextTask + "\n"
output += "- " + t.commands.new.updateProgress
\`\`\`

Output to user:
\`\`\`
✅ Project plan created successfully!

📄 File: PROJECT_PLAN.md
📊 Total Tasks: 18
🎯 Phases: 4

Next steps:
- Review the plan and adjust as needed
- Start with: /plan:next (to get the next task)
- Update progress: /plan:update T1.1 start
\`\`\`
```

## 🌐 AskUserQuestion with i18n

### Translated Options

```markdown
When asking user questions, translate all parts:

\`\`\`javascript
AskUserQuestion({
  questions: [{
    question: t.commands.new.projectType,
    // "What type of project are you building?"

    header: t.templates.fields.projectType,
    // "Project Type"

    options: [
      {
        label: t.wizard.projectTypes.fullstack,
        // "Full-Stack Web App"
        description: t.wizard.projectTypes.fullstackDesc
        // "Complete web application with frontend and backend"
      },
      {
        label: t.wizard.projectTypes.backend,
        description: t.wizard.projectTypes.backendDesc
      }
      // ... more options
    ]
  }]
})
\`\`\`
```

## ⚠️ Error Handling

### Translation Loading Errors

```markdown
## Handling Translation Errors

**If translation file doesn't exist:**

\`\`\`javascript
const translationPath = `locales/${language}.json`

if (!fileExists(translationPath)) {
  // Fall back to English
  language = "en"
  translationPath = "locales/en.json"
}

const t = JSON.parse(readFile(translationPath))
\`\`\`

**If translation file is corrupted:**

\`\`\`javascript
let t
try {
  const content = readFile(`locales/${language}.json`)
  t = JSON.parse(content)
} catch (error) {
  // Fall back to English
  const enContent = readFile("locales/en.json")
  t = JSON.parse(enContent)

  // Warn user
  console.log("⚠️ Translation error, using English")
}
\`\`\`
```

## 💡 Best Practices

### 1. Always Load Translations First

```markdown
✅ CORRECT:

## Step 0: Load translations
## Step 1: Show welcome message (using t.commands.new.welcome)
## Step 2: Ask questions (using t.commands.new.projectName)

❌ WRONG:

## Step 1: Show "Welcome to wizard!" (hardcoded English)
## Step 2: Load translations
```

### 2. Never Hardcode User-Facing Text

```markdown
✅ CORRECT:
console.log(t.commands.update.taskCompleted.replace("{taskId}", "T1.1"))

❌ WRONG:
console.log("✅ Task T1.1 completed!")
```

### 3. Use Fallbacks

```markdown
✅ CORRECT:
const language = config.language || "en"
const t = loadTranslations(language) || loadTranslations("en")

❌ WRONG:
const language = config.language  // What if undefined?
const t = loadTranslations(language)  // Could fail!
```

### 4. Preserve Formatting

```markdown
Translation strings include emojis and formatting:

"success": "✅ Success!"
"error": "❌ Error:"
"info": "ℹ️ Info:"

Don't add extra emojis or formatting - it's already in translations!
```

### 5. Test Both Languages

```markdown
After implementing i18n in a command:

Test 1: Set language to "en", run command
Test 2: Set language to "ka", run command
Test 3: Corrupt config, run command (should use "en" default)
Test 4: Use non-existent language "fr", run command (should fall back to "en")
```

## 📦 Complete Template for SKILL.md

```markdown
# /plan:commandname - Command Description

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

1. Read config to get language preference
2. Load translation file
3. Store translations for use

Pseudo-code:
\`\`\`javascript
// Read config
const configPath = "~/.config/claude/plan-plugin-config.json"
let language = "en"

if (fileExists(configPath)) {
  const config = JSON.parse(readFile(configPath))
  language = config.language || "en"
}

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))

// Now ready to use t.commands.commandname.key
\`\`\`

Instructions for Claude:

Use Read tool:
- file_path: ~/.config/claude/plan-plugin-config.json

Parse response, get language (default "en")

Use Read tool:
- file_path: locales/{language}.json

Parse response, store as `t`

## Step 1: Your Command Logic

Use translations for all output:

\`\`\`
{t.commands.commandname.welcome}
{t.commands.commandname.instructions}
\`\`\`

For dynamic content:
\`\`\`javascript
let message = t.commands.commandname.message
message = message.replace("{param}", actualValue)
\`\`\`

## Step 2: Continue...

Always use `t.commands.commandname.*` for user-facing text!
```

## 🧪 Testing i18n Integration

```bash
# Test 1: Default language (English)
rm ~/.config/claude/plan-plugin-config.json
/plan:new
# Should show English text

# Test 2: Georgian language
echo '{"language":"ka"}' > ~/.config/claude/plan-plugin-config.json
/plan:new
# Should show Georgian text

# Test 3: Invalid language (fallback to English)
echo '{"language":"fr"}' > ~/.config/claude/plan-plugin-config.json
/plan:new
# Should show English text (fr.json doesn't exist)

# Test 4: Corrupted config (fallback to English)
echo 'invalid json' > ~/.config/claude/plan-plugin-config.json
/plan:new
# Should show English text

# Test 5: All commands with Georgian
echo '{"language":"ka"}' > ~/.config/claude/plan-plugin-config.json
/plan:new
/plan:next
/plan:update T1.1 start
/plan:export json
# All should show Georgian text
```

## 📚 Quick Reference

### Common Translation Patterns

```javascript
// Success messages
t.common.success + "\n" + t.commands.commandname.details

// Error messages
t.common.error + " " + errorDetails

// Progress updates
t.commands.update.progressUpdate
  .replace("{old}", oldPercent)
  .replace("{new}", newPercent)
  .replace("{delta}", deltaPercent)

// Task counts
t.commands.new.totalTasks.replace("{count}", taskArray.length)

// File paths
t.commands.new.fileCreated  // "📄 File: PROJECT_PLAN.md"

// Next steps
t.commands.new.nextSteps + "\n" +
"- " + t.commands.new.reviewPlan + "\n" +
"- " + t.commands.new.getNextTask
```

### Translation Key Paths

```
t.meta.language              # "English" or "ქართული"
t.common.{key}              # Shared strings
t.commands.{cmd}.{key}      # Command outputs
t.wizard.projectTypes.{key} # Wizard options
t.templates.sections.{key}  # Template sections
t.templates.complexity.{key}# Complexity levels
t.templates.status.{key}    # Task statuses
t.templates.fields.{key}    # Field labels
```

---

**See complete examples in:**
- commands/settings/SKILL.md (when created in Day 2)
- Updated commands in Day 3

**Translation files:**
- locales/en.json - English reference
- locales/ka.json - Georgian translations
