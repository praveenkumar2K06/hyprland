---------------
---- INPUT ----
---------------


hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "",
        kb_rules           = "",

        follow_mouse       = 1,
        repeat_delay       = 300,
        repeat_rate        = 50,

        numlock_by_default = true,

        sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad           = {
            disable_while_typing    = true,
            natural_scroll          = true,
            clickfinger_behavior    = false,
            middle_button_emulation = false,
            tap_to_click            = true,
            drag_lock               = false,
        },
    },
})
