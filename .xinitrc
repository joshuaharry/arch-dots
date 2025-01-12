#!/bin/sh
setxkbmap -option "caps:swapescape"
setxkbmap -option ctrl:ralt_rctrl
setxkbmap -option altwin:swap_lalt_lwin

feh --bg-scale --no-fehbg ~/.config/wallpaper/farm.jpg

# Launch pybar when X starts.
if pgrep pybar; then
	pkill pybar
fi

# If we don't run pybar in a subshell as below, for mysterious reasons, it does
# not work.
/bin/sh -c '~/.config/pybar/pybar &'

# Launch picom.
picom &

exec dwm
