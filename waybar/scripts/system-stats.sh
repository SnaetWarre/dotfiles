#!/bin/bash
# ── system-stats.sh ─────────────────────────────────────────
# Description: CPU, RAM, VRAM usage with percentages (minimal)
# Usage: Waybar `custom/system-stats` every 2s
# Dependencies: awk, (optional) nvidia-smi
#  ─────────────────────────────────────────────────────────

set -eo pipefail

# Load wal/pywal colors from colors file
HAVE_PYWAL=false
if [ -f "$HOME/.cache/wal/colors" ]; then
  color_index=0
  while IFS= read -r color || [ -n "$color" ]; do
    color="${color#\#}"
    color="#${color}"
    eval "color${color_index}=${color}"
    color_index=$((color_index + 1))
    [ $color_index -ge 16 ] && break
  done < "$HOME/.cache/wal/colors"

  if [ -n "${color1:-}" ] && [ -n "${color4:-}" ] && [ -n "${color6:-}" ] && [ -n "${color7:-}" ]; then
    HAVE_PYWAL=true
  fi
fi

# CPU calculation
read_cpu() {
  awk '/^cpu\s/ {print $2+$3+$4+$5+$6+$7+$8, $5+$6}' /proc/stat
}

cpu_line_1=$(read_cpu)
sleep 0.2
cpu_line_2=$(read_cpu)

cpu_total_1=$(echo "$cpu_line_1" | awk '{print $1}')
cpu_idle_1=$(echo "$cpu_line_1" | awk '{print $2}')
cpu_total_2=$(echo "$cpu_line_2" | awk '{print $1}')
cpu_idle_2=$(echo "$cpu_line_2" | awk '{print $2}')

cpu_delta=$((cpu_total_2 - cpu_total_1))
idle_delta=$((cpu_idle_2 - cpu_idle_1))

cpu_used_pct=0
if [ "$cpu_delta" -gt 0 ]; then
  cpu_used_pct=$(awk -v i="$idle_delta" -v t="$cpu_delta" 'BEGIN { printf("%.0f", (1 - i/t) * 100) }')
fi

# RAM via /proc/meminfo
mem_total_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
mem_avail_kb=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
mem_used_kb=$((mem_total_kb - mem_avail_kb))

ram_pct=$(awk -v u="$mem_used_kb" -v t="$mem_total_kb" 'BEGIN { if (t>0) printf("%.0f", (u/t)*100); else print 0 }')

to_gib() {
  awk -v k="$1" 'BEGIN { printf("%.1f", k/1024/1024) }'
}

ram_used_gib=$(to_gib "$mem_used_kb")
ram_total_gib=$(to_gib "$mem_total_kb")

# VRAM via nvidia-smi (fallback to N/A if unavailable)
vram_pct="N/A"
vram_used_gib="N/A"
vram_total_gib="N/A"
if command -v nvidia-smi >/dev/null 2>&1; then
  if nv_out=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1); then
    v_used=$(echo "$nv_out" | awk -F, '{print $1}' | xargs)
    v_total=$(echo "$nv_out" | awk -F, '{print $2}' | xargs)
    if [ -n "$v_used" ] && [ -n "$v_total" ] && [ "$v_total" -gt 0 ] 2>/dev/null; then
      vram_pct=$(awk -v u="$v_used" -v t="$v_total" 'BEGIN { printf("%.0f", (u/t)*100) }')
      vram_used_gib=$(awk -v u="$v_used" 'BEGIN { printf("%.1f", u/1024) }')
      vram_total_gib=$(awk -v t="$v_total" 'BEGIN { printf("%.1f", t/1024) }')
    fi
  fi
fi

# Choose color based on thresholds from pywal
pick_color() {
  local pct=$1
  if ! $HAVE_PYWAL; then
    echo ""
    return
  fi
  if [ "$pct" = "N/A" ]; then
    echo "$color7"
  elif [ "$pct" -lt 50 ]; then
    echo "$color4"
  elif [ "$pct" -lt 75 ]; then
    echo "$color3"
  else
    echo "$color1"
  fi
}

format_stat() {
  local label=$1
  local pct=$2
  local text
  if [ "$pct" = "N/A" ]; then
    text="$label N/A"
  else
    text="$label ${pct}%"
  fi

  if $HAVE_PYWAL; then
    local col
    col=$(pick_color "$pct")
    printf "<span foreground='%s'>%s</span>" "$col" "$text"
  else
    printf "%s" "$text"
  fi
}

cpu_text=$(format_stat "CPU" "$cpu_used_pct")
ram_text=$(format_stat "RAM" "$ram_pct")
vram_text=$(format_stat "VRAM" "$vram_pct")

# Tooltip
tooltip_cpu="CPU: ${cpu_used_pct}%"
tooltip_ram="RAM: ${ram_used_gib}/${ram_total_gib} GiB (${ram_pct}%)"
if [ "$vram_pct" = "N/A" ]; then
  tooltip_vram="VRAM: N/A"
else
  tooltip_vram="VRAM: ${vram_used_gib}/${vram_total_gib} GiB (${vram_pct}%)"
fi

# Horizontal layout with pipe separators
text="${cpu_text} | ${ram_text} | ${vram_text}"
tooltip="${tooltip_cpu}\\r${tooltip_ram}\\r${tooltip_vram}"

# Escape for JSON
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//'
}

text_escaped=$(json_escape "$text")
tooltip_escaped="$tooltip"

# Final JSON output
printf '{"text":"%s","tooltip":"%s"}\n' "$text_escaped" "$tooltip_escaped"
