-- Hyprland Lua config migrated from hyprland.conf.
-- Keep hyprland.conf as a rollback path: Hyprland prefers this file only when it exists.

local mainMod = "SUPER"
local filemanager = "dolphin --platformtheme qt6ct"
local applauncher = 'rofi -show combi -modi drun,run,combi -combi-modi drun,run -combi-hide-mode-prefix true -display-combi "" -theme ~/.config/rofi/config.rasi'
local terminal = "kitty"
local browser = "helium-browser"
local capturing = 'grim -g "$(slurp)" - | swappy -f -'
local xdg_data_dirs = "/home/warre/.local/share:/usr/local/share:/usr/share:/opt/t3code-bin/usr/share"

local function load_wal_colors(path)
    local colors = {}
    local file = io and io.open(path, "r") or nil
    if not file then
        return colors
    end

    for line in file:lines() do
        local key, value = line:match("^%s*%$([%w_]+)%s*=%s*([^%s#]+)")
        if key and value then
            colors[key] = value
        end
    end

    file:close()
    return colors
end

local wal = load_wal_colors(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf")
local function rgb(name, fallback)
    return "rgb(" .. (wal[name] or fallback) .. ")"
end
local function rgba(name, alpha, fallback)
    return "rgba(" .. (wal[name] or fallback) .. alpha .. ")"
end

-- Monitors
hl.monitor({ output = "eDP-1", mode = "2560x1440@165.00", position = "0x0", scale = 1 })

-- Environment
hl.env("GTK_THEME", "Flat-Remix-GTK-Blue-Darkest")
hl.env("XCURSOR_THEME", "Adwaita", true)
hl.env("XCURSOR_SIZE", "24", true)
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_STYLE_OVERRIDE", "kvantum", true)
hl.env("QT_QPA_PLATFORMTHEME", "kvantum", true)
hl.env("QT_QUICK_CONTROLS_STYLE", "kvantum")
hl.env("AQ_FORCE_LINEAR_BLIT", "0")
hl.env("PIPEWIRE_LATENCY", "128/48000")
hl.env("PIPEWIRE_QUANTUM", "128/48000")
hl.env("QT_CURSOR_THEME", "Bibata-Modern-Classic", true)
hl.env("QT_CURSOR_SIZE", "24", true)
hl.env("XDG_DATA_DIRS", xdg_data_dirs, true)

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE XCURSOR_THEME XCURSOR_SIZE && systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE XCURSOR_THEME XCURSOR_SIZE")
    hl.exec_cmd("waybar")
    hl.exec_cmd("asusctl -k off")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("~/.config/hypr/scripts/auto-monitor-detect.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/usr/lib/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("GDK_BACKEND=wayland swaync")
    hl.exec_cmd("~/.config/hypr/scripts/battery-notify.sh")
    hl.exec_cmd("swaync")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("systemctl --user enable --now pipewire pipewire-pulse wireplumber")
    hl.exec_cmd("hyprshell -c /home/warre/.config/hyprshell/config.json5 run")
end)

hl.config({
    general = {
        allow_tearing = false,
        gaps_in = 2,
        gaps_out = 2,
        border_size = 1,
        col = {
            active_border = rgb("color4", "7d5a73"),
            inactive_border = rgb("color8", "433859"),
        },
        layout = "dwindle",
        resize_on_border = true,
        extend_border_grab_area = 25,
        snap = {
            enabled = true,
            window_gap = 1,
            monitor_gap = 1,
            border_overlap = false,
        },
    },

    decoration = {
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        rounding = 4,
        rounding_power = 3.0,
        dim_inactive = false,
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            new_optimizations = true,
            xray = true,
            ignore_opacity = true,
            noise = 0.02,
            brightness = 0.9,
            contrast = 0.9,
            vibrancy = 0.2,
        },
        shadow = {
            enabled = true,
            range = 10,
            render_power = 3,
            sharp = false,
            color = "rgba(00000099)",
            color_inactive = "rgba(00000066)",
            offset = { 0, 2 },
            scale = 1.0,
        },
    },

    animations = { enabled = true },

    input = {
        kb_layout = "be,us",
        kb_model = "",
        kb_rules = "",
        accel_profile = flat,
        force_no_accel = true,
        follow_mouse = 1,
        float_switch_override_focus = 2,
        sensitivity = 0,
        kb_options = "caps:escape",
        touchpad = {
            natural_scroll = true,
            scroll_factor = 1.0,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },

    gestures = {
        workspace_swipe_distance = 250,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 15,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = false,
    },

    group = {
        auto_group = true,
        insert_after_current = true,
        focus_removed_window = true,
        groupbar = {
            enabled = true,
            font_family = "JetBrainsMono Nerd Font",
            font_size = 8,
            text_color = 0x00000000,
            height = 10,
            gradients = true,
            render_titles = false,
        },
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        enable_swallow = true,
        swallow_regex = "^(cachy-browser|firefox|nautilus|nemo|thunar|vesktop|btrfs-assistant.)$",
        always_follow_on_dnd = true,
        layers_hog_keyboard_focus = true,
        animate_manual_resizes = false,
        vrr = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        disable_hyprland_guiutils_check = false,
    },

    binds = {
        allow_workspace_cycles = false,
        workspace_back_and_forth = true,
        workspace_center_on = 1,
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = true,
    },

    xwayland = {
        enabled = true,
        use_nearest_neighbor = true,
        force_zero_scaling = false,
    },

    opengl = {
        nvidia_anti_flicker = true,
    },

    render = {
        direct_scanout = false,
        expand_undersized_textures = true,
    },

    cursor = {
        no_hardware_cursors = false,
        enable_hyprcursor = true,
        hide_on_touch = true,
        sync_gsettings_theme = true,
        zoom_disable_aa = false,
    },

    dwindle = {
        force_split = 0,
        special_scale_factor = 0.8,
        split_width_multiplier = 1.0,
        use_active_for_splits = true,
        preserve_split = true,
    },

    master = {
        new_status = "master",
        special_scale_factor = 0.8,
        smart_resizing = true,
        drop_at_cursor = true,
    },
})

-- Animations
hl.curve("mangoOpen", { type = "bezier", points = { { 0.46, 1.0 }, { 0.29, 1 } } })
hl.curve("mangoClose", { type = "bezier", points = { { 0.08, 0.92 }, { 0, 1 } } })
hl.curve("mangoMove", { type = "bezier", points = { { 0.46, 1.0 }, { 0.29, 1 } } })
hl.curve("mangoTag", { type = "bezier", points = { { 0.46, 1.0 }, { 0.29, 1 } } })
hl.curve("mangoFade", { type = "bezier", points = { { 0.46, 1.0 }, { 0.29, 1 } } })
hl.curve("delayedFadeOut", { type = "bezier", points = { { 0.25, 0 }, { 0.5, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 0.9, bezier = "mangoOpen", style = "popin 70%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "mangoClose", style = "slide bottom right" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "delayedFadeOut" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 0.9, bezier = "mangoMove", style = "slide" })
hl.animation({ leaf = "windows", enabled = true, speed = 0.9, bezier = "mangoOpen" })
hl.animation({ leaf = "fade", enabled = true, speed = 0.9, bezier = "mangoFade" })
hl.animation({ leaf = "border", enabled = true, speed = 0.9, bezier = "mangoOpen" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.25, bezier = "mangoFade", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.25, bezier = "mangoFade", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.25, bezier = "mangoFade", style = "fade" })

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

hl.device({
    name = "asue120a:00-04f3:319b-touchpad",
    sensitivity = 0.35,
    accel_profile = "flat",
})

local function bind(keys, dispatcher, opts)
    hl.bind(keys, dispatcher, opts)
end

local function desc(text, extra)
    local opts = extra or {}
    opts.description = text
    return opts
end

-- Keybindings
bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot_full"), desc("Screenshot full"))
bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), desc("Opens your preferred terminal emulator (" .. terminal .. ")", { repeating = true }))
bind(mainMod .. " + E", hl.dsp.exec_cmd(filemanager), desc("Opens your preferred filemanager (" .. filemanager .. ")"))
bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/emoji_picker"), desc("Opens emoji picker menu"))
bind(mainMod .. " + A", hl.dsp.exec_cmd(capturing), desc("Screen capture selection"))
bind(mainMod .. " + Z", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'), desc("Screenshot selection to clipboard"))
bind(mainMod .. " + Q", hl.dsp.window.close(), desc("Closes (not kill) current window", { repeating = true }))
bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd('loginctl terminate-user ""'), desc("Exits Hyprland by terminating the user sessions"))
bind(mainMod .. " + V", hl.dsp.window.float(), desc("Switches current window between floating and tiling mode"))
bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(applauncher), desc("Runs your application launcher"))
bind(mainMod .. " + F", hl.dsp.window.fullscreen(), desc("Toggles current window fullscreen mode"))
bind(mainMod .. " + Y", hl.dsp.window.pin(), desc("Pin current window (shows on all workspaces)"))
bind(mainMod .. " + Tab", hl.dsp.group.next(), desc("Switches to the next window in the group"))

bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-volume-up.sh"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-volume-down.sh"), { locked = true, repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-volume-mute.sh"), { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), desc("Toggles play/pause"))
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), desc("Next track"))
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), desc("Previous track"))
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-brightness-up.sh"), { repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-brightness-down.sh"), { repeating = true })
bind("F7", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-brightness-down.sh"), { repeating = true })
bind("F8", hl.dsp.exec_cmd("~/.config/quickshell/scripts/osd-brightness-up.sh"), { repeating = true })
bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("swaylock-fancy -e -K -p 10"), desc("Lock the screen"))
bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/waybar/scripts/touchpad-toggle.sh"), desc("Toggle touchpad"))

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), desc("Move the window towards a direction", { mouse = true }))
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), desc("Resize the window towards a direction", { mouse = true }))

for _, item in ipairs({
    { "left", "left" }, { "right", "right" }, { "up", "up" }, { "down", "down" },
    { "h", "left" }, { "l", "right" }, { "k", "up" }, { "j", "down" },
}) do
    bind(mainMod .. " + SHIFT + " .. item[1], hl.dsp.window.move({ direction = item[2] }))
    bind(mainMod .. " + " .. item[1], hl.dsp.focus({ direction = item[2] }))
end

bind(mainMod .. " + R", hl.dsp.submap("resize"), desc("Activates window resizing mode"))
hl.define_submap("resize", function()
    for _, item in ipairs({
        { "right", 15, 0 }, { "left", -15, 0 }, { "up", 0, -15 }, { "down", 0, 15 },
        { "l", 15, 0 }, { "h", -15, 0 }, { "k", 0, -15 }, { "j", 0, 15 },
    }) do
        bind(item[1], hl.dsp.window.resize({ x = item[2], y = item[3], relative = true }), desc("Resize window", { repeating = true }))
    end
    bind("escape", hl.dsp.submap("reset"), desc("Ends window resizing mode"))
end)

for _, item in ipairs({
    { "right", 15, 0 }, { "left", -15, 0 }, { "up", 0, -15 }, { "down", 0, 15 },
    { "l", 15, 0 }, { "h", -15, 0 }, { "k", 0, -15 }, { "j", 0, 15 },
}) do
    bind(mainMod .. " + CTRL + SHIFT + " .. item[1], hl.dsp.window.resize({ x = item[2], y = item[3], relative = true }), desc("Resize window", { repeating = true }))
end

for _, item in ipairs({
    { "l", 15, 0 }, { "h", -15, 0 }, { "k", 0, -15 }, { "j", 0, 15 },
}) do
    bind(mainMod .. " + ALT + " .. item[1], hl.dsp.window.resize({ x = item[2], y = item[3], relative = true }), desc("Resize window", { repeating = true }))
end

local workspace_keys = {
    { "ampersand", "1" }, { "eacute", "2" }, { "quotedbl", "3" }, { "code:13", "4" },
    { "parenleft", "5" }, { "section", "6" }, { "egrave", "7" }, { "exclam", "8" },
    { "ccedilla", "9" }, { "agrave", "10" },
}

for _, item in ipairs(workspace_keys) do
    bind(mainMod .. " + CTRL + " .. item[1], hl.dsp.window.move({ workspace = item[2], follow = true }), desc("Move window and switch to workspace " .. item[2]))
    bind(mainMod .. " + SHIFT + " .. item[1], hl.dsp.window.move({ workspace = item[2], follow = false }), desc("Move window silently to workspace " .. item[2]))
    bind(mainMod .. " + " .. item[1], hl.dsp.focus({ workspace = item[2] }), desc("Switch to workspace " .. item[2]))
end

bind(mainMod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }), desc("Scroll through workspaces incrementally"))
bind(mainMod .. " + COMMA", hl.dsp.focus({ workspace = "e-1" }), desc("Scroll through workspaces decrementally"))
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), desc("Scroll through workspaces incrementally"))
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), desc("Scroll through workspaces decrementally"))
bind(mainMod .. " + slash", hl.dsp.focus({ workspace = "previous" }), desc("Switch to the previous workspace"))
bind(mainMod .. " + minus", hl.dsp.window.move({ workspace = "special" }), desc("Move active window to Special workspace"))
bind(mainMod .. " + equal", hl.dsp.workspace.toggle_special("special"), desc("Toggles the Special workspace"))
bind(mainMod .. " + F1", hl.dsp.workspace.toggle_special("scratchpad"), desc("Call special workspace scratchpad"))
bind(mainMod .. " + ALT + SHIFT + F1", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }), desc("Move active window to special workspace scratchpad"))

bind(mainMod .. " + SHIFT + F", hl.dsp.window.float(), desc("Toggle floating window"))
bind(mainMod .. " + P", hl.dsp.window.pseudo(), desc("Toggle pseudo tiling"))

bind(mainMod .. " + C", hl.dsp.exec_cmd('bash -c "cliphist list | tofi --config ~/.config/hypr/tofi-dmenu.conf | cliphist decode | wl-copy"'), desc("Opens clipboard history"))
bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"), desc("Opens notification center"))
bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh"))
bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-select.sh"))
bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/theme-select.sh"))
bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/gamemode.sh"), desc("Toggle game mode (Performance + disable rofi)"))
bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-gravity.sh"), desc("Black-hole window gravity"))
bind(mainMod .. " + SHIFT + P", hl.dsp.submap("passthrough"))
hl.define_submap("passthrough", function()
    bind(mainMod .. " + SHIFT + P", hl.dsp.submap("reset"))
end)
bind(mainMod .. " + SHIFT + CTRL + A", hl.dsp.exec_cmd("~/.config/hypr/scripts/autoclicker.py toggle"))
bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
bind(mainMod .. " + U", hl.dsp.exec_cmd("~/.config/waybar/waybar.sh"))

-- Window rules
hl.window_rule({ name = "windowrule-1", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ name = "mango-shadow-floating-only", match = { float = false }, no_shadow = true })
hl.window_rule({ name = "windowrule-2", match = { class = "^(Rofi)$" }, float = true })
hl.window_rule({ name = "windowrule-4", match = { class = "^()$", title = "^(Picture in picture)$" }, float = true })
hl.window_rule({ name = "windowrule-5", match = { class = "^()$", title = "^(Save File)$" }, float = true })
hl.window_rule({ name = "windowrule-6", match = { class = "^()$", title = "^(Open File)$" }, float = true })
hl.window_rule({ name = "windowrule-7", match = { class = "^(LibreWolf)$", title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ name = "windowrule-8", match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ name = "windowrule-9", match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" }, float = true })
hl.window_rule({ name = "windowrule-10", match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" }, float = true })
hl.window_rule({ name = "windowrule-11", match = { class = "^(CachyOSHello)$" }, float = true })
hl.window_rule({ name = "windowrule-12", match = { class = "^(zenity)$" }, float = true })
hl.window_rule({ name = "windowrule-13", match = { class = "^()$", title = "^(Steam - Self Updater)$" }, float = true })
hl.window_rule({ name = "windowrule-17", match = { title = "^(Picture-in-Picture)$" }, float = true, size = { 960, 540 } })
hl.window_rule({ name = "windowrule-18", match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" }, float = true, size = { 960, 540 } })
hl.window_rule({ name = "windowrule-19", match = { title = "^(danmufloat)$" }, pin = true })
hl.window_rule({ name = "windowrule-20", match = { class = "^(org.mozilla.firefox)$" }, no_blur = true })
hl.window_rule({ name = "windowrule-21", match = { class = "^(Alacritty)$" }, no_blur = true })
hl.window_rule({ name = "windowrule-22", match = { class = "^(gnome-calculator|Gnome-calculator)$" }, float = true })
hl.window_rule({ name = "mango-media-float-mpv-imv", match = { class = "^(mpv|imv)$" }, float = true })
hl.window_rule({ name = "mango-thunar-opacity", match = { class = "^(thunar|Thunar)$" }, opacity = "0.80 0.80" })
hl.window_rule({ name = "kitty-tiling", match = { class = "^(kitty)$" }, float = false })
hl.window_rule({ name = "discord-on-ws3", match = { class = "^(legcord)$" }, workspace = "4 silent" })

-- Layer rules
hl.layer_rule({ name = "mango-selection-capture", match = { namespace = "selection" }, no_anim = true, blur = false })
hl.layer_rule({ name = "layerrule-1", match = { namespace = "waybar" }, animation = "slide down", blur = true })
hl.layer_rule({ name = "layerrule-2", match = { namespace = "wallpaper" }, animation = "fade 50%" })
hl.layer_rule({ name = "layerrule-3", match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ name = "layerrule-4", match = { namespace = "eww" }, blur = true })
hl.layer_rule({ name = "layerrule-5", match = { namespace = "wlogout" }, blur = true })
