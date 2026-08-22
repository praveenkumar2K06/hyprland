#!/bin/bash

COLORS="$HOME/.config/gtk-4.0/colors.css"
GTK="$HOME/.config/gtk-4.0/gtk.css"

if [[ ! -f "$COLORS" ]]; then
    exit 1
fi

if [[ ! -e "$GTK" ]]; then
    exit 1
fi

GTK_REAL="$(realpath "$GTK")"
GTK_DIR="$(dirname "$GTK_REAL")"

LIBADWAITA="$GTK_DIR/libadwaita.css"
LIBADWAITA_TWEAKS="$GTK_DIR/libadwaita-tweaks.css"

LIBADWAITA_START=95
LIBADWAITA_END=139

LIBADWAITA_TWEAKS_START=1
LIBADWAITA_TWEAKS_END=2

LIBADWAITA_ACCENT_START=192
LIBADWAITA_ACCENT_END=192

LIBADWAITA_TWEAKS_ACCENT_START=4
LIBADWAITA_TWEAKS_ACCENT_END=4

accent_bg_color=$(
    grep -E '^@define-color[[:space:]]+accent_bg_color[[:space:]]+' "$COLORS" |
    sed -E 's/^@define-color[[:space:]]+accent_bg_color[[:space:]]+([^;]+);?$/\1/'
)

if [[ -z "$accent_bg_color" ]]; then
    exit 1
fi

process_file() {

    FILE="$1"

    COLOR_START="$2"
    COLOR_END="$3"

    ACCENT_START="$4"
    ACCENT_END="$5"

    [[ ! -f "$FILE" ]] && return

    while IFS= read -r line; do

        if [[ "$line" =~ ^@define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+(.+)$ ]]; then

            name="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            if sed -n "${COLOR_START},${COLOR_END}p" "$FILE" |
                grep -qE "^@define-color[[:space:]]+$name[[:space:]]+.*$"; then

                sed -i -E \
                    "${COLOR_START},${COLOR_END}s|^@define-color[[:space:]]+$name[[:space:]]+.*$|@define-color $name $value|" \
                    "$FILE"
            fi
        fi

    done < "$COLORS"

    if sed -n "${ACCENT_START},${ACCENT_END}p" "$FILE" |
        grep -qE '^[[:space:]]*--accent-custom[[:space:]]*:'; then

        sed -i -E \
            "${ACCENT_START},${ACCENT_END}s|(--accent-custom[[:space:]]*:[[:space:]]*)[^;]+(;)|\1${accent_bg_color}\2|" \
            "$FILE"
    fi
}

process_file \
    "$LIBADWAITA" \
    "$LIBADWAITA_START" \
    "$LIBADWAITA_END" \
    "$LIBADWAITA_ACCENT_START" \
    "$LIBADWAITA_ACCENT_END"

process_file \
    "$LIBADWAITA_TWEAKS" \
    "$LIBADWAITA_TWEAKS_START" \
    "$LIBADWAITA_TWEAKS_END" \
    "$LIBADWAITA_TWEAKS_ACCENT_START" \
    "$LIBADWAITA_TWEAKS_ACCENT_END"