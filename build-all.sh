#!/bin/bash
set -ex

docker build -t makeshift27015/bazarr -f bazarr.Dockerfile .

docker build -t makeshift27015/marauder_gcloud_init -f gcloud_init/Dockerfile .

docker build -t makeshift27015/radarr -f radarr/Dockerfile .

docker build -t makeshift27015/rclone -f rclone/Dockerfile .

docker build -t makeshift27015/marauder_rclone_generate_keys -f rclone_generate_keys/Dockerfile .

docker build -t makeshift27015/sonarr -f sonarr/Dockerfile .

docker build -t makeshift27015/traktarr -f traktarr/Dockerfile .
          
docker build -t makeshift27015/headphones -f headphones.Dockerfile .
          
docker build -t makeshift27015/lazylibrarian -f lazylibrarian.Dockerfile .
          
docker build -t makeshift27015/medusa -f medusa.Dockerfile .
          
docker build -t makeshift27015/mylar -f mylar.Dockerfile .
          
docker build -t makeshift27015/nzbhydra2 -f nzbhydra2.Dockerfile .
          
docker build -t makeshift27015/sabnzbd -f sabnzbd.Dockerfile .
          
docker build -t makeshift27015/transmission -f transmission.Dockerfile .
