-------------------
---- AUTOSTART ----
-------------------


hl.on("hyprland.start", function()
    -- hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- hl.exec_cmd("waybar")
    -- hl.exec_cmd("qs -c ii")
    -- hl.exec_cmd("awww-daemon")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("~/.local/bin/bezel")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")

    -- hl.exec_cmd("wl-paste --watch cliphist store")
end)
