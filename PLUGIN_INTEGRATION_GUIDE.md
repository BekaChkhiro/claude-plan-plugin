# PlanFlow MCP Plugin Integration Guide

This document provides detailed instructions for connecting the PlanFlow MCP (Model Context Protocol) plugin to the PlanFlow platform.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Backend API Requirements](#backend-api-requirements)
4. [Plugin Configuration](#plugin-configuration)
5. [Claude Code Integration](#claude-code-integration)
6. [Authentication Flow](#authentication-flow)
7. [Testing the Connection](#testing-the-connection)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

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
│                        PlanFlow Cloud                                │
│  ┌─────────────────┐      ┌─────────────────┐      ┌──────────────┐ │
│  │  api.planflow   │◄────►│   PostgreSQL    │      │  Web App     │ │
│  │    .tools       │      │    (Neon)       │      │ planflow     │ │
│  │   Hono API      │      │                 │      │   .tools     │ │
│  └─────────────────┘      └─────────────────┘      └──────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### Components

| Component | Location | Description |
|-----------|----------|-------------|
| MCP Server | `packages/mcp/` | Node.js server implementing MCP protocol |
| API Backend | `apps/api/` | Hono REST API server |
| Web Frontend | `apps/web/` | Next.js web application |
| Shared Types | `packages/shared/` | Common TypeScript types and schemas |

---

## Prerequisites

### 1. Infrastructure Requirements

- **Domain Configuration:**
  - `planflow.tools` - Web application
  - `api.planflow.tools` - REST API server
  - `docs.planflow.tools` - Documentation (optional)

- **SSL Certificates:** Valid HTTPS certificates for all domains

- **Database:** PostgreSQL database (Neon serverless recommended)

### 2. Environment Variables (API Server)

Create `apps/api/.env` with the following:

```env
# Database
DATABASE_URL=postgresql://user:password@host:5432/planflow
DATABASE_URL_POOLED=postgresql://user:password@host:5432/planflow?pgbouncer=true

# Authentication
JWT_SECRET=your-secure-jwt-secret-min-32-chars
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# Server
PORT=3001
NODE_ENV=production
CORS_ORIGIN=https://planflow.tools

# Payment (LemonSqueezy)
LEMON_SQUEEZY_API_KEY=your-api-key
LEMON_SQUEEZY_STORE_ID=your-store-id
LEMON_SQUEEZY_WEBHOOK_SECRET=your-webhook-secret
```

### 3. Build Requirements

- Node.js >= 20.0.0
- pnpm >= 8.0.0

---

## Backend API Requirements

The MCP plugin communicates with the following API endpoints. **All endpoints must be implemented and accessible.**

### Required Endpoints

#### Authentication

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/api-tokens/verify` | Verify API token validity | No |
| `GET` | `/auth/me` | Get current user info | Yes |

#### Projects

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/projects` | List all user projects | Yes |
| `POST` | `/projects` | Create new project | Yes |
| `GET` | `/projects/:id` | Get single project | Yes |
| `PUT` | `/projects/:id` | Update project | Yes |
| `DELETE` | `/projects/:id` | Delete project | Yes |
| `GET` | `/projects/:id/plan` | Get project plan content | Yes |
| `PUT` | `/projects/:id/plan` | Update project plan | Yes |

#### Tasks

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/projects/:id/tasks` | List project tasks | Yes |
| `PUT` | `/projects/:id/tasks` | Bulk update tasks | Yes |

#### Notifications

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/notifications` | List notifications | Yes |
| `PUT` | `/notifications/:id/read` | Mark as read | Yes |
| `PUT` | `/notifications/read-all` | Mark all as read | Yes |

#### Health

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/health` | Health check | No |
| `GET` | `/` | API info | No |

### API Response Format

All API responses must follow this structure:

```typescript
// Success response
{
  "success": true,
  "data": { /* response data */ }
}

// Error response
{
  "success": false,
  "error": "Error message"
}
```

### Authentication Header

All authenticated requests require:

```
Authorization: Bearer <api-token>
```

API tokens have the format: `pf_` followed by 64 hexadecimal characters.

---

## Plugin Configuration

### 1. API URL Configuration

The plugin's default API URL is configured in:

**File:** `packages/mcp/src/config.ts`

```typescript
// Lines 18-23
const ConfigSchema = z.object({
  apiToken: z.string().optional(),
  apiUrl: z.string().url().default('https://api.planflow.tools'),  // <-- Change this
  userId: z.string().uuid().optional(),
  userEmail: z.string().email().optional(),
})

// Lines 30-32
const DEFAULT_CONFIG: Config = {
  apiUrl: 'https://api.planflow.tools',  // <-- And this
}
```

### 2. User-Facing URLs

Update all user-facing URLs in MCP tools:

| File | URLs to Update |
|------|----------------|
| `packages/mcp/src/tools/login.ts` | Token generation URL |
| `packages/mcp/src/tools/logout.ts` | Token URL in help message |
| `packages/mcp/src/tools/whoami.ts` | Token URL in error messages |
| `packages/mcp/src/tools/projects.ts` | Token URL, project creation URL |
| `packages/mcp/src/tools/create.ts` | Token URL in error messages |
| `packages/mcp/src/tools/sync.ts` | Token URL in error messages |
| `packages/mcp/src/tools/task-list.ts` | Token URL in error messages |
| `packages/mcp/src/tools/task-update.ts` | Token URL in error messages |
| `packages/mcp/src/tools/task-next.ts` | Token URL in error messages |
| `packages/mcp/src/tools/notifications.ts` | Token URL in error messages |

**Search pattern:** `planflow.dev` → `planflow.tools`

### 3. Package Metadata

**File:** `packages/mcp/package.json`

```json
{
  "author": "PlanFlow <hello@planflow.tools>",
  "homepage": "https://planflow.tools",
  "bugs": {
    "url": "https://github.com/planflow/planflow/issues"
  }
}
```

### 4. Build the Plugin

After making changes:

```bash
# Install dependencies
pnpm install

# Build the MCP package
pnpm --filter @planflow/mcp build

# Run tests
pnpm --filter @planflow/mcp test
```

---

## Claude Code Integration

### Option 1: Global npm Installation

```bash
# Publish to npm (or use locally)
npm publish packages/mcp

# Users install globally
npm install -g @planflow/mcp
```

### Option 2: Claude Code Configuration

Users configure Claude Code to use the MCP server:

**File:** `~/.claude/claude_code_config.json`

```json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["-y", "@planflow/mcp"]
    }
  }
}
```

Or for local development:

```json
{
  "mcpServers": {
    "planflow": {
      "command": "node",
      "args": ["/path/to/plan-flow/packages/mcp/dist/index.js"]
    }
  }
}
```

### Option 3: With Environment Variables

```json
{
  "mcpServers": {
    "planflow": {
      "command": "npx",
      "args": ["-y", "@planflow/mcp"],
      "env": {
        "PLANFLOW_API_URL": "https://api.planflow.tools"
      }
    }
  }
}
```

---

## Authentication Flow

### Step 1: User Generates API Token

1. User logs into `https://planflow.tools`
2. Navigates to Settings → API Tokens (`/dashboard/settings/tokens`)
3. Creates new API token
4. Token is displayed once: `pf_abc123...`

### Step 2: User Authenticates in Claude Code

```
User: "Login to PlanFlow"
Claude: Uses planflow_login tool with token
```

The plugin:
1. Calls `POST /api-tokens/verify` with the token
2. Receives user info if valid
3. Stores credentials in `~/.config/planflow/config.json`

### Step 3: Credential Storage

**File:** `~/.config/planflow/config.json`

```json
{
  "apiToken": "pf_abc123def456...",
  "apiUrl": "https://api.planflow.tools",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "userEmail": "user@example.com"
}
```

### Token Verification Endpoint

**Request:**
```http
POST /api-tokens/verify
Content-Type: application/json

{
  "token": "pf_abc123def456..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": "John Doe"
    },
    "tokenName": "My CLI Token"
  }
}
```

---

## Testing the Connection

### 1. API Health Check

```bash
curl https://api.planflow.tools/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-01-31T12:00:00.000Z"
}
```

### 2. Token Verification

```bash
curl -X POST https://api.planflow.tools/api-tokens/verify \
  -H "Content-Type: application/json" \
  -d '{"token": "pf_your_token_here"}'
```

### 3. MCP Server Test

```bash
# Build and run locally
cd packages/mcp
pnpm build
node dist/index.js
```

### 4. Integration Test

In Claude Code:
```
User: "Login to PlanFlow with token pf_xxx"
User: "Show my PlanFlow projects"
User: "Create a new project called Test"
```

---

## Troubleshooting

### Common Issues

#### 1. "Network error" or "Connection refused"

**Cause:** API server not reachable

**Solution:**
- Verify `api.planflow.tools` DNS is configured
- Check API server is running
- Verify SSL certificate is valid
- Check firewall rules

#### 2. "CORS error"

**Cause:** CORS not configured for MCP server origin

**Solution:** Add to API server's CORS configuration:
```typescript
// apps/api/src/middleware/security.ts
const allowedOrigins = [
  'https://planflow.tools',
  // MCP server runs as a Node.js process, no origin needed for server-to-server
]
```

#### 3. "Invalid or expired token"

**Cause:** Token doesn't exist or was revoked

**Solution:**
- Generate new token at `https://planflow.tools/dashboard/settings/tokens`
- Run `planflow_logout` then `planflow_login` with new token

#### 4. "Not authenticated"

**Cause:** No token stored locally

**Solution:**
```bash
# Check if config exists
cat ~/.config/planflow/config.json

# If empty or missing, login again
```

### Debug Mode

Enable debug logging:

```bash
DEBUG=planflow:* node packages/mcp/dist/index.js
```

### Logs Location

MCP server logs to stderr by default. Check Claude Code logs for MCP communication issues.

---

## Checklist

Before going live, verify:

- [ ] API server deployed and accessible at `api.planflow.tools`
- [ ] Web app deployed at `planflow.tools`
- [ ] SSL certificates valid for both domains
- [ ] Database migrations applied
- [ ] `/api-tokens/verify` endpoint working
- [ ] `/health` endpoint returning healthy status
- [ ] CORS configured correctly
- [ ] MCP package built successfully
- [ ] All tests passing
- [ ] Token generation working in web dashboard
- [ ] End-to-end flow tested with real token

---

## Quick Reference

| Resource | URL |
|----------|-----|
| Web App | `https://planflow.tools` |
| API Server | `https://api.planflow.tools` |
| API Docs | `https://api.planflow.tools/docs` |
| Token Management | `https://planflow.tools/dashboard/settings/tokens` |
| User Config | `~/.config/planflow/config.json` |
| Claude Config | `~/.claude/claude_code_config.json` |

---

## Support

- Documentation: `https://docs.planflow.tools`
- Issues: `https://github.com/planflow/planflow/issues`
- Email: `support@planflow.tools`
