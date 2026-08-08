# Marks recognized successful build commands so the Waybar reactor can celebrate.

typeset -g reactor_command_can_trigger_build_celebration=false

reactor_track_potential_build_command() {
    local command_line="$1"
    local build_command_pattern='^[[:space:]]*(cargo[[:space:]]+(build|check)|bun[[:space:]]+((run[[:space:]]+)?build)|npm[[:space:]]+run[[:space:]]+build|pnpm[[:space:]]+((run[[:space:]]+)?build)|yarn[[:space:]]+((run[[:space:]]+)?build)|make([[:space:]]|$)|ninja([[:space:]]|$)|cmake[[:space:]]+--build|meson[[:space:]]+compile|go[[:space:]]+build|dotnet[[:space:]]+build|gradle([[:space:]].*)?[[:space:]]+build|\./gradlew([[:space:]].*)?[[:space:]]+build)'

    if [[ "$command_line" =~ "$build_command_pattern" ]]; then
        reactor_command_can_trigger_build_celebration=true
    else
        reactor_command_can_trigger_build_celebration=false
    fi
}

reactor_celebrate_finished_build() {
    local finished_command_exit_code="$1"
    local reactor_status_script="$HOME/.config/waybar/scripts/reactor-status.sh"

    if [[ "$reactor_command_can_trigger_build_celebration" == true ]] &&
       ((finished_command_exit_code == 0)) &&
       [[ -x "$reactor_status_script" ]]; then
        "$reactor_status_script" celebrate-build >/dev/null 2>&1
    fi

    reactor_command_can_trigger_build_celebration=false
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec reactor_track_potential_build_command
