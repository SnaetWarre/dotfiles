#!/usr/bin/env bash

set -u

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    reactor_runtime_directory="$XDG_RUNTIME_DIR/waybar-reactor"
else
    reactor_runtime_directory="/tmp/waybar-reactor-$UID"
fi

mkdir -p "$reactor_runtime_directory"
chmod 700 "$reactor_runtime_directory" 2>/dev/null || true

build_celebration_deadline_file="$reactor_runtime_directory/build-celebration-deadline"
cpu_sample_file="$reactor_runtime_directory/cpu-sample"
low_activity_sample_count_file="$reactor_runtime_directory/low-activity-sample-count"
reactor_watcher_pid_file="$reactor_runtime_directory/watcher.pid"
reactor_wakeup_pipe="$reactor_runtime_directory/wakeup.pipe"

current_epoch_seconds=$EPOCHSECONDS

if [[ "${1:-}" == "celebrate-build" ]]; then
    build_celebration_deadline=$((current_epoch_seconds + 12))
    temporary_deadline_file="$build_celebration_deadline_file.$$"
    printf '%s\n' "$build_celebration_deadline" > "$temporary_deadline_file"
    mv -f "$temporary_deadline_file" "$build_celebration_deadline_file"
    reactor_watcher_pid=0
    if [[ -r "$reactor_watcher_pid_file" ]]; then
        read -r reactor_watcher_pid < "$reactor_watcher_pid_file" || reactor_watcher_pid=0
    fi
    if [[ "$reactor_watcher_pid" =~ ^[1-9][0-9]*$ ]] &&
       kill -0 "$reactor_watcher_pid" 2>/dev/null &&
       [[ -p "$reactor_wakeup_pipe" ]]; then
        printf '\n' > "$reactor_wakeup_pipe"
    fi
    exit 0
fi

read_cpu_usage_percent() {
    local cpu_label cpu_user cpu_nice cpu_system cpu_idle cpu_iowait
    local cpu_irq cpu_softirq cpu_steal cpu_guest cpu_guest_nice
    local cpu_total cpu_idle_total previous_cpu_total previous_cpu_idle_total
    local cpu_total_delta cpu_idle_delta

    read -r cpu_label cpu_user cpu_nice cpu_system cpu_idle cpu_iowait \
        cpu_irq cpu_softirq cpu_steal cpu_guest cpu_guest_nice < /proc/stat

    cpu_total=$((cpu_user + cpu_nice + cpu_system + cpu_idle + cpu_iowait + cpu_irq + cpu_softirq + cpu_steal))
    cpu_idle_total=$((cpu_idle + cpu_iowait))

    if [[ -r "$cpu_sample_file" ]] &&
       read -r previous_cpu_total previous_cpu_idle_total < "$cpu_sample_file"; then
        cpu_total_delta=$((cpu_total - previous_cpu_total))
        cpu_idle_delta=$((cpu_idle_total - previous_cpu_idle_total))

        if ((cpu_total_delta > 0)); then
            printf '%d\n' "$(((cpu_total_delta - cpu_idle_delta) * 100 / cpu_total_delta))"
        else
            printf '0\n'
        fi
    else
        printf '0\n'
    fi

    printf '%s %s\n' "$cpu_total" "$cpu_idle_total" > "$cpu_sample_file"
}

find_playing_track() {
    local player_name player_playback_status playing_track_metadata

    while IFS=$'\t' read -r player_name player_playback_status playing_track_metadata; do
        if [[ "$player_playback_status" == "Playing" ]]; then
            if [[ -n "$playing_track_metadata" ]]; then
                printf '%s\n' "$playing_track_metadata"
            else
                printf '%s\n' "$player_name"
            fi
            return 0
        fi
    done < <(playerctl --all-players metadata \
        --format $'{{playerName}}\t{{status}}\t{{artist}} — {{title}}' 2>/dev/null)

    return 1
}

print_reactor_status() {
current_epoch_seconds=$EPOCHSECONDS
cpu_usage_percent=${REACTOR_CPU_USAGE_PERCENT_OVERRIDE:-$(read_cpu_usage_percent)}
if [[ -n "${REACTOR_BATTERY_CAPACITY_PERCENT_OVERRIDE:-}" ]]; then
    battery_capacity_percent=$REACTOR_BATTERY_CAPACITY_PERCENT_OVERRIDE
elif ! read -r battery_capacity_percent < /sys/class/power_supply/BAT0/capacity 2>/dev/null; then
    battery_capacity_percent=100
fi
if [[ -n "${REACTOR_BATTERY_CHARGE_STATUS_OVERRIDE:-}" ]]; then
    battery_charge_status=$REACTOR_BATTERY_CHARGE_STATUS_OVERRIDE
elif ! read -r battery_charge_status < /sys/class/power_supply/BAT0/status 2>/dev/null; then
    battery_charge_status=Unknown
fi

if [[ -n "${REACTOR_PLAYING_TRACK_OVERRIDE:-}" ]]; then
    playing_track="$REACTOR_PLAYING_TRACK_OVERRIDE"
else
    playing_track=$(find_playing_track || true)
fi

if [[ -n "$playing_track" ]]; then
    music_is_playing=true
else
    music_is_playing=false
fi

if [[ -n "${REACTOR_LOW_ACTIVITY_SAMPLE_COUNT_OVERRIDE:-}" ]]; then
    low_activity_sample_count=$REACTOR_LOW_ACTIVITY_SAMPLE_COUNT_OVERRIDE
elif ((cpu_usage_percent < 10)) && [[ "$music_is_playing" == false ]]; then
    low_activity_sample_count=0
    if [[ -r "$low_activity_sample_count_file" ]]; then
        read -r low_activity_sample_count < "$low_activity_sample_count_file" || low_activity_sample_count=0
    fi
    low_activity_sample_count=$((low_activity_sample_count + 1))
else
    low_activity_sample_count=0
fi
printf '%s\n' "$low_activity_sample_count" > "$low_activity_sample_count_file"

build_celebration_deadline=0
if [[ -r "$build_celebration_deadline_file" ]]; then
    read -r build_celebration_deadline < "$build_celebration_deadline_file" || build_celebration_deadline=0
fi
animation_frame=$((current_epoch_seconds % 2))

if ((battery_capacity_percent <= 15)) && [[ "$battery_charge_status" == "Discharging" ]]; then
    reactor_state="panicking"
    reactor_state_label="PANICKING"
    if ((animation_frame == 0)); then reactor_face='[!_!]'; else reactor_face='[!o!]'; fi
elif ((current_epoch_seconds < build_celebration_deadline)); then
    reactor_state="celebrating"
    reactor_state_label="BUILD COMPLETE"
    if ((animation_frame == 0)); then reactor_face='[*v*]'; else reactor_face='[+v+]'; fi
elif ((cpu_usage_percent >= 88)); then
    reactor_state="radioactive"
    reactor_state_label="RADIOACTIVE"
    if ((animation_frame == 0)); then reactor_face='[#x#]'; else reactor_face='[x#x]'; fi
elif ((cpu_usage_percent >= 65)); then
    reactor_state="overheating"
    reactor_state_label="OVERHEATING"
    if ((animation_frame == 0)); then reactor_face='[#~#]'; else reactor_face='[%~%]'; fi
elif [[ "$music_is_playing" == true ]]; then
    reactor_state="dancing"
    reactor_state_label="DANCING"
    if ((animation_frame == 0)); then reactor_face='[^o^]'; else reactor_face='[^.^]'; fi
elif ((low_activity_sample_count >= 15)); then
    reactor_state="sleeping"
    reactor_state_label="SLEEPING"
    if ((animation_frame == 0)); then reactor_face='[-_-]'; else reactor_face='[-.-]'; fi
else
    reactor_state="awake"
    reactor_state_label="AWAKE"
    if ((animation_frame == 0)); then reactor_face='[o_o]'; else reactor_face='[o.o]'; fi
fi

reactor_tooltip="REACTOR: $reactor_state_label\nCPU: ${cpu_usage_percent}%\nBattery: ${battery_capacity_percent}% ($battery_charge_status)"
if [[ "$music_is_playing" == true ]]; then
    reactor_tooltip+="\nPlaying: $playing_track"
fi

json_escape() {
    local escaped_text=$1

    escaped_text=${escaped_text//\\/\\\\}
    escaped_text=${escaped_text//\"/\\\"}
    escaped_text=${escaped_text//$'\n'/\\n}
    escaped_text=${escaped_text//$'\r'/\\r}
    escaped_text=${escaped_text//$'\t'/\\t}
    printf '%s' "$escaped_text"
}

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$(json_escape "$reactor_face")" \
    "$(json_escape "$reactor_tooltip")" \
    "$(json_escape "$reactor_state")"
}

if [[ "${1:-}" == "--watch" ]]; then
    rm -f "$reactor_wakeup_pipe"
    mkfifo -m 600 "$reactor_wakeup_pipe"
    printf '%s\n' "$$" > "$reactor_watcher_pid_file"
    exec {reactor_wakeup_file_descriptor}<>"$reactor_wakeup_pipe"

    cleanup_reactor_watcher() {
        local recorded_watcher_pid=0

        if [[ -r "$reactor_watcher_pid_file" ]]; then
            read -r recorded_watcher_pid < "$reactor_watcher_pid_file" || recorded_watcher_pid=0
        fi
        if [[ "$recorded_watcher_pid" == "$$" ]]; then
            rm -f "$reactor_watcher_pid_file" "$reactor_wakeup_pipe"
        fi
    }
    trap cleanup_reactor_watcher EXIT
    trap 'exit 0' INT TERM

    while true; do
        print_reactor_status
        IFS= read -r -t 1 -u "$reactor_wakeup_file_descriptor" _ || true
    done
else
    print_reactor_status
fi
