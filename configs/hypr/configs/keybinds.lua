---------------------------
---- PROGRAMS & CONFIG ----
---------------------------

local mainMod     = "SUPER"
local browser     = "zen-browser"
local terminal    = "kitty"
local fileManager = "nautilus"
local ipc         = "noctalia msg "

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Change focus
local arrowKeys = { Left = "l", Right = "r", Up = "u", Down = "d", BracketLeft = "l", BracketRight = "r" }
for key, direction in pairs(arrowKeys) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction, follow = true }))
end

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher /emo"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(ipc .. "bar-toggle bar-options"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + B", hl.dsp.exec_cmd(ipc .. "bar-toggle bar-options"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

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

hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind(mainMod .. " + Equal", function() zoomfunction(0.3) end, { repeating = true })

-- Screen Capture
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Screen Recording
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(ipc .. "plugin noctalia/screen_recorder:service all toggle"))
hl.bind("ALT + R", hl.dsp.exec_cmd(ipc .. "plugin noctalia/screen_recorder:service all pause-toggle"))

-- Clipboard & Wallpaper
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mainMod .. " + CONTROL + T", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus on workspace number
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Move active window to workspace
for i = 1, 9 do
    hl.bind(mainMod .. " + CONTROL + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move active window to workspace and follow
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Special workspace
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }))
hl.bind("CONTROL + " .. mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))

----------------------------
---- LAYOUT MANAGEMENT ----
----------------------------

hl.bind(mainMod .. " + SHIFT + Tab", function()
    local layouts = { "scrolling", "dwindle" }
    local workspace = hl.get_active_workspace()

    if hl.get_active_special_workspace() then
        workspace = hl.get_active_special_workspace()
    end

    if not workspace then
        return
    end

    local next_layout = "dwindle"

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            next_layout = layouts[(i % #layouts) + 1]
            break
        end
    end

    if workspace.special then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
    else
        hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
    end

    hl.dispatch(hl.dsp.exec_cmd(ipc .. "notification-show 'Layout changed' '" .. next_layout .. "'"))
end)

-------------------
---- SESSION ------
-------------------

hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd(ipc .. "panel-open session"))

-- Window switcher
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind(mainMod .. " + Tab", hl.plugin.gloview.toggle)
hl.bind(mainMod .. " + CONTROL + Tab", hl.plugin.gloview.allworkspaces)
