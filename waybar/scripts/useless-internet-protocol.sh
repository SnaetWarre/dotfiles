#!/usr/bin/env bash

set -u

print_ipv6_status() {
    local default_ipv6_route default_network_interface global_ipv6_address

    default_ipv6_route=$(ip -6 route show default 2>/dev/null | head -n 1)
    default_network_interface=$(awk '{for (field_index = 1; field_index <= NF; field_index++) if ($field_index == "dev") {print $(field_index + 1); exit}}' <<< "$default_ipv6_route")
    global_ipv6_address=$(awk '{for (field_index = 1; field_index <= NF; field_index++) if ($field_index == "src") {print $(field_index + 1); exit}}' <<< "$default_ipv6_route")

    if [[ -z "$global_ipv6_address" && -n "$default_network_interface" ]]; then
        global_ipv6_address=$(ip -o -6 address show dev "$default_network_interface" scope global 2>/dev/null |
            awk 'NR == 1 {split($4, address_with_prefix, "/"); print address_with_prefix[1]}')
    fi

    if [[ -z "$global_ipv6_address" ]]; then
        global_ipv6_address=$(ip -o -6 address show scope global 2>/dev/null |
            awk 'NR == 1 {split($4, address_with_prefix, "/"); print address_with_prefix[1]}')
    fi

    printf 'Useless Internet Protocol: %s\n' "${global_ipv6_address:-offline}"
}

print_ipv6_status

if [[ "${1:-}" == "--watch" ]]; then
    while IFS= read -r network_event; do
        [[ -n "$network_event" ]] && print_ipv6_status
    done < <(ip -6 monitor address route link 2>/dev/null)
fi
