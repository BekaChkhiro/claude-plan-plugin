#!/bin/bash

# Plan Plugin Installation Script for Claude Code
# Creates symlinks to ~/.claude/commands/ for global access

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}   PlanFlow Plugin Installation Script v1.5.1  ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    echo "Please install git first"
    exit 1
fi

# Determine installation directory
INSTALL_DIR="$HOME/.local/share/claude-plan-plugin"
COMMANDS_DIR="$HOME/.claude/commands"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$COMMANDS_DIR"

echo -e "${YELLOW}Installation directory: ${INSTALL_DIR}${NC}"
echo -e "${YELLOW}Commands directory: ${COMMANDS_DIR}${NC}"
echo ""

# Check if already installed
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${YELLOW}Plugin already installed. Updating...${NC}"
    cd "$INSTALL_DIR"
    git pull origin master
    echo -e "${GREEN}✓ Plugin updated!${NC}"
else
    # Fresh installation
    echo -e "${BLUE}Cloning plugin repository...${NC}"
    rm -rf "$INSTALL_DIR"
    git clone https://github.com/BekaChkhiro/claude-plan-plugin.git "$INSTALL_DIR"
    echo -e "${GREEN}✓ Plugin cloned!${NC}"
fi

echo ""
echo -e "${BLUE}Creating command symlinks...${NC}"

# List of commands to link
COMMANDS=(
    "planNew"
    "planNext"
    "planUpdate"
    "planSpec"
    "planExportJson"
    "planExportCsv"
    "planExportGithub"
    "planExportSummary"
    "planSettingsShow"
    "planSettingsReset"
    "planSettingsLanguage"
    "planSettingsAutoSync"
    "pfLogin"
    "pfLogout"
    "pfWhoami"
    "pfSyncPush"
    "pfSyncPull"
    "pfSyncStatus"
    "pfCloudNew"
    "pfCloudList"
    "pfCloudLink"
    "pfCloudUnlink"
    "pfTeamInvite"
    "pfTeamList"
)

# Create symlinks
linked=0
for cmd in "${COMMANDS[@]}"; do
    source_path="$INSTALL_DIR/commands/$cmd"
    target_path="$COMMANDS_DIR/$cmd"

    if [ -d "$source_path" ]; then
        # Remove existing symlink or directory
        rm -rf "$target_path"
        # Create symlink
        ln -s "$source_path" "$target_path"
        echo -e "  ${GREEN}✓${NC} $cmd"
        ((linked++))
    fi
done

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}   Installation Complete! 🎉 ($linked commands)  ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Getting Started:${NC}"
echo ""
echo "  1. Start Claude Code in any project:"
echo -e "     ${YELLOW}claude${NC}"
echo ""
echo "  2. Create your first project plan:"
echo -e "     ${YELLOW}/planNew${NC}"
echo ""
echo "  3. Get next task recommendation:"
echo -e "     ${YELLOW}/planNext${NC}"
echo ""
echo -e "${BLUE}Cloud Sync Commands:${NC}"
echo ""
echo "  • /pfLogin          - Login to PlanFlow cloud"
echo "  • /pfSyncPush       - Push plan to cloud"
echo "  • /pfSyncPull       - Pull plan from cloud"
echo ""
echo -e "${BLUE}All Commands:${NC}"
echo ""
echo "  Planning:    /planNew, /planNext, /planUpdate, /planSpec"
echo "  Export:      /planExportJson, /planExportCsv, /planExportGithub"
echo "  Settings:    /planSettingsShow, /planSettingsLanguage"
echo "  Cloud:       /pfLogin, /pfSyncPush, /pfSyncPull, /pfCloudLink"
echo ""
echo -e "${BLUE}Documentation:${NC} https://github.com/BekaChkhiro/claude-plan-plugin"
echo -e "${BLUE}PlanFlow Web:${NC}  https://planflow.tools"
echo ""
