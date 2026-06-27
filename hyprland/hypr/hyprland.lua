local terminal = "foot"
local menu     = "fuzzel"
local runMenu  = "fuzzel --list-executables-in-path"
local mainMod  = "SUPER"

hl.monitor({ output = "DP-1",     mode = "3840x2160", position = "3200x0",    scale = 1 })
hl.monitor({ output = "DP-2",     mode = "1920x1080", position = "1280x1080", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "7040x240",  scale = 1, transform = 1 })

hl.workspace_rule({ workspace = "1", monitor = "DP-2",     default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1",     default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("gammastep -l 55.7:12.6 -t 6500:2700 -g 0.8 -m wayland")
    hl.exec_cmd([[swayidle -w timeout 900 'swaylock -C ~/.config/swaylock/config' timeout 930 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -C ~/.config/swaylock/config']])
end)

hl.env("XCURSOR_THEME", "miniature")
hl.env("XCURSOR_SIZE", "64")
hl.env("HYPRCURSOR_SIZE", "64")

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 4,
        col = {
            active_border   = { colors = { "rgba(b3ff00ee)", "rgba(00ffffee)" }, angle = 45 },
            inactive_border = "rgba(132a13aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
    },
})

hl.animation({ leaf = "windows",    enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 1,   bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "layers",     enabled = true, speed = 1.5, bezier = "default" })

hl.config({
    dwindle = {
        preserve_split        = true,
        smart_split           = false,
        smart_resizing        = true,
        use_active_for_splits = true,
        force_split           = 2,
    },
})

hl.config({
    input = {
        kb_layout   = "dk",
        follow_mouse = 1,
        sensitivity  = 0,
        -- Laptop: natural_scroll = true
        touchpad = { natural_scroll = false },
    },
})

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(runMenu))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + V", hl.dsp.layout("preselect r"))
hl.bind(mainMod .. " + B", hl.dsp.layout("preselect d"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.layout("preselect l"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.layout("preselect u"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + W", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + minus",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local resizeStep = 80
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("H", hl.dsp.window.resize({ x = -resizeStep, y = 0, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = resizeStep,  y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -resizeStep, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = resizeStep,  relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -resizeStep, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = resizeStep,  y = 0, relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0, y = -resizeStep, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0, y = resizeStep,  relative = true }), { repeating = true })
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.submap("zoom"))
hl.define_submap("zoom", function()
    hl.bind("1", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 1 } })'"))
    hl.bind("2", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 2 } })'"))
    hl.bind("3", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 3 } })'"))
    hl.bind("4", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 4 } })'"))
    hl.bind("5", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 5 } })'"))
    hl.bind("0", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 1 } })'"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

local mouseStep = 15
hl.bind(mainMod .. " + ALT + G", hl.dsp.submap("mouse"))
hl.define_submap("mouse", function()
    hl.bind("H", hl.dsp.exec_cmd("wlrctl pointer move -" .. mouseStep .. " 0"), { repeating = true })
    hl.bind("J", hl.dsp.exec_cmd("wlrctl pointer move 0 " .. mouseStep),        { repeating = true })
    hl.bind("K", hl.dsp.exec_cmd("wlrctl pointer move 0 -" .. mouseStep),       { repeating = true })
    hl.bind("L", hl.dsp.exec_cmd("wlrctl pointer move " .. mouseStep .. " 0"),  { repeating = true })
    hl.bind("A", hl.dsp.exec_cmd("wlrctl pointer click left"))
    hl.bind("S", hl.dsp.exec_cmd("wlrctl pointer click middle"))
    hl.bind("D", hl.dsp.exec_cmd("wlrctl pointer click right"))
    hl.bind("R", hl.dsp.exec_cmd("wlrctl pointer scroll -" .. mouseStep .. " 0"), { repeating = true })
    hl.bind("F", hl.dsp.exec_cmd("wlrctl pointer scroll " .. mouseStep .. " 0"),  { repeating = true })
    hl.bind("G", hl.dsp.exec_cmd("wl-kbptr"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd("cliphist-fuzzel-img"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("wl-kbptr"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("swaylock -C ~/.config/swaylock/config"))

hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),         { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),       { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),          { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+"),   { locked = true, repeating = true })
-- Laptop:
-- hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("for d in 1 2 3; do ddcutil --display $d setvcp 10 + 10; done"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("for d in 1 2 3; do ddcutil --display $d setvcp 10 - 10; done"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
