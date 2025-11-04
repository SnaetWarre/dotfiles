#!/usr/bin/env bash
# ============================================================================
# Stow Dotfiles Deployment Script
# ============================================================================
# This script helps deploy home directory dotfiles using GNU Stow
# Run from anywhere - it will automatically find the .config directory

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Find the .config directory (this script's location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

echo -e "${BLUE}🔗 Dotfiles Stow Helper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if stow is installed
if ! command -v stow &>/dev/null; then
    echo -e "${RED}❌ GNU Stow is not installed!${NC}"
    echo ""
    echo "Install it with:"
    echo "  • Arch/Manjaro/CachyOS: sudo pacman -S stow"
    echo "  • Ubuntu/Debian: sudo apt install stow"
    echo "  • Fedora: sudo dnf install stow"
    echo "  • macOS: brew install stow"
    exit 1
fi

echo -e "${GREEN}✅ GNU Stow found${NC}"
echo ""

# Function to show usage
show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy    - Deploy dotfiles (create symlinks)"
    echo "  remove    - Remove dotfiles (delete symlinks)"
    echo "  restow    - Re-deploy dotfiles (useful after updates)"
    echo "  check     - Check what would happen (dry-run)"
    echo "  status    - Show current symlink status"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy   # Deploy all dotfiles"
    echo "  $0 check    # See what would be deployed"
    echo "  $0 remove   # Remove all symlinks"
    echo ""
}

# Function to check if file is a symlink pointing to our repo
is_our_symlink() {
    local file=$1
    if [[ -L "$file" ]]; then
        local target=$(readlink "$file")
        if [[ "$target" == *"/.config/home/"* ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Current Symlink Status${NC}"
    echo ""

    local files=(
        ".zshrc"
        ".zshenv"
        ".zprofile"
        ".p10k.zsh"
        ".gitconfig"
        ".fonts.conf"
    )

    for file in "${files[@]}"; do
        local path="$HOME/$file"
        if [[ -L "$path" ]]; then
            local target=$(readlink "$path")
            if [[ "$target" == *"/.config/home/"* ]]; then
                echo -e "  ${GREEN}✓${NC} $file → (stowed)"
            else
                echo -e "  ${YELLOW}⚠${NC} $file → (symlink to other location)"
            fi
        elif [[ -e "$path" ]]; then
            echo -e "  ${YELLOW}!${NC} $file (regular file, not stowed)"
        else
            echo -e "  ${RED}✗${NC} $file (not found)"
        fi
    done
    echo ""
}

# Function to deploy dotfiles
deploy_dotfiles() {
    echo -e "${BLUE}📦 Deploying dotfiles...${NC}"
    echo ""

    # Check for conflicts
    local has_conflicts=false
    local files=(
        ".zshrc"
        ".zshenv"
        ".zprofile"
        ".p10k.zsh"
        ".gitconfig"
        ".fonts.conf"
    )

    for file in "${files[@]}"; do
        local path="$HOME/$file"
        if [[ -e "$path" ]] && ! is_our_symlink "$path"; then
            echo -e "  ${YELLOW}⚠${NC}  Conflict: $file already exists"
            has_conflicts=true
        fi
    done

    if [[ "$has_conflicts" == true ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  Some files already exist!${NC}"
        echo ""
        echo "Options:"
        echo "  1. Backup existing files (recommended)"
        echo "  2. Overwrite (will lose existing files)"
        echo "  3. Cancel"
        echo ""
        read -p "Choose [1/2/3]: " choice

        case $choice in
            1)
                echo ""
                echo -e "${BLUE}📦 Backing up existing files...${NC}"
                local backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
                mkdir -p "$backup_dir"

                for file in "${files[@]}"; do
                    local path="$HOME/$file"
                    if [[ -e "$path" ]] && ! is_our_symlink "$path"; then
                        echo "  Backing up: $file"
                        mv "$path" "$backup_dir/"
                    fi
                done

                echo -e "${GREEN}✅ Backup saved to: $backup_dir${NC}"
                echo ""
                ;;
            2)
                echo ""
                echo -e "${YELLOW}⚠️  Removing existing files...${NC}"
                for file in "${files[@]}"; do
                    local path="$HOME/$file"
                    if [[ -e "$path" ]] && ! is_our_symlink "$path"; then
                        rm -f "$path"
                    fi
                done
                ;;
            *)
                echo ""
                echo -e "${RED}❌ Cancelled${NC}"
                exit 0
                ;;
        esac
    fi

    echo -e "${BLUE}🔗 Creating symlinks...${NC}"
    cd "$CONFIG_DIR"
    stow -v -t "$HOME" home 2>&1 | grep -E "(LINK|UNLINK|MKDIR)" || true

    echo ""
    echo -e "${GREEN}✅ Dotfiles deployed successfully!${NC}"
    echo ""
    echo "Your files are now symlinked:"
    show_status
}

# Function to remove dotfiles
remove_dotfiles() {
    echo -e "${BLUE}🗑️  Removing dotfiles...${NC}"
    echo ""

    cd "$CONFIG_DIR"
    stow -D -v -t "$HOME" home 2>&1 | grep -E "(UNLINK)" || true

    echo ""
    echo -e "${GREEN}✅ Symlinks removed${NC}"
    echo ""
}

# Function to restow dotfiles
restow_dotfiles() {
    echo -e "${BLUE}🔄 Re-deploying dotfiles...${NC}"
    echo ""

    cd "$CONFIG_DIR"
    stow -R -v -t "$HOME" home 2>&1 | grep -E "(LINK|UNLINK|MKDIR)" || true

    echo ""
    echo -e "${GREEN}✅ Dotfiles re-deployed${NC}"
    echo ""
}

# Function to check (dry-run)
check_dotfiles() {
    echo -e "${BLUE}🔍 Checking what would happen (dry-run)...${NC}"
    echo ""

    cd "$CONFIG_DIR"
    stow -n -v -t "$HOME" home

    echo ""
    echo -e "${YELLOW}ℹ️  This was a dry-run. No changes were made.${NC}"
    echo ""
}

# Main logic
case "${1:-help}" in
    deploy)
        deploy_dotfiles
        ;;
    remove)
        remove_dotfiles
        ;;
    restow)
        restow_dotfiles
        ;;
    check)
        check_dotfiles
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
