#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
cat <<EOF
Usage: ./scripts/link-dotfiles.sh [OPTIONS]

Symlinks everything under configs/ into \$HOME/.config (directories and
single files like starship.toml alike).

Existing files are backed up to '<target>.${BACKUP_SUFFIX}' before linking.
The previous '.${BACKUP_SUFFIX}' copy is replaced on each run, so at most one
rolling backup per target is kept.

Environment:
  DRY_RUN=1         Print planned actions without changing anything
EOF
exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)      usage ;;
        *) die "Unknown option: $1 (use --help)" ;;
    esac
done

link_path() {
    local src="$1" dest="$2"
    if [[ ! -e "$src" && ! -L "$src" ]]; then
        warn "Missing source: $src"
        return 1
    fi
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        ok "Already linked: $dest"
        return 0
    fi
    if dry_run; then
        info "[dry-run] Would link: $dest -> $src"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="${dest}.${BACKUP_SUFFIX}"
        rm -rf "$backup"
        mv "$dest" "$backup"
        warn "Backed up existing '$dest' -> '$backup'"
    fi
    ln -sfn "$src" "$dest"
    ok "Linked $dest -> $src"
}

deploy_configs() {
    info "Deploying configs to \$HOME/.config ..."
    local target="$HOME/.config"

    local entry name
    for entry in "$REPO_DIR"/configs/*; do
        [[ -e "$entry" ]] || continue
        name="$(basename "$entry")"
        link_path "$entry" "$target/$name"
    done

    if dry_run; then
        info "[dry-run] Would chmod +x all *.sh / *.py under configs/"
        return 0
    fi
    find "$REPO_DIR/configs" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
    ok "Made scripts executable."
}

main() {
    deploy_configs
    ok "Dotfiles linked."
}

main
