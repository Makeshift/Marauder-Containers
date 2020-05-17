#!/bin/sh
echo
echo "rclone_encryption_password1=$(./obscure encrypt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1))"
echo "rclone_encryption_password2=$(./obscure encrypt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1))"
echo