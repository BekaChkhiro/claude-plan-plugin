# 🚀 Plan Plugin for Claude Code

Intelligent project planning and task management plugin that helps you start and organize software projects systematically.

## 🎯 What it does

Starting a large project can be overwhelming. This plugin solves that by providing:

- **Interactive Project Wizard** (`/plan:new`) - Asks the right questions and generates a comprehensive plan
- **Smart Task Suggestions** (`/plan:next`) - Tells you exactly what to work on next
- **Progress Tracking** (`/plan:update`) - Simple checkbox-based progress management
- **Export Options** (`/plan:export`) - GitHub Issues, JSON, and more

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
/plan:new
```

If the wizard appears, installation was successful!

See [INSTALL.md](INSTALL.md) for detailed installation options and troubleshooting.

## 🎮 Commands

### `/plan:new` - Create New Project Plan

Interactive wizard that asks about your project and generates a detailed `PROJECT_PLAN.md` file.

**Example:**
```
You: /plan:new

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

### `/plan:next` - What to Work On Next

Analyzes your plan and suggests the next logical task based on dependencies and priorities.

**Example:**
```
You: /plan:next

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

Ready? /plan:update T2.1 start
```

### `/plan:update` - Update Task Status

Mark tasks as started, completed, or blocked.

**Usage:**
```bash
/plan:update T1.1 start    # Mark as in progress
/plan:update T1.1 done     # Mark as completed
/plan:update T2.3 block    # Mark as blocked
```

### `/plan:export` - Export Plan

Export your plan to different formats.

**Usage:**
```bash
/plan:export github        # Create GitHub Issues
/plan:export json          # Export as JSON
/plan:export summary       # Markdown summary
```

### `/plan:settings` - Plugin Settings

Configure language preferences and other plugin settings.

**Usage:**
```bash
/plan:settings              # View current settings
/plan:settings language     # Change language
/plan:settings reset        # Reset to defaults
```

**Supported Languages:**
- 🇬🇧 English (default)
- 🇬🇪 ქართული (Georgian)
- 🇷🇺 Русский (Russian) - coming soon

**Example:**
```
You: /plan:settings language

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
1. Set your language: `/plan:settings language`
2. Select your preferred language (English, Georgian, etc.)
3. All future interactions will use your chosen language
4. Language preference is saved and persists across sessions

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
│   ├── new/                     # /plan:new wizard
│   ├── next/                    # /plan:next suggestions
│   ├── update/                  # /plan:update status
│   └── export/                  # /plan:export formats
├── skills/
│   ├── analyze-codebase/        # Codebase analysis
│   ├── suggest-breakdown/       # Task breakdown
│   └── estimate-complexity/     # Complexity estimation
├── templates/
│   ├── PROJECT_PLAN.template.md
│   ├── fullstack.template.md
│   ├── backend-api.template.md
│   └── frontend-spa.template.md
└── README.md
```

## 🚀 Quick Start Example

```bash
# 1. Start Claude Code with the plugin
claude --plugin-dir ./plan-plugin

# 2. Create a new project plan
/plan:new

# 3. Answer questions about your project
# (interactive wizard guides you)

# 4. Check what to work on
/plan:next

# 5. Start working on a task
/plan:update T1.1 start

# 6. Mark it complete when done
/plan:update T1.1 done

# 7. Export to GitHub if needed
/plan:export github
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

Currently, the plugin works out of the box with no configuration needed. Future versions will support:

- Custom templates
- Team-specific defaults
- Custom phases and workflows
- Integration preferences

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

Current Version: **v1.0.0** (Release Candidate)

- ✅ **v1.0.0**: Core commands, wizard, templates, AI skills
- 🔜 **v1.1.0**: Multi-language support, custom templates
- 🔜 **v1.2.0**: Integrations (Jira, Linear), time tracking

See [CHANGELOG.md](CHANGELOG.md) for version history and [PROJECT_PLAN.md](./PROJECT_PLAN.md) for detailed roadmap.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Credits

Built with [Claude Code](https://claude.com/code) - AI pair programming on the command line.

---

**Questions or Issues?** Open an issue on GitHub!

**Want to contribute?** PRs welcome! Check the PROJECT_PLAN.md for tasks.
