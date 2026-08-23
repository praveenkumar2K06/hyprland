#!/usr/bin/env bash

set -u

STATE_FILE="$HOME/.local/state/quickshell/user/generated/screenshare/apps.txt"
STATE_DIR="$(dirname "$STATE_FILE")"

mkdir -p "$STATE_DIR"

LAST_STATE=""

cleanup() {
    rm -f "${STATE_FILE}.tmp"
}

trap cleanup EXIT INT TERM

while true; do
    CURRENT_STATE="$(
        pw-dump 2>/dev/null |
            jq -r '
                .[]
                | select(
                    (
                        .info.props."media.class" == "Stream/Input/Video"
                        or
                        .info.props."media.role" == "Screen"
                    )
                    and
                    .info.state == "running"
                )
                | .info.props["node.name"]
            ' 2>/dev/null |
            paste -sd ', ' -
    )"

    CURRENT_STATE="${CURRENT_STATE:-NONE}"

    if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
        TMP_FILE="$(mktemp "${STATE_DIR}/apps.XXXXXX")"

        printf '%s\n' "$CURRENT_STATE" > "$TMP_FILE"
        mv -f "$TMP_FILE" "$STATE_FILE"

        LAST_STATE="$CURRENT_STATE"
    fi

    sleep 1.5
done