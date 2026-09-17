local colors = require("generated-colors")


-----------------------
---- LOOK AND FEEL ----
-----------------------


hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 5,

        border_size      = 2,

        col              = {
            active_border   = { colors = { colors.primary_fixed_dim, colors.tertiary_fixed_dim }, angle = 45 },
            inactive_border = colors.outline,
        },

        resize_on_border = true,
        layout           = "dwindle",

        snap             = {
            enabled      = true,
            respect_gaps = true,
        },
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        dim_inactive     = true,
        dim_strength     = 0.2,
        dim_special      = 0.8,

        blur             = {
            xray    = true,
            special = true,
            passes  = 2,
            popups  = true
        },

        motion_blur      = {
            enabled = true
        },
    },

    animations = {
        enabled = true,
    },
})
