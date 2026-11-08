#!/data/data/com.termux/files/usr/bin/bash
set -eu
ha_dir=/data/data/com.termux/files/home/ha
exec udocker run --nobanner --user=root --workdir=/config \
  --volume="$ha_dir/config:/config" \
  --volume="$ha_dir/runtime/tmp:/tmp" \
  --volume="$ha_dir/runtime/shm:/dev/shm" \
  --volume="$ha_dir/runtime/resolv.conf:/etc/resolv.conf" \
  --volume=/proc/self/fd:/dev/fd \
  --volume=/proc/self/fd/0:/dev/stdin \
  --volume=/proc/self/fd/1:/dev/stdout \
  --volume=/proc/self/fd/2:/dev/stderr \
  --env=TZ=Asia/Shanghai --env=PYTHONUNBUFFERED=1 \
  --entrypoint=/usr/local/bin/python3 \
  home-assistant -m homeassistant --config /config
