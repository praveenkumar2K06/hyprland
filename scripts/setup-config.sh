#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
cat <<EOF
Usage: ./scripts/setup-config.sh [OPTIONS]

Post-install configuration:
  - downloads extra fonts (Space Grotesk, Material Symbols Rounded)
  - creates media directories (~/Pictures/Wallpapers, ~/Pictures/Screenshots, ~/Videos)
  - enables system services (NetworkManager, bluetooth, power-profiles-daemon)
  - enables PipeWire user services
  - optionally sets fish as login shell

Options:
  -h, --help        Show this help

Environment:
  NOCONFIRM=1       Non-interactive mode (auto-confirm all prompts)
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

download_font() {
    local url="$1" dest_dir="$2" filename="$3"
    if dry_run; then
        info "[dry-run] Would download font: $filename"
        return 0
    fi
    mkdir -p "$dest_dir"
    [[ -s "$dest_dir/$filename" ]] && { ok "Font present: $filename"; return 0; }
    if curl -fsSL "$url" -o "$dest_dir/$filename"; then
        ok "Downloaded font: $filename"
    else
        warn "Failed to download font: $filename"
    fi
}

install_fonts() {
    local fontdir="$HOME/.local/share/fonts/manual"
    info "Fetching extra fonts into $fontdir..."

    if fc-list 2>/dev/null | grep -qi "Material Symbols Rounded"; then
        ok "Material Symbols Rounded present."
    else
        download_font \
            "https://raw.githubusercontent.com/google/material-design-icons/e083cc60a0828fdd3b404cea0cb8a5b900e9c23e/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" \
            "$fontdir" "MaterialSymbolsRounded.ttf"
    fi

    if fc-list 2>/dev/null | grep -qi "space grotesk"; then
        ok "Space Grotesk present."
    else
        download_font \
            "https://raw.githubusercontent.com/google/fonts/2861cb7b12f90c0a294a12ed666e381e2211872f/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf" \
            "$fontdir" "SpaceGrotesk.ttf"
    fi

    fc-cache -f &>/dev/null || true
}

create_dirs() {
    if dry_run; then
        info "[dry-run] Would create ~/Pictures/Wallpapers ~/Pictures/Screenshots ~/Videos"
        return 0
    fi
    mkdir -p ~/Pictures/Wallpapers ~/Pictures/Screenshots ~/Videos
    ok "Ensured media directories exist."
}

enable_services() {
    local svc
    if dry_run; then
        info "[dry-run] Would enable --now: NetworkManager bluetooth power-profiles-daemon ydotoold"
        info "[dry-run] Would enable user services: pipewire pipewire-pulse wireplumber"
        return 0
    fi

    require_sudo

    info "Enabling system services..."
    for svc in NetworkManager bluetooth power-profiles-daemon ydotoold; do
        # systemctl cat is a more reliable existence check than list-unit-files,
        # which can exit 0 with no matches on some systemd versions.
        if systemctl cat "${svc}.service" &>/dev/null; then
            if sudo systemctl enable --now "$svc"; then
                ok "Enabled $svc"
            else
                warn "Could not enable $svc"
            fi
        else
            warn "Service not found: $svc"
        fi
    done

    info "Enabling user audio services..."
    if systemctl --user enable --now pipewire pipewire-pulse wireplumber; then
        ok "PipeWire stack enabled."
    else
        warn "Could not enable PipeWire user services."
    fi
}

setup_user_shell() {
    local fish_path
    fish_path="$(command -v fish)" || { warn "fish is not installed, skipping shell setup."; return 0; }

    if dry_run; then
        info "[dry-run] Would offer to set fish ($fish_path) as login shell."
        return 0
    fi

    grep -qx "$fish_path" /etc/shells 2>/dev/null \
        || printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null

    if [[ "${SHELL:-}" == "$fish_path" ]]; then
        ok "Fish is already the login shell."
        return 0
    fi
    if ask "Set fish as your default login shell?"; then
        chsh -s "$fish_path" && ok "Default shell set to fish."
    fi
}

print_summary() {
    cat <<EOF

${C_GREEN}==================== Done ====================${C_RESET}

Next steps:
  1. Reboot (or log out), then start Hyprland from a TTY:   Hyprland
  2. On first launch Quickshell creates ~/.config/illogical-impulse/config.json
  3. Put wallpapers in ~/Pictures/Wallpapers and press SUPER+CTRL+T to pick one.
  4. Optional extras (not auto-installed): ollama, dunst/mako
     NOTE: remove dunst/mako if you rely on Quickshell's notification daemon.

Existing configs were backed up alongside their targets with a '.${BACKUP_SUFFIX}' suffix
(the previous backup is replaced on each run, so it always holds the last version).
EOF
}

main() {
    create_dirs
    install_fonts
    enable_services
    setup_user_shell
    print_summary
}

main
