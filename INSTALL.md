# Installation Guide

## Quick Install

### Option 1: Clone to Claude Plugins Directory

```bash
# Clone directly to plugins directory
git clone https://github.com/BekaChkhiro/claude-plan-plugin.git ~/.config/claude/plugins/plan

# Restart Claude Code
claude
```

### Option 2: Manual Download

```bash
# Download and extract
wget https://github.com/BekaChkhiro/claude-plan-plugin/archive/refs/tags/v1.0.0.zip
unzip v1.0.0.zip
mv claude-plan-plugin-1.0.0 ~/.config/claude/plugins/plan

# Restart Claude Code
claude
```

### Option 3: Development Setup

```bash
# Clone repository
git clone https://github.com/BekaChkhiro/claude-plan-plugin.git
cd claude-plan-plugin

# Create symlink for auto-updates
ln -s $(pwd) ~/.config/claude/plugins/plan

# Restart Claude Code
claude
```

## Verification

After installation, start Claude Code and run:

```
/plan:new
```

If you see the wizard, the plugin is installed correctly!

## Troubleshooting

### Plugin not loading

```bash
# Check plugin exists
ls -la ~/.config/claude/plugins/plan/.claude-plugin/plugin.json

# Check permissions
chmod -R 755 ~/.config/claude/plugins/plan

# Try explicit path
claude --plugin-dir ~/.config/claude/plugins/plan
```

### Commands not working

```bash
# Ensure you're using correct command format
/plan:new        # ✅ Correct
plan:new         # ❌ Missing slash
/plan new        # ❌ Space instead of colon
```

## Uninstallation

```bash
# Remove plugin
rm -rf ~/.config/claude/plugins/plan

# Restart Claude Code
```

## Updates

```bash
# Pull latest changes
cd ~/.config/claude/plugins/plan
git pull origin master

# Or if using symlink, update source
cd /path/to/development/claude-plan-plugin
git pull origin master
```

## Support

- 📖 Documentation: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/BekaChkhiro/claude-plan-plugin/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/BekaChkhiro/claude-plan-plugin/discussions)
