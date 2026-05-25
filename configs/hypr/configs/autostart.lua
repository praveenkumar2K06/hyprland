-------------------
---- AUTOSTART ----
-------------------


hl.on("hyprland.start", function()
    -- hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- hl.exec_cmd("waybar")
    hl.exec_cmd("qs")
    hl.exec_cmd("awww-daemon")
end)
