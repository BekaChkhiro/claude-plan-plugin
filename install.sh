#!/bin/bash

# Plan Plugin Installation Script
# Automatically installs claude-plan-plugin to Claude Code plugins directory

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   Plan Plugin Installation Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    echo "Please install git first: sudo apt install git"
    exit 1
fi

# Create plugins directory if it doesn't exist
PLUGINS_DIR="$HOME/.config/claude/plugins"
mkdir -p "$PLUGINS_DIR"

echo -e "${YELLOW}Installing to: ${PLUGINS_DIR}/plan${NC}"
echo ""

# Check if plugin already exists
if [ -d "$PLUGINS_DIR/plan" ]; then
    echo -e "${YELLOW}Plugin already exists. What would you like to do?${NC}"
    echo "1) Update existing installation"
    echo "2) Remove and reinstall"
    echo "3) Cancel"
    read -p "Enter choice [1-3]: " choice

    case $choice in
        1)
            echo -e "${BLUE}Updating plugin...${NC}"
            cd "$PLUGINS_DIR/plan"
            git pull origin master
            echo -e "${GREEN}✓ Plugin updated successfully!${NC}"
            ;;
        2)
            echo -e "${BLUE}Removing old installation...${NC}"
            rm -rf "$PLUGINS_DIR/plan"
            echo -e "${BLUE}Installing fresh copy...${NC}"
            git clone https://github.com/BekaChkhiro/claude-plan-plugin.git "$PLUGINS_DIR/plan"
            echo -e "${GREEN}✓ Plugin reinstalled successfully!${NC}"
            ;;
        3)
            echo "Installation cancelled."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
else
    # Fresh installation
    echo -e "${BLUE}Cloning plugin repository...${NC}"
    git clone https://github.com/BekaChkhiro/claude-plan-plugin.git "$PLUGINS_DIR/plan"
    echo -e "${GREEN}✓ Plugin cloned successfully!${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}   Installation Complete! 🎉${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Start Claude Code:"
echo "   ${YELLOW}claude${NC}"
echo ""
echo "2. Create your first project plan:"
echo "   ${YELLOW}/plan:new${NC}"
echo ""
echo "3. Get help:"
echo "   ${YELLOW}cat ~/.config/claude/plugins/plan/README.md${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo "  • /plan:new     - Create new project plan"
echo "  • /plan:next    - Get next task recommendation"
echo "  • /plan:update  - Update task status"
echo "  • /plan:export  - Export plan to various formats"
echo ""
echo -e "${BLUE}Documentation:${NC} https://github.com/BekaChkhiro/claude-plan-plugin"
echo ""
