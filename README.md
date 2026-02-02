# 🚀 Plan Plugin for Claude Code

Intelligent project planning and task management plugin that helps you start and organize software projects systematically.

## 🎯 What it does

Starting a large project can be overwhelming. This plugin solves that by providing:

- **Interactive Project Wizard** (`/planNew`) - Asks the right questions and generates a comprehensive plan
- **Smart Task Suggestions** (`/planNext`) - Tells you exactly what to work on next
- **Progress Tracking** (`/planUpdate`) - Simple checkbox-based progress management
- **Export Options** (`/planExportGithub`, `/planExportJson`, etc.) - GitHub Issues, JSON, and more

## 📦 Installation

### Quick Install (Recommended)

```bash
# One-command installation
curl -fsSL https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh | bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/BekaChkhiro/claude-plan-plugin/master/install.sh
chmod +x install.sh
./install.sh
```

### Manual Installation

```bash
# Clone to plugins directory
git clone https://github.com/BekaChkhiro/claude-plan-plugin.git ~/.config/claude/plugins/plan

# Start Claude Code
claude
```

### Verification

After installation, start Claude Code and run:
```
/planNew
```

If the wizard appears, installation was successful!

See [INSTALL.md](INSTALL.md) for detailed installation options and troubleshooting.

## 🎮 Commands

### `/planNew` - Create New Project Plan

Interactive wizard that asks about your project and generates a detailed `PROJECT_PLAN.md` file.

**Example:**
```
You: /planNew

Claude: 📋 Let's create your project plan!

❓ What's your project name?
You: TaskMaster

❓ What does it do?
You: Team task management with real-time collaboration

[... more questions ...]

✅ Created PROJECT_PLAN.md with:
   - Architecture diagram
   - Tech stack
   - 15 tasks across 4 phases
   - Progress tracking
```

### `/planNext` - What to Work On Next

Analyzes your plan and suggests the next logical task based on dependencies and priorities.

**Example:**
```
You: /planNext

Claude: 🎯 Recommended Next Task:

╔═══════════════════════════════════╗
║ T2.1: Setup Database Schema      ║
║ Complexity: Medium                ║
║ Estimated: 3 hours                ║
╚═══════════════════════════════════╝

✅ All dependencies completed
🎯 Why this task?
  - Unlocks 4 other tasks
  - Critical for Phase 2
  - Good momentum after setup

Ready? /planUpdate T2.1 start
```

### `/planUpdate` - Update Task Status

Mark tasks as started, completed, or blocked.

**Usage:**
```bash
/planUpdate T1.1 start    # Mark as in progress
/planUpdate T1.1 done     # Mark as completed
/planUpdate T2.3 block    # Mark as blocked
```

### Export Commands

Export your plan to different formats.

**Available Commands:**
```bash
/planExportGithub         # Create GitHub Issues
/planExportJson           # Export as JSON
/planExportSummary        # Markdown summary
/planExportCsv            # Export as CSV
```

### Settings Commands

Configure language preferences, auto-sync, and other plugin settings.

**Available Commands:**
```bash
/planSettingsShow              # View current settings
/planSettingsLanguage          # Change language (global)
/planSettingsLanguage --local  # Change language (project only)
/planSettingsAutoSync          # Show auto-sync status
/planSettingsAutoSync on       # Enable auto-sync
/planSettingsAutoSync off      # Disable auto-sync
/planSettingsReset             # Reset global settings
/planSettingsReset --local     # Remove project settings
```

## ☁️ Cloud Features (v1.5.0)

Connect your local plans to PlanFlow Cloud for backup, collaboration, and cross-device access.

**Cloud commands use `pf` prefix to avoid conflicts with Claude commands.**

### `/pfLogin` - Authenticate with PlanFlow

```bash
/pfLogin                  # Interactive - prompts for token
/pfLogin pf_abc123...     # Direct token input
```

Get your API token at: https://planflow.tools/dashboard/settings/tokens

### Sync Commands

```bash
/pfSyncStatus             # Show sync status
/pfSyncPush               # Upload local → cloud
/pfSyncPush --force       # Overwrite cloud without conflict check
/pfSyncPull               # Download cloud → local
/pfSyncPull --force       # Overwrite local without confirmation
```

### Cloud Project Commands

```bash
/pfCloudList              # List all your cloud projects
/pfCloudLink              # Interactive project selection
/pfCloudLink <id>         # Link to specific project
/pfCloudUnlink            # Disconnect from cloud project
/pfCloudNew               # Create new cloud project from local plan
/pfCloudNew "Name"        # Create with custom name
```

### `/pfWhoami` - Check Authentication Status

```bash
/pfWhoami                 # Show current user info and cloud stats
```

### `/pfLogout` - Clear Credentials

```bash
/pfLogout                 # Clear stored PlanFlow credentials
```

### Cloud Workflow Example

```bash
# 1. Authenticate with PlanFlow
/pfLogin

# 2. Create a project plan
/planNew

# 3. Create cloud project and sync
/pfCloudNew
/pfSyncPush

# 4. Work on tasks
/planUpdate T1.1 start
/planUpdate T1.1 done

# 5. Sync progress to cloud
/pfSyncPush

# 6. On another device, pull latest
/pfSyncPull
```

### Auto-Sync Feature

Enable automatic sync after task updates using the settings command:

```bash
/planSettingsAutoSync on    # Enable auto-sync
/planSettingsAutoSync off   # Disable auto-sync
/planSettingsAutoSync       # Check current status
```

Or manually in config file:
```json
// In .plan-config.json or ~/.config/claude/plan-plugin-config.json
{
  "cloud": {
    "autoSync": true
  }
}
```

With auto-sync enabled, running `/planUpdate T1.1 done` will automatically push changes to the cloud.

## 🔀 Hybrid Sync (v1.3.0)

Smart merge system for seamless collaboration - work offline, sync when online, and resolve conflicts intelligently.

### Storage Modes

Configure how your project syncs with the cloud in `.plan-config.json`:

```json
{
  "cloud": {
    "storageMode": "hybrid"
  }
}
```

Options: `local`, `cloud`, `hybrid`

| Mode | Description | Best For |
|------|-------------|----------|
| `local` | PROJECT_PLAN.md only, manual sync | Offline work, solo projects |
| `cloud` | Cloud is authoritative, local is cache | Team collaboration |
| `hybrid` | Both local and cloud with smart merge | Best of both worlds |

### Smart Merge

When you and a teammate both make changes, Hybrid Sync intelligently merges them:

```
You update T1.1 → done     Teammate updates T2.3 → done
        ↓                           ↓
    ┌───────────────────────────────────────┐
    │         SMART MERGE                    │
    │   ✅ Auto-merged (different tasks)    │
    └───────────────────────────────────────┘
```

**Auto-merge scenarios:**
- Different tasks modified → merged automatically
- Same task, same change → merged automatically
- Same task, different changes → conflict UI shown

### Conflict Resolution

When conflicts occur, you get a rich diff UI:

```
⚠️ Conflict Detected!

Task T1.1: "Setup authentication"

┌─────────────────────────────────────────────────────┐
│ 📍 LOCAL                  │ ☁️ CLOUD                │
├─────────────────────────────────────────────────────┤
│ Status: done ✅           │ Status: blocked 🚫      │
│ Time: 10:00 (30 min ago)  │ Time: 09:30 (1 hr ago)  │
│ Author: You               │ Author: team@email.com  │
└─────────────────────────────────────────────────────┘

Which version to keep?
  1. Keep local (done)
  2. Keep cloud (blocked)
  3. Cancel
```

### Offline Support

Work offline and sync when you're back online:

```bash
# Working offline
/planUpdate T1.1 done
# → Changes saved locally
# → Queued for sync (1 pending)

# Back online
/pfSync push
# → Processing 1 pending changes...
# → ✅ All changes synced
```

### Hybrid Workflow Example

```bash
# 1. Enable auto-sync
/planSettingsAutoSync on

# 2. Work on tasks
/planUpdate T1.1 done
# → Local updated + auto-synced to cloud

# 3. Teammate makes changes on cloud...

# 4. Your next update triggers smart merge
/planUpdate T1.2 done
# → Pull cloud changes
# → Smart merge (no conflicts)
# → Push your changes

# 5. If conflict detected
# → Shows diff UI
# → You choose which version to keep
```

## 🔌 MCP Server (v1.4.0)

Alternative connection method using Model Context Protocol for native Claude integration.

### Two Ways to Connect

| Method | Setup | Best For |
|--------|-------|----------|
| **Commands** | Zero setup | Quick start, any terminal |
| **MCP Server** | npm install | Native AI integration, natural language |

### Commands (Default)

```bash
/planNext                # Get next task
/planUpdate T1.1 done    # Update status
/pfSyncPush              # Sync to cloud
```

### MCP Server (Native Integration)

With MCP, you talk to Claude naturally:

```
You: "What should I work on next?"
Claude: [calls planflow_task_next] → Shows your next task

You: "Mark T1.1 as done"
Claude: [calls planflow_task_update] → Updates and syncs
```

### MCP Installation

```bash
# Install globally
npm install -g @planflow-tools/mcp

# Or use npx (no install needed)
npx @planflow-tools/mcp
```

### MCP Configuration

**For Claude Desktop** (`~/.config/claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["@planflow-tools/mcp"]
    }
  }
}
```

**For Claude Code** (`.claude/settings.json`):

```json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["@planflow-tools/mcp"]
    }
  }
}
```

### MCP Tools Available

| Tool | Description | Example |
|------|-------------|---------|
| `planflow_login` | Authenticate | "Login to PlanFlow with token pf_xxx" |
| `planflow_projects` | List projects | "Show my PlanFlow projects" |
| `planflow_task_list` | List tasks | "What tasks do I have?" |
| `planflow_task_next` | Next task | "What should I work on?" |
| `planflow_task_update` | Update status | "Mark T1.1 as done" |
| `planflow_sync` | Sync project | "Sync my project plan" |
| `planflow_create` | Create project | "Create a new PlanFlow project" |

### MCP vs Commands

**Use Commands when:**
- Quick one-off operations
- Working in any terminal
- Don't want extra setup

**Use MCP when:**
- Want natural language interaction
- Using Claude Desktop or Claude Code
- Prefer conversational workflow

**Supported Languages:**
- 🇬🇧 English (default)
- 🇬🇪 ქართული (Georgian)
- 🇷🇺 Русский (Russian) - coming soon

**Example:**
```
You: /planSettingsLanguage

Claude: Select your preferred language:
○ English
● ქართული (Georgian) ✓
○ Русский (Russian)

You: [Select Georgian]

Claude: ✅ პარამეტრები განახლდა!
ენა შეიცვალა: English → ქართული

ახალი ენა გამოყენებული იქნება:
• ყველა ბრძანების შედეგებისთვის
• Wizard-ის კითხვებისთვის
• გენერირებული PROJECT_PLAN.md ფაილებისთვის
```

## 🌍 Multi-Language Support

The plugin supports multiple languages for the complete user experience:

**What's Translated:**
- ✅ All command outputs and messages
- ✅ Wizard questions and options
- ✅ Generated PROJECT_PLAN.md files
- ✅ Task status labels and descriptions
- ✅ Error messages and help text
- ✅ Progress tracking and success messages

**How It Works:**
1. **Global settings**: `/planSettingsLanguage` - Sets language for all projects
2. **Project-specific settings**: `/planSettingsLanguage --local` - Sets language for current project only
3. Select your preferred language (English, Georgian, etc.)
4. Language preference is saved and persists across sessions

**Hierarchical Configuration (v1.1.1+):**
- **Local** (`./.plan-config.json`) - Project-specific, highest priority
- **Global** (`~/.config/claude/plan-plugin-config.json`) - User-wide fallback
- **Default** (English) - Final fallback

This allows you to have different languages for different projects! For example, use Georgian for personal projects and English for work projects.

**Example Georgian Output:**
```markdown
# MyApp - Full-Stack პროექტის გეგმა

## მიმოხილვა

**პროექტის სახელი**: MyApp
**სტატუსი**: დაგეგმვა (0% დასრულებული)

## ამოცანები და იმპლემენტაციის გეგმა

### ეტაპი 1: საფუძველი

#### T1.1: პროექტის დაყენება
- [ ] **სტატუსი**: TODO
- **სირთულე**: დაბალი
- **შეფასებული**: 2 საათი
```

**Technical Details:**
- UTF-8 encoding for full Unicode support
- Mermaid diagrams with native language labels
- No performance impact
- Easy to add new languages (just add JSON file)

## 📋 Features

### ✨ What You Get

**Comprehensive Planning:**
- Project overview and goals
- Architecture diagrams (Mermaid)
- Tech stack recommendations
- Folder structure
- Task breakdown by phases

**Smart Task Management:**
- High-level tasks with clear descriptions
- Complexity indicators (Low/Medium/High)
- Time estimates
- Dependency tracking
- Progress visualization

**AI-Powered Skills:**
- Codebase analysis for existing projects
- Intelligent task breakdown
- Complexity estimation
- Tech stack detection

## 🏗️ Project Structure

```
plan-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   ├── planNew/                 # /planNew wizard
│   ├── planNext/                # /planNext suggestions
│   ├── planUpdate/              # /planUpdate status
│   ├── planSpec/                # /planSpec analyzer
│   ├── planExportGithub/        # /planExportGithub
│   ├── planExportJson/          # /planExportJson
│   ├── planExportSummary/       # /planExportSummary
│   ├── planExportCsv/           # /planExportCsv
│   ├── planSettingsShow/        # /planSettingsShow
│   ├── planSettingsLanguage/    # /planSettingsLanguage
│   ├── planSettingsAutoSync/    # /planSettingsAutoSync
│   ├── planSettingsReset/       # /planSettingsReset
│   ├── pfLogin/                 # /pfLogin
│   ├── pfLogout/                # /pfLogout
│   ├── pfWhoami/                # /pfWhoami
│   ├── pfSyncStatus/            # /pfSyncStatus
│   ├── pfSyncPush/              # /pfSyncPush
│   ├── pfSyncPull/              # /pfSyncPull
│   ├── pfCloudList/             # /pfCloudList
│   ├── pfCloudLink/             # /pfCloudLink
│   ├── pfCloudUnlink/           # /pfCloudUnlink
│   └── pfCloudNew/              # /pfCloudNew
├── skills/
│   ├── analyze-codebase/        # Codebase analysis
│   ├── suggest-breakdown/       # Task breakdown
│   ├── estimate-complexity/     # Complexity estimation
│   ├── api-client/              # HTTP client for cloud API
│   └── credentials/             # Token management
├── locales/
│   ├── en.json                  # English translations
│   └── ka.json                  # Georgian translations
├── templates/
│   ├── PROJECT_PLAN.template.md
│   ├── fullstack.template.md
│   ├── backend-api.template.md
│   └── frontend-spa.template.md
├── utils/
│   ├── config-guide.md          # Configuration documentation
│   └── i18n-guide.md            # Internationalization guide
└── README.md
```

## 🚀 Quick Start Example

```bash
# 1. Start Claude Code with the plugin
claude --plugin-dir ./plan-plugin

# 2. Create a new project plan
/planNew

# 3. Answer questions about your project
# (interactive wizard guides you)

# 4. Check what to work on
/planNext

# 5. Start working on a task
/planUpdate T1.1 start

# 6. Mark it complete when done
/planUpdate T1.1 done

# 7. Export to GitHub if needed
/planExportGithub
```

## 📖 Generated Plan Structure

The plugin creates a `PROJECT_PLAN.md` file with:

```markdown
# 🚀 Your Project Name

## 📋 Overview
- Description, goals, target users

## 🏗️ Architecture
- Mermaid diagrams

## 🛠️ Tech Stack
- Frontend, Backend, Database, DevOps

## 📂 Project Structure
- Folder tree

## 📝 Tasks
### Phase 1: Foundation
- [ ] T1.1: Task name (Complexity: Low, 2h)
- [ ] T1.2: Another task (Complexity: Medium, 4h)

### Phase 2: Core Features
...

## 📊 Progress Tracking
- Overall: 3/15 (20%)
- Current: Phase 1
```

## 🎯 Use Cases

**Perfect for:**
- Starting new projects from scratch
- Organizing large refactoring efforts
- Planning feature implementations
- Team project kickoffs
- Learning new tech stacks

**Supported Project Types:**
- Full-stack web applications
- Backend APIs (REST/GraphQL)
- Frontend SPAs
- Mobile apps
- CLI tools
- Libraries/packages

## 📚 Examples

Want to see what the plugin generates? Check out the `examples/` directory:

- **[Full-Stack App](examples/example-fullstack-plan.md)** - TaskMaster team collaboration tool
- **[Backend API](examples/example-backend-plan.md)** - E-commerce REST API
- More examples coming soon!

These examples show:
- Complete project plans with tasks and architecture
- Different project types and patterns
- Progress tracking in action
- How to structure phases and dependencies

## ⚙️ Configuration

The plugin uses a hierarchical configuration system:

1. **Local** (`./.plan-config.json`) - Project-specific, highest priority
2. **Global** (`~/.config/claude/plan-plugin-config.json`) - User-wide fallback
3. **Default** - Built-in defaults

### Configuration Options

```json
{
  "language": "en",
  "defaultProjectType": "fullstack",
  "lastUsed": "2026-01-31T12:00:00Z",
  "cloud": {
    "apiUrl": "https://api.planflow.tools",
    "apiToken": "pf_xxx...",
    "projectId": "uuid-of-linked-project",
    "userId": "uuid",
    "userEmail": "user@example.com",
    "autoSync": false,
    "lastSyncedAt": "2026-01-31T15:00:00Z"
  }
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `language` | string | `"en"` | UI language (en, ka) |
| `defaultProjectType` | string | `"fullstack"` | Default project type |
| `cloud.apiUrl` | string | `"https://api.planflow.tools"` | API endpoint |
| `cloud.apiToken` | string | `null` | Your API token |
| `cloud.projectId` | string | `null` | Linked cloud project |
| `cloud.autoSync` | boolean | `false` | Auto-sync on task updates |

See [utils/config-guide.md](utils/config-guide.md) for detailed configuration documentation

## 🤝 Contributing

Contributions are welcome! We appreciate:
- Bug reports and fixes
- New templates for different project types
- Documentation improvements
- Feature suggestions
- Code examples

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `claude --plugin-dir ./plan-plugin`
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📝 Development Status

Current Version: **v1.6.0**

- ✅ **v1.0.0**: Core commands, wizard, templates, AI skills
- ✅ **v1.1.0**: Multi-language support (English, Georgian), hierarchical config
- ✅ **v1.2.0**: PlanFlow Cloud integration (sync, backup, collaboration)
- ✅ **v1.3.0**: Hybrid Sync with smart merge, conflict resolution, offline support
- ✅ **v1.4.0**: MCP Server for native Claude integration (`@planflow-tools/mcp`)
- ✅ **v1.5.0**: `pf` prefix for cloud commands (`/pfLogin`, `/pfSync`, etc.)
- ✅ **v1.6.0**: Single-command format (no arguments) - `/pfSyncPush` instead of `/pfSync push`
- 🔜 **v1.7.0**: Integrations (Jira, Linear), time tracking

See [CHANGELOG.md](CHANGELOG.md) for version history and [PROJECT_PLAN.md](./PROJECT_PLAN.md) for detailed roadmap.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Credits

Built with [Claude Code](https://claude.com/code) - AI pair programming on the command line.

---

**Questions or Issues?** Open an issue on GitHub!

**Want to contribute?** PRs welcome! Check the PROJECT_PLAN.md for tasks.
