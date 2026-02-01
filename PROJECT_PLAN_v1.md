# 🚀 Plan Plugin - Implementation Plan

*Generated: 2026-01-26*
*Last Updated: 2026-01-31*

## 📋 Overview

**Description**: Claude Code plugin for intelligent project planning and task management. Provides interactive wizard for project initialization, automatic task breakdown, progress tracking, and export capabilities.

**Target Users**: Developers working on medium to large software projects who need structured planning and task management

**Project Type**: Claude Code Plugin (Skills + Commands + Templates)

**Status**: 🟡 Planning → 0% complete

---

## 🎯 Problem Statement

**Current Pain Points:**
1. Starting large projects is overwhelming - hard to structure everything
2. Manually creating implementation plans takes 2-3 hours
3. Separate files for tasks, progress, architecture get out of sync
4. Unclear what task to work on next
5. No systematic approach to breaking down features

**Solution:**
- Single command (`/new`) that runs interactive wizard
- Auto-generates comprehensive PROJECT_PLAN.md with all details
- Smart "next task" suggestions based on dependencies
- Simple progress tracking with checkboxes
- Optional GitHub Issues export

---

## 🏗️ Plugin Architecture

```mermaid
graph TB
    subgraph "Commands (Slash Commands)"
        A[/new]
        B[/next]
        C[/update]
        D[/export]
    end

    subgraph "Skills (AI Capabilities)"
        E[analyze-codebase]
        F[suggest-breakdown]
        G[estimate-complexity]
    end

    subgraph "Templates"
        H[PROJECT_PLAN.template.md]
        I[fullstack.template.md]
        J[backend.template.md]
        K[frontend.template.md]
    end

    subgraph "Output"
        L[PROJECT_PLAN.md]
        M[GitHub Issues]
        N[JSON Export]
    end

    A --> H
    A --> I
    A --> J
    A --> K
    B --> E
    C --> L
    D --> M
    D --> N
    E --> F
    F --> G
```

---

## 🛠️ Plugin Structure

```
plan-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
│
├── commands/
│   ├── new/
│   │   └── SKILL.md             # Interactive wizard for new projects
│   ├── next/
│   │   └── SKILL.md             # Suggest next task
│   ├── update/
│   │   └── SKILL.md             # Update task status
│   └── export/
│       └── SKILL.md             # Export to GitHub/JSON
│
├── skills/
│   ├── analyze-codebase/
│   │   └── SKILL.md             # Analyze existing code structure
│   ├── suggest-breakdown/
│   │   └── SKILL.md             # Break down high-level tasks
│   └── estimate-complexity/
│       └── SKILL.md             # Estimate task complexity & time
│
├── templates/
│   ├── PROJECT_PLAN.template.md    # Main template
│   ├── fullstack.template.md       # Full-stack specific
│   ├── backend-api.template.md     # Backend API specific
│   ├── frontend-spa.template.md    # Frontend SPA specific
│   └── sections/
│       ├── overview.md
│       ├── architecture.md
│       ├── tech-stack.md
│       └── tasks.md
│
├── utils/
│   ├── parsers.js                   # Parse PROJECT_PLAN.md
│   └── github-export.js             # GitHub API integration
│
└── README.md
```

---

## ✨ Core Features

### 🧙 Interactive Wizard (`/new`)
- Step-by-step questions about project
- Context-aware follow-up questions
- Template selection based on project type
- Automatic architecture diagram generation
- Tech stack recommendations

### 🎯 Smart Task Management (`/next`)
- Analyze dependencies
- Check what's unblocked
- Consider complexity and current phase
- Suggest logical next step
- Show estimated effort

### ✅ Progress Tracking (`/update`)
- Update task status (TODO → IN_PROGRESS → DONE)
- Auto-update progress bars
- Unlock dependent tasks
- Update timestamps
- Calculate phase completion

### 📤 Export Capabilities (`/export`)
- GitHub Issues with labels
- GitHub Project board setup
- JSON export for custom tools
- Markdown summary reports

### 🔍 AI Skills
- Codebase analysis for existing projects
- Intelligent task breakdown
- Complexity estimation
- Time estimation heuristics

---

## 📝 Tasks & Implementation Plan

### 🟢 Phase 1: Foundation (Est: 4-6 hours)

#### **T1.1**: Plugin Structure Setup
- [x] **Status**: DONE ✅
- **Complexity**: 🟢 Low
- **Estimated**: 1 hour
- **Dependencies**: None

---

#### **T1.2**: Plugin Manifest Configuration
- [x] **Status**: DONE ✅
- **Complexity**: 🟢 Low
- **Estimated**: 30 minutes
- **Dependencies**: T1.1

---

#### **T1.3**: Base Template Creation
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T1.1

---

#### **T1.4**: Project Type Templates
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 1.5 hours
- **Dependencies**: T1.3
- **შენიშვნა**: + Georgian templates (ka/) დაემატა

---

### 🔵 Phase 2: Core Commands (Est: 8-10 hours)

#### **T2.1**: `/new` Command - Basic Wizard
- [x] **Status**: DONE ✅
- **Complexity**: 🔴 High
- **Estimated**: 4 hours
- **Dependencies**: T1.3, T1.4

---

#### **T2.2**: `/new` Command - Template Generation
- [x] **Status**: DONE ✅
- **Complexity**: 🔴 High
- **Estimated**: 3 hours
- **Dependencies**: T2.1

---

#### **T2.3**: `/update` Command
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T2.2

---

#### **T2.4**: `/next` Command
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T2.2

---

### 🟣 Phase 3: Advanced Features (Est: 6-8 hours)

#### **T3.1**: Codebase Analysis Skill
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T2.2

---

#### **T3.2**: Task Breakdown Skill
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T2.2

---

#### **T3.3**: Complexity & Time Estimation Skill
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T2.2, T3.1

---

#### **T3.4**: `/export` Command - GitHub Issues
- [x] **Status**: DONE ✅
- **Complexity**: 🔴 High
- **Estimated**: 3 hours
- **Dependencies**: T2.2

---

### 🟠 Phase 4: Polish & Testing (Est: 4-5 hours)

#### **T4.1**: Documentation & Examples
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: ALL previous
- **შენიშვნა**: README, INSTALL, CHANGELOG, i18n-guide არსებობს

---

#### **T4.2**: Testing & Validation
- [x] **Status**: DONE ✅
- **Complexity**: 🟡 Medium
- **Estimated**: 2 hours
- **Dependencies**: T4.1
- **შენიშვნა**: TESTING_GUIDE.md და VALIDATION.md არსებობს

---

#### **T4.3**: Optimization & Release
- [x] **Status**: DONE ✅
- **Complexity**: 🟢 Low
- **Estimated**: 1 hour
- **Dependencies**: T4.2
- **შენიშვნა**: v1.1.1 გამოშვებულია, GitHub repo არსებობს

---

## 📊 Progress Tracking

### Overall Status
**Total Tasks**: 24
**Completed**: 16 🟩🟩🟩🟩🟩🟩🟩⬜⬜⬜ (67%)
**In Progress**: 1
**Blocked**: 0

### Phase Progress
- 🟢 Phase 1: Foundation → 4/4 (100%) ✅
- 🔵 Phase 2: Core Commands → 4/4 (100%) ✅
- 🟣 Phase 3: Advanced Features → 4/4 (100%) ✅
- 🟠 Phase 4: Polish & Testing → 3/3 (100%) ✅
- 🔌 Phase 5: MCP Integration → 1/9 (11%) 🔄

### Current Focus
🔄 **მიმდინარე ამოცანა**: T5.2 - User-Facing URL-ების განახლება
📍 **ფაზა**: 5 - PlanFlow MCP Integration

### Estimated Timeline
- **Total Estimated Time**: 22-29 hours
- **Phase 1**: 4-6 hours
- **Phase 2**: 8-10 hours
- **Phase 3**: 6-8 hours
- **Phase 4**: 4-5 hours

---

## 🎯 Success Criteria

### Minimum Viable Product (v1.0.0) ✅ COMPLETE
- ✅ `/new` creates comprehensive PROJECT_PLAN.md
- ✅ `/update` tracks task progress
- ✅ `/next` suggests next task intelligently
- ✅ Works for full-stack, backend, and frontend projects
- ✅ Clear documentation

### v1.1.0 Features ✅ COMPLETE
- ✅ GitHub Issues export
- ✅ JSON export
- ✅ Codebase analysis for existing projects
- ✅ Task breakdown skill
- ✅ Multiple language support (Georgian/English)
- ✅ `/spec` command - სპეციფიკაციიდან გეგმის გენერაცია
- ✅ `/settings` command - პარამეტრების მართვა
- ✅ Hierarchical config system (v1.1.1)

### v1.2.0 - PlanFlow Integration 🔄 IN PROGRESS
- ⬜ MCP Plugin integration with PlanFlow platform
- ⬜ Cloud sync for plans
- ⬜ Team collaboration features

---

## 📌 Technical Decisions & Notes

### Why Single Large File (PROJECT_PLAN.md)?
✅ **Pros:**
- Everything in one place
- Easy to search (Ctrl+F)
- Single source of truth
- Works offline
- Git-friendly

❌ **Cons:**
- Can get large for huge projects
- Harder to parse programmatically

**Decision**: Start with single file, add multi-file support in v2.0 if needed

### Why Markdown + Mermaid?
- ✅ Human-readable
- ✅ Git-friendly (diffs work well)
- ✅ Portable (works anywhere)
- ✅ Mermaid renders in GitHub/VSCode
- ✅ No external dependencies

### Why Interactive Wizard vs CLI Args?
**Wizard** (`/new` → questions) is better because:
- More user-friendly for complex input
- Context-aware follow-ups
- Prevents overwhelming users
- Natural conversation flow

---

## 🔗 Resources & References

### Claude Code Documentation
- [Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Skills documentation](https://code.claude.com/docs/en/skills)
- [Plugin reference](https://code.claude.com/docs/en/plugins-reference)

### Tools & Libraries
- [Mermaid.js](https://mermaid.js.org/) - Diagram syntax
- [GitHub CLI](https://cli.github.com/) - For exports

### Inspiration
- Linear - Task management UX
- Notion - Document structure
- GitHub Projects - Project planning

---

## 🚀 Getting Started (Development)

### Prerequisites
- Claude Code v1.0.33+
- Node.js (for testing export scripts)
- Git
- GitHub account (for testing exports)

### Development Setup
```bash
# Clone/create plugin directory
mkdir plan-plugin
cd plan-plugin

# Test plugin locally
claude --plugin-dir ./plan-plugin

# After making changes, restart Claude Code
```

### Testing Workflow
1. Make changes to plugin files
2. Restart Claude Code with `--plugin-dir`
3. Test commands with `/*`
4. Iterate based on results

---

## 🔌 Phase 5: PlanFlow MCP Integration (Est: 8-10 hours)

> **წყარო**: PLUGIN_INTEGRATION_GUIDE.md
> **წინაპირობა**: API უკვე მზადაა (`api.planflow.tools`)

### არქიტექტურა

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User's Machine                               │
│  ┌─────────────────┐      ┌─────────────────┐                       │
│  │   Claude Code   │◄────►│  PlanFlow MCP   │                       │
│  │   (IDE/CLI)     │      │    Server       │                       │
│  └─────────────────┘      └────────┬────────┘                       │
│                                    │                                 │
│         Config: ~/.config/planflow/config.json                      │
└────────────────────────────────────┼────────────────────────────────┘
                                     │ HTTPS
                                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        PlanFlow Cloud (მზადაა)                       │
│  ┌─────────────────┐      ┌─────────────────┐                       │
│  │  api.planflow   │◄────►│   PostgreSQL    │                       │
│  │    .tools       │      │    (Neon)       │                       │
│  └─────────────────┘      └─────────────────┘                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

#### **T5.1**: API URL-ის კონფიგურაცია
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **ფაილი**: `packages/mcp/src/config.ts`
- **აღწერა**:
  - `ConfigSchema`-ში `apiUrl` default → `https://api.planflow.tools`
  - `DEFAULT_CONFIG`-ში `apiUrl` განახლება
  - Lines 18-23 და 30-32

---

#### **T5.2**: User-Facing URL-ების განახლება
- [ ] **სტატუსი**: IN_PROGRESS 🔄
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T5.1
- **აღწერა**:
  - `planflow.dev` → `planflow.tools` შეცვლა შემდეგ ფაილებში:
    - `packages/mcp/src/tools/login.ts`
    - `packages/mcp/src/tools/logout.ts`
    - `packages/mcp/src/tools/whoami.ts`
    - `packages/mcp/src/tools/projects.ts`
    - `packages/mcp/src/tools/create.ts`
    - `packages/mcp/src/tools/sync.ts`
    - `packages/mcp/src/tools/task-list.ts`
    - `packages/mcp/src/tools/task-update.ts`
    - `packages/mcp/src/tools/task-next.ts`
    - `packages/mcp/src/tools/notifications.ts`

---

#### **T5.3**: Package Metadata განახლება
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟢 Low
- **ფაილი**: `packages/mcp/package.json`
- **აღწერა**:
  - `author` → `PlanFlow <hello@planflow.tools>`
  - `homepage` → `https://planflow.tools`
  - `bugs.url` → GitHub issues URL

---

#### **T5.4**: MCP Package Build
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T5.1, T5.2, T5.3
- **აღწერა**:
  ```bash
  pnpm install
  pnpm --filter @planflow/mcp build
  ```

---

#### **T5.5**: ლოკალური ტესტირების კონფიგურაცია
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T5.4
- **ფაილი**: `~/.claude/claude_code_config.json`
- **აღწერა**:
  ```json
  {
    "mcpServers": {
      "planflow": {
        "command": "node",
        "args": ["/path/to/packages/mcp/dist/index.js"]
      }
    }
  }
  ```

---

#### **T5.6**: Token Verification Flow ტესტი
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T5.4
- **აღწერა**:
  - API Health Check: `curl https://api.planflow.tools/health`
  - Token Verification:
    ```bash
    curl -X POST https://api.planflow.tools/api-tokens/verify \
      -H "Content-Type: application/json" \
      -d '{"token": "pf_xxx"}'
    ```

---

#### **T5.7**: End-to-End Integration Test
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🔴 High
- **დამოკიდებულებები**: T5.5, T5.6
- **აღწერა**:
  Claude Code-ში:
  1. "Login to PlanFlow with token pf_xxx"
  2. "Show my PlanFlow projects"
  3. "Create a new project called Test"
  4. "Sync current plan to PlanFlow"

---

#### **T5.8**: Unit Tests
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T5.4
- **აღწერა**:
  ```bash
  pnpm --filter @planflow/mcp test
  ```

---

#### **T5.9**: npm Package Publish
- [ ] **სტატუსი**: TODO
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T5.7, T5.8
- **აღწერა**:
  - package.json final review
  - README.md update
  - `npm publish packages/mcp`
  - Users install: `npm install -g @planflow/mcp`

---

### MCP Quick Reference

| რესურსი | URL |
|---------|-----|
| Web App | `https://planflow.tools` |
| API Server | `https://api.planflow.tools` |
| Token Management | `https://planflow.tools/dashboard/settings/tokens` |
| User Config | `~/.config/planflow/config.json` |
| Claude Config | `~/.claude/claude_code_config.json` |

### MCP Deployment Checklist

- [ ] API server accessible at `api.planflow.tools`
- [ ] SSL certificates valid
- [ ] `/api-tokens/verify` endpoint working
- [ ] `/health` endpoint returning healthy
- [ ] CORS configured correctly
- [ ] MCP package built successfully
- [ ] All tests passing
- [ ] Token generation working in web dashboard
- [ ] End-to-end flow tested

---

## 📝 Future Enhancements (v2.0+)

### Planned Features
- 🌍 Multi-language support (Georgian, Russian, etc.)
- 🤖 AI-powered task generation from features
- 📊 Gantt chart generation
- 🔄 Integration with Jira, Linear, Asana
- 📈 Velocity tracking & sprint planning
- 🧪 Test coverage tracking
- 📱 Mobile app project templates
- 🐳 Docker/Kubernetes templates
- 🔐 Security audit checklist
- 📚 API documentation generation

### Community Ideas
- Template marketplace
- Custom template creation
- Team templates sharing
- Slack/Discord notifications
- Time tracking integration
- Calendar integration

---

*Generated by plan-plugin (meta planning) v1.0.0*
*This plan follows the same structure that the plugin will generate! 🎯*
