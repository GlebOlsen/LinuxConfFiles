export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3
export DESKTOP_SESSION=i3
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=kitty
export BROWSER=brave-origin

xrdb -merge "$HOME/.Xresources"
exec dbus-run-session -- i3
