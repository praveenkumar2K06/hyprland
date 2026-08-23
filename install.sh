#!/usr/bin/env bash
set -Eeuo pipefail

# Keep console colors when teeing output to a log file (tee pipes stdout).
[[ -t 1 || -t 2 ]] && export FORCE_COLOR=1
export LOG_FILE="${LOG_FILE:-/tmp/install.log}"
exec > >(tee "$LOG_FILE") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"

SKIP_DEPS=false
SKIP_LINK=false
SKIP_SETUP=false

usage() {
cat <<EOF
Usage: ./install.sh [OPTIONS]

Runs the full setup for this Hyprland + Quickshell dotfiles repo:
   1. scripts/deps.sh          - install dependencies (packages, AUR, awww)
   2. scripts/link-dotfiles.sh - symlink configs into ~/.config
   3. scripts/setup-config.sh  - fonts, services, dirs, default shell

Options:
  -y, --noconfirm     Run non-interactively (auto-confirm all prompts)
  --skip-deps         Do not run deps.sh (packages / AUR / awww)
  --skip-link         Do not run link-dotfiles.sh
  --skip-setup        Do not run setup-config.sh (fonts, services, shell)
  --only STEPS        Comma-separated subset of: deps,link,setup
  --dry-run           Print planned actions without changing anything
  -h, --help          Show this help

Full output is logged to $LOG_FILE
EOF
exit 0
}

select_steps() {
    # $1 = --only, $2 = comma/space-separated step list; only these run.
    SKIP_DEPS=true SKIP_LINK=true SKIP_SETUP=true
    local steps
    IFS=', ' read -ra steps <<< "$2"
    local step
    for step in "${steps[@]}"; do
        case "$step" in
            deps)  SKIP_DEPS=false ;;
            link)  SKIP_LINK=false ;;
            setup) SKIP_SETUP=false ;;
            *) die "Unknown step '$step' in --only (valid: deps,link,setup)" ;;
        esac
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--noconfirm) export NOCONFIRM="--noconfirm"; shift ;;
        --skip-deps)    SKIP_DEPS=true; shift ;;
        --skip-link)    SKIP_LINK=true; shift ;;
        --skip-setup)   SKIP_SETUP=true; shift ;;
        --only)         [[ $# -ge 2 ]] || die "--only requires an argument"; select_steps "$@"; shift 2 ;;
        --dry-run)      export DRY_RUN=true; shift ;;
        -h|--help)      usage ;;
        *) die "Unknown option: $1 (use --help)" ;;
    esac
done

main() {
    info "Hyprland dotfiles installer"
    info "Repo: $REPO_DIR"
    if dry_run; then
        warn "Dry-run mode: no changes will be made."
    fi

    if $SKIP_DEPS; then
        warn "Skipping dependency install (--skip-deps)."
    else
        bash "$SCRIPT_DIR/scripts/deps.sh"
    fi

    if $SKIP_LINK; then
        warn "Skipping config linking (--skip-link)."
    else
        bash "$SCRIPT_DIR/scripts/link-dotfiles.sh"
    fi

    if $SKIP_SETUP; then
        warn "Skipping config setup (--skip-setup)."
    else
        bash "$SCRIPT_DIR/scripts/setup-config.sh"
    fi

    ok "All done."
}

main
