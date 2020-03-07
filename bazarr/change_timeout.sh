#!/usr/bin/with-contenv bash
# git is already installed from the base package so we may as well borrow it
  echo '----------------------------------'
  echo '|  Replacing Timeouts in Bazarr  |'
  echo '----------------------------------'
  echo

find /app/bazarr/ -type f -name "*.py" | xargs sed -E -i 's/timeout=[0-9]{1,3}/timeout=600/g'

echo Done!