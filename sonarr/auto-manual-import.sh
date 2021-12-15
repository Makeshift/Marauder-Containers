#!/usr/bin/with-contenv bash
# Sonarr occasionally fails to import things when they finish downloading
# I'm not sure why, probably something to do with disk caching that I haven't tracked down yet
# So this script runs the "Manual Import" feature and imports anything that doesn't have errors
# (Just like the normal import would)

_echo() {
  echo "[services.d] [auto-manual-import]-$(s6-basename "${0}"): $*"
}

_term() { 
  _echo "Caught SIGTERM"
  exit 0
}

trap _term SIGTERM

DO_AUTO_MANUAL_IMPORT=${DO_AUTO_MANUAL_IMPORT:-true}

if $DO_AUTO_MANUAL_IMPORT; then _echo "Script running"; fi

AUTO_MANUAL_IMPORT_DIR=${AUTO_MANUAL_IMPORT_DIR:-"/shared/merged/downloads/sabnzbd/sonarr/"}

HOST=localhost
PORT=8989

API_KEY=$(grep ApiKey /config/config.xml | cut -d ">" -f2 | cut -d "<" -f1)

HOW_OFTEN_IN_MINUTES=${HOW_OFTEN_IN_MINUTES-60}
HOW_OFTEN_IN_SECONDS=$((HOW_OFTEN_IN_MINUTES*60))

# Let Sonarr get warmed up
sleep 60

function go() {
  _echo "Starting manual import for Sonarr"

  HTTP_CODE=$(curl -s --output /tmp/data.json --write-out "%{http_code}" -G  \
    --data-urlencode "folder=${AUTO_MANUAL_IMPORT_DIR}" \
    --data-urlencode "filterExistingFiles=true" \
    -H "x-api-key: ${API_KEY}" \
    --max-time 1800 \
    "http://${HOST}:${PORT}/api/v3/manualimport")
  if [ "$?" -ne 0 ] || [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then
    _echo "We failed to get data from the Sonarr API with HTTP $HTTP_CODE. Here's what it returned:"
    _echo "$(cat /tmp/data.json)"
    return 1
  fi
  
  files_waiting_count=$(grep seriesId /tmp/data.json | wc -l)
  if [ "$?" -ne 0 ]; then
    _echo "We failed to get the list of files when parsing data:"
    _echo "$(cat /tmp/data.json)"
    return 1
  fi
  _echo "Got $files_waiting_count files waiting in Sonarr's import folder."

  jq '[.[] | select(.rejections | length == 0)] | [.[] | {
    path: .path,
    folderName: .folderName,
    seriesId: .series.id,
    episodeIds: [.episodes[].id],
    releaseGroup: .releaseGroup,
    quality: .quality,
    language: .language
  }]' /tmp/data.json > /tmp/no_rejections.json
  if [ "$?" -ne 0 ]; then
    _echo "We failed to filter rejections with data:"
    _echo "$(cat /tmp/data.json)"
    return 1
  fi
  
  files_not_rejected_count=$(grep seriesId /tmp/no_rejections.json | wc -l)
  if [ "$?" -ne 0 ]; then
    _echo "We failed to get the count of unrejected files when parsing data:"
    _echo "$(cat /tmp/no_rejections.json)"
    return 1
  fi
  _echo "Found $files_not_rejected_count episodes that have not been imported that should have been. Importing now..."

  jq '{name: "ManualImport", importMode:"move", files: [.[]]}' /tmp/no_rejections.json > /tmp/import-list.json
  HTTP_CODE=$(curl -s --output /tmp/import_out.json --write-out "%{http_code}" -X POST \
      -H "x-api-key: ${API_KEY}" \
      -H "Content-Type: application/json" \
      --max-time 1800 \
      -d @/tmp/import-list.json http://${HOST}:${PORT}/api/v3/command
  )
  if [ "$?" -ne 0 ] || [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]]; then
    _echo "Sonarr rejected our import request with a HTTP $HTTP_CODE with data:"
    _echo "$(cat /tmp/no_rejections.json)"
    _echo "and response from Sonarr:"
    _echo "$(cat /tmp/import_out.json)"
    return 1
  fi

  _echo "Sent manual import request to Sonarr."

  # TODO "rejections.type: permanent" files can be deleted
}

while [ "$DO_AUTO_MANUAL_IMPORT" = "true" ]; do
  (go && _echo "Sleeping for $HOW_OFTEN_IN_SECONDS" && sleep $HOW_OFTEN_IN_SECONDS)
done
