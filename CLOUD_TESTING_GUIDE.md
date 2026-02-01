# Cloud Integration End-to-End Testing Guide

## Overview

This guide provides comprehensive end-to-end test scenarios for the PlanFlow cloud integration features (v1.2.0). These tests verify the complete flows from authentication through project synchronization.

**Test Categories:**
1. [Authentication Flow](#1-authentication-flow)
2. [Fresh Login → Create Project → Sync → Update](#2-fresh-login-flow)
3. [Pull Existing Project → Modify → Push](#3-pull-modify-push-flow)
4. [Conflict Handling](#4-conflict-handling)
5. [Error Scenarios](#5-error-scenarios)
6. [Multi-Language Support](#6-multi-language-support)
7. [Auto-Sync Feature](#7-auto-sync-feature)
8. [Hybrid Sync (v1.3.0)](#8-hybrid-sync-v130)

---

## Prerequisites

Before running tests:

1. **API Token**: Get a valid token from https://planflow.tools/dashboard/settings/tokens
2. **Internet Connection**: Required for API communication
3. **Clean State**: Remove existing configs if testing fresh flows:
   ```bash
   rm -f ./.plan-config.json
   rm -f ~/.config/claude/plan-plugin-config.json
   ```
4. **PROJECT_PLAN.md**: Create or use existing plan for sync tests

---

## 1. Authentication Flow

### Test 1.1: Fresh Login (Interactive)

**Scenario**: User logs in for the first time interactively.

**Steps:**
```bash
# Ensure clean state
rm -f ~/.config/claude/plan-plugin-config.json

# Run login
/login
```

**Expected Flow:**
1. Welcome message displays:
   ```
   🔐 Welcome to PlanFlow Cloud!

   Get your token at: https://planflow.tools/dashboard/settings/tokens
   ```
2. Prompt for API token appears
3. User enters valid token (starts with `pf_`)
4. Shows "Validating token..."
5. Success message with masked token:
   ```
   ✅ Successfully logged in to PlanFlow!

     User:   John Doe
     Email:  john@example.com
     Token:  pf_abc12...xyz9
     🌐 Scope:  Global

   🎉 You can now use:
     • /sync     - Sync PROJECT_PLAN.md with cloud
     • /cloud    - Manage cloud projects
     • /status   - Check sync status
   ```

**Verification:**
```bash
cat ~/.config/claude/plan-plugin-config.json
# Should contain cloud section with apiToken, userId, userEmail, etc.
```

---

### Test 1.2: Direct Token Login

**Scenario**: User provides token directly in command.

**Steps:**
```bash
/login pf_your_valid_token_here
```

**Expected:**
- Skips interactive prompt
- Goes directly to validation
- Shows success or error

---

### Test 1.3: Login with --local Flag

**Scenario**: Save credentials to project-specific config.

**Steps:**
```bash
/login --local
# Enter token when prompted
```

**Expected:**
```
✅ Successfully logged in to PlanFlow!

  User:   John Doe
  Email:  john@example.com
  Token:  pf_abc12...xyz9
  📁 Scope:  Project
```

**Verification:**
```bash
cat ./.plan-config.json
# Should contain cloud section with credentials
```

---

### Test 1.4: Already Logged In

**Scenario**: User runs /login when already authenticated.

**Steps:**
```bash
# Login first
/login pf_valid_token

# Try to login again
/login
```

**Expected:**
```
⚠️ You are already logged in as john@example.com
Run /logout first to switch accounts.
```
Then prompts: "Do you want to log in with a different account?"

---

### Test 1.5: Invalid Token

**Scenario**: User provides invalid/expired token.

**Steps:**
```bash
/login pf_invalid_token_12345
```

**Expected:**
```
Validating token...

❌ Invalid API token. Please check and try again.

Get your token at: https://planflow.tools/dashboard/settings/tokens

💡 Common issues:
   • Token may have expired
   • Token may have been revoked
   • Copy-paste error (extra spaces?)
```

---

### Test 1.6: Invalid Token Format

**Scenario**: Token doesn't start with 'pf_'.

**Steps:**
```bash
/login not_a_valid_format
```

**Expected:**
```
❌ Invalid token format. Tokens should start with 'pf_'

Get your token at: https://planflow.tools/dashboard/settings/tokens
```

---

### Test 1.7: /whoami Command

**Scenario**: Verify current user info.

**Steps:**
```bash
/whoami
```

**Expected (when authenticated):**
```
👤 Current User

  Name:     John Doe
  Email:    john@example.com
  User ID:  550e8400-e29b-41d4-a716-446655440000
  API URL:  https://api.planflow.tools
  Status:   ✅ Connected
  Token:    pf_abc12...xyz9

📊 Cloud Stats:
  Projects:   5
  Tasks:      89/127 completed
  Last Sync:  2 hours ago
```

**Expected (when not authenticated):**
```
❌ Not logged in to PlanFlow.
Run /login to authenticate.
```

---

### Test 1.8: Logout

**Scenario**: Clear stored credentials.

**Steps:**
```bash
/logout
```

**Expected:**
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from global config.
```

**Verification:**
```bash
cat ~/.config/claude/plan-plugin-config.json
# apiToken, userId, userEmail should be removed
# language, projectId should be preserved
```

---

### Test 1.9: Logout with --local

**Scenario**: Clear only local credentials.

**Steps:**
```bash
/logout --local
```

**Expected:**
```
✅ Successfully logged out from PlanFlow.

Credentials cleared from local config.
```

---

### Test 1.10: Logout When Not Logged In

**Steps:**
```bash
rm -f ~/.config/claude/plan-plugin-config.json
/logout
```

**Expected:**
```
⚠️ You are not currently logged in.
```

---

## 2. Fresh Login Flow

### Test 2.1: Complete Fresh Flow (Login → Create → Sync → Update)

**Scenario**: New user completes full workflow.

**Steps:**

#### Step 1: Clean Environment
```bash
rm -f ~/.config/claude/plan-plugin-config.json
rm -f ./.plan-config.json
rm -f PROJECT_PLAN.md
```

#### Step 2: Create Local Plan
```bash
/new
# Answer wizard questions to generate PROJECT_PLAN.md
```

**Verify:**
```bash
cat PROJECT_PLAN.md
# Should contain generated plan with tasks
```

#### Step 3: Login
```bash
/login pf_your_token
```

**Expected:** Success message with user info.

#### Step 4: Check Sync Status (Before Sync)
```bash
/sync
```

**Expected:**
```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified just now)
  Cloud:   Not linked
  Status:  ❌ Not synced

❌ Project not linked to cloud. Run /cloud link first.

💡 Run: /cloud link
```

#### Step 5: Create Cloud Project and Sync
```bash
/sync push
```

**Expected:**
```
❌ Project not linked to cloud.

What would you like to do?
```

Select "Create new cloud project":

**Expected:**
```
Creating cloud project...

✅ Cloud project created!
  Project: Your Project Name
  ID: abc123

🔄 Pushing local changes to cloud...

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 18
   Completed: 0
   Progress: 0%
```

#### Step 6: Update a Task
```bash
/update T1.1 start
```

**Expected:** Task marked as IN_PROGRESS.

```bash
/update T1.1 done
```

**Expected:** Task marked as DONE, progress updated.

#### Step 7: Sync Updated Plan
```bash
/sync push
```

**Expected:**
```
🔄 Pushing local changes to cloud...

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 18
   Completed: 1
   Progress: 6%
```

#### Step 8: Verify on Cloud
Visit https://planflow.tools/dashboard/projects/{project-id} and verify:
- [ ] Project appears in list
- [ ] Task T1.1 shows as DONE
- [ ] Progress percentage matches local

---

## 3. Pull-Modify-Push Flow

### Test 3.1: Pull Existing Project

**Scenario**: Pull a cloud project to new local directory.

**Setup:**
```bash
mkdir test-pull-project
cd test-pull-project
```

**Steps:**

#### Step 1: Login
```bash
/login pf_your_token
```

#### Step 2: List Cloud Projects
```bash
/cloud
```

**Expected:**
```
☁️ Your Cloud Projects

  ID        Name                Tasks     Progress    Last Updated
  ────────  ──────────────────  ────────  ──────────  ────────────────
  abc123    E-commerce App      24/45     53%         2 hours ago
  def456    Mobile API          12/18     67%         Yesterday

  💡 Commands:
    /cloud link <id>     - Link local project
    /cloud unlink        - Unlink current project
    /cloud new           - Create cloud project
```

#### Step 3: Link to Existing Project
```bash
/cloud link abc123
```

**Expected:**
```
✅ Project linked successfully!

Local PROJECT_PLAN.md is now linked to:
  Project: E-commerce App
  ID: abc123

Run /sync push to upload your plan.
```

#### Step 4: Pull Cloud Plan
```bash
/sync pull
```

**Expected:**
```
🔄 Pulling cloud changes to local...

✅ Changes pulled from cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 45
   Completed: 24
   Progress: 53%
```

**Verify:**
```bash
cat PROJECT_PLAN.md
# Should contain the pulled plan
```

---

### Test 3.2: Modify and Push

**Scenario**: Modify pulled plan and sync back.

**Steps:**

#### Step 1: Complete a Task
```bash
/update T2.1 done
```

#### Step 2: Check Sync Status
```bash
/sync
```

**Expected:**
```
📊 Sync Status

  Local:   PROJECT_PLAN.md (modified 1 minute ago)
  Cloud:   E-commerce App (updated 2 hours ago)
  Last synced: 5 minutes ago
  Status:  ⚠️ Local changes not synced

  Changes:
    + 1 task completed locally
    ~ Progress: 53% → 56% (+3%)

Run /sync push to upload changes
```

#### Step 3: Push Changes
```bash
/sync push
```

**Expected:**
```
🔄 Pushing local changes to cloud...

✅ Changes pushed to cloud!

📊 Sync Details:
   ID: abc123
   Last synced: Just now

📈 Project Stats:
   Total Tasks: 45
   Completed: 25
   Progress: 56%
```

---

### Test 3.3: Pull with Local Changes (Confirmation)

**Scenario**: Pull when local has unsaved changes.

**Setup:** Make local changes without syncing.

**Steps:**
```bash
/sync pull
```

**Expected:**
```
🔄 Pulling cloud changes to local...

⚠️ Local PROJECT_PLAN.md will be overwritten.

📊 Comparison:
   Local file modified: 5 minutes ago
   Cloud version from: 2 hours ago

How would you like to proceed?
```

Options:
- "Overwrite local" - Replace with cloud version
- "Keep local" - Cancel pull
- "Show diff" - Display differences first

---

### Test 3.4: Force Pull

**Scenario**: Force overwrite local without confirmation.

**Steps:**
```bash
/sync pull --force
```

**Expected:**
```
🔄 Pulling cloud changes to local...
⚠️ Force mode enabled - will overwrite local version

✅ Changes pulled from cloud!
```

---

## 4. Conflict Handling

### Test 4.1: Push Conflict

**Scenario**: Cloud has changes since last sync.

**Setup:**
1. Sync project
2. Make changes on cloud (via web)
3. Make different changes locally
4. Try to push

**Steps:**
```bash
/sync push
```

**Expected:**
```
🔄 Pushing local changes to cloud...

⚠️ Conflict detected!

Both local and cloud have been modified since last sync.
   Server updated: 10 minutes ago

Choose how to resolve:
```

Options:
- "Keep local version" - Force push local
- "Keep cloud version" - Pull cloud instead
- "Cancel" - Stop and resolve manually

---

### Test 4.2: Force Push (Overwrite Cloud)

**Scenario**: Force push to overwrite cloud.

**Steps:**
```bash
/sync push --force
```

**Expected:**
```
🔄 Pushing local changes to cloud...
⚠️ Force mode enabled - will overwrite cloud version

✅ Changes pushed to cloud!
```

---

### Test 4.3: Resolve by Pulling Cloud

**Scenario**: During conflict, choose to pull cloud version.

**Steps:**
1. Get conflict on push
2. Select "Keep cloud version"

**Expected:**
```
🔄 Pulling cloud changes to local...

✅ Changes pulled from cloud!

Local PROJECT_PLAN.md has been updated with cloud version.
Your local changes have been discarded.
```

---

## 5. Error Scenarios

### Test 5.1: Network Error

**Scenario**: No internet connection.

**Setup:** Disconnect from internet.

**Steps:**
```bash
/sync push
```

**Expected:**
```
❌ Cannot connect to PlanFlow API

Please check:
   • Your internet connection
   • PlanFlow service status

Try again in a few moments.
```

---

### Test 5.2: Token Expired

**Scenario**: Stored token has expired.

**Setup:** Use an expired token in config.

**Steps:**
```bash
/sync push
```

**Expected:**
```
❌ Not authenticated. Run /login first.

💡 Run: /login
```

---

### Test 5.3: Project Not Found

**Scenario**: Linked project was deleted on cloud.

**Setup:** Delete project via cloud dashboard.

**Steps:**
```bash
/sync push
```

**Expected:**
```
❌ Project not found on cloud.

The linked project may have been deleted.

💡 Run: /cloud link to link a different project
```

---

### Test 5.4: Missing PROJECT_PLAN.md

**Scenario**: Trying to sync without local plan.

**Setup:** Delete or rename PROJECT_PLAN.md.

**Steps:**
```bash
/sync push
```

**Expected:**
```
❌ Error: PROJECT_PLAN.md not found in current directory.

Please run /new first to create a project plan.
```

---

### Test 5.5: Sync Without Authentication

**Scenario**: Not logged in.

**Setup:** Logout first.

**Steps:**
```bash
/logout
/sync push
```

**Expected:**
```
❌ Not authenticated. Run /login first.

💡 Run: /login
```

---

### Test 5.6: Cloud Command Without Auth

**Scenario**: Running /cloud without login.

**Steps:**
```bash
/logout
/cloud
```

**Expected:**
```
❌ Not authenticated. Run /login first.

💡 Run: /login
```

---

### Test 5.7: Link Non-Existent Project

**Scenario**: Try to link to invalid project ID.

**Steps:**
```bash
/cloud link invalid_project_id
```

**Expected:**
```
❌ Project 'invalid_project_id' not found.

Run /cloud list to see available projects.
```

---

### Test 5.8: Unlink When Not Linked

**Scenario**: Running /cloud unlink with no link.

**Steps:**
```bash
/cloud unlink
```

**Expected:**
```
⚠️ No project currently linked.
```

---

### Test 5.9: Server Error (500)

**Scenario**: API server error.

**Steps:** (Simulated during API outage)

**Expected:**
```
❌ Server error. Please try again later.

If the problem persists, check status.planflow.tools
```

---

## 6. Multi-Language Support

### Test 6.1: Login in Georgian

**Setup:**
```bash
/settings language
# Select Georgian (ქართული)
```

**Steps:**
```bash
/login
```

**Expected Output (Georgian):**
```
🔐 კეთილი იყოს თქვენი მობრძანება PlanFlow Cloud-ში!

მიიღეთ თქვენი ტოკენი: https://planflow.tools/dashboard/settings/tokens
```

After successful login:
```
✅ წარმატებით შეხვედით PlanFlow-ში!

  მომხმარებელი:   John Doe
  ელ-ფოსტა:       john@example.com
  ტოკენი:         pf_abc12...xyz9
  🌐 სფერო:       გლობალური

🎉 ახლა შეგიძლიათ გამოიყენოთ:
  • /sync     - PROJECT_PLAN.md-ის სინქრონიზაცია ქლაუდთან
  • /cloud    - ქლაუდ პროექტების მართვა
  • /status   - სინქრონიზაციის სტატუსის შემოწმება
```

---

### Test 6.2: Sync Status in Georgian

**Steps:**
```bash
/sync
```

**Expected Output (Georgian):**
```
📊 სინქრონიზაციის სტატუსი

  ლოკალური:   PROJECT_PLAN.md (შეცვლილია 5 წუთის წინ)
  ქლაუდი:   My Project (სინქრონიზებული 2 საათის წინ)
  სტატუსი:  ⚠️ ლოკალური ცვლილებები არ არის სინქრონიზებული

  ცვლილებები:
    + 2 ამოცანა დასრულდა ლოკალურად

გაუშვით /sync push ცვლილებების ასატვირთად
```

---

### Test 6.3: Cloud Commands in Georgian

**Steps:**
```bash
/cloud
```

**Expected Output (Georgian):**
```
☁️ თქვენი ქლაუდ პროექტები

  ID        სახელი              ამოცანები  პროგრესი    განახლებულია
  ────────  ──────────────────  ─────────  ──────────  ────────────────
  abc123    E-commerce App      24/45      53%         2 საათის წინ

  📍 მიმდინარე: E-commerce App

  💡 ბრძანებები:
    /cloud link <id>     - ლოკალური პროექტის დაკავშირება
    /cloud unlink        - მიმდინარე პროექტის გათიშვა
    /cloud new           - ახალი ქლაუდ პროექტის შექმნა
```

---

### Test 6.4: Error Messages in Georgian

**Steps:**
```bash
/logout
/sync push
```

**Expected Output (Georgian):**
```
❌ არ ხართ ავთენტიფიცირებული. გაუშვით /login პირველად.

💡 გაუშვით: /login
```

---

### Test 6.5: Switch Language Mid-Session

**Scenario**: Change language and verify output changes.

**Steps:**
```bash
# Start in English
/sync
# Should show English output

# Switch to Georgian
/settings language
# Select Georgian

# Run again
/sync
# Should show Georgian output
```

---

## 7. Auto-Sync Feature

### Test 7.1: Enable Auto-Sync

**Scenario**: Configure auto-sync in config.

**Setup:**
Edit `./.plan-config.json`:
```json
{
  "cloud": {
    "apiToken": "pf_...",
    "projectId": "abc123",
    "autoSync": true
  }
}
```

---

### Test 7.2: Auto-Sync on /update

**Scenario**: Task update triggers automatic sync.

**Prerequisites:**
- Authenticated
- Project linked
- `autoSync: true` in config

**Steps:**
```bash
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

📊 Progress: 0% → 6% (+6%)

[... normal update output ...]

☁️ Auto-syncing to cloud...
☁️ ✅ Synced to cloud
```

---

### Test 7.3: Auto-Sync Failed (Token Expired)

**Scenario**: Auto-sync fails due to auth issue.

**Steps:**
```bash
# Set expired token in config
# Run update
/update T1.2 done
```

**Expected:**
```
✅ Task T1.2 completed! 🎉

[... normal update output ...]

☁️ Auto-syncing to cloud...
☁️ ⚠️ Cloud sync failed (local update succeeded)
   Token may be expired. Run /login to re-authenticate.
```

---

### Test 7.4: Auto-Sync Disabled

**Scenario**: Verify no sync when disabled.

**Setup:**
Set `autoSync: false` in config (or remove it).

**Steps:**
```bash
/update T1.1 done
```

**Expected:**
Normal update output without any cloud sync messages.

---

## 8. Hybrid Sync (v1.3.0)

### Test 8.1: Storage Mode Configuration

**Scenario**: Configure and verify storage modes.

**Steps:**
```bash
# Check current mode
/settings storage

# Set to hybrid mode
/settings storage hybrid
```

**Expected:**
```
⚙️ Storage Mode Settings

  Storage Mode: hybrid
  Description: Both local and cloud with smart merge (recommended)

✅ Storage mode set to: hybrid

What this means:
  • Both local and cloud kept in sync
  • Smart merge for concurrent changes
  • Works offline, syncs when online
```

**Test all modes:**
```bash
/settings storage local   # Local only
/settings storage cloud   # Cloud source of truth
/settings storage hybrid  # Smart merge
```

---

### Test 8.2: Smart Merge - Different Tasks (Auto-Merge)

**Scenario**: Two users update different tasks simultaneously.

**Setup:**
1. User A and User B both have project synced
2. User A updates T1.1 locally
3. User B updates T2.1 on cloud (via web or another device)
4. User A runs /update

**Steps (User A):**
```bash
# Configure hybrid mode
/settings storage hybrid

# Update local task
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

📊 Progress: 90% → 95% (+5%)

🔄 Syncing with cloud (hybrid mode)...
   ↓ Pulling cloud state...
   ✓ Auto-merged changes
   ↑ Pushing local changes...

☁️ ✅ Synced to cloud (hybrid)

📊 Smart Merge Results:
  Auto-merged: 2 tasks (T1.1, T2.1)
  Conflicts: 0

🎯 Next: /next (get recommendation)
```

---

### Test 8.3: Smart Merge - Same Task, Same Value (Auto-Merge)

**Scenario**: Two users mark same task as done.

**Setup:**
1. User A marks T1.1 done locally
2. User B marks T1.1 done on cloud (before A syncs)
3. User A syncs

**Steps:**
```bash
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

🔄 Syncing with cloud (hybrid mode)...
   ↓ Pulling cloud state...
   ✓ Auto-merged changes (same value)
   ↑ Pushing local changes...

☁️ ✅ Synced to cloud (hybrid)
```

No conflict because both made the same change.

---

### Test 8.4: Smart Merge - Conflict Detection

**Scenario**: Two users update same task with different values.

**Setup:**
1. User A marks T1.1 as "done" locally
2. User B marks T1.1 as "blocked" on cloud
3. User A syncs

**Steps:**
```bash
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

🔄 Syncing with cloud (hybrid mode)...
   ↓ Pulling cloud state...
   ⚠️ Conflict detected!

⚠️ Sync Conflict Detected!

Task T1.1: "Project Setup"

┌─────────────────────────────────────────────────────┐
│ 📍 LOCAL                  │ ☁️ CLOUD                │
├─────────────────────────────────────────────────────┤
│ Status: done ✅           │ Status: blocked 🚫      │
│ Time: 10:00 (just now)    │ Time: 09:30 (30 min ago)│
│ Author: You               │ Author: team@email.com  │
└─────────────────────────────────────────────────────┘

Which version to keep?
  1. Keep local (done)
  2. Keep cloud (blocked)
  3. Cancel
```

**Test Resolution Options:**

Option 1 - Keep Local:
```
Pushing local version to cloud...
✅ Conflict resolved! Kept local version (done)
```

Option 2 - Keep Cloud:
```
Updating local file with cloud version...
✅ Conflict resolved! Kept cloud version (blocked)
```

Option 3 - Cancel:
```
❌ Conflict resolution cancelled.
No changes were made. Both versions remain as-is.

To resolve later:
  /sync push --force  - Overwrite cloud with local
  /sync pull --force  - Overwrite local with cloud
```

---

### Test 8.5: Offline Mode - Queue Changes

**Scenario**: Update tasks while offline.

**Setup:**
1. Enable hybrid mode
2. Disconnect from internet
3. Make updates

**Steps:**
```bash
# Disconnect network
# Then run:
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

📊 Progress: 90% → 95% (+5%)

🔄 Syncing with cloud (hybrid mode)...
   ⚠️ Network unavailable
   📤 Queued for sync when online (1 pending)

📝 Local changes saved to PROJECT_PLAN.md

💡 Run /sync when back online to push changes
```

---

### Test 8.6: Offline Mode - Process Queue When Online

**Scenario**: Sync queued changes when back online.

**Setup:**
1. Have pending changes from offline work
2. Reconnect to internet

**Steps:**
```bash
# Reconnect network
# Then run:
/sync push
```

**Expected:**
```
🔄 Pushing local changes to cloud...

📤 Processing 3 pending changes...
   ✓ T1.1: done
   ✓ T1.2: done
   ✓ T2.1: in_progress

✅ Changes pushed to cloud!

📊 Sync Details:
   Pending processed: 3
   Last synced: Just now
```

---

### Test 8.7: Network Error During Sync - Graceful Fallback

**Scenario**: Network fails mid-sync.

**Setup:**
1. Start sync
2. Simulate network interruption

**Steps:**
```bash
/update T1.1 done
# Network drops during sync
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

🔄 Syncing with cloud (hybrid mode)...
   ↓ Pulling cloud state...
   ⚠️ Could not fetch cloud state
   → Changes saved locally only

📝 Local changes saved to PROJECT_PLAN.md

☁️ ⚠️ Push failed
   📤 Queued for sync when online (1 pending)

💡 Run /sync when back online to push changes
```

---

### Test 8.8: Multiple Conflicts

**Scenario**: Multiple tasks have conflicts.

**Setup:**
1. User A changes T1.1, T1.2, T1.3 locally
2. User B changes T1.1, T1.2 differently on cloud
3. User A syncs

**Steps:**
```bash
/sync push
```

**Expected:**
```
🔄 Pushing local changes to cloud...

⚠️ Multiple Conflicts Detected!

Found 2 task conflicts:

  1. T1.1: "Project Setup"
     Local: done ✅  |  Cloud: blocked 🚫

  2. T1.2: "Database Setup"
     Local: in_progress 🔄  |  Cloud: done ✅

To resolve:
  1. Resolve each conflict interactively
  2. Keep all local versions (/sync push --force)
  3. Keep all cloud versions (/sync pull --force)
```

---

### Test 8.9: Conflict Timeline View

**Scenario**: View detailed conflict timeline.

**Steps:**
When conflict is shown, select "Show details":

**Expected:**
```
📝 Conflict Details

Task T1.1: "Project Setup"

Timeline:
  ──────────────────────────────────────────
  09:00  Base version (synced)
         Status: todo
  ──────────────────────────────────────────
  09:30  ☁️ Cloud changes
         Status: blocked
         By: teammate@example.com
  ──────────────────────────────────────────
  10:00  📍 Local changes
         Status: done
         By: You
  ──────────────────────────────────────────

Which version to keep?
```

---

### Test 8.10: Hybrid Mode with Auto-Sync

**Scenario**: Verify hybrid mode works with auto-sync enabled.

**Setup:**
```json
{
  "cloud": {
    "storageMode": "hybrid",
    "autoSync": true
  }
}
```

**Steps:**
```bash
/update T1.1 done
```

**Expected:**
```
✅ Task T1.1 completed! 🎉

🔄 Syncing with cloud (hybrid mode)...
   ↓ Pulling cloud state...
   ✓ No conflicts detected
   ↑ Pushing local changes...

☁️ ✅ Synced to cloud (hybrid)
```

---

## Test Checklist

### Authentication
- [ ] Test 1.1: Fresh Login (Interactive)
- [ ] Test 1.2: Direct Token Login
- [ ] Test 1.3: Login with --local
- [ ] Test 1.4: Already Logged In
- [ ] Test 1.5: Invalid Token
- [ ] Test 1.6: Invalid Token Format
- [ ] Test 1.7: /whoami Command
- [ ] Test 1.8: Logout
- [ ] Test 1.9: Logout with --local
- [ ] Test 1.10: Logout When Not Logged In

### Fresh Flow
- [ ] Test 2.1: Complete Fresh Flow

### Pull-Modify-Push
- [ ] Test 3.1: Pull Existing Project
- [ ] Test 3.2: Modify and Push
- [ ] Test 3.3: Pull with Local Changes
- [ ] Test 3.4: Force Pull

### Conflict Handling
- [ ] Test 4.1: Push Conflict
- [ ] Test 4.2: Force Push
- [ ] Test 4.3: Resolve by Pulling

### Error Scenarios
- [ ] Test 5.1: Network Error
- [ ] Test 5.2: Token Expired
- [ ] Test 5.3: Project Not Found
- [ ] Test 5.4: Missing PROJECT_PLAN.md
- [ ] Test 5.5: Sync Without Auth
- [ ] Test 5.6: Cloud Without Auth
- [ ] Test 5.7: Link Non-Existent Project
- [ ] Test 5.8: Unlink When Not Linked
- [ ] Test 5.9: Server Error

### Multi-Language
- [ ] Test 6.1: Login in Georgian
- [ ] Test 6.2: Sync Status in Georgian
- [ ] Test 6.3: Cloud Commands in Georgian
- [ ] Test 6.4: Error Messages in Georgian
- [ ] Test 6.5: Switch Language Mid-Session

### Auto-Sync
- [ ] Test 7.1: Enable Auto-Sync
- [ ] Test 7.2: Auto-Sync on /update
- [ ] Test 7.3: Auto-Sync Failed
- [ ] Test 7.4: Auto-Sync Disabled

### Hybrid Sync (v1.3.0)
- [ ] Test 8.1: Storage Mode Configuration
- [ ] Test 8.2: Smart Merge - Different Tasks (Auto-Merge)
- [ ] Test 8.3: Smart Merge - Same Task, Same Value (Auto-Merge)
- [ ] Test 8.4: Smart Merge - Conflict Detection
- [ ] Test 8.5: Offline Mode - Queue Changes
- [ ] Test 8.6: Offline Mode - Process Queue When Online
- [ ] Test 8.7: Network Error During Sync - Graceful Fallback
- [ ] Test 8.8: Multiple Conflicts
- [ ] Test 8.9: Conflict Timeline View
- [ ] Test 8.10: Hybrid Mode with Auto-Sync

---

## Quick Smoke Test

Run this sequence to verify core functionality:

```bash
# 1. Clean state
rm -f ~/.config/claude/plan-plugin-config.json
rm -f ./.plan-config.json

# 2. Create plan
/new
# Complete wizard

# 3. Login
/login pf_your_token

# 4. Check status
/sync

# 5. Create project and push
/sync push
# Select "Create new cloud project"

# 6. Verify project
/cloud

# 7. Update task
/update T1.1 done

# 8. Sync changes
/sync push

# 9. Verify sync status
/sync

# 10. Check user info
/whoami

# 11. Logout
/logout
```

If all steps complete successfully, the cloud integration is working correctly!

---

## Quick Smoke Test (Hybrid Sync v1.3.0)

Run this sequence to verify Hybrid Sync functionality:

```bash
# 1. Login and setup
/login pf_your_token
/cloud link <project-id>

# 2. Enable hybrid mode
/settings storage hybrid

# 3. Update a task (triggers smart merge)
/update T1.1 done
# Should show: "Syncing with cloud (hybrid mode)..."

# 4. Simulate offline work
# Disconnect network
/update T1.2 done
# Should show: "Queued for sync when online"

# 5. Reconnect and sync
# Reconnect network
/sync push
# Should show: "Processing pending changes..."

# 6. Test conflict resolution
# Make change on cloud via web
# Then locally:
/update T1.3 done
# If conflict: should show conflict UI

# 7. Verify sync status
/sync
```

If all steps complete successfully, Hybrid Sync is working correctly!

---

## Reporting Issues

If you encounter issues:

1. **Capture the error message**
2. **Note the command and arguments used**
3. **Check config files** (remove sensitive tokens):
   ```bash
   cat ~/.config/claude/plan-plugin-config.json
   cat ./.plan-config.json
   ```
4. **Note your environment**:
   - OS (macOS, Linux, Windows)
   - Claude Code version
   - Plugin version

Report issues at: https://github.com/anthropics/claude-code/issues

---

## Version History

- **v1.3.0** (2026-02-01): Hybrid Sync testing guide
  - Storage mode configuration tests
  - Smart merge tests (auto-merge scenarios)
  - Conflict detection and resolution tests
  - Offline mode and queue tests
  - Network error graceful fallback tests
  - Multiple conflicts handling tests

- **v1.2.0** (2026-01-31): Initial cloud integration testing guide
  - Authentication tests
  - Sync tests
  - Error handling tests
  - Multi-language tests
  - Auto-sync tests
