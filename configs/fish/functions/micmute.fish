function micmute
    pamixer --default-source --toggle-mute

    set -l muted (pamixer --default-source --get-mute)
    set -l icon
    set -l text

    if test $muted = true
        set icon microphone-disabled-symbolic
        set text "Microphone: Muted"
    else
        set icon audio-input-microphone-low-symbolic
        set text "Microphone: Active"
    end

    notify-send \
        -a "Core" \
        -i $icon \
        -h string:x-canonical-private-synchronous:microphone \
        "$text"
end