#!/bin/bash
TEAM_DRIVES_COUNT=$(printf "%s\n" ${rclone_team_drive_ids} | wc -l)
SERVICE_ACCOUNTS=$(find "${SERVICE_ACCOUNT_PATH}" -type f -name "*.json")
SERVICE_ACCOUNT_COUNT=$(printf "%s" "${SERVICE_ACCOUNTS}" | wc -l)
CONF_FILE=/config/.rclone.conf

for i in "$TEAM_DRIVES_COUNT[@]"; do
    # Pick a random service account
    RAND=$(shuf -i 0-${SERVICE_ACCOUNT_COUNT} -n 1)
    SERVICE_ACCOUNT=$SERVICE_ACCOUNTS[$RAND]
    # Do the dedupe using 'newest' dedupe mode. TODO: Make this configurable?
    rclone --config $CONF_FILE --drive-service-account-file $SERVICE_ACCOUNT dedupe gdrive_${i}: -vv -dedupe-mode newest
done