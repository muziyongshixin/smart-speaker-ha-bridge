#!/data/data/com.termux/files/usr/bin/bash
set -eu
ha_dir=/data/data/com.termux/files/home/ha
if [ -f "$ha_dir/runtime/ha.pid" ]; then
  ha_pid=$(cat "$ha_dir/runtime/ha.pid")
  if kill -0 "$ha_pid" 2>/dev/null && grep -aqE 'supervise-ha.sh|home-assistant' "/proc/$ha_pid/cmdline"; then
    # Signal the Python server first so it can save state before PRoot exits.
    ha_frontier="$ha_pid"
    ha_server_pid=""
    for ha_depth in 1 2 3 4; do
      ha_next=""
      for ha_parent in $ha_frontier; do
        for ha_child in $(pgrep -P "$ha_parent" || true); do
          if grep -aq 'homeassistant' "/proc/$ha_child/cmdline" && grep -aq '/usr/local/bin/python3' "/proc/$ha_child/cmdline" && ! grep -aq 'proot' "/proc/$ha_child/cmdline"; then
            ha_server_pid="$ha_child"
          fi
          ha_next="$ha_next $ha_child"
        done
      done
      ha_frontier="$ha_next"
    done
    if [ -n "$ha_server_pid" ]; then
      kill -TERM "$ha_server_pid"
      printf 'Requested graceful Home Assistant shutdown (PID %s)\n' "$ha_server_pid"
    else
      printf 'No running Home Assistant Python server found; no processes stopped\n'
    fi
  fi
fi
