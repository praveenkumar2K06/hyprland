#!/usr/bin/env bash

set -u

CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"
STATE_FILE="$HOME/.local/state/quickshell/states.json"

JSON_PATH=".screenRecord.savePath"
STATE_JSON_PATH=".screenRecord.active"

DEFAULT_RECORDING_DIR="$HOME/Videos"

TIMER_PID=""
SECONDS_ELAPSED=0

# --------------------------------------------------
# Helpers
# --------------------------------------------------

get_date() {
    date '+%Y-%m-%d_%H.%M.%S'
}

get_recording_dir() {
    local path

    path=$(jq -r "$JSON_PATH // empty" "$CONFIG_FILE" 2>/dev/null)

    if [[ -n "$path" && "$path" != "null" ]]; then
        printf '%s\n' "$path"
    else
        printf '%s\n' "$DEFAULT_RECORDING_DIR"
    fi
}

get_active_monitor() {
    hyprctl monitors -j |
        jq -r '.[] | select(.focused == true) | .name'
}

get_audio_output() {
    pactl list short sources |
        awk '$2 ~ /\.monitor$/ { print $2; exit }'
}

update_state() {
    local active="$1"

    [[ -f "$STATE_FILE" ]] || return 1

    local tmp
    tmp=$(mktemp "${STATE_FILE}.XXXXXX") || return 1

    if jq --argjson value "$active" \
        "$STATE_JSON_PATH = \$value" \
        "$STATE_FILE" > "$tmp"; then

        mv "$tmp" "$STATE_FILE"
    else
        rm -f "$tmp"
        return 1
    fi
}

update_seconds() {
    local seconds="$1"

    [[ -f "$STATE_FILE" ]] || return 1

    local tmp
    tmp=$(mktemp "${STATE_FILE}.XXXXXX") || return 1

    if jq --argjson value "$seconds" \
        ".screenRecord.seconds = \$value" \
        "$STATE_FILE" > "$tmp"; then

        mv "$tmp" "$STATE_FILE"
    else
        rm -f "$tmp"
        return 1
    fi
}

# --------------------------------------------------
# Timer
# --------------------------------------------------

start_timer() {
    stop_timer

    SECONDS_ELAPSED=0
    update_seconds 0

    (
        elapsed=0

        while true; do
            sleep 1

            ((elapsed++))

            update_seconds "$elapsed"
        done
    ) &

    TIMER_PID=$!
}

stop_timer() {
    if [[ -n "$TIMER_PID" ]]; then
        kill "$TIMER_PID" 2>/dev/null || true
        wait "$TIMER_PID" 2>/dev/null || true
        TIMER_PID=""
    fi

    update_seconds 0
}

cleanup() {
    stop_timer
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# --------------------------------------------------
# Recording directory
# --------------------------------------------------

RECORDING_DIR="$(get_recording_dir)"

mkdir -p "$RECORDING_DIR" || {
    notify-send \
        "Recorder Error" \
        "Could not create recording directory" \
        -a "Recorder"

    exit 1
}

cd "$RECORDING_DIR" || exit 1

# --------------------------------------------------
# Arguments
# --------------------------------------------------

MANUAL_REGION=""
SOUND_FLAG=0
FULLSCREEN_FLAG=0

ARGS=("$@")

for ((i = 0; i < ${#ARGS[@]}; i++)); do

    case "${ARGS[i]}" in

        --region)
            if (( i + 1 < ${#ARGS[@]} )); then
                MANUAL_REGION="${ARGS[i + 1]}"
                ((i++))
            else
                notify-send \
                    "Recording cancelled" \
                    "No region specified for --region" \
                    -a "Recorder"

                update_state false
                exit 1
            fi
            ;;

        --sound)
            SOUND_FLAG=1
            ;;

        --fullscreen)
            FULLSCREEN_FLAG=1
            ;;

    esac

done

# --------------------------------------------------
# Stop existing recording
# --------------------------------------------------

if pgrep -x wf-recorder >/dev/null; then

    notify-send \
        "Recording Stopped" \
        "Recording stopped" \
        -a "Recorder"

    update_state false

    pkill -INT -x wf-recorder

    # Give wf-recorder a moment to finalize the file
    wait_for_recorder=0

    while pgrep -x wf-recorder >/dev/null && ((wait_for_recorder < 30)); do
        sleep 0.1
        ((wait_for_recorder++))
    done

    exit 0
fi

# --------------------------------------------------
# Generate filename ONCE
# --------------------------------------------------

TIMESTAMP="$(get_date)"
OUTPUT_FILE="$RECORDING_DIR/recording_${TIMESTAMP}.mp4"

MONITOR="$(get_active_monitor)"

if [[ -z "$MONITOR" ]]; then
    notify-send \
        "Recorder Error" \
        "Could not determine active monitor" \
        -a "Recorder"

    update_state false
    exit 1
fi

# --------------------------------------------------
# Region selection
# --------------------------------------------------

GEOMETRY=""

if [[ "$FULLSCREEN_FLAG" -eq 0 ]]; then

    if [[ -n "$MANUAL_REGION" ]]; then

        GEOMETRY="$MANUAL_REGION"

    else

        if ! GEOMETRY="$(slurp 2>/dev/null)"; then

            notify-send \
                "Recording cancelled" \
                "Selection was cancelled" \
                -a "Recorder"

            update_state false
            exit 1
        fi

    fi

fi

# --------------------------------------------------
# Build wf-recorder command
# --------------------------------------------------

CMD=(
    wf-recorder
    -o "$MONITOR"
    --pixel-format
    yuv420p
    -f "$OUTPUT_FILE"
)

if [[ -n "$GEOMETRY" ]]; then
    CMD+=(--geometry "$GEOMETRY")
fi

if [[ "$SOUND_FLAG" -eq 1 ]]; then

    AUDIO="$(get_audio_output)"

    if [[ -z "$AUDIO" ]]; then
        notify-send \
            "Recorder Error" \
            "Could not find PulseAudio/PipeWire monitor source" \
            -a "Recorder"

        update_state false
        exit 1
    fi

    CMD+=(--audio="$AUDIO")
fi

# --------------------------------------------------
# Start recording
# --------------------------------------------------

notify-send \
    "Starting recording" \
    "$(basename "$OUTPUT_FILE")" \
    -a "Recorder"

update_state true
start_timer

"${CMD[@]}"

# --------------------------------------------------
# Recorder finished
# --------------------------------------------------

EXIT_CODE=$?

update_state false

if (( EXIT_CODE != 0 )); then
    notify-send \
        "Recording Error" \
        "wf-recorder exited with code $EXIT_CODE" \
        -a "Recorder"
fi

exit "$EXIT_CODE"
