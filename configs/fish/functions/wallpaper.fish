function wallpaper
    set dir ~/Pictures/wallpapers
    set sddm_bg /usr/share/sddm/themes/pixie/assets/background.jpg
    set sddm_theme /usr/share/sddm/themes/pixie/theme.conf
    set tmp_bg /tmp/matugen-sddm-background.jpg

    set img (find $dir -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

    if test -z "$img"
        echo "No wallpapers found in $dir"
        notify-send -i arch-error-symbolic -a 'Core' "Wallpaper" "No wallpapers found in $dir"
        return 1
    end


    ffmpeg -y -loglevel error -i "$img" -q:v 2 "$tmp_bg"
    or begin
        echo "Failed to convert wallpaper to jpg for SDDM"
        notify-send -i arch-error-symbolic -a 'Core' "Wallpaper" "Failed to convert image to JPG for SDDM"
        return 1
    end

    pkexec env TMP_BG="$tmp_bg" SDDM_BG="$sddm_bg" SDDM_THEME="$sddm_theme" sh -c 'install -Dm644 "$TMP_BG" "$SDDM_BG" && sed -i "s|^background=.*|background=assets/background.jpg|" "$SDDM_THEME"'
    or begin
        rm -f "$tmp_bg"
        echo "Failed to update SDDM wallpaper or theme.conf"
        notify-send -i arch-error-symbolic -a 'Core' "Wallpaper" "Failed to update SDDM wallpaper or theme.conf"
        return 1
    end

    rm -f "$tmp_bg"

    awww img --transition-type center "$img"
    matugen image "$img" --source-color-index 0
    or begin
        echo "Matugen failed for $img"
        notify-send -i arch-error-symbolic -a 'Core' "Wallpaper" "Matugen failed for selected image"
        return 1
    end
    
    echo "Wallpaper set: $img"
    notify-send -i archlinux-logo -a 'Core' 'Wallpaper Changed' 'Config reloaded!'
end