# PlanFlow Cloud Integration

## Overview

**Project:** claude-plan-plugin Cloud Integration
**Goal:** Connect local planning commands to planflow.tools cloud platform
**Created:** 2026-01-31
**Status:** Complete ✅
**Last Updated:** 2026-02-01
**Current Phase:** Complete - All Phases Done ✅

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          მომხმარებელი                                │
└─────────────────────────────────────────────────────────────────────┘
                    │                           │
                    ▼                           ▼
┌───────────────────────────────┐   ┌─────────────────────────────────┐
│   Method A: Plugin Commands   │   │   Method B: MCP Server          │
│   ─────────────────────────── │   │   ───────────────────────────── │
│                               │   │                                 │
│   /new    /next    /update    │   │   @planflow-tools/mcp           │
│   /sync   /cloud   /login     │   │   (npm package)                 │
│                               │   │                                 │
│   SKILL.md → Bash (curl)      │   │   Native Claude Tools:          │
│                               │   │   • planflow_task_next          │
│                               │   │   • planflow_task_update        │
│                               │   │   • planflow_sync               │
│                               │   │   • planflow_projects           │
└───────────────────────────────┘   └─────────────────────────────────┘
                    │                           │
                    │     ┌─────────────────┐   │
                    └────►│ PROJECT_PLAN.md │◄──┘
                          │    (local)      │
                          └─────────────────┘
                                    │
                                    │ HTTPS (Bearer Token)
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        api.planflow.tools                            │
│                                                                      │
│  POST /api-tokens/verify     GET /projects                          │
│  GET  /auth/me               POST /projects                         │
│  GET  /projects/:id/plan     PUT /projects/:id/plan                 │
│  GET  /projects/:id/tasks    PUT /projects/:id/tasks                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Connection Methods Comparison

| Feature | Commands (Plugin) | MCP Server |
|---------|-------------------|------------|
| Setup | Zero (plugin included) | `npm install -g @planflow-tools/mcp` |
| Usage | `/next`, `/update T1.1 done` | "What's my next task?" |
| Integration | Any terminal | Claude Desktop/Code native |
| Offline | ✅ Full support | ✅ Full support |
| Best for | Quick operations | Natural language workflow |

---

## Progress Tracking

### Overall Status
**Total Tasks**: 25
**Completed**: 25 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩 (100%)
**In Progress**: 0
**TODO**: 0

### Phase Progress
- 🔧 Phase 1: Foundation → 4/4 (100%) ✅
- 🔐 Phase 2: Authentication → 3/3 (100%) ✅
- 🔄 Phase 3: Sync Commands → 4/4 (100%) ✅
- ☁️ Phase 4: Cloud Commands → 3/3 (100%) ✅
- 🧪 Phase 5: Testing & Polish → 2/2 (100%) ✅
- 🔀 Phase 6: Hybrid Sync → 6/6 (100%) ✅
- 📚 Phase 7: MCP Documentation → 3/3 (100%) ✅

### Current Focus
🎉 **Project Status**: COMPLETE ✨
📍 **Version**: v1.4.0 Released
🏁 **All 25 tasks completed across 7 phases**

---

## Phase 1: Foundation

**Goal:** Set up infrastructure for API communication

---

#### **T1.1**: Config Schema Extension
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: None
- **აღწერა**:
  Extend `.plan-config.json` schema to support cloud settings:
  ```json
  {
    "language": "ka",
    "defaultProjectType": "fullstack",
    "cloud": {
      "apiUrl": "https://api.planflow.tools",
      "apiToken": "pf_xxx...",
      "userId": "uuid",
      "userEmail": "user@example.com",
      "autoSync": false,
      "lastSyncedAt": null
    }
  }
  ```

**Files to modify:**
- `utils/config-guide.md` - Document new schema
- All command SKILL.md files - Update Step 0 to handle cloud config

---

#### **T1.2**: API Client Skill Creation
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T1.1
- **აღწერა**:
  Create `skills/api-client/SKILL.md` with:
  - Base URL configuration
  - Bearer token authentication
  - Request/response handling via Bash + curl
  - Error parsing and user-friendly messages
  - Retry logic for transient failures

**Endpoints to support:**
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /api-tokens/verify | Verify token validity |
| GET | /auth/me | Get current user info |
| GET | /projects | List user projects |
| POST | /projects | Create new project |
| GET | /projects/:id | Get project details |
| GET | /projects/:id/plan | Get plan content |
| PUT | /projects/:id/plan | Update plan content |
| GET | /projects/:id/tasks | List tasks |
| PUT | /projects/:id/tasks | Bulk update tasks |

---

#### **T1.3**: Translation Keys for Cloud Commands
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: None
- **აღწერა**:
  Add translation keys to `locales/en.json` and `locales/ka.json`:
  ```json
  {
    "commands": {
      "login": {
        "welcome": "...",
        "tokenPrompt": "...",
        "success": "...",
        "invalidToken": "...",
        "alreadyLoggedIn": "..."
      },
      "logout": { ... },
      "sync": {
        "pushing": "...",
        "pulling": "...",
        "conflict": "...",
        "success": "..."
      },
      "cloud": {
        "listProjects": "...",
        "selectProject": "...",
        "linkSuccess": "..."
      }
    }
  }
  ```

---

#### **T1.4**: Credential Storage Utility
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T1.1
- **აღწერა**:
  Create `skills/credentials/SKILL.md` for:
  - Saving token to config (local or global)
  - Reading token from config
  - Clearing credentials (logout)
  - Checking if authenticated

**Storage locations:**
- Global: `~/.config/claude/plan-plugin-config.json`
- Local: `./.plan-config.json` (project-specific override)

---

## Phase 2: Authentication Commands

**Goal:** Enable users to authenticate with PlanFlow

---

#### **T2.1**: /login Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T1.2, T1.3, T1.4
- **აღწერა**:
  Create `commands/login/SKILL.md`:

**Usage:**
```bash
/login                    # Interactive - prompts for token
/login pf_abc123...       # Direct token input
/login --global           # Save to global config (default)
/login --local            # Save to project config only
```

**Flow:**
1. Step 0: Load translations
2. Check if already logged in → show warning
3. Prompt for token (or use argument)
4. Call POST /api-tokens/verify
5. If valid: save credentials, show success
6. If invalid: show error with link to get token

**Output:**
```
✅ Successfully logged in to PlanFlow!

  User:   John Doe
  Email:  john@example.com
  Token:  My CLI Token

🎉 You can now use:
  • /sync     - Sync PROJECT_PLAN.md with cloud
  • /cloud    - Manage cloud projects
  • /status   - Check sync status
```

---

#### **T2.2**: /logout Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T1.4
- **აღწერა**:
  Create `commands/logout/SKILL.md`:

**Usage:**
```bash
/logout           # Clear credentials
/logout --local   # Only clear local config
```

**Flow:**
1. Step 0: Load translations
2. Check if logged in → if not, show message
3. Clear credentials from config
4. Show success message

---

#### **T2.3**: /whoami Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T1.2, T1.4
- **აღწერა**:
  Create `commands/whoami/SKILL.md`:

**Usage:**
```bash
/whoami
```

**Output:**
```
👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-...
  API URL:  https://api.planflow.tools
  Status:   ✅ Connected

📊 Cloud Stats:
  Projects: 5
  Last Sync: 2 hours ago
```

---

## Phase 3: Sync Commands

**Goal:** Enable bidirectional sync between local and cloud

---

#### **T3.1**: /sync push Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T2.1, T1.2
- **აღწერა**:
  Add to `commands/sync/SKILL.md`:

**Usage:**
```bash
/sync push              # Push local → cloud
/sync push --force      # Overwrite cloud version
```

**Flow:**
1. Check authentication
2. Check PROJECT_PLAN.md exists
3. Check if linked to cloud project (or create new)
4. Read local plan content
5. PUT /projects/:id/plan with content
6. Update lastSyncedAt in config
7. Show success with stats

---

#### **T3.2**: /sync pull Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T2.1, T1.2
- **აღწერა**:
  Add to `commands/sync/SKILL.md`:

**Usage:**
```bash
/sync pull              # Pull cloud → local
/sync pull --force      # Overwrite local version
```

**Flow:**
1. Check authentication
2. Check if linked to cloud project
3. GET /projects/:id/plan
4. If local exists: show diff, ask confirmation
5. Write to PROJECT_PLAN.md
6. Update lastSyncedAt
7. Show success

---

#### **T3.3**: /sync status Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T1.2, T1.4
- **აღწერა**:
  Add to `commands/sync/SKILL.md`:

**Usage:**
```bash
/sync status
/sync          # Default action = status
```

**Output:**
```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 5 min ago)
  Cloud:   My Project (synced 2 hours ago)
  Status:  ⚠️ Local changes not synced

  Changes:
    + 2 tasks completed locally
    ~ 1 task status changed

  Run /sync push to upload changes
```

---

#### **T3.4**: Auto-sync on /update
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T3.1
- **აღწერა**:
  Modify `commands/update/SKILL.md`:

  After updating local PROJECT_PLAN.md, if:
  - User is authenticated
  - Project is linked to cloud
  - `autoSync: true` in config

  Then automatically sync task status to cloud.

**Config option:**
```json
{
  "cloud": {
    "autoSync": true
  }
}
```

---

## Phase 4: Cloud Project Management

**Goal:** Manage cloud projects from CLI

---

#### **T4.1**: /cloud list Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T2.1
- **აღწერა**:
  Create `commands/cloud/SKILL.md`:

**Usage:**
```bash
/cloud list
/cloud             # Default action = list
```

**Output:**
```
☁️ Your Cloud Projects

  ID        Name              Tasks    Progress    Last Updated
  ────────  ────────────────  ───────  ──────────  ────────────
  abc123    E-commerce App    24/45    53%         2 hours ago
  def456    Mobile API        12/18    67%         Yesterday
  ghi789    Dashboard         8/8      100% ✅     Last week

  📍 Current: abc123 (E-commerce App)

  💡 Commands:
    /cloud link <id>     - Link local project
    /cloud unlink        - Unlink current project
    /cloud new           - Create cloud project
```

---

#### **T4.2**: /cloud link Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T4.1
- **აღწერა**:
  Add to `commands/cloud/SKILL.md`:

**Usage:**
```bash
/cloud link              # Interactive - show list and select
/cloud link abc123       # Link to specific project
/cloud unlink            # Remove link
```

**Flow:**
1. If no ID: show project list, let user select
2. Save projectId to local config
3. Optionally sync immediately

---

#### **T4.3**: /cloud new Command
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T4.1, T3.1
- **აღწერა**:
  Add to `commands/cloud/SKILL.md`:

**Usage:**
```bash
/cloud new               # Create from local PROJECT_PLAN.md
/cloud new "My Project"  # With custom name
```

**Flow:**
1. Check PROJECT_PLAN.md exists
2. Extract project name from plan (or use argument)
3. POST /projects with name
4. Save projectId to config
5. Push current plan to cloud
6. Show success

---

## Phase 5: Testing & Documentation

**Goal:** Ensure quality and document features

---

#### **T5.1**: End-to-End Testing
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T4.3
- **აღწერა**:
  Test complete flows:
  1. Fresh login → create project → sync → update → verify on web
  2. Pull existing project → modify → push
  3. Conflict handling
  4. Error scenarios (network, auth, etc.)
  5. Multi-language support

  **Completed**: Created comprehensive CLOUD_TESTING_GUIDE.md with:
  - 35+ test scenarios covering all flows
  - Authentication flow tests (10 tests)
  - Fresh flow tests (complete workflow)
  - Pull-modify-push tests (4 tests)
  - Conflict handling tests (3 tests)
  - Error scenario tests (9 tests)
  - Multi-language tests (5 tests)
  - Auto-sync tests (4 tests)
  - Quick smoke test checklist

---

#### **T5.2**: Documentation Update
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T5.1
- **აღწერა**:
  Update documentation:
  - `README.md` - Add cloud features section
  - `utils/config-guide.md` - Document cloud config
  - Add examples for cloud commands
  - Update plugin.json version to 1.2.0

**Completed**: Updated all documentation for v1.2.0:
  - README.md: Added cloud features section with all new commands
  - README.md: Updated project structure to include new commands/skills
  - README.md: Added configuration section with cloud options
  - README.md: Updated development status to show v1.2.0 complete
  - plugin.json: Updated version to 1.2.0 with new keywords
  - utils/config-guide.md: Already contains full cloud config documentation

---

## File Structure (New Files)

```
claude-plan-plugin/
├── commands/
│   ├── login/
│   │   └── SKILL.md          # NEW: /login command
│   ├── logout/
│   │   └── SKILL.md          # NEW: /logout command
│   ├── whoami/
│   │   └── SKILL.md          # NEW: /whoami command
│   ├── sync/
│   │   └── SKILL.md          # NEW: /sync command
│   └── cloud/
│       └── SKILL.md          # NEW: /cloud command
├── skills/
│   ├── api-client/
│   │   └── SKILL.md          # NEW: HTTP client skill
│   └── credentials/
│       └── SKILL.md          # NEW: Token management skill
└── locales/
    ├── en.json               # MODIFY: Add cloud translations
    └── ka.json               # MODIFY: Add cloud translations
```

---

## Dependencies

### External Requirements
- `curl` - For HTTP requests (available on all platforms)
- Internet connection - For API communication

### API Requirements
- Backend API running at `api.planflow.tools`
- Valid API token from `planflow.tools/dashboard/settings/tokens`

---

## Success Criteria

- [x] User can login with API token
- [x] User can sync local PROJECT_PLAN.md to cloud
- [x] User can pull cloud project to local
- [x] Task updates sync automatically (optional)
- [x] User can manage multiple cloud projects
- [x] All commands work in English and Georgian
- [x] Error messages are helpful and actionable
- [x] Documentation is complete

---

## Notes

### Security Considerations
- API tokens stored in plain text in config (standard practice for CLI tools)
- Tokens should have limited scope
- Never log or display full token

### Offline Support
- All existing commands work offline
- Cloud commands show clear error when offline
- Local changes preserved until sync

### Conflict Resolution
- Default: Ask user what to do
- `--force` flag: Overwrite without asking
- ✅ Phase 6: Smart merge based on timestamps

---

## Phase 6: Hybrid Sync (v1.3.0)

**Goal:** Implement Smart Merge system for seamless local + cloud synchronization

**Features:**
- Storage mode configuration (local/cloud/hybrid)
- Auto-sync on every /update command
- Smart merge for non-conflicting changes
- Rich conflict UI with diff, timestamps, and author info

---

#### **T6.1**: Storage Mode Configuration
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: None
- **აღწერა**:
  Add `storage_mode` option to config schema:
  ```json
  {
    "cloud": {
      "storageMode": "hybrid",  // "local" | "cloud" | "hybrid"
      "autoSync": true
    }
  }
  ```

**Modes:**
- `local` - PROJECT_PLAN.md only, no auto-sync
- `cloud` - Cloud is source of truth, local is cache
- `hybrid` - Both local and cloud, with smart merge (default for authenticated users)

**Files to modify:**
- `utils/config-guide.md` - Document storage modes
- `locales/en.json` - Add translation keys
- `locales/ka.json` - Add Georgian translations

---

#### **T6.2**: Pull Before Push Logic
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T6.1
- **აღწერა**:
  Modify sync flow to always pull before push:

**Flow:**
```
/update T1.1 done
    ↓
1. Update local PROJECT_PLAN.md
    ↓
2. If hybrid mode + authenticated:
    ↓
3. PULL: GET /projects/:id/tasks (cloud state)
    ↓
4. COMPARE: Detect changes since lastSyncedAt
    ↓
5. MERGE or CONFLICT (T6.3)
    ↓
6. PUSH: PUT /projects/:id/tasks (merged state)
```

**Files to modify:**
- `commands/update/SKILL.md` - Add pull-before-push logic
- `skills/api-client/SKILL.md` - Add task comparison helpers

---

#### **T6.3**: Smart Merge Algorithm
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🔴 High
- **დამოკიდებულებები**: T6.2
- **აღწერა**:
  Implement Git-like smart merge for tasks:

**Merge Rules:**
```
LOCAL changed T1.1, CLOUD changed T2.3
→ AUTO MERGE ✓ (different tasks)

LOCAL changed T1.1 → done, CLOUD changed T1.1 → blocked
→ CONFLICT ⚠️ (same task, different values)

LOCAL changed T1.1 → done, CLOUD changed T1.1 → done
→ AUTO MERGE ✓ (same task, same value)
```

**Data Structure:**
```json
{
  "taskId": "T1.1",
  "localStatus": "done",
  "localUpdatedAt": "2026-02-01T10:00:00Z",
  "localUpdatedBy": "local",
  "cloudStatus": "blocked",
  "cloudUpdatedAt": "2026-02-01T09:30:00Z",
  "cloudUpdatedBy": "teammate@example.com"
}
```

**Files to create:**
- `skills/smart-merge/SKILL.md` - Merge algorithm implementation

---

#### **T6.4**: Conflict Detection UI
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T6.3
- **აღწერა**:
  Rich conflict UI showing:
  - ✅ სხვაობის ჩვენება (diff)
  - ✅ დროის ჩვენება (timestamps)
  - ✅ ავტორის ჩვენება (who changed)
  - ✅ Preview ორივე ვერსიის

**Conflict Output Example:**
```
⚠️ კონფლიქტი აღმოჩენილია!

Task T1.1: "Setup authentication"

┌─────────────────────────────────────────────────────┐
│ 📍 LOCAL                  │ ☁️ CLOUD                │
├─────────────────────────────────────────────────────┤
│ სტატუსი: done ✅          │ სტატუსი: blocked 🚫    │
│ დრო: 10:00 (30 წთ წინ)    │ დრო: 09:30 (1 სთ წინ)  │
│ ავტორი: შენ               │ ავტორი: team@email.com │
└─────────────────────────────────────────────────────┘

რომელი ვერსია შევინარჩუნოთ?
  1. ლოკალური (done)
  2. Cloud (blocked)
  3. გაუქმება
```

**Files modified:**
- `commands/sync/SKILL.md` - Added Conflict Detection UI section
- `locales/en.json` - Added conflict translation keys
- `locales/ka.json` - Added Georgian conflict translations

**Implementation includes:**
- Single task conflict display with side-by-side comparison
- Multiple conflicts summary view
- Conflict resolution options (keep local/cloud/cancel)
- Timeline diff view for detailed conflict analysis
- Error handling for network issues
- Full bilingual support (English/Georgian)

---

#### **T6.5**: Auto-Sync Enhancement
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟡 Medium
- **დამოკიდებულებები**: T6.3, T6.4
- **აღწერა**:
  Enhance /update auto-sync with smart merge:

**Current flow (v1.2.0):**
```
/update T1.1 done → update local → push to cloud (overwrite)
```

**New flow (v1.3.0):**
```
/update T1.1 done → update local → pull → smart merge → push
```

**Behavior by mode:**
- `local`: No sync, just update file
- `cloud`: Pull first, apply change, push
- `hybrid`: Update file, pull, smart merge, push

**Files modified:**
- `commands/update/SKILL.md` - Added:
  - Sync Mode Decision Flow section
  - Smart Merge skill integration documentation
  - Offline Fallback Handling section with pending sync queue
  - Complete flow diagrams
- `locales/en.json` - Added offline mode translation keys
- `locales/ka.json` - Added Georgian offline mode translations
- `utils/config-guide.md` - Already had storageMode documentation (v1.3.0)

**Implementation includes:**
- Mode-based sync decision logic (local/auto_sync/cloud/hybrid)
- Integration with `skills/smart-merge/SKILL.md` algorithm
- Offline detection and graceful degradation
- Pending sync queue (`.plan-pending-sync.json`)
- Queue processing on next online sync
- Full bilingual support (English/Georgian)

---

#### **T6.6**: Testing & Documentation
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T6.5
- **აღწერა**:
  Test and document Hybrid Sync:

**Test Scenarios:**
1. Two users update different tasks → auto merge
2. Two users update same task differently → conflict UI
3. Two users update same task same way → auto merge
4. Offline update → sync when online
5. Network error during sync → graceful fallback

**Documentation:**
- Update README.md with Hybrid Sync section
- Update CLOUD_TESTING_GUIDE.md with new tests
- Add examples for conflict resolution

---

## Success Criteria (v1.3.0)

- [x] User can choose storage mode (local/cloud/hybrid)
- [x] Auto-sync uses pull-before-push pattern
- [x] Non-conflicting changes merge automatically
- [x] Conflicts show rich diff UI with timestamps and author
- [x] User can resolve conflicts interactively
- [x] Offline mode works gracefully
- [x] All features work in English and Georgian

---

## Phase 7: MCP Documentation (v1.4.0)

**Goal:** Document MCP Server integration as alternative connection method

**MCP Package:** `@planflow-tools/mcp` ✅ Published on npm

---

#### **T7.1**: README განახლება
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: None
- **აღწერა**:
  Plugin README.md-ში დავამატოთ Connection Methods სექცია:

**დასამატებელი სექციები:**
- Connection Methods overview (Commands vs MCP)
- MCP Installation (`npm install -g @planflow-tools/mcp`)
- MCP Configuration for Claude Desktop/Code
- Usage examples

---

#### **T7.2**: არქიტექტურის დიაგრამის განახლება
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T7.1
- **აღწერა**:
  PROJECT_PLAN.md-ში არქიტექტურის დიაგრამა განვაახლოთ MCP-ით:

```
┌─────────────────────────────────────────────────┐
│               მომხმარებელი                       │
└─────────────────────────────────────────────────┘
              │                    │
              ▼                    ▼
┌──────────────────────┐  ┌────────────────────────┐
│ Method A: Commands   │  │ Method B: MCP Server   │
│ /next, /update, etc  │  │ @planflow-tools/mcp    │
│ (SKILL.md + curl)    │  │ (native Claude tools)  │
└──────────────────────┘  └────────────────────────┘
              │                    │
              └────────┬───────────┘
                       ▼
              api.planflow.tools
```

---

#### **T7.3**: MCP Setup Guide
- [x] **სტატუსი**: DONE ✅
- **სირთულე**: 🟢 Low
- **დამოკიდებულებები**: T7.1
- **აღწერა**:
  დეტალური setup guide:

**Claude Desktop კონფიგურაცია:**
```json
// ~/.config/claude/claude_desktop_config.json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["@planflow-tools/mcp"]
    }
  }
}
```

**Claude Code კონფიგურაცია:**
```json
// .claude/settings.json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["@planflow-tools/mcp"]
    }
  }
}
```

**გამოყენების მაგალითები:**
- "What's my next task?" → planflow_task_next
- "Mark T1.1 as done" → planflow_task_update
- "Sync my project" → planflow_sync

---

## Success Criteria (v1.4.0)

- [x] README documents both connection methods
- [x] Architecture diagram shows Commands + MCP
- [x] MCP setup guide is complete and clear
- [x] Examples show natural language usage
