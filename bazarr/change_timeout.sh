#!/usr/bin/with-contenv bash
# git is already installed from the base package so we may as well borrow it
  echo '----------------------------------'
  echo '|  Replacing Timeouts in Bazarr  |'
  echo '----------------------------------'
  echo

find /app/bazarr/ -type f -name "*.py" | xargs sed -i '/timeout=[0-9]*/{
h
s//timeout=600/g
H
x
s/\n/ >>> /
w /dev/stdout
x
}'

echo Done!