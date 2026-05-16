------------------
---- SETTINGS ----
------------------


hl.config({
    dwindle = {
        preserve_split = true,
        smart_split    = false,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },

    misc = {
        disable_splash_rendering   = true,
        disable_hyprland_logo      = true,
        vrr                        = 1,

        mouse_move_enables_dpms    = true,

        enable_swallow             = false,

        initial_workspace_tracking = 0,
        middle_click_paste         = false,
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },

    cursor = {
        hide_on_key_press = true,
    },
})
