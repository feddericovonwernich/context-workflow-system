#!/usr/bin/env bash
#
# Context Workflow System Installer
# Installs the workflow system into any repository's .claude/ directory
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/feddericovonwernich/context-workflow-system/main/install.sh | bash
#   ./install.sh [OPTIONS]
#
# Options:
#   --force     Overwrite existing files without creating backups
#   --dry-run   Show what would be done without making changes
#   --branch    Specify branch to install from (default: main)
#   --help      Show this help message

set -euo pipefail

# Configuration
REPO_URL="https://github.com/feddericovonwernich/context-workflow-system"
DEFAULT_BRANCH="main"

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# Defaults
FORCE=false
DRY_RUN=false
BRANCH="$DEFAULT_BRANCH"

# Counters
INSTALLED=0
UPDATED=0
SKIPPED=0

# Files to install (relative to .claude/)
WORKFLOW_FILES=(
    "agents/workflow/phase-executor.md"
    "agents/workflow/workflow-creator.md"
    "agents/workflow/workflow-validator.md"
    "commands/create-workflow.md"
    "commands/run-workflow.md"
    "commands/validate-workflow.md"
    "docs/INTRODUCTION.md"
    "docs/REFERENCE.md"
    "docs/SPECIFICATION.md"
    "schemas/phase-metadata-schema.yaml"
    "schemas/workflow-schema.yaml"
    "templates/phase-template.md"
)

# Print functions
info() { echo -e "${BLUE}INFO${NC} $1"; }
success() { echo -e "${GREEN}SUCCESS${NC} $1"; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }
error() { echo -e "${RED}ERROR${NC} $1" >&2; }
step() { echo -e "${BOLD}==>${NC} $1"; }

usage() {
    cat << EOF
${BOLD}Context Workflow System Installer${NC}

Installs the Context Workflow System into your repository's .claude/ directory.

${BOLD}USAGE${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS${NC}
    --force       Overwrite existing files without creating backups
    --dry-run     Show what would be done without making changes
    --branch NAME Specify branch to install from (default: main)
    --help        Show this help message

${BOLD}EXAMPLES${NC}
    # Install from main branch
    ./install.sh

    # Install from a specific branch
    ./install.sh --branch develop

    # Preview changes without installing
    ./install.sh --dry-run

    # Force overwrite without backups
    ./install.sh --force

${BOLD}ONE-LINER INSTALL${NC}
    curl -sSL https://raw.githubusercontent.com/feddericovonwernich/context-workflow-system/main/install.sh | bash

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check for required tools
check_requirements() {
    local missing=()

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl or wget")
    fi

    if ! command -v tar &> /dev/null; then
        missing+=("tar")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

# Download file using curl or wget
download() {
    local url="$1"
    local output="$2"

    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$output"
    else
        wget -q "$url" -O "$output"
    fi
}

# Create backup of existing file
backup_file() {
    local file="$1"
    local backup_dir=".claude/backups/$(date +%Y%m%d_%H%M%S)"
    local relative_path="${file#.claude/}"
    local backup_path="$backup_dir/$relative_path"

    if $DRY_RUN; then
        info "Would backup: $file -> $backup_path"
        return 0
    fi

    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"
    info "Backed up: $file -> $backup_path"
}

# Install a single file
install_file() {
    local source="$1"
    local target="$2"

    # Create target directory
    local target_dir
    target_dir=$(dirname "$target")

    if $DRY_RUN; then
        if [[ ! -d "$target_dir" ]]; then
            info "Would create directory: $target_dir"
      fi
    else
        mkdir -p "$target_dir"
    fi

    # Handle existing file
    if [[ -f "$target" ]]; then
        if $FORCE; then
            if $DRY_RUN; then
                info "Would overwrite: $target (--force)"
            else
                cp "$source" "$target"
                info "Overwrote: $target"
            fi
            ((++UPDATED))
        else
            backup_file "$target"
            if $DRY_RUN; then
                info "Would update: $target"
            else
                cp "$source" "$target"
                info "Updated: $target"
            fi
            ((++UPDATED))
        fi
    else
        if $DRY_RUN; then
            info "Would install: $target"
        else
            cp "$source" "$target"
            success "Installed: $target"
        fi
        ((++INSTALLED))
    fi
}

main() {
    echo ""
    echo -e "${BOLD}Context Workflow System Installer${NC}"
    echo ""

    # Check requirements
    check_requirements

    # Warn if not in a git repo (but continue anyway)
    if [[ ! -d ".git" ]]; then
        warn "Current directory is not a git repository"
        warn "Installing anyway - make sure you're in the right directory"
        echo ""
    fi

    if $DRY_RUN; then
        echo -e "${YELLOW}DRY RUN MODE${NC} - No changes will be made"
        echo ""
    fi

    step "Downloading workflow system from $REPO_URL (branch: $BRANCH)"

    # Create temp directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT

    # Download tarball
    local tarball="$tmp_dir/workflow-system.tar.gz"
    local extract_dir="$tmp_dir/extracted"

    if ! download "$REPO_URL/archive/refs/heads/$BRANCH.tar.gz" "$tarball"; then
        error "Failed to download from $REPO_URL"
        error "Check your internet connection and verify the branch '$BRANCH' exists"
        exit 1
    fi

    # Extract tarball
    mkdir -p "$extract_dir"
    tar -xzf "$tarball" -C "$extract_dir"

    # Find the extracted directory (it's named context-workflow-system-<branch>)
    local source_dir
    source_dir=$(find "$extract_dir" -maxdepth 1 -type d -name "context-workflow-system-*" | head -n1)

    if [[ -z "$source_dir" ]]; then
        error "Failed to extract workflow system files"
        exit 1
    fi

    step "Installing workflow system files"
    echo ""

    # Install each file
    for file in "${WORKFLOW_FILES[@]}"; do
        local source_file="$source_dir/.claude/$file"
        local target_file=".claude/$file"

        if [[ -f "$source_file" ]]; then
            install_file "$source_file" "$target_file"
        else
            warn "Source file not found: $file"
            ((++SKIPPED))
        fi
    done

    echo ""
    step "Installation complete"
    echo ""
    echo -e "  ${GREEN}Installed:${NC} $INSTALLED files"
    echo -e "  ${BLUE}Updated:${NC}   $UPDATED files"
    if [[ $SKIPPED -gt 0 ]]; then
        echo -e "  ${YELLOW}Skipped:${NC}   $SKIPPED files"
    fi
    echo ""

    if $DRY_RUN; then
        echo -e "${YELLOW}This was a dry run. Run without --dry-run to apply changes.${NC}"
        echo ""
    else
        echo "The Context Workflow System is now installed!"
        echo ""
        echo "Available commands:"
        echo "  /create-workflow   Generate workflows from input files"
        echo "  /run-workflow      Execute multi-phase workflows"
        echo "  /validate-workflow Validate workflow structure"
        echo ""
        echo "Documentation: .claude/docs/INTRODUCTION.md"
        echo ""
    fi
}

main
