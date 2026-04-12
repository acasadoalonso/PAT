#!/bin/bash
cd ~/src/pat/patServer
echo "USER: "$USER
export HOSTNAME=$(hostname -I | awk '{ print $1 }' | tail -n1)
echo "HOST: "$HOSTNAME
DIR=$(pwd)

export GIT_REVISION=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)
export GIT_DATESTAMP=$(git -C "$DIR" log -1 --date=iso-strict --format=%cd 2>/dev/null || echo unknown)
export CLIENT_GIT_REVISION=$(git -C "$DIR/../patClient" rev-parse --short HEAD 2>/dev/null || echo "$GIT_REVISION")
export CLIENT_GIT_DATESTAMP=$(git -C "$DIR/../patClient" log -1 --date=iso-strict --format=%cd 2>/dev/null || echo "$GIT_DATESTAMP")


echo "GIT_REVISION: $GIT_REVISION"
echo "GIT_DATESTAMP: $GIT_DATESTAMP"
echo "CLIENT_GIT_REVISION: $CLIENT_GIT_REVISION"
echo "CLIENT_GIT_DATESTAMP: $CLIENT_GIT_DATESTAMP"

if [ -f "$DIR/.env" ]
then
  set -a
  . "$DIR/.env"
  set +a
fi

export CORS_ORIGINS=http://${HOSTNAME}:${GUI_PORT},http://localhost:${GUI_PORT}
echo $CORS_ORIGINS
pwd
docker compose up -d
