# Release v1.1.1: Project-Specific Language Settings 📁

**Release Date**: 2026-01-27
**Type**: Patch Release (v1.1.0 → v1.1.1)
**Focus**: Hierarchical configuration system

---

## 🎯 What's New

### Project-Specific Language Settings

You can now set different languages for different projects! The plugin now supports a **hierarchical configuration system**:

```bash
# Set global language (affects all projects)
/settings language

# Set project-specific language (only affects current project)
/settings language --local
```

**Configuration Priority:**
1. **Local** (`./.plan-config.json`) - Project-specific, highest priority
2. **Global** (`~/.config/claude/plan-plugin-config.json`) - User-wide fallback
3. **Default** (English) - Final fallback

---

## 💡 Use Cases

### Different Languages for Different Projects

```bash
# Personal project in Georgian
cd ~/projects/personal-app
/settings language --local
# Select: ქართული (Georgian)
/new  # Creates Georgian plan

# Work project in English
cd ~/projects/work-app
/settings language --local
# Select: English
/new  # Creates English plan
```

### Global Default with Project Overrides

```bash
# Set global default to Georgian
/settings language
# Select: ქართული

# Override for specific project
cd ~/projects/international-collab
/settings language --local
# Select: English

# Other projects use Georgian automatically
cd ~/projects/other-project
/new  # Uses Georgian (from global config)
```

---

## ⚙️ Enhanced Settings Command

### View Configuration Hierarchy

```bash
/settings
```

**Output:**
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
- /settings language           # Change global language
- /settings language --local   # Change project language
- /settings reset              # Reset global settings
- /settings reset --local      # Remove project settings
```

### Reset Commands

```bash
# Remove project-specific settings (fall back to global)
/settings reset --local

# Reset global settings to defaults (English)
/settings reset
```

---

## 🔧 Technical Changes

### All Commands Updated

All commands now use hierarchical config reading:
- `/new` - Creates plans in project's language
- `/next` - Recommends tasks in project's language
- `/update` - Updates progress in project's language
- `/export` - Exports in project's language
- `/settings` - Manages both local and global configs

### New Translation Keys

Added 5 new translation keys for hierarchical config messages:
- `projectScope` - "Project-specific settings saved"
- `globalScope` - "Global settings saved"
- `projectSettingsRemoved` - "Project-specific settings removed"
- `nowUsing` - "Now using"
- `globalSettingsReset` - "Global settings reset to defaults"

### Backward Compatibility

✅ **Fully backward compatible** with v1.1.0:
- Existing global configs continue to work
- No migration needed
- Projects without local config use global config

---

## 📊 Changes Summary

- **Files Modified**: 8 files
- **New Features**: Hierarchical config, `--local` flag
- **Commands Updated**: All 5 commands (new, next, update, export, settings)
- **Translation Keys Added**: 5 keys (English + Georgian)
- **Breaking Changes**: None (fully backward compatible)

---

## 🚀 Upgrade Instructions

### From v1.1.0

```bash
cd ~/.config/claude/plugins/plan
git pull origin master

# Or use install script
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash
```

Your existing global language settings will continue to work. To use project-specific settings, just use the `--local` flag:

```bash
/settings language --local
```

---

## 🐛 Bug Fixes

- Config file corruption now gracefully falls back through hierarchy
- Missing local config no longer throws errors
- Empty config files handled properly
- Improved error messages when config cannot be read

---

## 📚 Documentation

### Updated Documentation
- ✅ `CHANGELOG.md` - Complete v1.1.1 changelog
- ✅ `README.md` - Updated multi-language section
- ✅ `utils/config-guide.md` - Hierarchical config documentation
- ✅ All command `SKILL.md` files - Updated Step 0 with hierarchical config

### Testing Guide

The comprehensive [TESTING_GUIDE.md](TESTING_GUIDE.md) has been updated with scenarios for testing hierarchical config.

---

## 🎓 Example Workflow

### Team Project with Mixed Languages

```bash
# You prefer Georgian globally
/settings language
# Select: ქართული

# Create personal project (uses global Georgian)
cd ~/projects/personal-blog
/new
# ✅ Creates plan in Georgian

# Join international team project (needs English)
cd ~/projects/team-project
/settings language --local
# Select: English
/new
# ✅ Creates plan in English

# Check settings
/settings
# Shows:
#   Active: English (local)
#   Local: English
#   Global: ქართული

# Remove local override to use Georgian again
/settings reset --local
# Now uses global Georgian
```

---

## 🔮 What's Next?

### Coming in v1.2.0
- 🇷🇺 Russian language support (Русский)
- 📝 Custom template creation
- 👥 Team template sharing
- 📈 More analytics and insights

---

## 💬 Feedback

Found a bug? Have a suggestion?

- 🐛 [Report Issues](https://github.com/BekaChkhiro/claude-plan-plugin/issues)
- 💡 [Suggest Features](https://github.com/BekaChkhiro/claude-plan-plugin/issues/new)
- 🌍 [Add Translation](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/utils/i18n-guide.md)

---

**Full Changelog**: https://github.com/BekaChkhiro/claude-plan-plugin/compare/v1.1.0...v1.1.1

**Download**: https://github.com/BekaChkhiro/claude-plan-plugin/releases/tag/v1.1.1

Made with ❤️ by [@BekaChkhiro](https://github.com/BekaChkhiro)

გმადლობთ! (Thank you!)
