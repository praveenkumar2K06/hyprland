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

-- Scratchpad gestures
local SCRATCH_TOGGLE = "special"
local SCRATCH_WS = "special:special"

local last_sent = nil

-- Get the existing scratchpad workspace WITHOUT creating it.
local function get_scratchpad()
    local ws = hl.get_workspace(SCRATCH_WS)

    -- Workspace doesn't exist, or has no windows.
    if not ws or ws.windows == 0 then
        return nil
    end

    return ws
end

local function in_scratchpad(win)
    local ws = win and win.workspace
    return ws ~= nil and ws.name == SCRATCH_WS
end

local function any_scratchpad_window()
    for _, w in ipairs(hl.get_windows()) do
        if in_scratchpad(w) then
            return w
        end
    end

    return nil
end

local function show_scratchpad_and_refocus()
    local target = in_scratchpad(last_sent) and last_sent
        or any_scratchpad_window()

    -- IMPORTANT:
    -- Never call toggle_special() if the scratchpad doesn't exist/is empty.
    if not target then
        last_sent = nil
        return
    end

    hl.dispatch(
        hl.dsp.workspace.toggle_special("special")
    )

    hl.dispatch(
        hl.dsp.focus({ window = target })
    )
end

local function handle_scratchpad_gesture(direction)
    local monitor = hl.get_active_monitor()
    if not monitor then
        return
    end

    local special = monitor.active_special_workspace

    local scratch_visible =
        special ~= nil
        and special.name == SCRATCH_WS

    if direction == "up" then

        if scratch_visible then

            local win = hl.get_active_window()

            if in_scratchpad(win) then
                -- Move the focused scratchpad window back.
                if monitor.active_workspace then
                    hl.dispatch(
                        hl.dsp.window.move({
                            workspace = monitor.active_workspace,
                            window = win
                        })
                    )

                    if last_sent and last_sent.address == win.address then
                        last_sent = nil
                    end
                end

            else
                -- Scratchpad is visible but another window is focused.
                -- Focus a scratchpad window if one exists.
                local target =
                    in_scratchpad(last_sent) and last_sent
                    or any_scratchpad_window()

                if target then
                    hl.dispatch(
                        hl.dsp.focus({
                            window = target
                        })
                    )
                else
                    -- Do NOT toggle/open an empty scratchpad.
                    last_sent = nil
                end
            end

        else
            -- Scratchpad isn't visible.
            -- Only open it if it actually exists and contains a window.
            local target =
                in_scratchpad(last_sent) and last_sent
                or any_scratchpad_window()

            if target then
                hl.dispatch(
                    hl.dsp.workspace.toggle_special("special")
                )

                hl.dispatch(
                    hl.dsp.focus({
                        window = target
                    })
                )
            else
                -- Nothing in scratchpad -> do nothing.
                last_sent = nil
            end
        end

    elseif direction == "down" then

        if special then
            -- Hide whichever special workspace is visible.
            hl.dispatch(
                hl.dsp.workspace.toggle_special(
                    string.sub(special.name, 9)
                )
            )

        else
            local win = hl.get_active_window()

            if win then
                hl.dispatch(
                    hl.dsp.window.move({
                        workspace = SCRATCH_WS,
                        window = win,
                        follow = false
                    })
                )

                -- Remember the window only if it really moved.
                if in_scratchpad(win) then
                    last_sent = win
                end
            end
        end
    end
end

hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        handle_scratchpad_gesture("up")
    end
})

hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
        handle_scratchpad_gesture("down")
    end
})