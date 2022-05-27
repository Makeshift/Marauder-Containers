#!/usr/bin/with-contenv bash

# This sets the vars for the "generic" auto-import script that works with Sonarr/Radarr and anything
#  based on their codebase.

if $DEBUG; then set -x; fi

# Exports all vars
set -a

PROGRAM_NAME="Sonarr"
PROGRAM_NAME_LOWER=${PROGRAM_NAME,,}
DEFAULT_AUTO_MANUAL_IMPORT_DIR="/shared/merged/downloads/sabnzbd/$PROGRAM_NAME_LOWER/"
FILES_WAITING_GREP="grep seriesId /tmp/data.json | wc -l"
FILES_NOT_REJECTED_GREP="grep seriesId /tmp/no_rejections.json | wc -l"
JQ_FILTER_REJECTIONS="jq '[.[] | select(.rejections | length == 0)] | [.[] | try {
    path: .path,
    folderName: .folderName,
    seriesId: .series.id,
    episodeIds: [.episodes[].id],
    releaseGroup: .releaseGroup,
    quality: .quality,
    language: .language
  }]' /tmp/data.json >/tmp/no_rejections.json"
HOW_OFTEN_IN_MINUTES=${HOW_OFTEN_IN_MINUTES-60}
HOW_OFTEN_IN_SECONDS=$((HOW_OFTEN_IN_MINUTES * 60))
MAX_WAIT_TIME_FOR_HTTP_REQ_IN_SECONDS=1800

HOST=localhost
PORT=8989
API_KEY=$(grep ApiKey /config/config.xml | cut -d ">" -f2 | cut -d "<" -f1)
AUTO_MANUAL_IMPORT_DIR=${AUTO_MANUAL_IMPORT_DIR:-$DEFAULT_AUTO_MANUAL_IMPORT_DIR}

source /etc/sbin/arr-go-import.sh
