# Release v1.1.0: Multi-Language Support 🌍

We're excited to announce v1.1.0 of the Plan Plugin, featuring complete **multi-language support** with Georgian (ქართული) as our first additional language!

## 🎉 What's New

### Multi-Language Support

The plugin now speaks your language! Set your preferred language and get a fully localized experience:

```bash
/settings language
```

**Supported Languages:**
- 🇬🇧 **English** (default)
- 🇬🇪 **ქართული** (Georgian) - NEW!
- 🇷🇺 **Русский** (Russian) - Coming in v1.2.0

### Language Settings Command

New `/settings` command to manage your preferences:

```bash
/settings              # View current settings
/settings language     # Change language
/settings reset        # Reset to defaults
```

### Complete Georgian Translation

Everything is translated - not just UI strings:

✅ **All Commands**
- Wizard questions in Georgian
- Success messages in Georgian
- Error messages in Georgian
- Progress tracking in Georgian

✅ **Template Files**
- Full-Stack template → ქართული
- Backend API template → ქართული
- Frontend SPA template → ქართული
- All section headings translated

✅ **Mermaid Diagrams**
- Component labels in Georgian
- Flow descriptions in Georgian
- Sequence diagrams in Georgian

### Example Output

**English:**
```
✅ Task T1.1 completed! 🎉
📊 Progress: 0% → 6% (+6%)
```

**Georgian:**
```
✅ ამოცანა T1.1 დასრულდა! 🎉
📊 პროგრესი: 0% → 6% (+6%)
```

## 📋 Full Feature List

### New Features
- ⚙️ Plugin settings management
- 🌐 Language selection and persistence
- 📝 Georgian template translations (3 templates)
- 🔄 Language switching without restart
- 💾 User configuration system
- 📊 250+ translation keys

### Technical Improvements
- UTF-8 encoding support for all Unicode characters
- JSON-based translation system
- Language-aware template loading
- Graceful fallback to English
- Zero performance impact
- Robust error handling

### Documentation
- Complete testing guide (10 test scenarios)
- Configuration system guide
- i18n implementation guide
- Multi-language analysis document
- Updated README with examples

## 🚀 Getting Started

### For New Users

```bash
# Install the plugin
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash

# Start Claude Code
claude

# Try it in Georgian!
/settings language
# Select: ქართული (Georgian)

/new
# Wizard now speaks Georgian!
```

### For Existing Users

```bash
# Pull latest changes
cd ~/.config/claude/plugins/plan
git pull origin master

# Or reinstall
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash

# Set your language
/settings language
```

## 📊 By The Numbers

- **Translation Keys**: 250+ keys translated
- **Templates**: 6 total (3 English + 3 Georgian)
- **Commands Updated**: All 5 commands now support i18n
- **Lines of Code**: +4,500 lines of translations
- **Languages Supported**: 2 (English, Georgian)
- **Performance Impact**: 0% (no measurable difference)

## 🔧 Technical Details

### Configuration File
Settings are stored at: `~/.config/claude/plan-plugin-config.json`

```json
{
  "language": "ka",
  "lastUsed": "2026-01-27T15:30:00Z"
}
```

### Translation Files
Located in: `locales/`
- `locales/en.json` - English translations
- `locales/ka.json` - Georgian translations

### Adding New Languages
It's easy to add new languages! Just:
1. Create `locales/{code}.json` with translations
2. Add templates in `templates/{code}/`
3. Submit a PR!

## 🐛 Bug Fixes

- Config file corruption now handled gracefully
- Missing translation files fall back to English
- UTF-8 encoding issues resolved
- Mermaid diagrams work with non-ASCII characters

## 🙏 Acknowledgments

Special thanks to all Georgian speakers who will benefit from native language support!

## 📚 Documentation

- [README](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/README.md) - Updated with multi-language examples
- [CHANGELOG](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/CHANGELOG.md) - Complete change history
- [TESTING_GUIDE](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/TESTING_GUIDE.md) - Test all features
- [Installation Guide](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/INSTALL.md) - Detailed setup

## 🔮 What's Next?

### Coming in v1.2.0
- 🇷🇺 Russian language support
- 📝 Custom template creation
- 👥 Team template sharing
- 📈 More analytics and insights

## 💬 Feedback

Found a bug? Have a suggestion? Want to add your language?

- 🐛 [Report Issues](https://github.com/BekaChkhiro/claude-plan-plugin/issues)
- 💡 [Suggest Features](https://github.com/BekaChkhiro/claude-plan-plugin/issues/new)
- 🌍 [Add Translation](https://github.com/BekaChkhiro/claude-plan-plugin/blob/master/utils/i18n-guide.md)

## 📦 Installation

```bash
# Quick install
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/v1.1.0/install.sh | bash

# Or clone directly
git clone -b v1.1.0 https://github.com/BekaChkhiro/claude-plan-plugin.git ~/.config/claude/plugins/plan
```

## ⬆️ Upgrade from v1.0.0

If you're upgrading from v1.0.0:

```bash
cd ~/.config/claude/plugins/plan
git pull origin master
# Your existing plans will still work!
# Just set your language: /settings language
```

---

**Full Changelog**: https://github.com/BekaChkhiro/claude-plan-plugin/compare/v1.0.0...v1.1.0

**Download**: https://github.com/BekaChkhiro/claude-plan-plugin/releases/tag/v1.1.0

Made with ❤️ by [@BekaChkhiro](https://github.com/BekaChkhiro)

გმადლობთ! (Thank you!)
