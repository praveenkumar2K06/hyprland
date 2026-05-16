---------------------
---- MY PROGRAMS ----
---------------------


local browser     = "zen-browser"
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "wofi --show drun"

---------------------
---- KEYBINDINGS ----
---------------------


local mainMod = "SUPER"

-- Common actions
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + R", function()
    hl.dispatch(hl.dsp.exec_cmd("pkill waybar; waybar"))
    hl.dispatch(hl.dsp.exec_raw("fish -c wallpaper"))
end)

-- Lock
hl.bind(mainMod .. " + L",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Misc: Zoom out" })
hl.bind(mainMod .. " + Equal", function() zoomfunction(0.3) end, { repeating = true, description = "Misc: Zoom in" })

-- Special Keys

-- TODO: Add media keys
-- Mic
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(""), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd("grimshot save full"), { locked = true })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grimshot save area"), { locked = true })

-- Special
hl.bind(mainMod .. " + ALT + S",
    hl.dsp.window.move({ workspace = "special:special", follow = false }), { description = "Window: Send to scratchpad" })
hl.bind("CTRL + " .. mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))


-- Focus
for i = 1, 6 do
    local arrowkey = { "Left", "Right", "Up", "Down", "BracketLeft", "BracketRight" }
    local focusdir = { "l", "r", "u", "d", "l", "r" }
    hl.bind(mainMod .. " + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }))
    hl.bind(mainMod .. " + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ direction = focusdir[i], follow = true }))
end

-- Workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })
