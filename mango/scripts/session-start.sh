#!/bin/sh
# Mango version of the Hyprland "hyprland.start" bootstrap: push the session
# environment to D-Bus/systemd, then start the session target, portals and the
# polkit agent (a systemd user service so it restarts after a crash). Waybar
# starts last because its unit requires graphical-session.target to be up.
vars="WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION KDE_FULL_SESSION XDG_SESSION_TYPE MANGO_INSTANCE_SIGNATURE GTK_THEME QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE XCURSOR_THEME XCURSOR_SIZE"

dbus-update-activation-environment --systemd $vars &&
    systemctl --user import-environment $vars &&
    systemctl --user start mango-session.target &&
    systemctl --user start xdg-desktop-portal.service &&
    systemctl --user start plasma-polkit-agent.service
systemctl --user start waybar.service
