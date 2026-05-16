------------------
---- GESTURES ----
------------------


hl.config({
    gestures = {
        workspace_swipe_distance           = 300,
        workspace_swipe_cancel_ratio       = 0.2,
        workspace_swipe_min_speed_to_force = 5
    }
})

hl.gesture({
    fingers   = 3,
    direction = "swipe",
    action    = "move"
})

hl.gesture({
    fingers   = 4,
    direction = "horizontal",
    action    = "workspace"
})
