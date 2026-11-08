#!/data/data/com.termux/files/usr/bin/bash
set -eu
ha_dir=/data/data/com.termux/files/home/ha
if [ -f "$ha_dir/runtime/ha.pid" ]; then
  ha_pid=$(cat "$ha_dir/runtime/ha.pid")
  if kill -0 "$ha_pid" 2>/dev/null && grep -aqE 'supervise-ha.sh|home-assistant' "/proc/$ha_pid/cmdline"; then
    printf 'Home Assistant is already running (PID %s)\n' "$ha_pid"
    exit 0
  fi
fi
termux-wake-lock
nohup setsid "$ha_dir/supervise-ha.sh" >> "$ha_dir/runtime/console.log" 2>&1 < /dev/null &
ha_pid=$!
printf '%s\n' "$ha_pid" > "$ha_dir/runtime/ha.pid"
printf 'Started Home Assistant (PID %s)\n' "$ha_pid"
