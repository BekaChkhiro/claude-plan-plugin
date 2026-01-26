# Changelog

All notable changes to the Plan Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-26

### Added

#### Core Commands
- **`/plan:new`** - Interactive project wizard
  - Asks strategic questions about your project
  - Generates comprehensive PROJECT_PLAN.md
  - Supports multiple project types (Full-stack, Backend, Frontend)
  - Creates Mermaid architecture diagrams
  - Generates phased task breakdown

- **`/plan:update`** - Task status management
  - Update tasks: `start`, `done`, `block`
  - Automatic progress calculation
  - Phase-by-phase tracking
  - Visual progress bars
  - Dependency tracking

- **`/plan:next`** - Intelligent task recommendations
  - Analyzes dependencies and priorities
  - Suggests optimal next task
  - Provides reasoning for recommendations
  - Shows alternative tasks
  - Considers complexity balance

- **`/plan:export`** - Multiple export formats
  - GitHub Issues integration (via gh CLI)
  - JSON structured export
  - Markdown summary generation
  - CSV export (optional)

#### Templates
- **Base Template** - Generic project planning template
  - Overview and problem statement
  - Architecture diagrams
  - Tech stack sections
  - Task breakdown by phases
  - Progress tracking
  - Success criteria

- **Full-Stack Template** - Complete web applications
  - Frontend + Backend + Database architecture
  - Comprehensive tech stack recommendations
  - Integration-focused tasks
  - End-to-end workflows

- **Backend API Template** - Server-side applications
  - API architecture patterns
  - Database and caching layers
  - Authentication and security
  - Performance benchmarks

- **Frontend SPA Template** - Single-page applications
  - Component architecture
  - State management patterns
  - Design system integration
  - Performance optimization

#### AI Skills
- **analyze-codebase** - Existing project analysis
  - Auto-detect tech stack
  - Identify project structure
  - Find incomplete features
  - Suggest improvement tasks
  - Generate analysis reports

- **suggest-breakdown** - Task decomposition
  - Break high-level tasks into subtasks
  - Provide implementation details
  - Estimate effort per subtask
  - Define clear acceptance criteria

- **estimate-complexity** - Time and complexity estimation
  - Calculate task complexity (Low/Medium/High)
  - Estimate time in hours
  - Apply heuristics and multipliers
  - Account for testing and buffers

#### Documentation
- Comprehensive README with examples
- Detailed skill documentation
- Template customization guide
- Plugin manifest configuration

### Features

- **Interactive Wizards** - Step-by-step project setup
- **Progress Visualization** - Clear progress bars and percentages
- **Dependency Management** - Track task dependencies
- **Phase-Based Planning** - Organize work into logical phases
- **Mermaid Diagrams** - Auto-generated architecture diagrams
- **Tech Stack Detection** - Smart technology recommendations
- **Export Integration** - GitHub Issues, JSON, Markdown

### Technical

- Plugin manifest: `plan` namespace
- Commands: 4 (new, update, next, export)
- Skills: 3 (analyze, breakdown, estimate)
- Templates: 4 project types + section partials
- Lines of code: ~5,800

## [Unreleased]

### Planned for v1.1.0
- Multi-language support (Georgian, Russian)
- Custom template creation
- Team templates sharing
- AI-powered task generation from features
- Gantt chart generation
- Integration with Jira, Linear, Asana
- Velocity tracking
- Sprint planning tools

### Planned for v1.2.0
- Real-time collaboration
- Time tracking integration
- Calendar integration
- Slack/Discord notifications
- Template marketplace
- Mobile app project templates
- Docker/Kubernetes templates
- Security audit checklist

## Version History

- **1.0.0** (2026-01-26) - Initial release

---

For detailed changes, see the [commit history](https://github.com/BekaChkhiro/claude-plan-plugin/commits/master).
