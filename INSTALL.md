# Installation Guide

## Quick Install (Recommended)

Run this single command to install:

```bash
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash
```

This will:
1. Clone the plugin to `~/.local/share/claude-plan-plugin`
2. Create symlinks in `~/.claude/commands/`
3. Make all commands available globally in Claude Code

## Manual Installation

### Option 1: Clone and Link (Best for Development)

```bash
# Clone to your preferred location
git clone https://github.com/BekaChkhiro/claude-plan-plugin.git ~/claude-plan-plugin

# Create commands directory if needed
mkdir -p ~/.claude/commands

# Create symlinks for each command
cd ~/claude-plan-plugin/commands
for cmd in */; do
    ln -sf "$(pwd)/${cmd%/}" ~/.claude/commands/
done
```

### Option 2: Download Release

```bash
# Download latest release
curl -L https://github.com/BekaChkhiro/claude-plan-plugin/archive/refs/heads/master.zip -o plugin.zip
unzip plugin.zip
mv claude-plan-plugin-master ~/.local/share/claude-plan-plugin

# Create symlinks
mkdir -p ~/.claude/commands
cd ~/.local/share/claude-plan-plugin/commands
for cmd in */; do
    ln -sf "$(pwd)/${cmd%/}" ~/.claude/commands/
done
```

## Verification

After installation, start Claude Code:

```bash
claude
```

Then test with:

```
/planNew
```

If you see the project wizard, installation was successful!

## Directory Structure

After installation:

```
~/.local/share/claude-plan-plugin/    # Plugin source code
├── commands/
│   ├── planNew/
│   ├── planNext/
│   ├── planUpdate/
│   └── ...
├── locales/
├── templates/
└── README.md

~/.claude/commands/                    # Symlinks (global commands)
├── planNew -> ~/.local/share/claude-plan-plugin/commands/planNew
├── planNext -> ~/.local/share/claude-plan-plugin/commands/planNext
└── ...
```

## Available Commands

| Command | Description |
|---------|-------------|
| `/planNew` | Create new project plan with wizard |
| `/planNext` | Get next task recommendation |
| `/planUpdate` | Update task status |
| `/planSpec` | Analyze specification document |
| `/planExportJson` | Export plan as JSON |
| `/planExportCsv` | Export tasks as CSV |
| `/planExportGithub` | Export tasks to GitHub Issues |
| `/planSettingsShow` | Show current settings |
| `/planSettingsLanguage` | Change language (en/ka) |
| `/pfLogin` | Login to PlanFlow cloud |
| `/pfLogout` | Logout from cloud |
| `/pfSyncPush` | Push plan to cloud |
| `/pfSyncPull` | Pull plan from cloud |
| `/pfCloudLink` | Link project to cloud |

## Updating

```bash
# If installed with install.sh
cd ~/.local/share/claude-plan-plugin
git pull origin master

# If cloned manually
cd /path/to/claude-plan-plugin
git pull origin master
```

## Uninstallation

```bash
# Remove symlinks
rm -rf ~/.claude/commands/plan*
rm -rf ~/.claude/commands/pf*

# Remove plugin source
rm -rf ~/.local/share/claude-plan-plugin
```

## Troubleshooting

### Commands not showing

1. Check symlinks exist:
   ```bash
   ls -la ~/.claude/commands/
   ```

2. Verify symlinks point to correct location:
   ```bash
   readlink ~/.claude/commands/planNew
   ```

3. Restart Claude Code

### Permission denied

```bash
chmod +x ~/.local/share/claude-plan-plugin/install.sh
```

### Symlink broken

```bash
# Remove and recreate
rm ~/.claude/commands/planNew
ln -s ~/.local/share/claude-plan-plugin/commands/planNew ~/.claude/commands/
```

## Support

- 📖 Documentation: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/BekaChkhiro/claude-plan-plugin/issues)
- 🌐 Web Dashboard: [planflow.tools](https://planflow.tools)
