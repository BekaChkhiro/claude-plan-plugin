# /login - PlanFlow Cloud Authentication

Authenticate with PlanFlow cloud to enable project synchronization and cloud features.

## Usage

```bash
/login                    # Interactive - prompts for token
/login pf_abc123...       # Direct token input
/login --global           # Save to global config (default)
/login --local            # Save to project config only
```

## What This Command Does

- Authenticates the user with PlanFlow cloud API
- Verifies the API token is valid
- Saves credentials to config (local or global)
- Enables cloud features: `/sync`, `/cloud`, `/whoami`

## Prerequisites

- API token from https://planflow.tools/dashboard/settings/tokens
- Internet connection

---

## Step 0: Load User Language & Translations

**CRITICAL: Execute this step FIRST, before any output!**

Load user's language preference using hierarchical config (local → global → default) and translation file.

**Pseudo-code:**
```javascript
// Read config with hierarchy (v1.1.1+)
function getConfig() {
  // Try local config first
  if (fileExists("./.plan-config.json")) {
    try {
      return JSON.parse(readFile("./.plan-config.json"))
    } catch (error) {}
  }

  // Fall back to global config
  const globalPath = expandPath("~/.config/claude/plan-plugin-config.json")
  if (fileExists(globalPath)) {
    try {
      return JSON.parse(readFile(globalPath))
    } catch (error) {}
  }

  // Fall back to defaults
  return { "language": "en" }
}

const config = getConfig()
const language = config.language || "en"

// Load translations
const translationPath = `locales/${language}.json`
const t = JSON.parse(readFile(translationPath))
```

**Instructions for Claude:**

1. Try to read `./.plan-config.json` (local, highest priority)
2. If not found/corrupted, try `~/.config/claude/plan-plugin-config.json` (global)
3. If not found/corrupted, use default: `language = "en"`
4. Use Read tool: `locales/{language}.json`
5. Store as `t` variable for translations

---

## Step 1: Parse Command Arguments

Check for token argument and scope flags.

**Pseudo-code:**
```javascript
const args = parseArguments()  // Get arguments after "/login"

// Check for --local flag
const isLocal = args.includes("--local")
const isGlobal = args.includes("--global") || !isLocal  // Default is global

// Remove flags from args
const cleanArgs = args.filter(arg => !arg.startsWith("--"))

// Check for direct token input
const directToken = cleanArgs.length > 0 ? cleanArgs[0] : null

// Determine scope
const scope = isLocal ? "local" : "global"
```

**Instructions for Claude:**

Parse the command arguments:
- `/login` → `directToken = null`, `scope = "global"`
- `/login pf_abc123` → `directToken = "pf_abc123"`, `scope = "global"`
- `/login --local` → `directToken = null`, `scope = "local"`
- `/login pf_abc123 --local` → `directToken = "pf_abc123"`, `scope = "local"`
- `/login --global` → `directToken = null`, `scope = "global"`

---

## Step 2: Check If Already Logged In

Before prompting for a new token, check if user is already authenticated.

**Pseudo-code:**
```javascript
function isAuthenticated(config) {
  return !!config.cloud?.apiToken
}

function getExistingUser(config) {
  if (!config.cloud?.apiToken) return null
  return {
    email: config.cloud.userEmail,
    name: config.cloud.userName,
    tokenName: config.cloud.tokenName
  }
}

// Check current auth status
const existingUser = getExistingUser(config)

if (existingUser) {
  // Show warning about existing login
  console.log(t.commands.login.alreadyLoggedIn.replace("{email}", existingUser.email))
  console.log(t.commands.login.logoutFirst)

  // Ask if they want to continue anyway
  const continueAnyway = AskUserQuestion({
    questions: [{
      question: "Do you want to log in with a different account?",
      header: "Switch account",
      options: [
        { label: "Yes, log in with new token", description: "Replace current credentials" },
        { label: "No, keep current login", description: "Cancel and keep existing credentials" }
      ]
    }]
  })

  if (continueAnyway === "No, keep current login") {
    return  // Exit command
  }
}
```

**Instructions for Claude:**

1. Check if `config.cloud?.apiToken` exists in the loaded config
2. If exists, show warning:
   ```
   ⚠️ You are already logged in as user@example.com
   Run /logout first to switch accounts.
   ```
3. Use AskUserQuestion to ask if they want to continue
4. If user chooses to keep current login, stop execution
5. If user chooses to continue, proceed to Step 3

---

## Step 3: Get Token (Interactive or Direct)

Either use the provided token or prompt the user for one.

### If Direct Token Provided

```javascript
if (directToken) {
  token = directToken
  // Proceed to Step 4
}
```

### If No Token Provided (Interactive)

Prompt user for their API token.

**Pseudo-code:**
```javascript
console.log(t.commands.login.welcome)
console.log("")
console.log(t.commands.login.tokenHint)
console.log("   https://planflow.tools/dashboard/settings/tokens")
console.log("")

const response = AskUserQuestion({
  questions: [{
    question: t.commands.login.tokenPrompt,
    header: "API Token",
    options: [
      { label: "Enter token", description: "Paste your API token (starts with pf_)" }
    ]
  }]
})

// User will enter token via "Other" option
token = response.trim()
```

**Instructions for Claude:**

1. If `directToken` exists from arguments, use it directly
2. If no token provided, show welcome message and use AskUserQuestion:

   ```
   🔐 Welcome to PlanFlow Cloud!

   Get your token at: https://planflow.tools/dashboard/settings/tokens
   ```

   Then use AskUserQuestion with a single option that allows user to enter token:
   - question: "Please enter your API token:"
   - header: "API Token"
   - options: Single option prompting for token input

3. The user will select "Other" and type their token
4. Trim whitespace from the token

---

## Step 4: Validate Token Format

Basic validation before making API call.

**Pseudo-code:**
```javascript
function validateTokenFormat(token) {
  if (!token || token.length === 0) {
    return { valid: false, error: "Token cannot be empty" }
  }

  // PlanFlow tokens start with "pf_"
  if (!token.startsWith("pf_")) {
    return { valid: false, error: "Invalid token format. Tokens should start with 'pf_'" }
  }

  if (token.length < 20) {
    return { valid: false, error: "Token appears too short" }
  }

  return { valid: true }
}

const validation = validateTokenFormat(token)
if (!validation.valid) {
  console.log(`❌ ${validation.error}`)
  console.log("")
  console.log(t.commands.login.tokenHint)
  return
}
```

**Instructions for Claude:**

Validate the token:
1. Check token is not empty
2. Check token starts with "pf_"
3. Check token length is reasonable (> 20 characters)

If invalid, show error and stop:
```
❌ Invalid token format. Tokens should start with 'pf_'

Get your token at: https://planflow.tools/dashboard/settings/tokens
```

---

## Step 5: Verify Token with API

Call the PlanFlow API to verify the token is valid.

**Pseudo-code:**
```javascript
console.log(t.commands.login.validating)

// Make API request using api-client skill pattern
const apiUrl = config.cloud?.apiUrl || "https://api.planflow.tools"

const response = makeRequest("POST", "/api-tokens/verify", null, token)

// response structure:
// Success (200):
// {
//   "valid": true,
//   "token": { "id": "uuid", "name": "My CLI Token", ... },
//   "user": { "id": "uuid", "email": "user@example.com", "name": "John Doe" }
// }
//
// Error (401):
// { "error": "Invalid or expired token", "code": "INVALID_TOKEN" }
```

**Bash Implementation:**
```bash
API_URL="https://api.planflow.tools"
TOKEN="pf_user_provided_token"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  "${API_URL}/api-tokens/verify")

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Status: $HTTP_CODE"
echo "Body: $BODY"
```

**Instructions for Claude:**

1. Show "Validating token..." message
2. Use Bash tool to make curl request:
   ```bash
   curl -s -w "\n%{http_code}" \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Authorization: Bearer {TOKEN}" \
     "https://api.planflow.tools/api-tokens/verify"
   ```
3. Parse the response:
   - Last line = HTTP status code
   - Everything else = JSON body
4. Proceed to Step 6 based on result

---

## Step 6: Handle API Response

Process the verification response.

### Success Response (HTTP 200)

**Pseudo-code:**
```javascript
if (httpCode >= 200 && httpCode < 300) {
  const data = JSON.parse(body)

  if (data.valid) {
    // Extract user and token info
    const userInfo = {
      userId: data.user.id,
      userEmail: data.user.email,
      userName: data.user.name,
      tokenName: data.token.name,
      apiToken: token
    }

    // Proceed to Step 7 (save credentials)
    saveCredentials(userInfo, scope)
    showSuccess(userInfo)
  }
}
```

### Error Response (HTTP 401)

**Pseudo-code:**
```javascript
if (httpCode === 401) {
  console.log(t.commands.login.invalidToken)
  console.log("")
  console.log(t.commands.login.tokenHint)
  console.log("   https://planflow.tools/dashboard/settings/tokens")
  console.log("")
  console.log("💡 Common issues:")
  console.log("   • Token may have expired")
  console.log("   • Token may have been revoked")
  console.log("   • Copy-paste error (extra spaces?)")
  return
}
```

### Network/Server Error

**Pseudo-code:**
```javascript
if (httpCode === 0 || httpCode >= 500) {
  console.log("❌ Cannot connect to PlanFlow API")
  console.log("")
  console.log("Please check:")
  console.log("   • Your internet connection")
  console.log("   • PlanFlow service status")
  console.log("")
  console.log("Try again in a few moments.")
  return
}
```

**Instructions for Claude:**

Based on HTTP status code:

**If 200-299 (Success):**
- Parse JSON body
- Extract user info (id, email, name) and token info (name)
- Proceed to Step 7

**If 401 (Unauthorized):**
```
❌ Invalid API token. Please check and try again.

Get your token at: https://planflow.tools/dashboard/settings/tokens

💡 Common issues:
   • Token may have expired
   • Token may have been revoked
   • Copy-paste error (extra spaces?)
```

**If 0 or 500+ (Network/Server Error):**
```
❌ Cannot connect to PlanFlow API

Please check:
   • Your internet connection
   • PlanFlow service status

Try again in a few moments.
```

---

## Step 7: Save Credentials

Save the verified credentials to config file.

**Pseudo-code:**
```javascript
function saveCredentials(userInfo, scope) {
  // Determine target file
  const targetPath = scope === "local"
    ? "./.plan-config.json"
    : expandPath("~/.config/claude/plan-plugin-config.json")

  // Ensure directory exists (for global)
  if (scope === "global") {
    const configDir = expandPath("~/.config/claude")
    if (!directoryExists(configDir)) {
      createDirectory(configDir, { recursive: true })
    }
  }

  // Read existing config or create new
  let existingConfig = {}
  if (fileExists(targetPath)) {
    try {
      existingConfig = JSON.parse(readFile(targetPath))
    } catch (error) {
      existingConfig = {}
    }
  }

  // Merge credentials into cloud section
  existingConfig.cloud = {
    ...existingConfig.cloud,
    apiUrl: "https://api.planflow.tools",
    apiToken: userInfo.apiToken,
    userId: userInfo.userId,
    userEmail: userInfo.userEmail,
    userName: userInfo.userName,
    tokenName: userInfo.tokenName,
    savedAt: new Date().toISOString()
  }

  // Write back
  writeFile(targetPath, JSON.stringify(existingConfig, null, 2))

  return { success: true, path: targetPath, scope: scope }
}
```

**Instructions for Claude:**

1. Determine target path based on scope:
   - `local` → `./.plan-config.json`
   - `global` → `~/.config/claude/plan-plugin-config.json`

2. For global scope, ensure directory exists:
   ```bash
   mkdir -p ~/.config/claude
   ```

3. Read existing config (if exists) to preserve other fields
   - Use Read tool on target path
   - If exists, parse JSON
   - If not exists or corrupted, start with `{}`

4. Update config with cloud credentials:
   ```json
   {
     "language": "en",  // Preserve existing
     "cloud": {
       "apiUrl": "https://api.planflow.tools",
       "apiToken": "pf_...",
       "userId": "uuid",
       "userEmail": "user@example.com",
       "userName": "John Doe",
       "tokenName": "My CLI Token",
       "savedAt": "2026-01-31T15:00:00Z"
     }
   }
   ```

5. Write config file using Write tool

---

## Step 8: Show Success Message

Display success confirmation with user info and next steps.

**Pseudo-code:**
```javascript
function maskToken(token) {
  if (!token || token.length < 12) return "***"
  return token.substring(0, 8) + "..." + token.substring(token.length - 4)
}

const scopeIcon = scope === "local" ? "📁" : "🌐"
const scopeText = scope === "local" ? "Project" : "Global"

console.log(t.commands.login.success)
console.log("")
console.log(`  ${t.commands.login.user}   ${userInfo.userName}`)
console.log(`  ${t.commands.login.email}  ${userInfo.userEmail}`)
console.log(`  ${t.commands.login.token}  ${maskToken(userInfo.apiToken)}`)
console.log(`  ${scopeIcon} Scope:  ${scopeText}`)
console.log("")
console.log(t.commands.login.nowYouCan)
console.log(t.commands.login.syncCommand)
console.log(t.commands.login.cloudCommand)
console.log(t.commands.login.statusCommand)
```

**Instructions for Claude:**

Output success message:

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

**IMPORTANT:**
- Use `maskToken()` to only show first 8 and last 4 characters of token
- Show scope indicator (📁 for local, 🌐 for global)
- Use translation keys from `t.commands.login.*`

---

## Error Handling

### Empty Token

```
❌ Token cannot be empty

Please enter your API token or run:
   /login pf_your_token_here
```

### Invalid Token Format

```
❌ Invalid token format. Tokens should start with 'pf_'

Get your token at: https://planflow.tools/dashboard/settings/tokens
```

### Network Error

```
❌ Cannot connect to PlanFlow API

Please check:
   • Your internet connection
   • PlanFlow service status (status.planflow.tools)

Try again in a few moments.
```

### Token Expired/Revoked

```
❌ Invalid API token. Please check and try again.

Get your token at: https://planflow.tools/dashboard/settings/tokens

💡 Common issues:
   • Token may have expired
   • Token may have been revoked
   • Copy-paste error (extra spaces?)
```

### Config Write Error

```
⚠️ Warning: Couldn't save credentials to config file

Login successful but credentials will only persist for this session.
Check file permissions on: ~/.config/claude/
```

---

## Examples

### Example 1: Interactive Login (Global)

```bash
$ /login
```

Output:
```
🔐 Welcome to PlanFlow Cloud!

Get your token at: https://planflow.tools/dashboard/settings/tokens
```

User enters token: `pf_abc123...`

Output:
```
Validating token...

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

### Example 2: Direct Token Login

```bash
$ /login pf_abc123xyz789
```

Output:
```
Validating token...

✅ Successfully logged in to PlanFlow!

  User:   John Doe
  Email:  john@example.com
  Token:  pf_abc12...789
  🌐 Scope:  Global

🎉 You can now use:
  • /sync     - Sync PROJECT_PLAN.md with cloud
  • /cloud    - Manage cloud projects
  • /status   - Check sync status
```

### Example 3: Project-Specific Login

```bash
$ /login --local
```

Output:
```
🔐 Welcome to PlanFlow Cloud!

Get your token at: https://planflow.tools/dashboard/settings/tokens
```

User enters token...

Output:
```
✅ Successfully logged in to PlanFlow!

  User:   Jane Smith
  Email:  jane@company.com
  Token:  pf_xyz78...abc1
  📁 Scope:  Project

🎉 You can now use:
  • /sync     - Sync PROJECT_PLAN.md with cloud
  • /cloud    - Manage cloud projects
  • /status   - Check sync status
```

### Example 4: Already Logged In

```bash
$ /login
```

Output:
```
⚠️ You are already logged in as john@example.com
Run /logout first to switch accounts.
```

User selects "Yes, log in with new token"...

Continues with normal login flow.

### Example 5: Invalid Token

```bash
$ /login pf_invalid_token
```

Output:
```
Validating token...

❌ Invalid API token. Please check and try again.

Get your token at: https://planflow.tools/dashboard/settings/tokens

💡 Common issues:
   • Token may have expired
   • Token may have been revoked
   • Copy-paste error (extra spaces?)
```

### Example 6: Georgian Language

```bash
$ /login
```

Output (with Georgian translations):
```
🔐 კეთილი იყოს თქვენი მობრძანება PlanFlow Cloud-ში!

მიიღეთ თქვენი ტოკენი: https://planflow.tools/dashboard/settings/tokens
```

User enters token...

Output:
```
ტოკენის ვალიდაცია...

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

## Testing

Test cases to verify login command:

```bash
# Test 1: Fresh login (no existing credentials)
rm -f ./.plan-config.json
rm -f ~/.config/claude/plan-plugin-config.json
/login
# Enter valid token
# Should succeed and save to global config

# Test 2: Verify credentials saved
cat ~/.config/claude/plan-plugin-config.json
# Should show cloud section with apiToken, userId, etc.

# Test 3: Already logged in
/login
# Should show warning about existing login
# Select "Keep current" - should exit
# Select "Login with new" - should continue

# Test 4: Direct token input
/login pf_valid_token_here
# Should skip prompt and verify directly

# Test 5: Local scope
/login --local
# Enter valid token
# Should save to ./.plan-config.json

# Test 6: Verify local credentials
cat ./.plan-config.json
# Should show cloud section

# Test 7: Invalid token
/login pf_invalid_token
# Should show error message

# Test 8: Empty token
/login ""
# Should show "Token cannot be empty"

# Test 9: Bad format
/login not_a_pf_token
# Should show "Invalid token format"

# Test 10: Network error (disconnect internet)
/login pf_some_token
# Should show "Cannot connect to PlanFlow API"

# Test 11: Georgian language
# Set language to ka first
/settings language
# Select Georgian
/login
# All messages should be in Georgian
```

---

## Security Notes

1. **Token Storage**: Tokens are stored in plain text in config files (standard practice for CLI tools like gh, aws-cli)

2. **Token Masking**: Never display full token - always use `maskToken()` to show only prefix and suffix

3. **No Command Line Exposure**: When token is passed as argument, it may appear in shell history. Recommend interactive mode for better security.

4. **HTTPS Only**: All API communication uses HTTPS

5. **File Permissions**: Recommend setting config file permissions to user-only:
   ```bash
   chmod 600 ~/.config/claude/plan-plugin-config.json
   ```

---

## Dependencies

This command uses:
- **skills/api-client/SKILL.md** - For making API requests
- **skills/credentials/SKILL.md** - For saving credentials

---

## Related Commands

- `/logout` - Clear stored credentials
- `/whoami` - Show current user info
- `/sync` - Sync project with cloud
- `/cloud` - Manage cloud projects

---

## Notes

- Tokens are obtained from https://planflow.tools/dashboard/settings/tokens
- Global scope saves to `~/.config/claude/plan-plugin-config.json`
- Local scope saves to `./.plan-config.json` (project-specific)
- Local credentials override global when both exist
- All cloud commands check for valid credentials before operating
