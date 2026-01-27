# Utils - i18n & Config System

ეს დირექტორია შეიცავს დოკუმენტაციას მრავალენოვანი მხარდაჭერისა და კონფიგურაციის სისტემის გამოსაყენებლად SKILL.md ფაილებში.

## 📁 სტრუქტურა

```
utils/
├── README.md           # ეს ფაილი
├── config-guide.md     # Config system documentation
└── i18n-guide.md       # Translation system documentation
```

## 🌍 Multi-Language Support

Plugin ახლა მხარს უჭერს მრავალ ენას:
- English (en)
- ქართული (ka)
- Русский (ru) - მომავალში

### როგორ მუშაობს

1. მომხმარებელი ირჩევს ენას: `/plan:settings language`
2. არჩევანი ინახება: `~/.config/claude/plan-plugin-config.json`
3. თარგმანები იტვირთება: `locales/{lang}.json`
4. Commands იყენებენ თარგმნილ strings-ებს

## 📚 Documentation Files

### config-guide.md
როგორ წაიკითხოთ და ჩაწეროთ user configuration

### i18n-guide.md
როგორ გამოიყენოთ translations SKILL.md-ში

## 🚀 Quick Start

Commands-ში დაამატეთ:

```markdown
## Step 0: Load Language & Translations

Before showing any output to user:

1. Read user config from: ~/.config/claude/plan-plugin-config.json
2. Get language preference (default: "en")
3. Load translations from: locales/{language}.json
4. Use translations for all user-facing text

Example pseudo-code:
\`\`\`javascript
// Read config
const configPath = "~/.config/claude/plan-plugin-config.json"
const config = readJSON(configPath) // { "language": "ka", ... }
const language = config.language || "en"

// Load translations
const translationsPath = `locales/${language}.json`
const t = readJSON(translationsPath)

// Use translations
console.log(t.commands.new.welcome)
// EN: "📋 Welcome to Plan Creation Wizard!"
// KA: "📋 მოგესალმებით გეგმის შექმნის Wizard-ში!"
\`\`\`
```

## 🔄 როგორ განაახლოთ არსებული Commands

იხილეთ დეტალური ინსტრუქციები:
- `config-guide.md` - config operations
- `i18n-guide.md` - using translations

## 💾 Config File Format

```json
{
  "language": "ka",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-27"
}
```

## 🌐 Translation Keys

მთავარი keys:
- `commands.{commandName}.{key}` - Command outputs
- `wizard.{key}` - Wizard questions
- `templates.{key}` - Template text
- `common.{key}` - Shared strings

მაგალითად:
```javascript
t.commands.update.taskCompleted  // "✅ Task {taskId} completed!"
t.common.success                 // "✅ Success!"
t.templates.complexity.high      // "High" or "მაღალი"
```

## 🔧 Parameter Replacement

Translation strings-ში შეგიძლია გამოიყენოთ placeholders:

```javascript
// Translation string:
"taskCompleted": "✅ Task {taskId} completed!"

// Usage (pseudo-code):
const message = t.commands.update.taskCompleted
  .replace("{taskId}", "T1.1")
// Result: "✅ Task T1.1 completed!"
```

---

დეტალური ინსტრუქციებისთვის იხილეთ:
- [config-guide.md](config-guide.md)
- [i18n-guide.md](i18n-guide.md)
