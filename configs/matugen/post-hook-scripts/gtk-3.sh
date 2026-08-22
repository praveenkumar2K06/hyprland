#!/bin/bash

MODE="$1"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo "Invalid mode: $MODE"
    exit 1
fi

if [[ "$MODE" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi

COLORS="$HOME/.config/gtk-3.0/colors.css"
GTK="$HOME/.config/gtk-3.0/gtk.css"

if [[ ! -f "$COLORS" ]]; then
    exit 1
fi

if [[ ! -e "$GTK" ]]; then
    exit 1
fi

GTK_REAL="$(realpath "$GTK")"

if [[ ! -f "$GTK_REAL" ]]; then
    exit 1
fi

while IFS= read -r line; do

    if [[ "$line" =~ ^@define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+(.+)$ ]]; then

        name="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"

        if grep -qE "^@define-color[[:space:]]+$name[[:space:]]+.*$" "$GTK_REAL"; then

            sed -i -E \
                "s|^@define-color[[:space:]]+$name[[:space:]]+.*$|@define-color $name $value|" \
                "$GTK_REAL"
        fi
    fi

done < "$COLORS"