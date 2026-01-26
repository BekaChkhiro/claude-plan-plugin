#!/bin/bash

# Plugin Validation Script
# Automated checks for plan-plugin

echo "🔍 Plan Plugin Validation"
echo "=========================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Test 1: Plugin Structure
echo "📁 Testing Plugin Structure..."
echo ""

if [ -f ".claude-plugin/plugin.json" ]; then
    pass "Plugin manifest exists"
else
    fail "Plugin manifest missing"
fi

# Check commands
for cmd in new update next export; do
    if [ -f "commands/$cmd/SKILL.md" ]; then
        pass "Command /$cmd exists"
    else
        fail "Command /$cmd missing"
    fi
done

# Check skills
for skill in analyze-codebase suggest-breakdown estimate-complexity; do
    if [ -f "skills/$skill/SKILL.md" ]; then
        pass "Skill $skill exists"
    else
        fail "Skill $skill missing"
    fi
done

# Check templates
for template in PROJECT_PLAN.template.md fullstack.template.md backend-api.template.md frontend-spa.template.md; do
    if [ -f "templates/$template" ]; then
        pass "Template $template exists"
    else
        fail "Template $template missing"
    fi
done

# Check documentation
for doc in README.md CHANGELOG.md CONTRIBUTING.md LICENSE VALIDATION.md; do
    if [ -f "$doc" ]; then
        pass "$doc exists"
    else
        fail "$doc missing"
    fi
done

echo ""

# Test 2: JSON Validation
echo "📝 Validating JSON Files..."
echo ""

if command -v python3 &> /dev/null; then
    if python3 -c "import json; json.load(open('.claude-plugin/plugin.json'))" 2>/dev/null; then
        pass "plugin.json is valid JSON"
    else
        fail "plugin.json is invalid JSON"
    fi
else
    warn "Python3 not found, skipping JSON validation"
fi

echo ""

# Test 3: Template Placeholders
echo "🔤 Checking Template Placeholders..."
echo ""

# Check templates have placeholders
if grep -r "{{" templates/ > /dev/null 2>&1; then
    pass "Templates contain placeholders"
else
    warn "No placeholders found in templates"
fi

# Check that documentation properly explains placeholders (not an error)
if grep -r "{{" commands/ skills/ > /dev/null 2>&1; then
    pass "Documentation includes placeholder examples"
fi

echo ""

# Test 4: Markdown Syntax
echo "📋 Validating Markdown Syntax..."
echo ""

# Check for common markdown issues
markdown_files=$(find . -name "*.md" -not -path "./.git/*")

todo_count=0
for file in $markdown_files; do
    # Check for broken reference-style links [text][]
    if grep -n "\[.*\]\[\]" "$file" > /dev/null 2>&1; then
        warn "Possible broken link in $file"
    fi

    # Check for actual TODO/FIXME markers (not in examples or documentation about TODOs)
    # Skip examples, templates, VALIDATION.md, PROJECT_PLAN.md as they're meant to have TODOs
    if [[ ! "$file" =~ (examples|templates|VALIDATION\.md|PROJECT_PLAN\.md) ]]; then
        if grep -n "TODO:\|FIXME:\|TBD:" "$file" 2>/dev/null | grep -v "// TODO" | grep -v "Found TODO" > /dev/null 2>&1; then
            warn "Found actual TODO/FIXME markers in $file"
            ((todo_count++))
        fi
    fi
done

if [ $todo_count -eq 0 ]; then
    pass "No unfinished TODO markers in code"
fi

pass "Markdown files checked"

echo ""

# Test 5: File Sizes
echo "📊 Checking File Sizes..."
echo ""

large_files=$(find . -type f -size +1M -not -path "./.git/*")
if [ -n "$large_files" ]; then
    warn "Large files found (>1MB):"
    echo "$large_files"
else
    pass "No unusually large files"
fi

echo ""

# Test 6: Line Endings
echo "🔚 Checking Line Endings..."
echo ""

if command -v file &> /dev/null; then
    crlf_files=$(find . -name "*.md" -o -name "*.json" | xargs file | grep CRLF || true)
    if [ -n "$crlf_files" ]; then
        warn "Files with CRLF line endings found (Windows-style)"
        echo "$crlf_files"
    else
        pass "All files use LF line endings"
    fi
else
    warn "file command not found, skipping line ending check"
fi

echo ""

# Test 7: Mermaid Diagrams
echo "🎨 Validating Mermaid Diagrams..."
echo ""

mermaid_count=$(grep -r "\`\`\`mermaid" templates/ examples/ 2>/dev/null | wc -l)
if [ "$mermaid_count" -gt 0 ]; then
    pass "Found $mermaid_count Mermaid diagrams"

    # Basic syntax check
    if grep -A 5 "\`\`\`mermaid" templates/*.md 2>/dev/null | grep -E "(graph|flowchart|sequenceDiagram)" > /dev/null 2>&1; then
        pass "Mermaid diagram types look valid"
    else
        warn "Mermaid diagrams may have syntax issues"
    fi
else
    warn "No Mermaid diagrams found in templates"
fi

echo ""

# Test 8: Plugin Metadata
echo "ℹ️  Checking Plugin Metadata..."
echo ""

if [ -f ".claude-plugin/plugin.json" ]; then
    plugin_name=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json')).get('name', 'N/A'))" 2>/dev/null || echo "N/A")
    plugin_version=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json')).get('version', 'N/A'))" 2>/dev/null || echo "N/A")

    if [ "$plugin_name" != "N/A" ]; then
        pass "Plugin name: $plugin_name"
    else
        fail "Plugin name not found"
    fi

    if [ "$plugin_version" != "N/A" ]; then
        pass "Plugin version: $plugin_version"
    else
        fail "Plugin version not found"
    fi
fi

echo ""

# Test 9: Git Status
echo "🔧 Checking Git Status..."
echo ""

if [ -d ".git" ]; then
    untracked=$(git status --porcelain | grep "^??" | wc -l)
    modified=$(git status --porcelain | grep "^ M\|^M " | wc -l)

    if [ "$untracked" -gt 0 ]; then
        warn "$untracked untracked files"
    fi

    if [ "$modified" -gt 0 ]; then
        warn "$modified modified files not committed"
    fi

    if [ "$untracked" -eq 0 ] && [ "$modified" -eq 0 ]; then
        pass "Git working directory clean"
    fi
else
    warn "Not a git repository"
fi

echo ""

# Summary
echo "=========================="
echo "📊 Validation Summary"
echo "=========================="
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✅ All checks passed! Plugin is ready.${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  All checks passed with warnings. Review before release.${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ Some checks failed. Fix issues before release.${NC}"
    exit 1
fi
