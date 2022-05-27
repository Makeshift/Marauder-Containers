#!/usr/bin/with-contenv bash

# $PROGRAM_NAME occasionally fails to import things when they finish downloading
# I'm not sure why, probably something to do with disk caching that I haven't tracked down yet
# So this script runs the "Manual Import" feature and imports anything that doesn't have errors
# (Just like the normal import would)

if $DEBUG; then set -x; fi

_echo() {
  echo "[services.d] [auto-manual-import]-$(s6-basename "${0}")-($(date +"%Y-%m-%d %T")): $*"
}

_term() {
  _echo "Caught SIGTERM"
  exit 0
}

trap _term SIGTERM

DO_AUTO_MANUAL_IMPORT=${DO_AUTO_MANUAL_IMPORT:-true}

if $DO_AUTO_MANUAL_IMPORT; then _echo "Script running"; fi

# Let $PROGRAM_NAME get warmed up
sleep 60

function go() {
  _echo "Starting manual import for $PROGRAM_NAME"

  HTTP_CODE=$(curl -s --output /tmp/data.json --write-out "%{http_code}" -G \
    --data-urlencode "folder=${AUTO_MANUAL_IMPORT_DIR}" \
    --data-urlencode "filterExistingFiles=true" \
    -H "x-api-key: ${API_KEY}" \
    --max-time ${MAX_WAIT_TIME_FOR_HTTP_REQ_IN_SECONDS} \
    "http://${HOST}:${PORT}/api/v3/manualimport")
  EXIT_CODE="$?"
  if [ "$EXIT_CODE" -ne 0 ] || [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then
    head /tmp/data.json
    _echo "We failed to get data from the $PROGRAM_NAME API with HTTP code $HTTP_CODE and exit code $EXIT_CODE. Here's what it returned (Possibly truncated) /tmp/data.json ^"
    _echo "We're going to wait for a minute and then try again"
    sleep 60
    go
    return $?
  fi

  files_waiting_count=$(eval $FILES_WAITING_GREP)
  if [ "$?" -ne 0 ]; then
    head /tmp/data.json
    _echo "We failed to get the list of files when parsing data (possibly truncated) /tmp/data.json ^"
    return 1
  fi
  _echo "Got $files_waiting_count files waiting in $PROGRAM_NAME's import folder."

  error=$(eval $JQ_FILTER_REJECTIONS)
  if [ "$?" -ne 0 ]; then
    head /tmp/data.json
    _echo "We failed to filter rejections with data (possibly truncated) /tmp/data.json ^"
    _echo "$error"
    _echo "^jq output"
    return 1
  fi

  files_not_rejected_count=$(eval $FILES_NOT_REJECTED_GREP)
  if [ "$?" -ne 0 ]; then
    head /tmp/no_rejections.json
    _echo "We failed to get the count of unrejected files when parsing data (possibly truncated) /tmp/no_rejections.json ^"
    return 1
  fi
  _echo "Found $files_not_rejected_count episodes that have not been imported that should have been. Importing now..."

  error=$(jq '{name: "ManualImport", importMode:"move", files: [.[]]}' /tmp/no_rejections.json >/tmp/import_list.json)
  if [ "$?" -ne 0 ]; then
    head /tmp/no_rejections.json
    _echo "^/tmp/no_rejections.json"
    head /tmp/import_list.json
    _echo "^/tmp/import_list.json"
    _echo "We failed to filter rejections with above data (possibly truncated)^"
    _echo "$error"
    _echo "^jq output"
    return 1
  fi
  HTTP_CODE=$(
    curl -s --output /tmp/import_out.json --write-out "%{http_code}" -X POST \
      -H "x-api-key: ${API_KEY}" \
      -H "Content-Type: application/json" \
      --max-time ${MAX_WAIT_TIME_FOR_HTTP_REQ_IN_SECONDS} \
      -d @/tmp/import_list.json http://${HOST}:${PORT}/api/v3/command
  )
  EXIT_CODE="$?"
  if [ "$EXIT_CODE" -ne 0 ] || [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then
    head /tmp/no_rejections.json
    _echo "^/tmp/no_rejections.json"
    head /tmp/import_out.json
    _echo "^/tmp/import_out.json"
    _echo "$PROGRAM_NAME rejected our import request with a HTTP $HTTP_CODE and exit code $EXIT_CODE with above data and response ^"
    return 1
  fi

  _echo "Sent manual import request to $PROGRAM_NAME."

  # TODO "rejections.type: permanent" files can be deleted
}

while [ "$DO_AUTO_MANUAL_IMPORT" = "true" ]; do
  (go && _echo "Sleeping for $HOW_OFTEN_IN_SECONDS" && sleep $HOW_OFTEN_IN_SECONDS)
done
