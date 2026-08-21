#!/bin/bash
# Rofi-driven display and Sunshine network-display manager for Hyprland.

set -uo pipefail

ROFI_THEME="${ROFI_THEME:-$HOME/.config/rofi/config.rasi}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-display"
MODE_FILE="$STATE_DIR/mode"
EXTERNAL_FILE="$STATE_DIR/external"
NETWORK_OUTPUT_FILE="$STATE_DIR/network-output"
NETWORK_MODE_FILE="$STATE_DIR/network-mode"
SUNSHINE_OUTPUT_ID_FILE="$STATE_DIR/sunshine-output-id"
PROMPT_LOCK="$STATE_DIR/prompt.lock"
LOG_FILE="$HOME/.config/hypr/logs/display-manager.log"
SUNSHINE_CONFIG_DIR="${SUNSHINE_CONFIG_DIR:-$HOME/.config/sunshine}"
SUNSHINE_CONFIG_FILE="$SUNSHINE_CONFIG_DIR/sunshine.conf"
SUNSHINE_APPS_FILE="$SUNSHINE_CONFIG_DIR/apps.json"
SUNSHINE_LOG_FILE="$STATE_DIR/sunshine.log"
SUNSHINE_APP_NAME="${SUNSHINE_APP_NAME:-Hyprland Network Display}"
SUNSHINE_WEB_UI="${SUNSHINE_WEB_UI:-https://localhost:47990}"
SUNSHINE_SERVICE="${SUNSHINE_SERVICE:-app-dev.lizardbyte.app.Sunshine.service}"

LAPTOP_FALLBACK="${DISPLAY_MANAGER_LAPTOP:-eDP-1}"
LAPTOP_MODE="${DISPLAY_MANAGER_LAPTOP_MODE:-2560x1440@165.00}"
LAPTOP_SCALE="${DISPLAY_MANAGER_LAPTOP_SCALE:-1}"
EXTERNAL_SCALE="${DISPLAY_MANAGER_EXTERNAL_SCALE:-1}"
NETWORK_SCALE="${DISPLAY_MANAGER_NETWORK_SCALE:-1}"

mkdir -p "$STATE_DIR" "$(dirname "$LOG_FILE")"

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG_FILE"
}

notify() {
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send -u low "$1" "$2" -t 2500
}

refresh_waybar_display_mode() {
    pkill -RTMIN+11 waybar 2>/dev/null || true
}

refresh_waybar_keyboard_layout() {
    pkill -RTMIN+13 waybar 2>/dev/null || true
}

valid_json() {
    jq -e . >/dev/null 2>&1
}

hypr_instance_signature() {
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local found

    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
        return 0
    fi

    found="$(
        find "$runtime_dir/hypr" -maxdepth 2 -type s -name .socket.sock -printf '%h\n' 2>/dev/null |
            awk -F/ '{print $NF}' |
            sort |
            tail -n 1
    )"
    [ -n "$found" ] || return 1
    printf '%s\n' "$found"
}

hyprctl_cmd() {
    local signature

    signature="$(hypr_instance_signature 2>/dev/null || true)"
    if [ -n "$signature" ]; then
        hyprctl --instance "$signature" "$@"
    else
        hyprctl "$@"
    fi
}

hypr_monitors_json() {
    local scope="${1:-active}"
    local out

    if [ "$scope" = "all" ]; then
        out="$(hyprctl_cmd -j monitors all 2>/dev/null)" || out=""
        if printf '%s' "$out" | valid_json; then
            printf '%s\n' "$out"
            return 0
        fi
    fi

    out="$(hyprctl_cmd -j monitors 2>/dev/null)" || out=""
    if printf '%s' "$out" | valid_json; then
        printf '%s\n' "$out"
        return 0
    fi

    return 1
}

is_laptop_output() {
    [[ "${1:-}" == eDP-* ]]
}

network_output_name() {
    cat "$NETWORK_OUTPUT_FILE" 2>/dev/null || true
}

is_network_output() {
    local output="${1:-}"
    local network_output

    [ -n "$output" ] || return 1
    network_output="$(network_output_name)"

    [ -n "$network_output" ] && [ "$output" = "$network_output" ] && return 0
    [[ "$output" == *HEADLESS-* ]]
}

event_output_name() {
    local payload="${1:-}"

    if [[ "$payload" == *,* ]]; then
        payload="${payload#*,}"
        payload="${payload%%,*}"
    fi

    printf '%s\n' "$payload"
}

detect_laptop() {
    local json laptop
    if json="$(hypr_monitors_json all)"; then
        laptop="$(printf '%s' "$json" | jq -r '[.[] | select(.name | test("^eDP-"))][0].name // empty')"
        if [ -n "$laptop" ]; then
            printf '%s\n' "$laptop"
            return 0
        fi
    fi

    printf '%s\n' "$LAPTOP_FALLBACK"
}

detect_external() {
    local preferred="${1:-}"
    local allow_cached="${2:-yes}"
    local json external

    if [ -n "$preferred" ] && ! is_laptop_output "$preferred" && ! is_network_output "$preferred"; then
        printf '%s\n' "$preferred"
        return 0
    fi

    if json="$(hypr_monitors_json all)"; then
        external="$(
            printf '%s' "$json" |
                jq -r --arg network "$(network_output_name)" \
                    '[.[] | select((.name | test("^eDP-")) | not) | select(.name != $network) | select((.name | test("^HEADLESS-")) | not)][0].name // empty'
        )"
        if [ -n "$external" ]; then
            printf '%s\n' "$external"
            return 0
        fi
    fi

    if [ "$allow_cached" = "yes" ] && [ -s "$EXTERNAL_FILE" ]; then
        external="$(cat "$EXTERNAL_FILE")"
        if [ -n "$external" ] && ! is_laptop_output "$external" && ! is_network_output "$external"; then
            printf '%s\n' "$external"
            return 0
        fi
    fi

    return 1
}

hypr_monitor() {
    local rule="$1"
    log "hyprctl keyword monitor $rule"
    hyprctl_cmd keyword monitor "$rule" >/dev/null
}

write_state() {
    local mode="$1"
    local external="${2:-}"

    printf '%s\n' "$mode" > "$MODE_FILE"
    if [ -n "$external" ]; then
        printf '%s\n' "$external" > "$EXTERNAL_FILE"
    fi
}

require_external() {
    local external="${1:-}"
    if [ -z "$external" ]; then
        notify "Display Mode" "No external monitor found"
        log "No external monitor found"
        return 1
    fi
}

apply_mode() {
    local mode="$1"
    local preferred_external="${2:-}"
    local laptop external

    laptop="$(detect_laptop)"

    case "$mode" in
        extend)
            external="$(detect_external "$preferred_external" no 2>/dev/null || true)"
            require_external "$external" || return 1
            hypr_monitor "$laptop,$LAPTOP_MODE,0x0,$LAPTOP_SCALE" || return 1
            hypr_monitor "$external,preferred,auto-right,$EXTERNAL_SCALE" || return 1
            write_state extend "$external"
            notify "Display Mode" "Extended"
            ;;
        mirror)
            external="$(detect_external "$preferred_external" no 2>/dev/null || true)"
            require_external "$external" || return 1
            hypr_monitor "$laptop,$LAPTOP_MODE,0x0,$LAPTOP_SCALE" || return 1
            hypr_monitor "$external,preferred,0x0,$EXTERNAL_SCALE,mirror,$laptop" || return 1
            write_state mirror "$external"
            notify "Display Mode" "Mirroring"
            ;;
        external-only)
            external="$(detect_external "$preferred_external" no 2>/dev/null || true)"
            require_external "$external" || return 1
            hypr_monitor "$external,preferred,0x0,$EXTERNAL_SCALE" || return 1
            sleep 0.2
            hypr_monitor "$laptop,disable" || return 1
            write_state external-only "$external"
            notify "Display Mode" "External only"
            ;;
        laptop-only)
            external="$(detect_external "$preferred_external" yes 2>/dev/null || true)"
            hypr_monitor "$laptop,$LAPTOP_MODE,0x0,$LAPTOP_SCALE" || return 1
            if [ -n "$external" ]; then
                hypr_monitor "$external,disable" || true
            fi
            write_state laptop-only "$external"
            notify "Display Mode" "Laptop only"
            ;;
        *)
            printf 'Unknown display mode: %s\n' "$mode" >&2
            return 2
            ;;
    esac

    refresh_waybar_display_mode
}

choose_mode() {
    local preferred_external="${1:-}"
    local choice

    choice="$(
        printf '%s\n' "Extend" "Mirror" "External only" "Laptop only" "Cancel" |
            rofi -dmenu -i -no-custom -theme "$ROFI_THEME" -p "Display"
    )" || return 0

    case "$choice" in
        Extend) apply_mode extend "$preferred_external" ;;
        Mirror) apply_mode mirror "$preferred_external" ;;
        "External only") apply_mode external-only "$preferred_external" ;;
        "Laptop only") apply_mode laptop-only "$preferred_external" ;;
        Cancel|"") return 0 ;;
    esac
}

choose_display_center() {
    local choice

    choice="$(
        printf '%s\n' "Physical displays" "Network display" "Sunshine web UI" "Status" "Cancel" |
            rofi -dmenu -i -no-custom -theme "$ROFI_THEME" -p "Display"
    )" || return 0

    case "$choice" in
        "Physical displays") choose_mode ;;
        "Network display") choose_network ;;
        "Sunshine web UI") open_sunshine_web ;;
        Status) show_status ;;
        Cancel|"") return 0 ;;
    esac
}

choose_network() {
    local choice

    choice="$(
        printf '%s\n' "Prepare network display" "Stop network display" "Restart Sunshine" "Sunshine web UI" "Status" "Cancel" |
            rofi -dmenu -i -no-custom -theme "$ROFI_THEME" -p "Network Display"
    )" || return 0

    case "$choice" in
        "Prepare network display") network_prepare ;;
        "Stop network display") network_stop ;;
        "Restart Sunshine") restart_sunshine ;;
        "Sunshine web UI") open_sunshine_web ;;
        Status) show_status ;;
        Cancel|"") return 0 ;;
    esac
}

active_output_names() {
    local json
    json="$(hypr_monitors_json active)" || return 1
    printf '%s' "$json" | jq -r '.[].name'
}

infer_mode() {
    local state active_names laptop_active external_active

    state="$(cat "$MODE_FILE" 2>/dev/null || true)"
    active_names="$(active_output_names 2>/dev/null || true)"

    laptop_active="$(printf '%s\n' "$active_names" | grep -E '^eDP-' | head -n 1 || true)"
    external_active="$(printf '%s\n' "$active_names" | while IFS= read -r output; do
        [ -n "$output" ] || continue
        is_laptop_output "$output" && continue
        is_network_output "$output" && continue
        printf '%s\n' "$output"
    done | head -n 1 || true)"

    if network_active; then
        printf 'network\n'
        return 0
    fi

    if [ -n "$laptop_active" ] && [ -z "$external_active" ]; then
        printf 'laptop-only\n'
    elif [ -z "$laptop_active" ] && [ -n "$external_active" ]; then
        printf 'external-only\n'
    elif [ -n "$laptop_active" ] && [ -n "$external_active" ]; then
        case "$state" in
            mirror|extend) printf '%s\n' "$state" ;;
            *) printf 'extend\n' ;;
        esac
    elif [ -n "$state" ]; then
        printf '%s\n' "$state"
    else
        printf 'unknown\n'
    fi
}

status_json() {
    case "$(infer_mode)" in
        network)
            printf '{"text":"DISP net","tooltip":"Sunshine network display active - click for display center","class":"network"}\n'
            ;;
        extend)
            printf '{"text":"DISP extend","tooltip":"Extended - click for display center","class":"extend"}\n'
            ;;
        mirror)
            printf '{"text":"DISP mirror","tooltip":"Mirroring - click for display center","class":"mirror"}\n'
            ;;
        external-only)
            printf '{"text":"DISP external","tooltip":"External only - click for display center","class":"external"}\n'
            ;;
        laptop-only)
            printf '{"text":"DISP laptop","tooltip":"Laptop only - click for display center","class":"laptop"}\n'
            ;;
        *)
            printf '{"text":"DISP ?","tooltip":"Display state unknown - click for display center","class":"unknown"}\n'
            ;;
    esac
}

network_active() {
    local output json

    output="$(network_output_name)"
    [ -n "$output" ] || return 1
    json="$(hypr_monitors_json all)" || return 1
    printf '%s' "$json" | jq -e --arg output "$output" '.[] | select(.name == $output and (.disabled // false | not))' >/dev/null
}

sunshine_running() {
    systemctl --user is-active --quiet "$SUNSHINE_SERVICE" 2>/dev/null && return 0
    pgrep -x sunshine >/dev/null 2>&1
}

show_status() {
    local output mode sunshine

    output="$(network_output_name)"
    mode="$(cat "$NETWORK_MODE_FILE" 2>/dev/null || true)"
    if sunshine_running; then
        sunshine="running"
    else
        sunshine="stopped"
    fi

    notify "Display Status" "Mode: $(infer_mode)
Network output: ${output:-none}
Network mode: ${mode:-waiting for client}
Sunshine: $sunshine"
}

open_sunshine_web() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$SUNSHINE_WEB_UI" >/dev/null 2>&1 &
    fi
    notify "Sunshine" "Opening $SUNSHINE_WEB_UI"
}

ensure_sunshine_installed() {
    if command -v sunshine >/dev/null 2>&1; then
        return 0
    fi

    notify "Sunshine" "Sunshine is not installed yet"
    printf 'sunshine is not installed. Install it first, then run this again.\n' >&2
    return 1
}

set_sunshine_conf_key() {
    local key="$1"
    local value="$2"
    local tmp

    mkdir -p "$SUNSHINE_CONFIG_DIR"
    touch "$SUNSHINE_CONFIG_FILE"
    tmp="$(mktemp)"

    awk -v key="$key" -v value="$value" '
        BEGIN { done = 0 }
        $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
            print key " = " value
            done = 1
            next
        }
        { print }
        END {
            if (!done) {
                print key " = " value
            }
        }
    ' "$SUNSHINE_CONFIG_FILE" > "$tmp" && mv "$tmp" "$SUNSHINE_CONFIG_FILE"
}

remove_sunshine_conf_key() {
    local key="$1"
    local tmp

    mkdir -p "$SUNSHINE_CONFIG_DIR"
    touch "$SUNSHINE_CONFIG_FILE"
    tmp="$(mktemp)"

    awk -v key="$key" '
        $0 ~ "^[[:space:]]*" key "[[:space:]]*=" { next }
        { print }
    ' "$SUNSHINE_CONFIG_FILE" > "$tmp" && mv "$tmp" "$SUNSHINE_CONFIG_FILE"
}

write_sunshine_apps() {
    local tmp app_json prep_do prep_undo script_path

    mkdir -p "$SUNSHINE_CONFIG_DIR"
    if ! jq -e . "$SUNSHINE_APPS_FILE" >/dev/null 2>&1; then
        printf '{"env":{},"apps":[]}\n' > "$SUNSHINE_APPS_FILE"
    fi

    script_path="$HOME/.config/hypr/scripts/display-manager.sh"
    prep_do="sh -c '$script_path network-client-start \"\$SUNSHINE_CLIENT_WIDTH\" \"\$SUNSHINE_CLIENT_HEIGHT\" \"\$SUNSHINE_CLIENT_FPS\"'"
    prep_undo="sh -c '$script_path network-client-stop'"
    app_json="$(
        jq -n \
            --arg name "$SUNSHINE_APP_NAME" \
            --arg prep_do "$prep_do" \
            --arg prep_undo "$prep_undo" \
            '{
                name: $name,
                output: "",
                cmd: "",
                detached: [],
                "exclude-global-prep-cmd": false,
                "prep-cmd": [
                    {
                        do: $prep_do,
                        undo: $prep_undo,
                        elevated: false
                    }
                ],
                "image-path": "desktop.png"
            }'
    )"

    tmp="$(mktemp)"
    jq --argjson app "$app_json" '
        if type != "object" then
            {"env": {}, "apps": []}
        else
            .
        end
        | .env = (.env // {})
        | .apps = (((.apps // []) | map(select(.name != $app.name))) + [$app])
    ' "$SUNSHINE_APPS_FILE" > "$tmp" && mv "$tmp" "$SUNSHINE_APPS_FILE"
}

sunshine_output_id_for() {
    local output="$1"
    local id log

    for log in "$SUNSHINE_LOG_FILE" "$SUNSHINE_CONFIG_DIR/sunshine.log"; do
        [ -r "$log" ] || continue
        id="$(
            awk -v name="$output" '
                index($0, "Detected display: " name " (id: ") {
                    line = $0
                    sub(/^.*\(id: /, "", line)
                    sub(/\).*/, "", line)
                    print line
                }
                index($0, "[wlgrab] Monitor ") && index($0, " is " name) {
                    line = $0
                    sub(/^.*Monitor /, "", line)
                    sub(/ is .*/, "", line)
                    print line
                }
            ' "$log" | tail -n 1
        )"
        [ -n "$id" ] && printf '%s\n' "$id" && return 0
    done

    if command -v journalctl >/dev/null 2>&1; then
        id="$(
            journalctl --user -u "$SUNSHINE_SERVICE" -n 300 --no-pager 2>/dev/null |
                awk -v name="$output" '
                    index($0, "Detected display: " name " (id: ") {
                        line = $0
                        sub(/^.*\(id: /, "", line)
                        sub(/\).*/, "", line)
                        print line
                    }
                    index($0, "[wlgrab] Monitor ") && index($0, " is " name) {
                        line = $0
                        sub(/^.*Monitor /, "", line)
                        sub(/ is .*/, "", line)
                        print line
                    }
                ' |
                tail -n 1
        )"
        [ -n "$id" ] && printf '%s\n' "$id" && return 0
    fi

    return 1
}

wait_for_sunshine_output_id() {
    local output="$1"
    local id attempt

    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        id="$(sunshine_output_id_for "$output" 2>/dev/null || true)"
        if [ -n "$id" ]; then
            printf '%s\n' "$id"
            return 0
        fi
        sleep 0.5
    done

    return 1
}

configure_sunshine() {
    local output_id="${1:-}"

    set_sunshine_conf_key capture wlr
    if [ -n "$output_id" ]; then
        set_sunshine_conf_key output_name "$output_id"
    else
        remove_sunshine_conf_key output_name
    fi
    set_sunshine_conf_key file_apps apps.json
    set_sunshine_conf_key log_path "$SUNSHINE_LOG_FILE"
    write_sunshine_apps
}

map_sunshine_output() {
    local output="$1"
    local output_id

    output_id="$(wait_for_sunshine_output_id "$output")" || {
        notify "Network Display" "Could not map $output to a Sunshine display ID"
        log "Could not map $output to a Sunshine output_name id"
        return 1
    }

    printf '%s\n' "$output_id" > "$SUNSHINE_OUTPUT_ID_FILE"
    configure_sunshine "$output_id"
    log "Mapped $output to Sunshine display id $output_id"
}

monitor_names_from_json() {
    jq -r '.[].name' 2>/dev/null
}

detect_new_output() {
    local before="$1"
    local after="$2"
    local output

    output="$(
        comm -13 \
            <(printf '%s' "$before" | monitor_names_from_json | sort) \
            <(printf '%s' "$after" | monitor_names_from_json | sort) |
            grep -E '^HEADLESS-' |
            head -n 1
    )"

    if [ -z "$output" ]; then
        output="$(
            comm -13 \
                <(printf '%s' "$before" | monitor_names_from_json | sort) \
                <(printf '%s' "$after" | monitor_names_from_json | sort) |
                head -n 1
        )"
    fi

    printf '%s\n' "$output"
}

ensure_network_output() {
    local output before after attempt

    output="$(network_output_name)"
    if [ -n "$output" ] && hypr_monitors_json all | jq -e --arg output "$output" '.[] | select(.name == $output)' >/dev/null; then
        printf '%s\n' "$output"
        return 0
    fi

    before="$(hypr_monitors_json all)" || before="[]"
    log "hyprctl output create headless"
    hyprctl_cmd output create headless >/dev/null || return 1

    for attempt in 1 2 3 4 5; do
        sleep 0.2
        after="$(hypr_monitors_json all)" || after="[]"
        output="$(detect_new_output "$before" "$after")"
        if [ -n "$output" ]; then
            printf '%s\n' "$output" > "$NETWORK_OUTPUT_FILE"
            printf '%s\n' "$output"
            return 0
        fi
    done

    notify "Network Display" "Could not detect the new Hyprland headless output"
    return 1
}

restart_sunshine() {
    ensure_sunshine_installed || return 1

    if systemctl --user restart "$SUNSHINE_SERVICE" >/dev/null 2>&1; then
        notify "Sunshine" "Restarted"
        return 0
    fi

    pkill -x sunshine 2>/dev/null || true
    sleep 0.5
    nohup sunshine >/dev/null 2>&1 &
    notify "Sunshine" "Started"
}

stop_sunshine() {
    if systemctl --user stop "$SUNSHINE_SERVICE" >/dev/null 2>&1; then
        return 0
    fi

    pkill -x sunshine 2>/dev/null || true
}

remove_network_output() {
    local output

    output="$(network_output_name)"
    [ -n "$output" ] || return 0

    if hypr_monitors_json all | jq -e --arg output "$output" '.[] | select(.name == $output)' >/dev/null; then
        log "hyprctl output remove $output"
        hyprctl_cmd output remove "$output" >/dev/null || true
    fi

    rm -f "$NETWORK_OUTPUT_FILE" "$NETWORK_MODE_FILE" "$SUNSHINE_OUTPUT_ID_FILE"
    if [ -s "$EXTERNAL_FILE" ] && is_network_output "$(cat "$EXTERNAL_FILE")"; then
        rm -f "$EXTERNAL_FILE"
    fi
    remove_sunshine_conf_key output_name
    refresh_waybar_display_mode
}

network_prepare() {
    local output

    ensure_sunshine_installed || return 1
    output="$(ensure_network_output)" || return 1
    configure_sunshine ""
    restart_sunshine || return 1
    map_sunshine_output "$output" || return 1
    restart_sunshine || return 1
    notify "Network Display" "Prepared $output. Pick '$SUNSHINE_APP_NAME' from Moonlight."
    refresh_waybar_display_mode
}

valid_dimension() {
    [[ "${1:-}" =~ ^[0-9]{3,5}$ ]]
}

valid_fps() {
    [[ "${1:-}" =~ ^[0-9]{1,4}([.][0-9]{1,3})?$ ]]
}

network_client_start() {
    local width="${1:-}"
    local height="${2:-}"
    local fps="${3:-}"
    local output

    if ! valid_dimension "$width" || ! valid_dimension "$height" || ! valid_fps "$fps"; then
        notify "Network Display" "Missing client resolution/FPS from Sunshine"
        log "Invalid Sunshine client mode: width='$width' height='$height' fps='$fps'"
        return 1
    fi

    output="$(ensure_network_output)" || return 1
    configure_sunshine "$(cat "$SUNSHINE_OUTPUT_ID_FILE" 2>/dev/null || true)"
    hypr_monitor "$output,${width}x${height}@${fps},auto-right,$NETWORK_SCALE" || return 1
    printf '%sx%s@%s\n' "$width" "$height" "$fps" > "$NETWORK_MODE_FILE"
    notify "Network Display" "Streaming ${width}x${height}@${fps} on $output"
    refresh_waybar_display_mode
}

network_client_stop() {
    remove_network_output
    notify "Network Display" "Client stream ended"
}

network_stop() {
    stop_sunshine
    remove_network_output
    notify "Network Display" "Stopped"
}

socket_path() {
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local explicit="$runtime_dir/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"
    local found

    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -S "$explicit" ]; then
        printf '%s\n' "$explicit"
        return 0
    fi

    found="$(find "$runtime_dir/hypr" -maxdepth 2 -type s -name .socket2.sock 2>/dev/null | sort | tail -n 1)"
    if [ -n "$found" ]; then
        printf '%s\n' "$found"
        return 0
    fi

    return 1
}

handle_added() {
    local output="$1"
    is_laptop_output "$output" && return 0
    is_network_output "$output" && return 0

    printf '%s\n' "$output" > "$EXTERNAL_FILE"
    apply_mode extend "$output" || true

    if mkdir "$PROMPT_LOCK" 2>/dev/null; then
        choose_mode "$output"
        rmdir "$PROMPT_LOCK" 2>/dev/null || true
    else
        log "Prompt already active, skipping hotplug prompt for $output"
    fi
}

handle_removed() {
    local output="$1"
    is_laptop_output "$output" && return 0
    is_network_output "$output" && return 0

    log "External monitor removed: $output"
    apply_mode laptop-only "$output" || true
}

watch_events() {
    local socket line output
    local initial_checked=0

    while true; do
        socket="$(socket_path 2>/dev/null || true)"
        if [ -z "$socket" ]; then
            log "No Hyprland socket2 found; retrying"
            sleep 2
            continue
        fi

        if [ "$initial_checked" -eq 0 ]; then
            initial_checked=1
            output="$(detect_external 2>/dev/null || true)"
            if [ -n "$output" ]; then
                log "Initial external monitor detected: $output"
                handle_added "$output"
            fi
        fi

        log "Listening on $socket"
        socat -U - UNIX-CONNECT:"$socket" 2>>"$LOG_FILE" | while IFS= read -r line; do
            case "$line" in
                monitoradded*">>"*)
                    output="$(event_output_name "${line#*>>}")"
                    log "Monitor added: $output"
                    handle_added "$output"
                    ;;
                monitorremoved*">>"*)
                    output="$(event_output_name "${line#*>>}")"
                    handle_removed "$output"
                    ;;
                activelayout*">>"*)
                    refresh_waybar_keyboard_layout
                    ;;
            esac
        done

        log "Socket listener exited; restarting"
        sleep 1
    done
}

usage() {
    cat <<EOF
Usage: ${0##*/} watch|choose|status-json|apply MODE [OUTPUT]
       ${0##*/} choose-physical|choose-network|network-prepare|network-stop
       ${0##*/} network-client-start WIDTH HEIGHT FPS|network-client-stop

Modes: extend, mirror, external-only, laptop-only
EOF
}

case "${1:-choose}" in
    watch)
        watch_events
        ;;
    choose)
        choose_display_center
        ;;
    choose-physical)
        choose_mode "${2:-}"
        ;;
    choose-network)
        choose_network
        ;;
    status-json)
        status_json
        ;;
    apply)
        shift
        apply_mode "${1:-}" "${2:-}"
        ;;
    network-prepare)
        network_prepare
        ;;
    network-stop)
        network_stop
        ;;
    network-client-start)
        shift
        network_client_start "${1:-}" "${2:-}" "${3:-}"
        ;;
    network-client-stop)
        network_client_stop
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
