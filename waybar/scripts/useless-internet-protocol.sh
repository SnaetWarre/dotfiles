#!/usr/bin/env bash

set -u

default_ipv4_route=$(ip -4 route show default 2>/dev/null | head -n 1)
default_network_interface=$(awk '{for (field_index = 1; field_index <= NF; field_index++) if ($field_index == "dev") {print $(field_index + 1); exit}}' <<< "$default_ipv4_route")
private_ipv4_address=$(awk '{for (field_index = 1; field_index <= NF; field_index++) if ($field_index == "src") {print $(field_index + 1); exit}}' <<< "$default_ipv4_route")

if [[ -z "$private_ipv4_address" && -n "$default_network_interface" ]]; then
    private_ipv4_address=$(ip -o -4 address show dev "$default_network_interface" scope global 2>/dev/null |
        awk 'NR == 1 {split($4, address_with_prefix, "/"); print address_with_prefix[1]}')
fi

if [[ -z "$private_ipv4_address" ]]; then
    private_ipv4_address=$(ip -o -4 address show scope global 2>/dev/null |
        awk '{split($4, address_with_prefix, "/"); ipv4_address = address_with_prefix[1]; if (ipv4_address ~ /^10\./ || ipv4_address ~ /^192\.168\./ || ipv4_address ~ /^172\.(1[6-9]|2[0-9]|3[01])\./) {print ipv4_address; exit}}')
fi

printf 'Useless Internet Protocol: %s\n' "${private_ipv4_address:-offline}"
