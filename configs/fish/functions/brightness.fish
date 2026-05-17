function brightness
    set -l step 5

    set -l current (brightnessctl -m | cut -d',' -f4 | tr -d '%')

    switch $argv[1]
        case up
            brightnessctl set +$step%

        case down
            if test $current -le 5
                brightnessctl set 5%
            else
                brightnessctl set $step%-
            end
    end

    set -l level (brightnessctl -m | cut -d',' -f4 | tr -d '%')

    set -l icon
    set -l text "Brightness: $level%"

    if test $level -ge 67
        set icon display-brightness-high-symbolic
    else if test $level -ge 34
        set icon display-brightness-medium-symbolic
    else
        set icon display-brightness-low-symbolic
    end

    notify-send \
        -a "Core" \
        -i $icon \
        -h string:x-canonical-private-synchronous:brightness \
        -h int:value:$level \
        "$text"
end