# 🎯 Quick Reference Guide

სწრაფი სახელმძღვანელო Plan Plugin-თან მუშაობისთვის.

---

## 📍 სად არის Plugin?

### Development Version (მუშაობისთვის)
```bash
/home/bekolozi/Desktop/plan-plugin/
```
- აქ ცვლი კოდს
- აქედან push-ავ GitHub-ზე
- აქ არის Git repository

### Installed Version (გამოსაყენებლად)
```bash
~/.config/claude/plugins/plan/
```
- აქედან იტვირთება Claude Code-ში
- გადაიტანე ან გააკეთე symlink

### GitHub Repository
```
https://github.com/BekaChkhiro/claude-plan-plugin
```
- საჯარო repository
- Release v1.0.0
- Install script ხელმისაწვდომია

---

## 🔧 როგორ ვიმუშაო Plugin-ზე

### Setup Development Environment

```bash
# 1. გადადი development ფოლდერში
cd /home/bekolozi/Desktop/plan-plugin

# 2. შექმენი symlink (რომ არ გჭირდეს copy)
rm -rf ~/.config/claude/plugins/plan
ln -s $(pwd) ~/.config/claude/plugins/plan

# 3. გახსენი editor-ში
code .
```

### Make Changes

```bash
# შეცვალე რაც გინდა:
# - commands/ - slash commands
# - skills/ - AI skills
# - templates/ - project templates
# - examples/ - example plans

# Test locally
claude
# სცადე შენი commands
```

### Commit & Push

```bash
cd /home/bekolozi/Desktop/plan-plugin

# Check changes
git status
git diff

# Commit
git add .
git commit -m "Your change description"

# Push to GitHub
git push origin master

# Tag new version (optional)
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

---

## 🎮 როგორ გამოვიყენო Plugin

### Installation

```bash
# Option 1: Quick install
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash

# Option 2: Manual
git clone https://github.com/BekaChkhiro/claude-plan-plugin.git ~/.config/claude/plugins/plan

# Option 3: Development (already set up)
# symlink არის უკვე: ~/.config/claude/plugins/plan -> /home/bekolozi/Desktop/plan-plugin
```

### Basic Usage

```bash
# Start Claude Code
claude

# Create plan
/plan:new

# Get next task
/plan:next

# Update task
/plan:update T1.1 start
/plan:update T1.1 done

# Export
/plan:export json
/plan:export summary
```

---

## 📁 სტრუქტურა

```
plan-plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin config
│
├── commands/                  # Slash commands
│   ├── new/SKILL.md          # /plan:new
│   ├── update/SKILL.md       # /plan:update
│   ├── next/SKILL.md         # /plan:next
│   └── export/SKILL.md       # /plan:export
│
├── skills/                    # AI skills
│   ├── analyze-codebase/
│   ├── suggest-breakdown/
│   └── estimate-complexity/
│
├── templates/                 # Project templates
│   ├── PROJECT_PLAN.template.md
│   ├── fullstack.template.md
│   ├── backend-api.template.md
│   ├── frontend-spa.template.md
│   └── sections/
│
├── examples/                  # Example plans
│   ├── example-fullstack-plan.md
│   └── example-backend-plan.md
│
├── README.md                  # Main docs
├── INSTALL.md                 # Install guide
├── CONTRIBUTING.md            # Contribution guide
├── CHANGELOG.md               # Version history
├── PUBLISHING.md              # Distribution guide
└── install.sh                 # Auto-install script
```

---

## 🚀 Common Tasks

### დაამატე ახალი Command

```bash
# 1. შექმენი დირექტორია
mkdir commands/status

# 2. შექმენი SKILL.md
nano commands/status/SKILL.md

# 3. დაწერე instructions Claude-სთვის
# 4. Test
claude
/plan:status

# 5. Commit
git add commands/status/
git commit -m "Add /plan:status command"
git push
```

### განაახლე Template

```bash
# 1. Edit template
nano templates/fullstack.template.md

# 2. Test generation
claude
/plan:new

# 3. Verify PROJECT_PLAN.md looks good

# 4. Commit
git add templates/fullstack.template.md
git commit -m "Improve fullstack template"
git push
```

### დაამატე ახალი Skill

```bash
# 1. შექმენი skill
mkdir skills/my-new-skill
nano skills/my-new-skill/SKILL.md

# 2. დაწერე AI instructions

# 3. Test (skills ავტომატურად invoke-დება)

# 4. Commit
git add skills/my-new-skill/
git commit -m "Add new AI skill"
git push
```

---

## 🐛 Debugging

### Plugin არ იტვირთება

```bash
# Check symlink
ls -la ~/.config/claude/plugins/plan

# Re-create symlink
rm -rf ~/.config/claude/plugins/plan
ln -s /home/bekolozi/Desktop/plan-plugin ~/.config/claude/plugins/plan

# Verify plugin.json
cat ~/.config/claude/plugins/plan/.claude-plugin/plugin.json
```

### Commands არ მუშაობს

```bash
# Check command files exist
ls commands/*/SKILL.md

# Check for syntax errors in SKILL.md
cat commands/new/SKILL.md

# Restart Claude Code
```

### Changes არ ჩანს

```bash
# If using symlink, just restart Claude
# No need to copy files

# If not using symlink:
cp -r /home/bekolozi/Desktop/plan-plugin ~/.config/claude/plugins/plan
```

---

## 📊 Testing Checklist

```bash
cd /home/bekolozi/Desktop/plan-plugin

# Run validation
./validate-plugin.sh

# Manual tests
claude
/plan:new      # Should start wizard
/plan:next     # Should recommend task
/plan:update   # Should show usage
/plan:export   # Should show formats
```

---

## 🌐 Sharing Plugin

### Share GitHub Link

```
https://github.com/BekaChkhiro/claude-plan-plugin
```

### Installation Command

```bash
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash
```

### Post on Social Media

```
🚀 Check out my Claude Code plugin!

Plan Plugin helps you:
✅ Create comprehensive project plans
✅ Get smart task recommendations
✅ Track progress automatically
✅ Export to GitHub Issues

Install: https://github.com/BekaChkhiro/claude-plan-plugin
```

---

## 📚 Documentation Files

- **README.md** - Main documentation
- **INSTALL.md** - Installation instructions
- **CONTRIBUTING.md** - How to contribute
- **CHANGELOG.md** - Version history
- **VALIDATION.md** - Testing checklist
- **PUBLISHING.md** - Distribution guide
- **QUICK_REFERENCE.md** - This file (თუ არ წაშლი 😊)

---

## 🔗 Important Links

- **Repository**: https://github.com/BekaChkhiro/claude-plan-plugin
- **Issues**: https://github.com/BekaChkhiro/claude-plan-plugin/issues
- **Releases**: https://github.com/BekaChkhiro/claude-plan-plugin/releases

---

## ⚡ Quick Commands

```bash
# Development
cd /home/bekolozi/Desktop/plan-plugin
code .
git status
git add .
git commit -m "message"
git push

# Testing
./validate-plugin.sh
claude

# Release
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

---

**ყველაფერი რაც გჭირდება ერთ ადგილას! 🎯**

გაქვს კითხვა? იხილე:
- README.md - დეტალები
- PUBLISHING.md - როგორ გავაზიარო
- INSTALL.md - როგორ დავაინსტალირო
