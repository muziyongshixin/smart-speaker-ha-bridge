#!/data/data/com.termux/files/usr/bin/bash
ha_dir=/data/data/com.termux/files/home/ha
while true; do
  "$ha_dir/run-ha.sh"
  ha_exit=$?
  if [ "$ha_exit" -ne 100 ]; then
    printf 'Home Assistant exited with code %s\n' "$ha_exit"
    exit "$ha_exit"
  fi
  sleep 2
done
