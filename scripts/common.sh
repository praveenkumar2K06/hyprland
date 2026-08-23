#!/usr/bin/env bash
# shellcheck shell=bash

# Shared helpers. Sourced by install.sh and scripts/*.sh.

# Used by sourcing scripts (install.sh, deps.sh, link-dotfiles.sh).
# shellcheck disable=SC2034
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Rolling backup suffix; referenced in usage/summary text of sub-scripts.
# shellcheck disable=SC2034
BACKUP_SUFFIX="bak"

DRY_RUN="${DRY_RUN:-false}"
NOCONFIRM="${NOCONFIRM:-}"
# Pacman/AUR flag expansion; used by deps.sh.
# shellcheck disable=SC2034
CONFIRM_FLAGS=()
[[ -n "$NOCONFIRM" ]] && CONFIRM_FLAGS=(--noconfirm)

dry_run() {
    case "${DRY_RUN:-}" in
        1|true|TRUE|yes|YES) return 0 ;;
        *)                   return 1 ;;
    esac
}

# Colors only when attached to a terminal, unless forced (e.g. when teeing to a log).
if [[ -z "${NO_COLOR:-}" && ( -t 1 || -n "${FORCE_COLOR:-}" ) ]]; then
    C_BLUE='\033[1;34m'
    C_GREEN='\033[1;32m'
    C_YELLOW='\033[1;33m'
    C_RED='\033[1;31m'
    C_RESET='\033[0m'
else
    C_BLUE='' C_GREEN='' C_YELLOW='' C_RED='' C_RESET=''
fi

info() { printf "${C_BLUE}:: ${C_RESET}%s\n" "$*"; }
ok()   { printf "${C_GREEN} ✔ ${C_RESET}%s\n" "$*"; }
warn() { printf "${C_YELLOW} ! ${C_RESET}%s\n" "$*"; }
die()  { printf "${C_RED} ✖ %s${C_RESET}\n" "$*" >&2; exit 1; }

trap 'die "Failed at line $LINENO"' ERR

ask() {
    local question="$1"
    if [[ -n "$NOCONFIRM" ]]; then
        info "$question [auto: yes]"
        return 0
    fi
    local reply
    read -rp "$(printf "${C_BLUE}? ${C_RESET}%s [y/N] " "$question")" reply
    [[ "$reply" =~ ^[Yy] ]]
}

require_sudo() {
    [[ $EUID -eq 0 ]] && die "Do not run as root. The script uses sudo where needed."
    command -v sudo &>/dev/null || die "sudo is required."
}

check_arch() {
    if ! grep -qiE '^(ID=arch|ID_LIKE=.*arch)' /etc/os-release 2>/dev/null; then
        warn "This script targets Arch Linux(-based) distros."
        ask "Continue anyway?" || die "Aborted."
    fi
}
