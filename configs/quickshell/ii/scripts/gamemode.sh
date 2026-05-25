#!/usr/bin/env bash

current=$(hyprctl -j getoption decoration.blur.enabled | jq '.bool')

if [ "$current" = "true" ]; then
    hyprctl eval 'hl.config({
        decoration = {
            blur = {
                enabled = false,
            },
            shadow = {
                enabled = false,
            },
        }
    })'

    hyprctl eval "hl.window_rule({name = 'Blur'}):set_enabled(false)"
else
    hyprctl eval 'hl.config({
        decoration = {
            blur = {
                enabled = true,
            },
            shadow = {
                enabled = true,
            },
        }
    })'

    hyprctl eval "hl.window_rule({name = 'Blur'}):set_enabled(true)"
fi
