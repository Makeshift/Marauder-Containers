#!/usr/bin/with-contenv bash
  echo '----------------------------------------------'
  echo '|  Replacing Timeouts & Intervals in Bazarr  |'
  echo '----------------------------------------------'
  echo

find /app/bazarr/ -type f -name "*.py" | xargs sed -E -i 's/timeout=[0-9]{1,3}/timeout=600/g'
sed -i 's/IntervalTrigger(minutes=1)/IntervalTrigger(hours=6)/g' /app/bazarr/bazarr/scheduler.py
sed -i 's/IntervalTrigger(minutes=5)/IntervalTrigger\(hours=8\)/g' /app/bazarr/bazarr/scheduler.py

echo Done!