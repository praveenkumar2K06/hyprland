function wallpaper
    set dir ~/Pictures/wallpapers

    set img (find $dir -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

    if test -z "$img"
        echo "No wallpapers found in $dir"
        return 1
    end

    awww img "$img"
    echo "Wallpaper set: $img"
end