# 🌍 Multi-Language Support - დეტალური ანალიზი

## 📋 რა უნდა ითარგმნოს?

### 1. User-Facing Text (მომხმარებლისთვის)

#### A. Command Output Messages
```javascript
// ინგლისური
"✅ Project plan created successfully!"
"📊 Progress: 0% → 7% (+7%)"
"🎯 Recommended Next Task:"

// ქართული
"✅ პროექტის გეგმა წარმატებით შეიქმნა!"
"📊 პროგრესი: 0% → 7% (+7%)"
"🎯 რეკომენდირებული შემდეგი ამოცანა:"
```

#### B. Wizard Questions
```javascript
// ინგლისური
"What's your project name?"
"What type of project are you building?"
"Which frontend framework?"

// ქართული
"რა სახელია თქვენი პროექტს?"
"რა ტიპის პროექტს აშენებთ?"
"რომელი frontend framework?"
```

#### C. Error Messages
```javascript
// ინგლისური
"❌ Error: PROJECT_PLAN.md not found"
"⚠️ Invalid task ID"

// ქართული
"❌ შეცდომა: PROJECT_PLAN.md არ მოიძებნა"
"⚠️ არასწორი task ID"
```

### 2. Generated Content (დაგენერირებული)

#### A. PROJECT_PLAN.md Sections
```markdown
## Overview  →  ## მიმოხილვა
## Architecture  →  ## არქიტექტურა
## Tech Stack  →  ## ტექნოლოგიები
## Tasks  →  ## ამოცანები
## Progress Tracking  →  ## პროგრესის თრექინგი
```

#### B. Task Descriptions
```markdown
// ინგლისური
#### T1.1: Project Setup
- [ ] **Status**: TODO
- **Complexity**: Low
- **Estimated**: 2 hours
- **Description**: Initialize project structure...

// ქართული
#### T1.1: პროექტის დაყენება
- [ ] **სტატუსი**: TODO
- **სირთულე**: დაბალი
- **სავარაუდო დრო**: 2 საათი
- **აღწერა**: პროექტის სტრუქტურის ინიციალიზაცია...
```

### 3. Documentation (NOT translated initially)

README.md, CONTRIBUTING.md და სხვა docs დარჩება ინგლისურად (საერთაშორისო აუდიტორიისთვის).

---

## 🏗️ არქიტექტურა

### Option 1: Configuration File (რეკომენდირებული)

```
plan-plugin/
├── .claude-plugin/
│   └── plugin.json
│
├── locales/                    # ← ახალი!
│   ├── en.json                # ინგლისური
│   ├── ka.json                # ქართული
│   └── ru.json                # რუსული (მომავალში)
│
├── commands/
│   ├── new/SKILL.md
│   ├── settings/SKILL.md      # ← ახალი! ენის შეცვლა
│   └── ...
│
└── templates/
    ├── en/                     # ← ახალი!
    │   ├── fullstack.template.md
    │   └── ...
    └── ka/                     # ← ახალი!
        ├── fullstack.template.md
        └── ...
```

### Option 2: Inline Translation (უფრო simple)

```javascript
// commands/new/SKILL.md-ში
const messages = {
  en: {
    welcome: "Welcome to Plan Creation Wizard!",
    projectName: "What's your project name?"
  },
  ka: {
    welcome: "მოგესალმებით Plan-ის შექმნის Wizard-ში!",
    projectName: "რა სახელია თქვენს პროექტს?"
  }
}
```

**რეკომენდაცია:** Option 1 (separate files) - უფრო clean და maintainable.

---

## 💾 ენის შენახვა

### Storage Options:

#### Option A: Local Config File (რეკომენდირებული)
```json
// ~/.config/claude/plan-plugin-config.json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-26"
}
```

#### Option B: Environment Variable
```bash
export CLAUDE_PLAN_LANG=ka
```

#### Option C: In PROJECT_PLAN.md itself
```markdown
<!-- plan-plugin-config: lang=ka -->
```

**რეკომენდაცია:** Option A - persistent და user-friendly.

---

## 🔄 როგორ მუშაობს

### Flow Diagram:

```
User starts Claude Code
       ↓
Plugin loads
       ↓
Read config: ~/.config/claude/plan-plugin-config.json
       ↓
Load language: locales/{lang}.json
       ↓
User runs /plan:new
       ↓
Show wizard in selected language
       ↓
Generate PROJECT_PLAN.md with selected language template
```

### Language Selection:

```bash
# First time - ask user
/plan:new
> 🌍 Select your language / აირჩიეთ ენა:
  1. English
  2. ქართული
  3. Русский

# Or change anytime
/plan:settings
> Current language: ქართული
> Change to: English / Русский
```

---

## 📝 Implementation Plan

### Phase 1: Infrastructure (2-3 საათი)

#### T1.1: Create Language Files
```bash
mkdir locales
touch locales/en.json
touch locales/ka.json
```

**en.json:**
```json
{
  "common": {
    "success": "✅ Success!",
    "error": "❌ Error:",
    "warning": "⚠️ Warning:"
  },
  "commands": {
    "new": {
      "welcome": "Welcome to Plan Creation Wizard!",
      "projectName": "What's your project name?",
      "projectType": "What type of project?",
      "description": "Brief description?",
      "success": "Project plan created successfully!"
    },
    "next": {
      "title": "🎯 Recommended Next Task:",
      "noDependencies": "✅ All dependencies completed",
      "whyThisTask": "🎯 Why this task?"
    },
    "update": {
      "taskStarted": "Task {taskId} started",
      "taskCompleted": "✅ Task {taskId} completed! 🎉",
      "progressUpdate": "📊 Progress: {old}% → {new}% (+{delta}%)"
    }
  },
  "wizard": {
    "questions": {
      "projectName": "What's your project name?",
      "projectType": "What type of project are you building?",
      "description": "Brief description (1-2 sentences)?",
      "targetUsers": "Who will use this project?",
      "frontend": "Which frontend framework?",
      "backend": "Which backend framework?",
      "database": "Which database?",
      "features": "Main features (3-5)?"
    },
    "projectTypes": {
      "fullstack": "Full-Stack Web App",
      "backend": "Backend API",
      "frontend": "Frontend SPA"
    }
  },
  "templates": {
    "sections": {
      "overview": "Overview",
      "architecture": "Architecture",
      "techStack": "Tech Stack",
      "tasks": "Tasks & Implementation Plan",
      "progress": "Progress Tracking"
    },
    "complexity": {
      "low": "Low",
      "medium": "Medium",
      "high": "High"
    },
    "status": {
      "todo": "TODO",
      "inProgress": "IN_PROGRESS",
      "done": "DONE",
      "blocked": "BLOCKED"
    }
  }
}
```

**ka.json:**
```json
{
  "common": {
    "success": "✅ წარმატება!",
    "error": "❌ შეცდომა:",
    "warning": "⚠️ გაფრთხილება:"
  },
  "commands": {
    "new": {
      "welcome": "მოგესალმებით გეგმის შექმნის Wizard-ში!",
      "projectName": "რა სახელია თქვენს პროექტს?",
      "projectType": "რა ტიპის პროექტს აშენებთ?",
      "description": "მოკლე აღწერა?",
      "success": "პროექტის გეგმა წარმატებით შეიქმნა!"
    },
    "next": {
      "title": "🎯 რეკომენდირებული შემდეგი ამოცანა:",
      "noDependencies": "✅ ყველა დამოკიდებულება შესრულებულია",
      "whyThisTask": "🎯 რატომ ეს ამოცანა?"
    },
    "update": {
      "taskStarted": "ამოცანა {taskId} დაიწყო",
      "taskCompleted": "✅ ამოცანა {taskId} დასრულდა! 🎉",
      "progressUpdate": "📊 პროგრესი: {old}% → {new}% (+{delta}%)"
    }
  },
  "wizard": {
    "questions": {
      "projectName": "რა სახელია თქვენს პროექტს?",
      "projectType": "რა ტიპის პროექტს აშენებთ?",
      "description": "მოკლე აღწერა (1-2 წინადადება)?",
      "targetUsers": "ვინ გამოიყენებს ამ პროექტს?",
      "frontend": "რომელი frontend framework?",
      "backend": "რომელი backend framework?",
      "database": "რომელი მონაცემთა ბაზა?",
      "features": "მთავარი ფუნქციები (3-5)?"
    },
    "projectTypes": {
      "fullstack": "Full-Stack ვებ აპლიკაცია",
      "backend": "Backend API",
      "frontend": "Frontend SPA"
    }
  },
  "templates": {
    "sections": {
      "overview": "მიმოხილვა",
      "architecture": "არქიტექტურა",
      "techStack": "ტექნოლოგიური Stack",
      "tasks": "ამოცანები და განხორციელების გეგმა",
      "progress": "პროგრესის თრექინგი"
    },
    "complexity": {
      "low": "დაბალი",
      "medium": "საშუალო",
      "high": "მაღალი"
    },
    "status": {
      "todo": "TODO",
      "inProgress": "მიმდინარეობს",
      "done": "შესრულებული",
      "blocked": "დაბლოკილი"
    }
  }
}
```

#### T1.2: Create Config System
```bash
mkdir utils
touch utils/config.js
touch utils/i18n.js
```

**utils/config.js** (pseudo-code for SKILL.md):
```javascript
// Read/write user config
function getConfig() {
  // Read ~/.config/claude/plan-plugin-config.json
  // Return { language: 'ka', ... }
}

function setConfig(key, value) {
  // Update config file
}

function getLanguage() {
  const config = getConfig()
  return config.language || 'en' // default to English
}
```

**utils/i18n.js** (pseudo-code):
```javascript
// Load translations
function loadTranslations(lang) {
  // Read locales/{lang}.json
  // Return translation object
}

function t(key, params) {
  const lang = getLanguage()
  const translations = loadTranslations(lang)
  let text = translations[key]

  // Replace {param} with actual values
  // "Task {taskId} completed" → "Task T1.1 completed"

  return text
}

// Usage:
t('commands.update.taskCompleted', { taskId: 'T1.1' })
// EN: "✅ Task T1.1 completed! 🎉"
// KA: "✅ ამოცანა T1.1 დასრულდა! 🎉"
```

---

### Phase 2: Settings Command (1-2 საათი)

#### T2.1: Create /plan:settings Command

**commands/settings/SKILL.md:**
```markdown
# Plan Settings Command

You help users configure their Plan Plugin preferences.

## Objective

Allow users to:
1. View current settings
2. Change language
3. Set defaults

## Process

### Step 1: Show Current Settings

When user runs `/plan:settings`, display:

\`\`\`
⚙️ Plan Plugin Settings

Current Configuration:
  🌍 Language: ქართული (Georgian)
  📁 Default Project Type: Full-Stack
  📅 Last Used: 2026-01-26

Available Commands:
  /plan:settings language    - Change language
  /plan:settings reset       - Reset to defaults
\`\`\`

### Step 2: Change Language

When user runs `/plan:settings language`:

Use AskUserQuestion tool:

\`\`\`json
{
  "questions": [{
    "question": "Select your preferred language:",
    "header": "Language",
    "multiSelect": false,
    "options": [
      {
        "label": "English",
        "description": "Use English for all plugin interactions"
      },
      {
        "label": "ქართული (Georgian)",
        "description": "გამოიყენე ქართული ყველა ურთიერთქმედებისთვის"
      },
      {
        "label": "Русский (Russian)",
        "description": "Использовать русский язык"
      }
    ]
  }]
}
\`\`\`

### Step 3: Save Configuration

Update config file at:
\`~/.config/claude/plan-plugin-config.json\`

\`\`\`json
{
  "language": "ka",
  "updated": "2026-01-26T20:00:00Z"
}
\`\`\`

Show confirmation:
\`\`\`
✅ Settings updated!

Language changed: English → ქართული

The new language will be used for:
  • All command outputs
  • Wizard questions
  • Generated PROJECT_PLAN.md files

Try it: /plan:new
\`\`\`

## Important Notes

- Settings are stored per-user (not per-project)
- Existing PROJECT_PLAN.md files keep their language
- New plans will use the selected language
```

---

### Phase 3: Update Commands (4-6 საათი)

#### T3.1: Update /plan:new

In `commands/new/SKILL.md`, add:

```markdown
## Step 0: Load Language

Before starting wizard:

\`\`\`
1. Read config: ~/.config/claude/plan-plugin-config.json
2. Load translations: locales/{lang}.json
3. Use translated strings for all output
\`\`\`

Example:
\`\`\`javascript
const lang = getLanguage() // 'ka'
const t = loadTranslations(lang)

// Instead of:
"Welcome to Plan Creation Wizard!"

// Use:
t.commands.new.welcome
// Output: "მოგესალმებით გეგმის შექმნის Wizard-ში!"
\`\`\`

## Questions in Selected Language

For Georgian:
\`\`\`
❓ რა სახელია თქვენს პროექტს?
→ TaskMaster

❓ რა ტიპის პროექტს აშენებთ?
→ Full-Stack ვებ აპლიკაცია

❓ მოკლე აღწერა?
→ ამოცანების მენეჯმენტის აპლიკაცია
\`\`\`
```

#### T3.2: Update /plan:next

Translate output messages using i18n system.

#### T3.3: Update /plan:update

Translate progress messages.

#### T3.4: Update /plan:export

Translate export messages.

---

### Phase 4: Template Translations (6-8 საათი)

#### T4.1: Create Georgian Templates

```bash
mkdir -p templates/ka
mkdir -p templates/ka/sections
```

Copy and translate:
```bash
# Copy English templates
cp templates/fullstack.template.md templates/ka/fullstack.template.md
cp templates/backend-api.template.md templates/ka/backend-api.template.md
cp templates/frontend-spa.template.md templates/ka/frontend-spa.template.md

# Copy sections
cp -r templates/sections templates/ka/sections

# Now translate each file
```

**templates/ka/fullstack.template.md:**
```markdown
# {{PROJECT_NAME}} - Full-Stack პროექტის გეგმა

*შეიქმნა: {{CREATED_DATE}}*
*ბოლო განახლება: {{LAST_UPDATED}}*

## მიმოხილვა

**პროექტის სახელი**: {{PROJECT_NAME}}

**აღწერა**: {{DESCRIPTION}}

**მიზნობრივი მომხმარებლები**: {{TARGET_USERS}}

**პროექტის ტიპი**: Full-Stack ვებ აპლიკაცია

**სტატუსი**: {{STATUS}} ({{PROGRESS_PERCENT}}% დასრულებული)

---

## პრობლემის განსაზღვრა

**მიმდინარე პრობლემები:**
{{PAIN_POINTS}}

**გადაწყვეტა:**
{{SOLUTION}}

**ძირითადი ფუნქციები:**
{{KEY_FEATURES}}

---

## არქიტექტურა

### სისტემის მიმოხილვა

\`\`\`mermaid
{{ARCHITECTURE_DIAGRAM}}
\`\`\`

---

## ტექნოლოგიური Stack

### Frontend
{{FRONTEND_STACK}}

### Backend
{{BACKEND_STACK}}

### მონაცემთა ბაზა
{{DATABASE_STACK}}

---

## ამოცანები და განხორციელების გეგმა

### ფაზა 1: საფუძველი (სავარაუდო: {{PHASE1_ESTIMATE}})

#### T1.1: პროექტის დაყენება
- [ ] **სტატუსი**: TODO
- **სირთულე**: დაბალი
- **სავარაუდო დრო**: 2 საათი
- **დამოკიდებულებები**: არ არის
- **აღწერა**:
  - Frontend პროექტის ინიციალიზაცია ({{FRONTEND_FRAMEWORK}})
  - Backend პროექტის ინიციალიზაცია ({{BACKEND_FRAMEWORK}})
  - TypeScript-ის კონფიგურაცია
  - ESLint + Prettier დაყენება

---

## პროგრესის თრექინგი

### საერთო სტატუსი
**სულ ამოცანები**: {{TOTAL_TASKS}}
**შესრულებული**: {{COMPLETED_TASKS}} {{PROGRESS_BAR}} ({{PROGRESS_PERCENT}}%)
**მიმდინარეობს**: {{IN_PROGRESS_TASKS}}
**დაბლოკილი**: {{BLOCKED_TASKS}}

### ფაზების პროგრესი
- 🟢 ფაზა 1: საფუძველი → {{PHASE1_PROGRESS}}%
- 🔵 ფაზა 2: ძირითადი ფუნქციები → {{PHASE2_PROGRESS}}%
- 🟣 ფაზა 3: დამატებითი ფუნქციები → {{PHASE3_PROGRESS}}%
- 🟠 ფაზა 4: ტესტირება და Deploy → {{PHASE4_PROGRESS}}%

### მიმდინარე ფოკუსი
{{CURRENT_FOCUS}}

---

*შექმნილია plan-plugin v{{PLUGIN_VERSION}}-ით*
```

---

### Phase 5: Testing (2-3 საათი)

#### T5.1: Test Language Switching

```bash
# Test 1: Default (English)
claude
/plan:new
# Should show English

# Test 2: Switch to Georgian
/plan:settings language
# Select ქართული
/plan:new
# Should show Georgian

# Test 3: Generated plan
cat PROJECT_PLAN.md
# Should be in Georgian

# Test 4: Other commands
/plan:next
/plan:update T1.1 start
/plan:export json
# All should be in Georgian
```

#### T5.2: Test Both Languages

Create test plans in both languages and verify:
- Translations are correct
- No untranslated text
- Formatting is preserved
- Emojis work correctly

---

## 🎨 Design Decisions

### What to Translate?

✅ **YES:**
- Command output messages
- Wizard questions
- Error messages
- Generated PROJECT_PLAN.md content
- Section headers
- Task descriptions
- Progress messages

❌ **NO (Keep in English):**
- Command names (/plan:new, /plan:update)
- Task IDs (T1.1, T2.3)
- File names (PROJECT_PLAN.md)
- Code/technical terms (React, Express, PostgreSQL)
- URLs and links
- Git commit messages
- GitHub-related text

### Mixed Language Handling

For Georgian user working in English codebase:
```markdown
#### T1.1: პროექტის დაყენება
- [ ] **სტატუსი**: TODO
- **სირთულე**: დაბალი
- **აღწერა**:
  - Initialize React project with Vite
  - Setup TypeScript configuration
  - Configure ESLint + Prettier
```

Technical terms stay in English!

---

## 📊 Effort Estimate

| Phase | Task | Estimate |
|-------|------|----------|
| 1 | Infrastructure | 2-3h |
| 2 | Settings command | 1-2h |
| 3 | Update commands | 4-6h |
| 4 | Template translations | 6-8h |
| 5 | Testing | 2-3h |
| **Total** | | **15-22 hours** |

---

## 🚀 Release Plan

### v1.1.0 - Georgian Language Support

**Features:**
- ✅ Language selection (/plan:settings)
- ✅ Georgian translations
- ✅ Georgian templates
- ✅ Persistent language preference
- ✅ All commands translated

**Breaking Changes:**
- None (English is default)

**Migration:**
- Existing users: No action needed
- New feature: Run /plan:settings to choose language

---

## 🔮 Future Enhancements

### v1.2.0 - More Languages
- Russian (Русский)
- Spanish (Español)
- French (Français)

### v1.3.0 - Advanced Features
- Auto-detect system language
- Per-project language override
- Mixed language support
- Translation contributions via Crowdin

---

## ✅ Success Criteria

Multi-language support is successful when:

1. ✅ User can select language via /plan:settings
2. ✅ All commands work in both languages
3. ✅ Generated plans are fully translated
4. ✅ No English text appears in Georgian mode (except technical terms)
5. ✅ Language preference persists across sessions
6. ✅ Easy to add new languages
7. ✅ Documentation updated

---

## 📝 Implementation Checklist

### Infrastructure
- [ ] Create locales/ directory
- [ ] Create en.json with all strings
- [ ] Create ka.json with Georgian translations
- [ ] Create utils/config.js for settings
- [ ] Create utils/i18n.js for translations

### Commands
- [ ] Create /plan:settings command
- [ ] Update /plan:new to use i18n
- [ ] Update /plan:next to use i18n
- [ ] Update /plan:update to use i18n
- [ ] Update /plan:export to use i18n

### Templates
- [ ] Create templates/ka/ directory
- [ ] Translate fullstack.template.md
- [ ] Translate backend-api.template.md
- [ ] Translate frontend-spa.template.md
- [ ] Translate section partials

### Testing
- [ ] Test language switching
- [ ] Test Georgian wizard
- [ ] Test Georgian plan generation
- [ ] Test all commands in Georgian
- [ ] Verify no untranslated strings

### Documentation
- [ ] Update README with language info
- [ ] Update CHANGELOG
- [ ] Add LANGUAGES.md guide
- [ ] Create contribution guide for translations

---

*დეტალური ანალიზი მზადაა იმპლემენტაციისთვის!*
