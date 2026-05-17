function volume
    set -l step 5

    switch $argv[1]
        case up
            pamixer --increase $step
        case down
            pamixer --decrease $step
        case mute
            pamixer --toggle-mute
    end

    set -l volume (pamixer --get-volume)
    set -l muted (pamixer --get-mute)

    set -l icon audio-volume-muted-symbolic
    set -l text "Volume: Muted"
    set -l hint 0

    if test "$muted" = false
        set hint $volume
        set text "Volume: $volume%"

        if test $volume -ge 67
            set icon audio-volume-high-symbolic
        else if test $volume -ge 34
            set icon audio-volume-medium-symbolic
        else if test $volume -gt 0
            set icon audio-volume-low-symbolic
        end
    end

    notify-send \
        -a "Core" \
        -i $icon \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:$hint \
        "$text"
end