#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

TMPDIRS=()

usage() {
cat <<EOF
Usage: ./scripts/deps.sh [OPTIONS]

Installs all required packages for this Hyprland + Quickshell setup:
official repo packages, AUR packages, awww (wallpaper daemon) and an AUR helper.

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

OFFICIAL_PKGS=(
    base-devel git curl wget unzip
    hyprland hyprlock hypridle hyprsunset
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    quickshell qt6-5compat qt6-multimedia qt6-positioning qt6-sensors
    qt6-virtualkeyboard qt6-imageformats kirigami kdialog syntax-highlighting
    kitty fish starship lua python
    grim slurp wf-recorder wl-clipboard cliphist wtype
    hyprpicker
    pipewire wireplumber pamixer playerctl brightnessctl libpulse pavucontrol
    jq ffmpeg imagemagick zenity libnotify fuzzel cava
    ydotool lm_sensors file xdg-utils
    nautilus
    networkmanager network-manager-applet nm-connection-editor
    bluez bluez-utils
    power-profiles-daemon upower
    adw-gtk-theme bibata-cursor-theme qt5ct qt6ct
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-dejavu
)

AUR_PKGS=(
    matugen
    ttf-material-symbols-rounded-git
    zen-browser-bin
    cloudflare-warp-bin
)

cleanup_tmpdirs() {
    local d
    for d in "${TMPDIRS[@]}"; do
        rm -rf "$d"
    done
}
trap cleanup_tmpdirs EXIT

new_tmpdir() {
    local tmpdir
    tmpdir="$(mktemp -d)"
    TMPDIRS+=("$tmpdir")
    printf '%s' "$tmpdir"
}

install_aur_helper() {
    if command -v paru &>/dev/null; then
        AUR_HELPER="paru"; ok "Using AUR helper: paru"; return 0
    fi
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"; ok "Using AUR helper: yay"; return 0
    fi

    info "No AUR helper found. Installing paru..."
    local tmpdir
    tmpdir="$(new_tmpdir)"
    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (
        cd "$tmpdir/paru"
        makepkg -sf --noconfirm
        sudo pacman -U --noconfirm ./*.pkg.tar.zst
    )

    command -v paru &>/dev/null || die "Failed to install paru."
    AUR_HELPER="paru"; ok "Installed paru."
}

install_official_packages() {
    info "Installing official repository packages..."
    sudo pacman -Syu "${CONFIRM_FLAGS[@]}" --needed -- "${OFFICIAL_PKGS[@]}"
    ok "Official packages installed."
}

install_aur_packages() {
    info "Installing AUR packages (official-repo hits are installed via pacman)..."
    local remaining=()
    local pkg
    for pkg in "${AUR_PKGS[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            info "'$pkg' is now in official repos, using pacman."
            sudo pacman -S "${CONFIRM_FLAGS[@]}" --needed -- "$pkg"
        else
            remaining+=("$pkg")
        fi
    done
    if ((${#remaining[@]})); then
        "$AUR_HELPER" -S "${CONFIRM_FLAGS[@]}" --needed --removemake -- "${remaining[@]}"
    fi
    ok "AUR packages done."
}

install_awww() {
    command -v awww-daemon &>/dev/null && { ok "awww already installed."; return 0; }

    info "Trying to install awww (wallpaper daemon) from AUR..."
    if "$AUR_HELPER" -S "${CONFIRM_FLAGS[@]}" --needed --removemake awww; then
        ok "awww installed."
        return 0
    fi

    warn "AUR 'awww' unavailable. Building from end-4/awww (illogical-impulse swww fork)..."
    local tmpdir
    tmpdir="$(new_tmpdir)"
    local built=false
    if git clone --depth 1 https://github.com/end-4/awww.git "$tmpdir/awww"; then
        if (
            cd "$tmpdir/awww" &&
            makepkg -sf --noconfirm &&
            sudo pacman -U --noconfirm ./*.pkg.tar.zst
        ); then
            built=true
        fi
    fi
    if $built; then
        ok "awww built and installed."
    else
        warn "Could not install awww automatically. Install it manually or swap autostart.lua to 'swww-daemon' after installing swww."
    fi
}

main() {
    if dry_run; then
        info "[dry-run] Would install official packages: ${OFFICIAL_PKGS[*]}"
        info "[dry-run] Would ensure an AUR helper exists (paru/yay), building paru from AUR if missing."
        info "[dry-run] Would install AUR packages: ${AUR_PKGS[*]}"
        info "[dry-run] Would install awww (via AUR, falling back to building end-4/awww)."
        ok "Dry-run complete: no packages were touched."
        return 0
    fi

    require_sudo
    check_arch

    # Official packages go first so git/base-devel/curl exist before any
    # AUR package needs to be cloned and built.
    info "[1/4] Official packages"
    install_official_packages

    info "[2/4] AUR helper"
    install_aur_helper

    info "[3/4] AUR packages"
    install_aur_packages

    info "[4/4] awww wallpaper daemon"
    install_awww

    ok "All dependencies installed."
}

main
