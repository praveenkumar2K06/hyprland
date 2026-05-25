#!/usr/bin/env bash
set -euo pipefail

readonly WALL_DIR="$HOME/Pictures/Wallpapers"
readonly CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"

MODE="dark"
CHANGE_SDDM=false
PICK_RANDOM=false

get_config() {
    jq -r "$1" "$CONFIG_FILE"
}

set_config() {
    local key="$1"
    local value="$2"

    tmp="$(mktemp)"
    jq --arg v "$value" "$key = \$v" "$CONFIG_FILE" > "$tmp"
    mv "$tmp" "$CONFIG_FILE"
}

CURRENT_WALL="$(get_config '.background.wallpaperPath')"
SCHEME="$(get_config '.appearance.palette.type')"

show_help() {
cat <<EOF
Usage:
  wallpaper.sh [OPTIONS]

Options:
  --pick              Open wallpaper picker
  --random            Pick random wallpaper
  --wall PATH         Set wallpaper directly
  --dark              Apply dark theme
  --light             Apply light theme
  --sddm              Also update SDDM background
  --help              Show help
EOF
}

pick_wallpaper() {
    zenity --file-selection \
        --title="Choose Wallpaper" \
        --filename="$WALL_DIR/" \
        --file-filter="Images | *.png *.jpg *.jpeg *.webp"
}

random_wallpaper() {
    find "$WALL_DIR" \
        -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) |
        shuf -n 1
}

set_gtk_theme() {
    local theme

    if [[ "$MODE" == "dark" ]]; then
        theme="Colloid-Dark-Nord"

        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    else
        theme="Colloid-Light-Nord"

        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    fi

    gsettings set org.gnome.desktop.interface gtk-theme "$theme"
}

update_sddm_background() {
    local wall="$1"

    local sddm_bg="/usr/share/sddm/themes/pixie/assets/background.jpg"
    local sddm_theme="/usr/share/sddm/themes/pixie/theme.conf"

    local tmp_bg
    tmp_bg="$(mktemp --suffix=.jpg)"

    trap 'rm -f "$tmp_bg"' RETURN

    ffmpeg -y -loglevel error \
        -i "$wall" \
        -q:v 2 \
        "$tmp_bg"

    pkexec bash -c '
        install -Dm644 "$1" "$2"
        sed -i "s|^background=.*|background=assets/background.jpg|" "$3"
    ' _ "$tmp_bg" "$sddm_bg" "$sddm_theme"
}

apply_wallpaper() {
    local wall="$1"

    [[ -f "$wall" ]] || {
        notify-send "Wallpaper Error" "File not found"
        exit 1
    }

    wall="$(realpath "$wall")"

    notify-send "Applying Wallpaper" "$(basename "$wall")"

    if [[ "$CHANGE_SDDM" == true ]]; then
        update_sddm_background "$wall"
    fi

    set_config '.background.wallpaperPath' "$wall"

    set_gtk_theme

    awww img \
        --transition-type center \
        "$wall"

    local effect="${SCHEME:-scheme-tonal-spot}"

    [[ "$effect" == "auto" ]] && effect="scheme-tonal-spot"

    matugen image \
        "$wall" \
        --mode "$MODE" \
        --type "$effect" \
        --source-color-index 0

    notify-send \
        "Wallpaper Applied" \
        "$(basename "$wall") [$MODE]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pick)
            CURRENT_WALL="$(pick_wallpaper)"
            CHANGE_SDDM=true
            shift
            ;;

        --random)
            PICK_RANDOM=true
            CHANGE_SDDM=true
            shift
            ;;

        --wall)
            CURRENT_WALL="$2"
            CHANGE_SDDM=true
            shift 2
            ;;

        --dark)
            MODE="dark"
            shift
            ;;

        --light)
            MODE="light"
            shift
            ;;

        --help)
            show_help
            exit 0
            ;;

        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$PICK_RANDOM" == true ]]; then
    CURRENT_WALL="$(random_wallpaper)"
fi

if [[ -z "${CURRENT_WALL:-}" ]]; then
    echo "No wallpaper selected"
    exit 1
fi

apply_wallpaper "$CURRENT_WALL"