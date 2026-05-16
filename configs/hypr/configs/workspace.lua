--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name = "Blur",
    match = { class = ".*" },
    opacity = "0.9 0.9",
})

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "Avoid idle for fullscreen apps",
    match = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name = "Float popups and dialogue",
    match = {
        title = "^(Authentication Required|Add Folder to Workspace|Save As)$",
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "Float Open Files",
    match = { initial_title = "(Open Files)" },
    float = true,
    size = "(monitor_w*0.7) (monitor_h*0.6)",
    center = true,
})

hl.window_rule({
    name = "Float TUI",
    match = { class = "(tui)" },
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
    stay_focused = true,
    center = true,
})

hl.window_rule({
    name = "Picture-in-Picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    move = "monitor_w-500 monitor_h-300",
    keep_aspect_ratio = true,
    opacity = "0.5 0.8",
})
